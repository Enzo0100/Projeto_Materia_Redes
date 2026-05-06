from fastapi import FastAPI, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import json
import os
from datetime import datetime

app = FastAPI(title="Kimura AI - Monitoring Dashboard")

# Permitir CORS para o frontend (HTML simples)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simulando um storage de resultados em memória
processed_results = []
MAX_RESULTS = 50

class InferenceResult(BaseModel):
    occurrence_id: str
    imei: str
    alarm_type: str
    yolo_conf: float
    vlm_res: bool
    status: str # "valid", "invalid", "review"
    timestamp: str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

@app.get("/")
def read_root():
    return {"status": "running", "service": "Kimura AI Monitoring"}

@app.get("/results")
def get_results():
    """Retorna os últimos resultados processados"""
    return processed_results[::-1] # Do mais recente para o mais antigo

@app.post("/webhook/result")
def receive_result(result: InferenceResult):
    """
    Endpoint que receberá o resultado real do app.py
    (Simula a plataforma do cliente recebendo o dado)
    """
    processed_results.append(result.dict())
    if len(processed_results) > MAX_RESULTS:
        processed_results.pop(0)
    return {"msg": "Result received"}

# HTML Embutido para visualização rápida
@app.get("/dashboard", response_class=FastAPI.responses.HTMLResponse)
def dashboard():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Kimura AI | Monitoramento</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body { background: #f4f7f6; }
            .card { margin-bottom: 20px; border: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
            .status-valid { color: #28a745; font-weight: bold; }
            .status-invalid { color: #dc3545; font-weight: bold; }
            .header-bar { background: #1a2a6c; color: white; padding: 20px; margin-bottom: 30px; }
        </style>
    </head>
    <body onload="fetchResults()">
        <div class="header-bar">
            <h2 class="container">Plataforma Kimura AI - Simulação de Monitoramento</h2>
        </div>
        
        <div class="container">
            <div class="row">
                <div class="col-md-4">
                    <div class="card p-4 text-center">
                        <h5>Alertas Processados</h5>
                        <h2 id="counter">0</h2>
                    </div>
                </div>
                <div class="col-md-8">
                    <div class="card p-4">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tipo</th>
                                    <th>YOLO Conf</th>
                                    <th>VLM Validação</th>
                                    <th>Status Final</th>
                                </tr>
                            </thead>
                            <tbody id="resultsTable">
                                <!-- Preenchido dinamicamente -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <script>
            function fetchResults() {
                fetch('/results')
                    .then(res => res.json())
                    .then(data => {
                        document.getElementById('counter').innerText = data.length;
                        const tbody = document.getElementById('resultsTable');
                        tbody.innerHTML = '';
                        data.forEach(item => {
                            const row = `<tr>
                                <td>${item.occurrence_id}</td>
                                <td>${item.alarm_type}</td>
                                <td>${(item.yolo_conf * 100).toFixed(1)}%</td>
                                <td>${item.vlm_res ? '✅ Confirmado' : '❌ Falso Positivo'}</td>
                                <td class="status-${item.status}">${item.status.toUpperCase()}</td>
                            </tr>`;
                            tbody.innerHTML += row;
                        });
                    });
            }
            setInterval(fetchResults, 2000);
        </script>
    </body>
    </html>
    """

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
