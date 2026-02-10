-- otel.lua: Sends OTEL spans to the collector via HTTP

local http = require("socket.http")
local json = require("dkjson")

-- Collector endpoint
local OTEL_COLLECTOR = "http://otel-collector:4318/v1/traces"

-- Function called by Apache on each request
function log_request(r)
    local span = {
        resourceSpans = {{
            instrumentationLibrarySpans = {{
                spans = {{
                    name = r.method .. " " .. r.uri,
                    kind = 1,  -- CLIENT=1, SERVER=2
                    startTimeUnixNano = os.time() * 1e9,
                    endTimeUnixNano = (os.time() + 0.001) * 1e9,
                    attributes = {
                        {key="http.method", value={stringValue=r.method}},
                        {key="http.url", value={stringValue=r.unparsed_uri}},
                        {key="http.user_agent", value={stringValue=r.headers_in["User-Agent"] or ""}}
                    }
                }}
            }}
        }}
    }

    local payload = json.encode(span)
    -- Fire-and-forget POST to collector
    http.request{
        url = OTEL_COLLECTOR,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#payload)
        },
        source = ltn12.source.string(payload),
        sink = ltn12.sink.table({})
    }
end
