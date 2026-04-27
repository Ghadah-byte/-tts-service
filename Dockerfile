FROM ubuntu:22.04

WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip wget ffmpeg \
    libstdc++6 \
    libgomp1 \
    libespeak-ng1 \
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

# Fix library path
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Create folders
RUN mkdir -p /app/output
RUN mkdir -p /app/voices/en_US

#  GitHub Releases 
RUN wget -O /app/voices/en_US/en_US-john-medium.onnx "https://github.com/Ghadah-byte/-tts-service/releases/download/v1.0/en_US-john-medium.onnx" \
    && wget -O /app/voices/en_US/en_US-john-medium.onnx.json "https://github.com/Ghadah-byte/-tts-service/releases/download/v1.0/en_US-john-medium.onnx.json"

# COPY app.py .


# Run server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5002"]
