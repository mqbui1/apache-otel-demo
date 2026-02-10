FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
ENV OTEL_TRACES_EXPORTER=otlp_proto_http
ENV OTEL_SERVICE_NAME=flask-demo-app

CMD ["opentelemetry-instrument", "flask", "run", "--host=0.0.0.0"]
