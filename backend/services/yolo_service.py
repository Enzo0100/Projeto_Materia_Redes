from ultralytics import YOLO
from core.config import settings
import os

class YOLOProcessor:
    _models = {}

    @classmethod
    def get_model(cls, alarm_type):
        # Resolve o caminho do modelo baseado no tipo de alarme
        model_path = settings.MODELS.get(alarm_type, settings.DEFAULT_MODEL)
        
        # Garante o path absoluto dentro do container/backend
        full_path = os.path.join(os.getcwd(), model_path)

        if model_path not in cls._models:
            print(f" [YOLO] Carregando modelo para '{alarm_type}': {model_path}")
            cls._models[model_path] = YOLO(full_path)
        return cls._models[model_path]

    @staticmethod
    def run_inference(video_path, alarm_type):
        model = YOLOProcessor.get_model(alarm_type)
        try:
            # stream=True evita acúmulo de memória RAM em workers de longa duração
            results = model.predict(source=video_path, save=False, conf=0.25, verbose=False, stream=True)
            
            detections = 0
            conf_sum = 0
            
            for r in results:
                detections += len(r.boxes)
                if len(r.boxes) > 0:
                    conf_sum += r.boxes.conf.mean().item()
            
            conf = conf_sum / detections if detections > 0 else 0.0
            
            return {"result": f"DETECTADO_{detections}", "confidence": float(conf), "is_false_positive": detections == 0}
        except Exception as e:
            return {"result": "ERROR", "confidence": 0.0, "is_false_positive": True}
