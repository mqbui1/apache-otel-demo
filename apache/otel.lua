-- otel.lua
local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")

-- Helper to send a single span to OTEL Collector
local function send_span(trace_id, span_id, name, method, url)
    local span = {
        traceId = trace_id,
        spanId = span_id,
        name = name,
        kind = 1,  -- 1 = SERVER
        startTimeUnixNano = os.time() * 1e9,
        endTimeUnixNano = (os.time() * 1e9) + 1e6,  -- +1ms for example
        attributes = {
            { key = "http.method", value = { stringValue = method } },
            { key = "http.url", value = { stringValue = url } }
        }
    }

    local body = json.encode({
        resourceSpans = {
            {
                instrumentationLibrarySpans = {
                    { spans = { span } }
                }
            }
        }
    })

    local resp_body = {}
    local res, code = http.request{
        url = "http://otel-collector:4318/v1/traces",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#body)
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(resp_body)
    }

    if code ~= 200 then
        ngx.log(ngx.ERR, "OTEL export failed: ", code, " - ", table.concat(resp_body))
    end
end

-- Hook to Apache requests
function trace_request()
    local method = ngx.var.request_method
    local uri = ngx.var.request_uri
    local trace_id = tostring(math.random(1, 0xFFFFFFFFFFFFFFFF))  -- simple example
    local span_id  = tostring(math.random(1, 0xFFFFFFFFFFFFFFFF))

    send_span(trace_id, span_id, uri, method, uri)

    return 0  -- Fixups phase requires numeric return
end
