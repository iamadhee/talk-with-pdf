# Lite version
FROM python:3.10-slim AS lite

# Common dependencies
RUN apt-get update -qqy && \
    apt-get install -y --no-install-recommends \
      ssh \
      git \
      gcc \
      g++ \
      poppler-utils \
      libpoppler-dev \
      unzip \
      curl \
      cargo

# Install Ollama
RUN curl -L https://ollama.com/install.sh | bash

# Setup args
ARG TARGETPLATFORM
ARG TARGETARCH

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8
ENV TARGETARCH=${TARGETARCH}

# Create working directory
WORKDIR /app

# Download pdfjs
COPY scripts/download_pdfjs.sh /app/scripts/download_pdfjs.sh
RUN chmod +x /app/scripts/download_pdfjs.sh

# Copy contents
COPY . /app
COPY .env /app/.env

# Install pip packages
RUN --mount=type=ssh  \
    --mount=type=cache,target=/root/.cache/pip  \
    pip install -e "libs/kotaemon" \
    && pip install -e "libs/ktem" \
    && pip install "pdfservices-sdk@git+https://github.com/niallcm/pdfservices-python-sdk.git@bump-and-unfreeze-requirements"

RUN --mount=type=ssh  \
    --mount=type=cache,target=/root/.cache/pip  \
    if [ "$TARGETARCH" = "amd64" ]; then pip install graphrag future; fi

# Clean up
RUN apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf ~/.cache

# Copy the start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Run the shell script to start both Ollama and the Python app
CMD ["/bin/bash", "/app/start.sh"]
