FROM python:3.11-slim

RUN pip install \
    flask \
    opentelemetry-api \
    opentelemetry-sdk \
    opentelemetry-exporter-otlp \
    opentelemetry-instrumentation-flask

COPY app.py /

ENV OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf

CMD opentelemetry-instrument \
    --traces_exporter otlp \
    --metrics_exporter none \
    --logs_exporter none \
    python /app.py
