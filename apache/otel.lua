-- File: /usr/local/apache2/otel/otel.lua

local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")

-- helper to generate random IDs
local function random_hex(len)
    local res = {}
    for i = 1, len do
        res[i] = string.format("%x", math.random(0, 15))
    end
    return table.concat(res)
end

function log_request(r)
    -- create a minimal OTLP ResourceSpans payload
    local span = {
        resourceSpans = {{
            resource = {},  -- empty resource
            instrumentationLibrarySpans = {{
                instrumentationLibrary = {
                    name = "apache-lua",
                    version = "0.1"
                },
                spans = {{
                    traceId = random_hex(32),  -- 16 bytes in hex
                    spanId = random_hex(16),   -- 8 bytes in hex
                    name = r.method .. " " .. r.uri,
                    kind = 2, -- SERVER span
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

    -- send to OTLP HTTP endpoint
    local response = {}
    local ok, status, headers = http.request{
        url = "http://otel-collector:4318/v1/traces",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#payload)
        },
        source = ltn12.source.string(payload),
        sink = ltn12.sink.table(response)
    }

    -- optional debug
    -- print("HTTP status:", status, table.concat(response))

    return 0  -- Apache.OK
end
