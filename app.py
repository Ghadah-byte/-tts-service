from fastapi import FastAPI
from pydantic import BaseModel
import subprocess
import uuid
import os

app = FastAPI()

class Request(BaseModel):
    text: str

@app.post("/tts")
def tts(req: Request):

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
            input=req.text,   # صح
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