FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/venv/bin:$PATH" \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Clean apt caches, doc files, and temporary logs in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget gnupg unzip curl \
    libpq5 \
    tesseract-ocr libreoffice \
    libgl1 default-jre-headless \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

COPY requirements.txt .

# Install pip packages with no-cache-dir and purge pip/wheel caches immediately
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && rm -rf /root/.cache/pip

COPY . .

# Combine user setup and permission handling into one layer to prevent duplicated layer size
RUN useradd --create-home --shell /bin/bash appuser \
    && chown -R appuser:appuser /app

COPY --chown=appuser:appuser entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

USER appuser

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
