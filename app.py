import pika
import os
import json
import mysql.connector
import requests
import time
import queue
import threading
from dotenv import load_dotenv
from intelligence import FrameIntelligence

load_dotenv()

# --- FILA DE INFERÊNCIA ASSÍNCRONA ---
# Esta fila garante que a GPU não seja sobrecarregada por múltiplas inferências simultâneas.
inference_queue = queue.Queue(maxsize=100)

def inference_worker():
    """
    Worker que roda em background consumindo a fila de vídeos.
    """
    print(" [WORKER] Iniciando fila de inferência assíncrona...")
    while True:
        try:
            task = inference_queue.get()
            video_path = task['path']
            alarm_type = task['type']
            occurrence_id = task['occ_id']
            processor = task['processor']

            print(f"\n [WORKER] Processando Inferência: {alarm_type} (Occ: {occurrence_id})")
            
            # Inteligência de Amostragem: Define a estratégia antes de rodar
            strategy = FrameIntelligence.get_inference_strategy(alarm_type, video_path)
            
            # 1. Executa a primeira validação com o modelo especialista (YOLO)
            yolo_result = processor(video_path, alarm_type)
            
            # 2. SEGUNDA OPINIÃO (VLM): 
            # Mesmo que o YOLO detecte, pedimos ao VLM para confirmar usando Pontos de Interesse (POI)
            final_result = IAProcessor.process_vlm_confirmation(
                video_path, 
                alarm_type, 
                yolo_result.get('result')
            )
            
            # Formata o resultado consolidado para envio ao RabbitMQ
            processed_data = {
                "occurrence_id": occurrence_id,
                "alarm_type": alarm_type,
                "yolo_pre_check": yolo_result.get('result'),
                "vlm_confirmation": final_result.get('result'),
                "confidence": final_result.get('confidence'),
                "is_false_positive": final_result.get('is_false_positive'),
                "processed_at": time.strftime('%Y-%m-%d %H:%M:%S')
            }

            # Envia para a nova fila de resultados no RabbitMQ
            try:
                # Criamos uma conexão temporária ou usamos uma persistente no worker
                # Para maior modularidade, enviamos aqui para uma fila específica
                res_connection = pika.BlockingConnection(parameters)
                res_channel = res_connection.channel()
                res_channel.queue_declare(queue=RESULTS_QUEUE_NAME, durable=True)
                res_channel.basic_publish(
                    exchange='',
                    routing_key=RESULTS_QUEUE_NAME,
                    body=json.dumps(processed_data),
                    properties=pika.BasicProperties(delivery_mode=2) # Mensagem persistente
                )
                res_connection.close()
                print(f" [->] Resultado enviado para a fila {RESULTS_QUEUE_NAME}")
            except Exception as e:
                print(f" [!] Erro ao enviar resultado para RabbitMQ: {e}")

            conf = result.get('confidence', 0) * 100
            res = result.get('result')
            is_fp = "Sim" if result.get('is_false_positive') else "Não"
            print(f" [REPORT] Occ {occurrence_id} | {res} | Conf: {conf:.1f}% | FP: {is_fp}")
            
            inference_queue.task_done()
        except Exception as e:
            print(f" [WORKER ERROR] {e}")

# Inicia o thread do worker
threading.Thread(target=inference_worker, daemon=True).start()

# Configurações do .env
host = os.getenv("RABBITMQ_HOST")
port = int(os.getenv("RABBITMQ_PORT"))
user = os.getenv("RABBITMQ_USER")
password = os.getenv("RABBITMQ_PASSWORD")
queue_name = os.getenv("RABBITMQ_QUEUE_NAME")

# Nova fila para exportar resultados processados
RESULTS_QUEUE_NAME = "kimura.processed.results"

# Política restritiva: Lista de IMEIs permitidos
ALLOWED_IMEIS = [
    "869247060308514",
    "869247060310940",
]

# Configuração do Cliente: Tipos de alarme que ele deseja pós-processar
# Se o tipo não estiver nesta lista, o vídeo nem será baixado.
SELECTED_ALARM_TYPES = [
    "Bocejo",
    "Distração",
    "Uso de Celular",
    "Fumar",
    "EPI",
    "Capacete",
    "Acompanhante",
    # "Excesso de Velocidade", # Exemplo de tipo desativado pelo cliente
]

