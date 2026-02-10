local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")

local function random_hex(len)
    local res = {}
    for i = 1, len do
        res[i] = string.format("%x", math.random(0, 15))
    end
    return table.concat(res)
end

function log_request(r)
    local span = {
        resourceSpans = {{
            instrumentationLibrarySpans = {{
                instrumentationLibrary = {name="apache-lua", version="0.1"},
                spans = {{
                    traceId = random_hex(32),
                    spanId = random_hex(16),
                    name = r.method .. " " .. r.uri,
                    kind = 2,
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
    local resp = {}
    local ok, status, headers = http.request{
        url = "http://otel-collector:4318/v1/traces",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#payload)
        },
        source = ltn12.source.string(payload),
        sink = ltn12.sink.table(resp)
    }

    r:err("Lua OTLP sent? status: " .. tostring(status) .. " ok: " .. tostring(ok))
end
