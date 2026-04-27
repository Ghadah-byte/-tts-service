FROM ubuntu:22.04

WORKDIR /app

# System dependencies (IMPORTANT for piper runtime)
RUN apt-get update && apt-get install -y \
    python3 python3-pip wget ffmpeg \
    libstdc++6 \
    libgomp1 \
    libespeak-ng1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Python deps
RUN pip3 install fastapi uvicorn pydantic

# Install Piper (correct way)
RUN wget -O piper.tar.gz https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
    && tar -xvzf piper.tar.gz \
    && mv piper/piper /usr/local/bin/piper \
    && mv piper/*.so* /usr/local/lib/ || true \
    && rm -rf piper.tar.gz piper \
    && ldconfig

# IMPORTANT: fix runtime library path
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# App folders
RUN mkdir -p /app/output

# Copy app + voices
COPY app.py .
COPY voices ./voices

# Run server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5002"]
