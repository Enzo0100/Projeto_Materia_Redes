from ultralytics import YOLO
from core.config import settings
import os
import cv2
import uuid
from services.minio_service import MinioService

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
            
            frames_dir = os.path.join(settings.DOWNLOAD_PATH, "frames")
            os.makedirs(frames_dir, exist_ok=True)
            
            video_filename = f"{uuid.uuid4()}.mp4"
            out_video_path = os.path.join(frames_dir, video_filename)
            video_writer = None
            
            for r in results:
                annotated_frame = r.plot()
                
                if video_writer is None:
                    height, width, _ = annotated_frame.shape
                    # Usar mp4v para salvar o video
                    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
                    # Assumimos 15 fps como fallback para o video processado
                    video_writer = cv2.VideoWriter(out_video_path, fourcc, 15.0, (width, height))
                    
                video_writer.write(annotated_frame)
                
                if len(r.boxes) > 0:
                    detections += len(r.boxes)
                    mean_conf = r.boxes.conf.mean().item()
                    conf_sum += mean_conf
                    
                    if mean_conf > best_conf:
                        best_conf = mean_conf
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
            
            if video_writer is not None:
                video_writer.release()
                
            conf = conf_sum / detections if detections > 0 else 0.0
            
            inference_video_url = None
            if os.path.exists(out_video_path):
                # Upload to Minio
                inference_video_url = MinioService.upload_file(out_video_path, content_type="video/mp4")
                try:
                    os.remove(out_video_path)
                except:
                    pass
            
            return {
                "result": f"DETECTADO_{detections}", 
                "confidence": float(conf), 
                "is_false_positive": detections == 0,
                "best_frame_path": best_frame_path,
                "inference_video_url": inference_video_url
            }
        except Exception as e:
            return {"result": "ERROR", "confidence": 0.0, "is_false_positive": True}
