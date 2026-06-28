FROM python:3.10-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    make \
    libc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY bgmi_killer.c .
COPY bgmi_api.py .
COPY requirements.txt .

# Compile C binary
RUN gcc -O3 -pthread -o bgmi_killer bgmi_killer.c && \
    chmod +x bgmi_killer && \
    ls -lh bgmi_killer

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["gunicorn", "--worker-class", "gevent", "--workers", "16", "--bind", "0.0.0.0:5000", "bgmi_api:app"]
