# # Stage 1: Builder
# FROM python:3.7 AS builder

# WORKDIR /app
# COPY requirements.txt .

# RUN pip install -r requirements.txt

# # Stage 2: Slim runtime
# FROM python:3.7-slim

# WORKDIR /app

# # Copy installed Python packages from builder
# COPY --from=builder /usr/local/lib/python3.7/site-packages/ /usr/local/lib/python3.7/site-packages/

# # Install system dependencies
# RUN apt-get update \
#     && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
#     && rm -rf /var/lib/apt/lists/*

# # Copy requirements and app
# COPY requirements.txt .
# RUN pip install mysqlclient
# RUN pip install --no-cache-dir -r requirements.txt

# COPY . .

# CMD ["python", "app.py"]
# Stage 1: builder
FROM python:3.8-slim AS builder

WORKDIR /app

# Install build dependencies only in this stage
RUN apt-get update && apt-get install -y \
    gcc default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy and install dependencies (with no cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: runtime (minimal)
FROM python:3.8-slim

WORKDIR /app

# Copy installed dependencies only (no gcc, etc.)
COPY --from=builder /usr/local/lib/python3.8/site-packages/ /usr/local/lib/python3.8/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# Copy only necessary app files
COPY . .

CMD ["python", "app.py"]
