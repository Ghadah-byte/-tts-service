FROM ubuntu:22.04

WORKDIR /app

RUN apt-get update && apt-get install -y \
    python3 python3-pip wget ffmpeg \
    libstdc++6 \
    libgomp1 \
    libespeak-ng1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install fastapi uvicorn pydantic

# تحميل Piper الرسمي (FULL bundle)
RUN wget https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
    && tar -xvzf piper_linux_x86_64.tar.gz \
    && mv piper/* /usr/local/bin/ \
    && mv *.so* /usr/local/lib/ || true \
    && ldconfig

RUN chmod +x /usr/local/bin/piper

RUN mkdir -p /app/output

COPY app.py .
COPY voices ./voices

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5002"]