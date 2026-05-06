from fastapi import FastAPI, Request, BackgroundTasks, Depends, HTTPException, status
from fastapi.templating import Jinja2Templates
from fastapi.security import HTTPBasic, HTTPBasicCredentials, APIKeyHeader
import uvicorn
import requests
import os
import datetime
import secrets
from core.config import settings

app = FastAPI()

# IAM Config
security_basic = HTTPBasic()
api_key_header = APIKeyHeader(name="X-API-Key")

def get_current_user(credentials: HTTPBasicCredentials = Depends(security_basic)):
    correct_username = secrets.compare_digest(credentials.username, settings.DASHBOARD_USERNAME)
    correct_password = secrets.compare_digest(credentials.password, settings.DASHBOARD_PASSWORD)
    if not (correct_username and correct_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username

def verify_api_key(api_key: str = Depends(api_key_header)):
    if not secrets.compare_digest(api_key, settings.API_KEY):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="API Key inválida ou ausente",
        )
    return api_key

# Configuração de templates
base_dir = os.path.dirname(os.path.abspath(__file__))
templates_dir = os.path.join(base_dir, "..", "templates")
templates = Jinja2Templates(directory=templates_dir)

results_db = []
EXTERNAL_WEBHOOK_URL = os.getenv("EXTERNAL_WEBHOOK_URL", "")

def forward_to_client(data: dict):
    if EXTERNAL_WEBHOOK_URL:
        try:
            yuv_payload = {
                "id": data.get("occurrence_id"),
                "status": "VALIDATED" if data.get("status") == "valid" else "DISCARDED",
                "ai_meta": {
                    "yolo_confidence": data.get("yolo_conf"),
                    "vlm_justification": data.get("vlm_reason"),
                    "processing_time": data.get("processing_time_ms")
                }
            }
            print(f" [API] Encaminhando resultado para cliente externo: {EXTERNAL_WEBHOOK_URL}")
            requests.post(EXTERNAL_WEBHOOK_URL, json=yuv_payload, timeout=5)
        except Exception as e:
            print(f" [API ERROR] Falha ao encaminhar webhook: {e}")

@app.get("/")
async def index(request: Request, username: str = Depends(get_current_user)):
    total_processed = len(results_db)
    valid_alerts = sum(1 for r in results_db if r.get("status") == "valid")
    invalid_alerts = total_processed - valid_alerts
    
    avg_time = 0
    if total_processed > 0:
        total_time = sum(r.get("processing_time_ms", 0) for r in results_db)
        avg_time = round(total_time / total_processed, 2)

    return templates.TemplateResponse("index.html", {
        "request": request,
        "results": list(reversed(results_db[-50:])),
        "stats": {
            "total": total_processed,
            "valid": valid_alerts,
            "invalid": invalid_alerts,
            "avg_time_ms": avg_time
        }
    })

@app.post("/webhook/result")
async def receive_result(data: dict, background_tasks: BackgroundTasks, api_key: str = Depends(verify_api_key)):
    data["timestamp"] = datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    print(f" [API] Resultado recebido: {data['occurrence_id']}")
    
    results_db.append(data)
    background_tasks.add_task(forward_to_client, data)
    
    return {"status": "received"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
