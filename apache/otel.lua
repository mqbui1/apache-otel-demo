-- File: /usr/local/apache2/otel/otel.lua

local http = require("socket.http")
local json = require("dkjson")

-- Lua hook function for logging phase (takes r and phase)
function log_request(r, phase)
    local span = {
        resourceSpans = {{
            instrumentationLibrarySpans = {{
                spans = {{
                    name = r.method .. " " .. r.uri,
                    kind = 2,  -- SERVER span
                    startTimeUnixNano = os.time() * 1e9,
                    endTimeUnixNano = (os.time() + 0.001) * 1e9,
                    attributes = {
                        {key="http.method", value={stringValue=r.method}},
                        {key="http.url", value={stringValue=r.unparsed_uri or ""}},
                        {key="http.user_agent", value={stringValue=r.headers_in["User-Agent"] or ""}}
                    }
                }}
            }}
        }}
    }

    local payload = json.encode(span)

    http.request{
        url = "http://otel-collector:4318/v1/traces",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#payload)
        },
        source = ltn12.source.string(payload),
        sink = ltn12.sink.table({})
    }
end