class IAProcessor:
    # --- MODELOS PERSISTENTES (WARM-UP) ---
    _loaded_models = {}

    @classmethod
    def load_all_models(cls):
        """
        Carrega todos os modelos especialistas e customizados.
        """
        print(" [GPU] Carregando modelos especialistas e customizados...")
        # Simulação: Aqui carregaríamos o motor YOLO v8/v10 padrão
        cls._loaded_models['yolo_engine'] = "YOLO_MOTOR_GLOBAL"
        print(" [GPU] Modelos carregados com sucesso!")

    @staticmethod
    def run_inference(video_path, alarm_type, model_key='yolo_engine'):
        """
        Motor de inferência modular: permite usar modelos treinados pelo cliente.
        """
        print(f" [AI] Executando inferência modular ({alarm_type}) com: {model_key}")
        # Simulando lógica de detecção dinâmica
        return {"result": f"YOLO_DETECTADO_{alarm_type}", "confidence": 0.82, "is_false_positive": False}

    @staticmethod
    def process_vlm_confirmation(video_path, alarm_type, yolo_result):
        """
        Pega o resultado do YOLO e pede uma 'segunda opinião' ao VLM
        usando um prompt focado no Ponto de Interesse (POI).
        """
        prompt = FrameIntelligence.get_vlm_prompt_by_poi(alarm_type, yolo_result)
        print(f" [VLM] Validando POI com prompt: {prompt}")
        # Simulação de chamada de VLM (ex: Gemini/GPT-4o-V)
        return {"result": f"VLM_CONFIRMADO_{alarm_type}", "confidence": 0.98, "is_false_positive": False}

# Chama o carregamento
IAProcessor.load_all_models()

# Mapeamento dinâmico Plug-and-Play
ALARM_MODEL_MAPPING = {
    "Bocejo": IAProcessor.run_inference,
    "Sono": IAProcessor.run_inference,
    "Celular": IAProcessor.run_inference,
    "Fumar": IAProcessor.run_inference,
    "Distração": IAProcessor.run_inference,
    "EPI": IAProcessor.run_inference,
    "Capacete": IAProcessor.run_inference,
    "Acompanhante": IAProcessor.run_inference
}

def get_processor_for_alarm(alarm_type):
    """
    Retorna o método de processamento correto baseado no mapeamento.
    """
    for key, processor in ALARM_MODEL_MAPPING.items():
        if key.lower() in alarm_type.lower():
            return processor
    return IAProcessor.run_inference

# --- BANCO DE DADOS ---
    'host': os.getenv("DB_HOST"),
    'port': os.getenv("DB_PORT"),
    'user': os.getenv("DB_USER"),
    'password': os.getenv("DB_PASSWORD"),
    'database': os.getenv("DB_NAME")
}

def get_alarm_files(occurrence_id, retries=3, delay=60):
    """
    Tenta buscar arquivos no banco com um mecanismo de retry, 
    pois o vídeo pode demorar alguns minutos a mais que o alerta.
    """
    query = """
        SELECT af.file_name, a.device_imei, at.name as alarm_type
        FROM yuv_main.occurrence_alarms oa
        JOIN yuv_main.alarms a ON oa.alarm_id = a.id
        JOIN yuv_main.alarm_files af ON a.id = af.alarm_id
        JOIN yuv_main.alarm_types at ON a.alarm_type_id = at.id
        WHERE oa.occurrence_id = %s
    """
    
    for attempt in range(retries):
        try:
            conn = mysql.connector.connect(**db_config)
            cursor = conn.cursor(dictionary=True)
            
            cursor.execute(query, (occurrence_id,))
            results = cursor.fetchall()
            
            cursor.close()
            conn.close()
            
            if results:
                return results
            
            print(f" [?] Tentativa {attempt + 1}: Nenhum arquivo encontrado para {occurrence_id}. Aguardando {delay}s...")
            time.sleep(delay)
            
        except Exception as e:
            print(f" [!] Erro ao consultar banco de dados (tentativa {attempt + 1}): {e}")
            if 'conn' in locals() and conn.is_connected():
                conn.close()
            time.sleep(delay)
            
    return []

