local http = require("socket.http")
local json = require("dkjson")

function log(r)
    local trace = {
        name = r.uri,
        kind = 1,  -- SERVER
        startTimeUnixNano = os.clock() * 1e9,
        endTimeUnixNano = os.clock() * 1e9 + 1000,  -- placeholder
        attributes = {
            { key = "http.method", value = { stringValue = r.method } },
            { key = "http.url", value = { stringValue = r.uri } }
        }
    }

    -- Print to Apache log
    r:warn("OTEL TRACE: " .. json.encode(trace))

    -- Send to OTEL collector
    local body = json.encode({ spans = { trace } })
    local _, code = http.request{
        url = "http://otel-collector:4318/v1/traces",
        method = "POST",
        headers = { ["Content-Type"] = "application/json" },
        source = ltn12.source.string(body),
        sink = ltn12.sink.null()
    }
end
