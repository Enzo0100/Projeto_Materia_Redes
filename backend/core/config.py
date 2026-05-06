import os
from dotenv import load_dotenv
load_dotenv()
class Config:
    RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "localhost")
    RABBITMQ_PORT = int(os.getenv("RABBITMQ_PORT", 5672))
    RABBITMQ_USER = os.getenv("RABBITMQ_USER")
    RABBITMQ_PASSWORD = os.getenv("RABBITMQ_PASSWORD")
    RABBITMQ_QUEUE_NAME = os.getenv("RABBITMQ_QUEUE_NAME", "yns.occurrence")
    DB_HOST = os.getenv("DB_HOST")
    DB_PORT = int(os.getenv("DB_PORT", 3306))
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_NAME = os.getenv("DB_NAME", "yuv_main")
    OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://host.docker.internal:11434")
    OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llava")
    
    MODELS = {
        "Bocejo": "models/bocejo.pt",
        "Distração": "models/distração.pt",
        "Uso de Celular": "models/celular.pt",
        "Fumar": "models/fumar.pt",
        "EPI": "models/epi.pt",
        "Capacete": "models/capacete.pt",
        "Acompanhante": "models/acompanhante.pt"
    }
    DEFAULT_MODEL = "models/epi.pt"
    
    DOWNLOAD_PATH = "downloads"
    SELECTED_ALARM_TYPES = ["Bocejo", "Distração", "Uso de Celular", "Fumar", "EPI", "Capacete", "Acompanhante"]
    DASHBOARD_URL = "http://dashboard:8000/webhook/result"
    
    # IAM Settings
    DASHBOARD_USERNAME = os.getenv("DASHBOARD_USERNAME", "admin")
    DASHBOARD_PASSWORD = os.getenv("DASHBOARD_PASSWORD", "admin123")
    API_KEY = os.getenv("API_KEY", "super-secret-kimura-key")
settings = Config()
