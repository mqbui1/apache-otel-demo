local http = require "socket.http"
local ltn12 = require "ltn12"
local json = require "dkjson"

math.randomseed(os.time())

function random_hex(len)
local res = ""
for i = 1, len do
res = res .. string.format("%x", math.random(0,15))
end
return res
end

function trace_request(r)

```
local trace_id = random_hex(32)
local span_id = random_hex(16)

local traceparent =
    "00-" .. trace_id .. "-" .. span_id .. "-01"

local backend_url =
    "http://app:5000" .. r.uri

http.request{
    url = backend_url,
    method = "GET",
    headers = {
        ["traceparent"] = traceparent
    }
}

local span = {
    traceId = trace_id,
    spanId = span_id,
    name = "apache-request",
    kind = 2,
    attributes = {
        {
            key="service.name",
            value={stringValue="apache"}
        },
        {
            key="http.method",
            value={stringValue=r.method}
        },
        {
            key="http.target",
            value={stringValue=r.uri}
        }
    }
}

local payload = json.encode({
    resourceSpans = {{
        scopeSpans = {{
            spans = { span }
        }}
    }}
})

http.request{
    url = "http://otel-collector:4318/v1/traces",
    method = "POST",
    headers = {
        ["Content-Type"] = "application/json"
    },
    source = ltn12.source.string(payload)
}

return apache2.OK
```

end
