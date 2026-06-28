# =====================================================================
# UNCAI_ABSOLUTE_06.28 – BGMI KILLER DOCKERFILE (RAILWAY DEPLOYMENT)
# TASK: Full Docker build with C binary compilation and Python API
#       Automatic compile on Railway deploy
# =====================================================================

FROM python:3.10-slim

# Install build tools for C compilation
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    make \
    libc-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy C source
COPY bgmi_killer.c .

# Compile C binary with static linking
RUN gcc -O3 -pthread -static -o bgmi_killer bgmi_killer.c && \
    chmod +x bgmi_killer && \
    ls -lh bgmi_killer

# Copy Python requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Python API
COPY bgmi_api.py .

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/api/v1/health || exit 1

# Run Python API (binary will be called from within)
CMD ["gunicorn", "--worker-class", "gevent", "--workers", "16", "--bind", "0.0.0.0:5000", "bgmi_api:app"]