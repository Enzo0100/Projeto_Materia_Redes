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
    
    MODELS = {
        "Bocejo": "models/bocejo.pt",
        "Distração": "models/distração.pt",
        "Uso de Celular": "models/celular.pt",
        "Fumar": "models/fumar.pt",
        "EPI": "models/epi.pt",
        "Capacete": "models/capacete.pt",
        "Acompanhante": "models/acompanhante.pt",
        "Cinto de Segurança": "models/cinto.pt",
        "Fadiga": "models/fadiga.pt",
        "Olhos Fechados": "models/olhos_fechados.pt",
        "Uso de Máscara": "models/mascara.pt",
        "Distância Segura": "models/distancia_segura.pt",
        "Mudança de Faixa": "models/mudanca_faixa.pt",
        "Obstrução de Câmera": "models/obstrucao.pt",
        "Blur Face": "models/blur_face.pt",
        "Blur Placa": "models/blur_placa.pt",
        "Excesso de Velocidade": "models/velocidade.pt",
        "Frenagem Brusca": "models/frenagem.pt",
        "Aceleração Brusca": "models/aceleracao.pt",
        "Curva Brusca": "models/curva.pt",
        "Detector de Pedestre": "models/pedestre.pt",
        "Detector de Ciclista": "models/ciclista.pt"
    }
    DEFAULT_MODEL = "models/fadiga.pt"
    
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
