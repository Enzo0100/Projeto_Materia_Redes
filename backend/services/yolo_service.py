from ultralytics import YOLO
from core.config import settings
class YOLOProcessor:
    _model = None
    @classmethod
    def get_model(cls):
        if cls._model is None:
            cls._model = YOLO(settings.MODEL_PATH)
        return cls._model
    @staticmethod
    def run_inference(video_path, alarm_type):
        model = YOLOProcessor.get_model()
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
