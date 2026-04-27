FROM ubuntu:22.04

WORKDIR /app

# System dependencies (FIXED)
RUN apt-get update && apt-get install -y \
    python3 python3-pip wget ffmpeg \
    libstdc++6 \
    libgomp1 \
    libespeak-ng1 \
    espeak-ng \
    espeak-ng-data \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Python deps
RUN pip3 install fastapi uvicorn pydantic

# Install Piper
RUN wget -O piper.tar.gz https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
    && tar -xvzf piper.tar.gz \
    && mv piper/piper /usr/local/bin/piper \
    && mv piper/*.so* /usr/local/lib/ || true \
    && rm -rf piper.tar.gz piper \
    && ldconfig

# 🔥 مهم جداً: إصلاح espeak path
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV ESPEAK_DATA_PATH=/usr/share/espeak-ng-data

# folders
RUN mkdir -p /app/output
RUN mkdir -p /app/voices/en_US

# Download model
RUN wget -O /app/voices/en_US/en_US-john-medium.onnx \
    https://github.com/Ghadah-byte/-tts-service/releases/download/v1.0/en_US-john-medium.onnx \
    && wget -O /app/voices/en_US/en_US-john-medium.onnx.json \
    https://github.com/Ghadah-byte/-tts-service/releases/download/v1.0/en_US-john-medium.onnx.json

COPY app.py .

CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port $PORT"]
