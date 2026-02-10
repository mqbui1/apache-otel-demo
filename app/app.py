from flask import Flask, request
import time
import random

from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.resources import Resource

from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter

from opentelemetry.sdk.trace.export import BatchSpanProcessor

from opentelemetry.instrumentation.flask import FlaskInstrumentor

resource = Resource.create({
"service.name": "flask"
})

provider = TracerProvider(resource=resource)

processor = BatchSpanProcessor(
OTLPSpanExporter(
endpoint="[http://otel-collector:4318/v1/traces](http://otel-collector:4318/v1/traces)"
)
)

provider.add_span_processor(processor)

trace.set_tracer_provider(provider)

app = Flask(**name**)

FlaskInstrumentor().instrument_app(app)

@app.route("/")
def home():

```
traceparent = request.headers.get("traceparent")

print("traceparent:", traceparent)

time.sleep(random.uniform(0.1,0.4))

return "Hello from Flask\n"
```

@app.route("/test")
def test():

```
traceparent = request.headers.get("traceparent")

print("traceparent:", traceparent)

time.sleep(random.uniform(0.2,0.5))

return "Test endpoint\n"
```

app.run(host="0.0.0.0", port=5000)
