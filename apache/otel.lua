-- /usr/local/apache2/otel/otel.lua
local http = require("socket.http")
local json = require("dkjson")

-- Collector endpoint inside Docker network
local OTEL_COLLECTOR = "http://otel-collector:4318/v1/traces"

-- Function to send a single span
local function send_trace(span_name, method, url)
    -- OTLP JSON format (v1)
    local trace = {
        resourceSpans = {{
            resource = { attributes = {{ key = "service.name", value = { stringValue = "apache-demo" } }} },
            scopeSpans = {{
                scope = { name = "lua-otel", version = "0.1" },
                spans = {{
                    name = span_name,
                    kind = 1, -- CLIENT
                    traceId = string.format("%032x", math.random(0, 0xFFFFFFFF)), -- random 16-byte hex
                    spanId = string.format("%016x", math.random(0, 0xFFFFFFFF)), -- random 8-byte hex
                    startTimeUnixNano = os.time() * 1e9,
                    endTimeUnixNano = (os.time() + 0.001) * 1e9,
                    attributes = {
                        { key = "http.method", value = { stringValue = method } },
                        { key = "http.url", value = { stringValue = url } }
                    }
                }}
            }}
        }}
    }

    local body = json.encode(trace)
    local response_body = {}
    local res, code, headers, status = http.request{
        url = OTEL_COLLECTOR,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#body)
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response_body)
    }

    if code ~= 200 then
        ngx.log(ngx.ERR, "Failed to send trace: ", code, " ", status)
    end
end

-- Hook into Apache request
function trace_request(r)
    local path = r.uri
    local method = r.method
    send_trace(path, method, path)
    return 0 -- must return numeric value for fixups phase
end
