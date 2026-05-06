from ultralytics import YOLO
from core.config import settings
import os
import cv2
import uuid

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
            best_conf = 0.0
            best_frame_path = None
            
            for r in results:
                if len(r.boxes) > 0:
                    detections += len(r.boxes)
                    mean_conf = r.boxes.conf.mean().item()
                    conf_sum += mean_conf
                    
                    if mean_conf > best_conf:
                        best_conf = mean_conf
                        frames_dir = os.path.join(settings.DOWNLOAD_PATH, "frames")
                        os.makedirs(frames_dir, exist_ok=True)
                        frame_filename = f"{uuid.uuid4()}.jpg"
                        temp_path = os.path.join(frames_dir, frame_filename)
                        # Save the image using OpenCV
                        cv2.imwrite(temp_path, r.orig_img)
                        # Delete the previous best frame to save space
                        if best_frame_path and os.path.exists(best_frame_path):
                            try:
                                os.remove(best_frame_path)
                            except:
                                pass
                        best_frame_path = temp_path
            
            conf = conf_sum / detections if detections > 0 else 0.0
            
            return {
                "result": f"DETECTADO_{detections}", 
                "confidence": float(conf), 
                "is_false_positive": detections == 0,
                "best_frame_path": best_frame_path
            }
        except Exception as e:
            return {"result": "ERROR", "confidence": 0.0, "is_false_positive": True}
