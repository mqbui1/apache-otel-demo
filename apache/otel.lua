-- otel.lua
local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")

-- OTEL Collector HTTP endpoint
local OTEL_COLLECTOR = "http://otel-collector:4318/v1/traces"

-- Random hex generator for trace/span IDs
local function random_hex(n)
    local s = ""
    for i = 1, n do
        s = s .. string.format("%x", math.random(0, 15))
    end
    return s
end

-- Send trace
local function send_trace(name, method, url)
    local trace = {
        resourceSpans = {{
            resource = { attributes = {{ key = "service.name", value = { stringValue = "apache-demo" }}} },
            scopeSpans = {{
                scope = { name = "lua-otel", version = "0.1" },
                spans = {{
                    name = name,
                    kind = 1, -- SERVER
                    traceId = random_hex(32),
                    spanId = random_hex(16),
                    startTimeUnixNano = os.time() * 1e9,
                    endTimeUnixNano = (os.time() + 0.001) * 1e9,
                    attributes = {
                        { key = "http.method", value = { stringValue = method }},
                        { key = "http.url", value = { stringValue = url }}
                    }
                }}
            }}
        }}
    }

    local body = json.encode(trace)
    local resp = {}
    local ok, err = http.request{
        url = OTEL_COLLECTOR,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#body)
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(resp)
    }

    if not ok then
        r:warn("OTEL trace failed: " .. tostring(err))
    end
end

-- Hook called by Apache Lua
function trace_request(r)
    send_trace(r.uri, r.method, r.uri)
    return 0 -- must return numeric
end
