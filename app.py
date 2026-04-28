from fastapi import FastAPI, Header, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel
import subprocess
import uuid
import os

app = FastAPI()

API_KEY = os.getenv("API_KEY")


class Request(BaseModel):
    text: str


# ------------------ AUTH ------------------
def verify_api_key(x_api_key: str):
    if not API_KEY:
        raise HTTPException(status_code=500, detail="API_KEY not set on server")

    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Unauthorized")


# ------------------ TTS ENDPOINT ------------------
@app.post("/tts")
def tts(req: Request, x_api_key: str = Header(None)):

    verify_api_key(x_api_key)

    os.makedirs("/app/output", exist_ok=True)

    filename = f"{uuid.uuid4()}.wav"
    output = f"/app/output/{filename}"

    command = [
        "piper",
        "--model",
        "voices/en_US/en_US-john-medium.onnx",
        "--output_file",
        output
    ]

    try:
        result = subprocess.run(
            command,
            input=req.text,
            text=True,
            capture_output=True
        )

        if result.returncode != 0:
            return {
                "error": result.stderr,
                "stdout": result.stdout
            }

        # ✅ رجّع رابط بدل path
        return {
            "audio_url": f"https://tts-service-4830.onrender.com/audio/{filename}"
        }

    except Exception as e:
        return {"exception": str(e)}


# ------------------ AUDIO FILE SERVER ------------------
@app.get("/audio/{filename}")
def get_audio(filename: str):

    file_path = f"/app/output/{filename}"

    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="Audio not found")

    return FileResponse(file_path, media_type="audio/wav")
