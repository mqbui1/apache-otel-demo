-- OpenTelemetry Lua script for Apache HTTPD
local json = require("dkjson")
local http = require("socket.http")
local ltn12 = require("ltn12")

local OTEL_COLLECTOR = "http://otel-collector:4318/v1/traces"

local function get_trace_context(r)
    return r.headers_in["traceparent"], r.headers_in["tracestate"] or ""
end

local function send_span(span)
    local payload = {
        resourceSpans = {{
            resource = {
                attributes = {
                    { key = "service.name", value = { stringValue = "apache" } }
                }
            },
            scopeSpans = {{
                scope = { name = "apache-lua", version = "0.1" },
                spans = { span }
            }}
        }}
    }
    local body = json.encode(payload)
    local res, code = http.request{
        url = OTEL_COLLECTOR,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#body)
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table({})
    }
    if code ~= 200 then
        r:err("Failed to send span, status: "..tostring(code))
    end
end

function handle_request(r)
    local traceparent, tracestate = get_trace_context(r)

    local span = {
        name = r.method.." "..r.unparsed_uri,
        kind = "SPAN_KIND_SERVER",
        startTimeUnixNano = os.time() * 1e9,
        endTimeUnixNano = os.time() * 1e9,
        attributes = {
            { key = "http.method", value = { stringValue = r.method } },
            { key = "http.target", value = { stringValue = r.unparsed_uri } },
            { key = "http.status_code", value = { intValue = r.status or 200 } }
        },
        links = {},
    }

    if traceparent then
        span.links[1] = { traceId = traceparent, traceState = tracestate }
    end

    send_span(span)
end

return handle_request
