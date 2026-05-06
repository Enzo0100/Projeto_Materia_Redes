from fastapi import FastAPI, Request
import uvicorn

app = FastAPI()
results_db = []

@app.get("/")
async def index():
    return {"status": "ok", "results": results_db[-20:]}

@app.post("/webhook/result")
async def receive_result(data: dict):
    print(f" [API] Resultado recebido: {data}")
    results_db.append(data)
    return {"status": "received"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
