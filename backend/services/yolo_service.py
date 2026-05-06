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
            if not os.path.exists(full_path):
                print(f" [YOLO] ERRO: Arquivo do modelo não encontrado: {full_path}")
                # Fallback para o modelo padrão se o solicitado não existir
                default_path = os.path.join(os.getcwd(), settings.DEFAULT_MODEL)
                if os.path.exists(default_path):
                    print(f" [YOLO] Usando modelo padrão: {settings.DEFAULT_MODEL}")
                    full_path = default_path
                else:
                    print(f" [YOLO] ERRO CRÍTICO: Modelo padrão também não encontrado: {default_path}")
                    return None
            
            try:
                cls._models[model_path] = YOLO(full_path)
            except Exception as e:
                print(f" [YOLO] Erro ao carregar modelo {full_path}: {e}")
                return None
        return cls._models.get(model_path)

    @staticmethod
    def run_inference(video_path, alarm_type):
        model = YOLOProcessor.get_model(alarm_type)
        if model is None:
            print(f" [YOLO] Falha ao obter modelo para {alarm_type}. Pulando inferência.")
            return None
            
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
                    # Usar mp4v que é o mais compatível para gravação via software quando H264 hardware falha
                    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
                    # Assumimos 15 fps como fallback para o video processado
                    video_writer = cv2.VideoWriter(out_video_path, fourcc, 15.0, (width, height))
                    
                    if not video_writer.isOpened():
                        print(" [YOLO] Falha ao abrir VideoWriter com mp4v, tentando MJPG...")
                        fourcc = cv2.VideoWriter_fourcc(*'MJPG')
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
                # Converter para H.264 via FFmpeg para garantir compatibilidade com navegadores
                browser_video_path = out_video_path.replace(".mp4", "_browser.mp4")
                try:
                    import subprocess
                    # -vcodec libx264: codec H.264 via software
                    # -pix_fmt yuv420p: garante compatibilidade com a maioria dos players html5
                    # -preset ultrafast: velocidade sobre compressão para o worker
                    cmd = [
                        'ffmpeg', '-y', '-i', out_video_path,
                        '-vcodec', 'libx264', '-pix_fmt', 'yuv420p',
                        '-preset', 'ultrafast', browser_video_path
                    ]
                    print(f" [YOLO] Convertendo vídeo para H.264: {' '.join(cmd)}")
                    subprocess.run(cmd, check=True, capture_output=True)
                    target_file = browser_video_path
                except Exception as e:
                    print(f" [YOLO] Erro ao converter vídeo com FFmpeg: {e}. Usando original.")
                    target_file = out_video_path

                # Upload to Minio
                inference_video_url = MinioService.upload_file(target_file, content_type="video/mp4")
                
                # Cleanup
                try:
                    os.remove(out_video_path)
                    if os.path.exists(browser_video_path):
                        os.remove(browser_video_path)
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
