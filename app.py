from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
import subprocess
import uuid
import os

app = FastAPI()

API_KEY = os.getenv("API_KEY")

class Request(BaseModel):
    text: str


def verify_api_key(x_api_key: str):
    if not API_KEY:
        raise HTTPException(status_code=500, detail="API_KEY not set on server")

    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Unauthorized")


@app.post("/tts")
def tts(req: Request, x_api_key: str = Header(None)):

    verify_api_key(x_api_key)

    os.makedirs("/app/output", exist_ok=True)

    output = f"/app/output/{uuid.uuid4()}.wav"

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

        return {"audio": output}

    except Exception as e:
        return {"exception": str(e)}