def download_video(imei, file_name, occurrence_id):
    # A URL base fornecida: https://grxwzzpo0ewx.compat.objectstorage.sa-saopaulo-1.oraclecloud.com/yuv-dvr-media/{IMEI}/{AlarmName}
    url = f"https://grxwzzpo0ewx.compat.objectstorage.sa-saopaulo-1.oraclecloud.com/yuv-dvr-media/{imei}/{file_name}"
    
    # Cria pasta específica para a ocorrência dentro de downloads/
    occurrence_dir = os.path.join("downloads", str(occurrence_id))
    os.makedirs(occurrence_dir, exist_ok=True)
    
    print(f" [->] Baixando vídeo para pasta {occurrence_dir}: {url}")
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            local_path = os.path.join(occurrence_dir, file_name)
            with open(local_path, 'wb') as f:
                f.write(response.content)
            print(f" [ok] Vídeo salvo em: {local_path}")
            return local_path
        else:
            print(f" [!] Falha ao baixar vídeo. Status: {response.status_code}")
    except Exception as e:
        print(f" [!] Erro durante o download: {e}")
    return None

credentials = pika.PlainCredentials(user, password)
parameters = pika.ConnectionParameters(host, port, '/', credentials)
connection = pika.BlockingConnection(parameters)
channel = connection.channel()

# Contador global para amostragem (1 a cada 10)
message_counter = 0

def callback(ch, method, properties, body):
    global message_counter
    print(f"\n [x] Recebido: {body}")
    
    try:
        message_counter += 1
        
        # Lógica de amostragem: processa apenas se for a 10ª mensagem
        if message_counter % 10 != 0:
            print(f" [S] Amostragem: Ignorando mensagem {message_counter} (processando apenas 1 a cada 10)")
        else:
            print(f" [P] Amostragem: Processando mensagem {message_counter}")
            data = json.loads(body)
            occurrence_id = data.get('id')
            
            if occurrence_id:
                print(f" [*] Processando ocorrência ID: {occurrence_id}")
                
                # 1. Buscar arquivos no banco
                files = get_alarm_files(occurrence_id)
                
                if not files:
                    print(f" [?] Nenhum arquivo encontrado para a ocorrência {occurrence_id}")
                
            # Coleta todos os tipos de alarme únicos presentes nesta ocorrência
            unique_alarm_types = list(set(f['alarm_type'] for f in files))
            print(f" [!] Ocorrência {occurrence_id} contém os tipos: {', '.join(unique_alarm_types)}")

            for f in files:
                imei = f['device_imei']
                file_name = f['file_name']
                alarm_type = f['alarm_type']
                
                # 1. Filtro de Seleção do Cliente (Pós-processamento desejado)
                # Verifica se este arquivo específico deve ser processado
                if not any(selected.lower() in alarm_type.lower() for selected in SELECTED_ALARM_TYPES):
                    print(f" [S] Pulando arquivo '{file_name}' (Tipo '{alarm_type}' não selecionado).")
                    if 'ALLOWED_IMEIS' in globals() and imei not in ALLOWED_IMEIS:
                        print(f" [!] IMEI {imei} não está na lista permitida. Ignorando download.")
                        continue
                    
                    # 3. Montar URL e Baixar vídeo
                    video_path = download_video(imei, file_name, occurrence_id)
                    
                    if video_path:
                        print(f" [READY] Vídeo baixado: {video_path}")
                        
                        # 4. Adiciona à fila de inferência assíncrona
                        # Isso libera o consumidor do RabbitMQ para pegar o próximo alerta imediatamente
                        processor = get_processor_for_alarm(alarm_type)
                        task = {
                            'path': video_path,
                            'type': alarm_type,
                            'occ_id': occurrence_id,
                            'processor': processor
                        }
                        
                        try:
                            inference_queue.put(task, block=False)
                            print(f" [QUEUE] Tarefa adicionada à fila de inferência. Fila: {inference_queue.qsize()}")
                        except queue.Full:
                            print(f" [!] Fila de inferência cheia! Ignorando {occurrence_id}")
        
    except Exception as e:
        print(f" [!] Erro ao processar mensagem: {e}")
    
    # IMPORTANTE: Mantendo na fila (requeue=True) conforme solicitado
    ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)
    print(" [!] Mensagem processada e devolvida para a fila (requeue=True).")

channel.basic_consume(queue=queue_name, on_message_callback=callback, auto_ack=False)

print(' [*] Aguardando mensagens. Para sair pressione CTRL+C')
channel.start_consuming()