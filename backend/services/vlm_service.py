import base64
import requests
import json
from core.config import settings

class VLMProcessor:
    @staticmethod
    def encode_image(image_path):
        with open(image_path, "rb") as image_file:
            return base64.b64encode(image_file.read()).decode('utf-8')

    @staticmethod
    def analyze_frame(frame_path, prompt):
        try:
            base64_image = VLMProcessor.encode_image(frame_path)
        except Exception as e:
            print(f" [VLM] Erro ao ler imagem {frame_path}: {e}")
            return {"confirmed": True, "reason": "Erro na leitura da imagem"}
            
        url = f"{settings.OLLAMA_BASE_URL}/api/generate"
        
        # O prompt pede para o modelo ser estrito com a estrutura do JSON
        full_prompt = f"{prompt}\nResponda estritamente com um JSON válido no formato exato (sem formatação markdown ao redor): {{\"confirmed\": true, \"reason\": \"sua justificativa aqui\"}}"

        payload = {
            "model": settings.OLLAMA_MODEL,
            "prompt": full_prompt,
            "stream": False,
            "images": [base64_image],
            "options": {
                "temperature": 0.1 # Reduzir temperatura para evitar saídas muito criativas que quebrem o JSON
            }
        }

        try:
            print(f" [VLM] Analisando frame {frame_path} com Ollama ({settings.OLLAMA_MODEL})...")
            response = requests.post(url, json=payload, timeout=60)
            response.raise_for_status()
            
            result_json = response.json()
            content = result_json.get("response", "").strip()
            
            # Limpa formatação markdown se a API retornar
            if content.startswith("```json"):
                content = content.replace("```json", "", 1)
            if content.endswith("```"):
                content = content[::-1].replace("```", "", 1)[::-1]
            content = content.strip()
            
            try:
                data = json.loads(content)
                print(f" [VLM] Resultado: {data}")
                return {"confirmed": data.get("confirmed", True), "reason": data.get("reason", "Sem razão informada")}
            except json.JSONDecodeError:
                print(f" [VLM] Ollama não retornou JSON válido. Retorno puro: {content}")
                return {"confirmed": True, "reason": f"Fallback: JSON parse failed. Raw: {content[:50]}..."}
                
        except Exception as e:
            print(f" [VLM] Erro ao analisar frame na API Ollama: {e}")
            return {"confirmed": True, "reason": "Erro de conexão/API no Ollama, assume resultado YOLO"}
