-- OTEL Lua instrumentation for Apache
-- Full example for tracing HTTP requests

-- Ensure apache2 constants are available
local apache2 = require "apache2"

-- Table to hold helper functions
local otel = {}

-- Generate a simple trace ID
local function generate_trace_id()
    local template ='xxxxxxxxxxxxxxxx'
    return string.gsub(template, '[x]', function (c)
        return string.format('%x', math.random(0, 15))
    end)
end

-- Generate a simple span ID
local function generate_span_id()
    local template ='xxxxxxxxxxxxxxxx'
    return string.gsub(template, '[x]', function (c)
        return string.format('%x', math.random(0, 15))
    end)
end

-- Function called on each request by LuaHookFixups
function trace_request(r)
    -- Generate IDs
    local trace_id = generate_trace_id()
    local span_id  = generate_span_id()

    -- Capture basic request info
    local method = r.method
    local uri    = r.uri
    local headers = r.headers_in

    -- Set a custom response header
    r.headers_out["X-OTEL-TraceId"] = trace_id
    r.headers_out["X-OTEL-SpanId"]  = span_id

    -- Log to Apache error log (for debugging)
    r:err(string.format(
        "OTEL TRACE: trace_id=%s span_id=%s method=%s uri=%s\n",
        trace_id, span_id, method, uri
    ))

    -- Return DECLINED so Apache continues normal processing
    return apache2.DECLINED
end

-- Optionally, add more hooks for logging response or metrics
function otel.log_response(r)
    r:err(string.format(
        "OTEL RESPONSE: trace_id=%s status=%d\n",
        r.headers_out["X-OTEL-TraceId"] or "none",
        r.status
    ))
    return apache2.DECLINED
end

return otel
