from fastapi import FastAPI, Request, BackgroundTasks, Depends, HTTPException, status
from fastapi.templating import Jinja2Templates
from fastapi.security import HTTPBasic, HTTPBasicCredentials, APIKeyHeader
import uvicorn
import requests
import os
import datetime
import secrets
from pydantic import BaseModel
from typing import Dict, List, Any
from core.config import settings
from services.iam_service import IAMService
from services import timescale_db

app = FastAPI()

@app.on_event("startup")
def startup_event():
    timescale_db.init_db()

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
    stats = timescale_db.get_stats()
    recent_events = timescale_db.get_recent_events(limit=50)

    return templates.TemplateResponse(
        request=request,
        name="index.html",
        context={
            "results": recent_events,
            "stats": stats
        }
    )

@app.get("/permissions")
async def permissions_page(request: Request, username: str = Depends(get_current_user)):
    return templates.TemplateResponse(
        request=request,
        name="permissions.html",
        context={}
    )

@app.get("/api/permissions")
async def get_permissions(username: str = Depends(get_current_user)):
    return IAMService.get_all_permissions()

@app.post("/api/permissions")
async def save_permissions(data: Dict[str, Any], username: str = Depends(get_current_user)):
    IAMService.save_permissions(data)
    return {"status": "success"}

@app.post("/webhook/result")
async def receive_result(data: dict, background_tasks: BackgroundTasks, api_key: str = Depends(verify_api_key)):
    data["timestamp"] = datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    print(f" [API] Resultado recebido: {data['occurrence_id']}")
    
    # Log event into TimescaleDB
    timescale_db.log_event(data)
    
    background_tasks.add_task(forward_to_client, data)
    
    return {"status": "received"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
