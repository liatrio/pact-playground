FROM python:3.9-slim as base

# Update existing packages and install necessary SSL/TLS related packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install opentelemetry packages
RUN pip install opentelemetry-distro \
    opentelemetry-exporter-otlp

RUN opentelemetry-bootstrap -a install

WORKDIR /app
COPY requirements.lock ./
RUN PYTHONDONTWRITEBYTECODE=1 pip install --no-cache-dir -r requirements.lock

# Add the application
COPY app.py .

ENV OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=true
ENV OTEL_LOGS_EXPORTER=otlp

EXPOSE 8082

CMD ["opentelemetry-instrument", "flask", "run", "--host", "0.0.0.0", "--port", "8082"]
