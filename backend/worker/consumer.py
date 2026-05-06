import pika, os, json, requests, time, queue, threading
from core.config import settings
from services.yolo_service import YOLOProcessor
from services.database import get_alarm_files
from services.intelligence import FrameIntelligence
from services.vlm_service import VLMProcessor
from services.iam_service import IAMService

inference_queue = queue.Queue(maxsize=100)

def send_to_dashboard(processed_data):
    try:
        payload = {
            "occurrence_id": str(processed_data.get("occurrence_id")),
            "alarm_type": str(processed_data.get("alarm_type")),
            "yolo_conf": float(processed_data.get("confidence", 0.0)),
            "status": processed_data.get("final_status", "invalid"),
            "vlm_reason": processed_data.get("vlm_reason", ""),
            "processing_time_ms": processed_data.get("processing_time_ms", 0)
        }
        headers = {"X-API-Key": settings.API_KEY}
        response = requests.post(settings.DASHBOARD_URL, json=payload, headers=headers, timeout=5)
        response.raise_for_status()
    except Exception as e:
        print(f" [WORKER ERROR] Falha ao enviar resultado para o dashboard: {e}")

def inference_worker():
    while True:
        task = inference_queue.get()
        start_time = time.time()
        imei = task.get('imei')
        
        print(f" [WORKER] Processando Occ {task['occ_id']} (IMEI: {imei})...")
        
        # 1. Verificação de IAM: O IMEI pode processar este tipo de alarme?
        if not IAMService.can_process_alarm(imei, task['type']):
            print(f" [IAM] IMEI {imei} NÃO autorizado para modelo '{task['type']}'. Pulando...")
            send_to_dashboard({
                "occurrence_id": task['occ_id'],
                "alarm_type": task['type'],
                "final_status": "skipped_iam",
                "vlm_reason": "IMEI não autorizado para este modelo"
            })
            inference_queue.task_done()
            continue

        res = YOLOProcessor.run_inference(task['path'], task['type'])
        
        is_false_positive = res.get('is_false_positive', True)
        vlm_reason = "Não processado pelo VLM (IAM Disabled)"
        final_status = "invalid"

        # 2. Verificação de IAM: O IMEI tem VLM ativo?
        use_vlm = IAMService.should_use_vlm(imei)

        # Estágio 2: VLM (Apenas se o YOLO detectar algo E IAM permitir VLM)
        if not is_false_positive and res.get('best_frame_path') and use_vlm:
            prompt = FrameIntelligence.get_vlm_prompt_by_poi(task['type'], res['result'])
            vlm_res = VLMProcessor.analyze_frame(res['best_frame_path'], prompt)
            
            if vlm_res.get('confirmed', False):
                final_status = "valid"
                is_false_positive = False
            else:
                final_status = "invalid"
                is_false_positive = True
            
            vlm_reason = vlm_res.get('reason', '')
        elif not is_false_positive and not use_vlm:
            # Se não usa VLM, confia no YOLO
            final_status = "valid"
            vlm_reason = "Validado via YOLO (VLM Bypass via IAM)"
        
        if res.get('best_frame_path'):
            try:
                os.remove(res['best_frame_path'])
            except:
                pass
        
        processing_time = int((time.time() - start_time) * 1000)

        send_to_dashboard({
            "occurrence_id": task['occ_id'],
            "alarm_type": task['type'],
            "confidence": res.get('confidence'),
            "is_false_positive": is_false_positive,
            "final_status": final_status,
            "vlm_reason": vlm_reason,
            "processing_time_ms": processing_time
        })
        
        try:
            os.remove(task['path'])
        except:
            pass

        inference_queue.task_done()

threading.Thread(target=inference_worker, daemon=True).start()

def download_video(imei, file_name, occ_id):
    url = f"https://grxwzzpo0ewx.compat.objectstorage.sa-saopaulo-1.oraclecloud.com/yuv-dvr-media/{imei}/{file_name}"
    dest = os.path.join(settings.DOWNLOAD_PATH, str(occ_id))
    os.makedirs(dest, exist_ok=True)
    try:
        r = requests.get(url, timeout=15)
        r.raise_for_status()
        path = os.path.join(dest, file_name)
        with open(path, 'wb') as f: f.write(r.content)
        return path
    except Exception as e:
        print(f" [WORKER ERROR] Falha no download do vídeo {file_name}: {e}")
        return None

def callback(ch, method, properties, body):
    try:
        data = json.loads(body)
        occ_id = data.get('id')
        if occ_id:
            files = get_alarm_files(occ_id)
            for f in files:
                if any(s.lower() in f['alarm_type'].lower() for s in settings.SELECTED_ALARM_TYPES):
                    video = download_video(f['device_imei'], f['file_name'], occ_id)
                    if video:
                        inference_queue.put({
                            'path': video, 
                            'type': f['alarm_type'], 
                            'occ_id': occ_id,
                            'imei': f['device_imei']
                        })
        ch.basic_ack(delivery_tag=method.delivery_tag)
    except json.JSONDecodeError as e:
        print(f" [RABBITMQ ERROR] Payload JSON inválido na mensagem: {e}")
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)
    except Exception as e:
        print(f" [RABBITMQ ERROR] Erro inesperado no callback: {e}")
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)

def run():
    print(" [*] Worker Kimu-Ra (Segmented) iniciado...")
    while True:
        try:
            cred = pika.PlainCredentials(settings.RABBITMQ_USER, settings.RABBITMQ_PASSWORD)
            params = pika.ConnectionParameters(
                host=settings.RABBITMQ_HOST, 
                port=settings.RABBITMQ_PORT, 
                virtual_host='/', 
                credentials=cred,
                heartbeat=60
            )
            conn = pika.BlockingConnection(params)
            chan = conn.channel()
            chan.queue_declare(queue=settings.RABBITMQ_QUEUE_NAME, durable=True)
            chan.basic_qos(prefetch_count=1)
            chan.basic_consume(queue=settings.RABBITMQ_QUEUE_NAME, on_message_callback=callback)
            print(" [OK] Conectado ao RabbitMQ.")
            chan.start_consuming()
        except Exception as e:
            print(f" [!] Erro de conexão: {e}. Reconectando...")
            time.sleep(5)

if __name__ == "__main__":
    run()
