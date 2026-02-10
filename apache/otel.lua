-- otel.lua
local http = require("socket.http")
local ltn12 = require("ltn12")
local dkjson = require("dkjson")
local socket = require("socket")

-- Utility: generate random hex IDs for trace/span
local function random_hex(length)
    local chars = "0123456789abcdef"
    local s = ""
    for i = 1, length do
        local idx = math.random(1, #chars)
        s = s .. chars:sub(idx, idx)
    end
    return s
end

local function generate_trace_id()
    return random_hex(32)
end

local function generate_span_id()
    return random_hex(16)
end

-- Send a trace to OTEL Collector OTLP HTTP endpoint
local function send_trace(trace)
    local body = dkjson.encode({
        resourceSpans = {{
            resource = {attributes={{key="service.name", value={stringValue="apache-demo"}}}},
            instrumentationLibrarySpans = {{
                instrumentationLibrary = {name="lua-apache", version="0.1"},
                spans = {trace}
            }}
        }}
    })

    local response = {}
    local ok, err = http.request{
        url = "http://otel-collector:4318/v1/traces",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#body)
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response)
    }

    if not ok then
        ngx.log(ngx.ERR, "Failed to send trace: ", err)
    end
end

-- Apache Lua hook
function trace_request(r)
    local trace_id = generate_trace_id()
    local span_id = generate_span_id()
    local timestamp = socket.gettime()

    local trace = {
        traceId = trace_id,
        spanId = span_id,
        name = r.uri,
        kind = 1,  -- 1 = CLIENT, 2 = SERVER
        startTimeUnixNano = math.floor(timestamp * 1e9),
        endTimeUnixNano = math.floor((timestamp + 0.001) * 1e9),  -- fake short duration
        attributes = {
            {key="http.method", value={stringValue=r.method}},
            {key="http.url", value={stringValue=r.uri}}
        }
    }

    -- Log locally for debugging
    r:err("OTEL TRACE: " .. dkjson.encode(trace))
    -- Send to OTEL Collector
    send_trace(trace)

    return 0  -- must return numeric for phase fixups
end
