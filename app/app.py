from flask import Flask
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# Configure OpenTelemetry
resource = Resource.create({
    "service.name": "flask-app",
    "service.version": "1.0"
})

provider = TracerProvider(resource=resource)
trace.set_tracer_provider(provider)

otlp_exporter = OTLPSpanExporter(
    endpoint="http://otel-collector:4317",
    insecure=True
)

provider.add_span_processor(BatchSpanProcessor(otlp_exporter))
provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))

tracer = trace.get_tracer(__name__)

# Flask app
app = Flask(__name__)

@app.route("/")
def hello():
    with tracer.start_as_current_span("hello-span"):
        return "Hello from Flask with OpenTelemetry!"

@app.route("/ping")
def ping():
    with tracer.start_as_current_span("ping-span"):
        return "pong"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
