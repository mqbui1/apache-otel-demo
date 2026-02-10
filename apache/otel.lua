-- otel.lua
local socket = require("socket")
local dkjson = require("dkjson")

-- Simple trace/span ID generator
local function random_hex(len)
    local s = ""
    for i = 1, len do
        s = s .. string.format("%x", math.random(0, 15))
    end
    return s
end

local function generate_trace_id()
    return random_hex(32)
end

local function generate_span_id()
    return random_hex(16)
end

-- Function called by Apache on each request in fixups phase
function trace_request(r)
    -- Gather request info
    local method = r.method
    local uri = r.uri
    local trace_id = generate_trace_id()
    local span_id = generate_span_id()
    local timestamp = socket.gettime()

    -- Build log message
    local log_entry = {
        trace_id = trace_id,
        span_id = span_id,
        method = method,
        uri = uri,
        timestamp = timestamp
    }

    -- Log as JSON to Apache error log
    r:err("OTEL TRACE: " .. dkjson.encode(log_entry))

    -- Return numeric status for Apache (0 = OK)
    return 0
end
