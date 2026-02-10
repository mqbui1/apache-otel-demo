-- otel.lua
-- Apache Lua script for OpenTelemetry-style tracing
-- Place in /usr/local/apache2/otel/otel.lua

local apache2 = require "apache2"
local socket = require "socket"      -- optional, for timestamps
local json = require "dkjson"        -- optional, for JSON formatting

-- Simple in-memory trace ID generator
local function generate_trace_id()
    local random = math.random
    local template ='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    return string.gsub(template, 'x', function ()
        return string.format('%x', random(0, 15))
    end)
end

local function generate_span_id()
    local random = math.random
    local template ='xxxxxxxxxxxxxxxx'
    return string.gsub(template, 'x', function ()
        return string.format('%x', random(0, 15))
    end)
end

-- Main hook function for LuaHookFixups
function trace_request(r)
    local method = r.method
    local uri = r.uri
    local trace_id = generate_trace_id()
    local span_id = generate_span_id()
    local timestamp = socket.gettime()

    -- Log to Apache error log
    r:err(string.format(
        "OTEL TRACE: trace_id=%s span_id=%s method=%s uri=%s timestamp=%.6f",
        trace_id, span_id, method, uri, timestamp
    ))

    -- Optional: you could push to OTEL collector over HTTP/gRPC here
    -- Example (pseudo-code):
    -- send_to_otlp_collector({trace_id=trace_id, span_id=span_id, method=method, uri=uri, ts=timestamp})

    -- Return numeric status to Apache (required)
    return apache2.OK
end
