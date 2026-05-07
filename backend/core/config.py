import os
from dotenv import load_dotenv
load_dotenv()
class Config:
    RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "")
    RABBITMQ_PORT = int(os.getenv("RABBITMQ_PORT", 5672))
    RABBITMQ_USER = os.getenv("RABBITMQ_USER")
    RABBITMQ_PASSWORD = os.getenv("RABBITMQ_PASSWORD")
    RABBITMQ_QUEUE_NAME = os.getenv("RABBITMQ_QUEUE_NAME", "")
    DB_HOST = os.getenv("DB_HOST")
    DB_PORT = int(os.getenv("DB_PORT", 3306))
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_NAME = os.getenv("DB_NAME", "yuv_main")
    
    TS_DB_HOST = os.getenv("TS_DB_HOST", "timescaledb")
    TS_DB_PORT = int(os.getenv("TS_DB_PORT", 5432))
    TS_DB_USER = os.getenv("TS_DB_USER", "events_user")
    TS_DB_PASSWORD = os.getenv("TS_DB_PASSWORD", "events_password")
    TS_DB_NAME = os.getenv("TS_DB_NAME", "events_db")
    OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://host.docker.internal:11434")
    OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llava")
    
    # Modelos YOLO unificados por câmera
    YOLO_MODELS = {
        "cabin": os.getenv("YOLO_MODEL_CABIN", "models/cabin.pt"),
        "front": os.getenv("YOLO_MODEL_FRONT", "models/front.pt")
    }

    # Mapeamento de tipos de alarme para qual câmera/modelo deve ser usado
    ALARM_TO_CAMERA = {
        "Bocejo": "cabin",
        "Distração": "cabin",
        "Uso de Celular": "cabin",
        "Fumar": "cabin",
        "EPI": "front",
        "Capacete": "front",
        "Acompanhante": "cabin",
        "Cinto de Segurança": "cabin",
        "Fadiga": "cabin",
        "Olhos Fechados": "cabin",
        "Uso de Máscara": "cabin",
        "Distância Segura": "front",
        "Mudança de Faixa": "front",
        "Obstrução de Câmera": "cabin", # Pode ser ambas, mas geralmente interna
        "Blur Face": "cabin",
        "Blur Placa": "front",
        "Excesso de Velocidade": "front",
        "Frenagem Brusca": "front",
        "Aceleração Brusca": "front",
        "Curva Brusca": "front",
        "Detector de Pedestre": "front",
        "Detector de Ciclista": "front",
        "Colisão": "front",
        "Risco de Colisão": "front"
    }

    DEFAULT_MODEL = "models/front.pt"
    
    DOWNLOAD_PATH = "downloads"
    SELECTED_ALARM_TYPES = [
        "Bocejo", "Distração", "Uso de Celular", "Fumar", "EPI", "Capacete", 
        "Acompanhante", "Cinto de Segurança", "Fadiga", "Olhos Fechados", 
        "Uso de Máscara", "Distância Segura", "Mudança de Faixa", "Obstrução de Câmera",
        "Blur Face", "Blur Placa", "Excesso de Velocidade", "Frenagem Brusca",
        "Aceleração Brusca", "Curva Brusca", "Detector de Pedestre", "Detector de Ciclista"
    ]
    DASHBOARD_URL = "http://dashboard:8000/webhook/result"
    
    # IAM Settings
    DASHBOARD_USERNAME = os.getenv("DASHBOARD_USERNAME", "admin")
    DASHBOARD_PASSWORD = os.getenv("DASHBOARD_PASSWORD", "admin123")
    API_KEY = os.getenv("API_KEY", "super-secret-key")
settings = Config()
