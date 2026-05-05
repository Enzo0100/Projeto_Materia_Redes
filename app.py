import pika
import os
import json
import mysql.connector
import requests
from dotenv import load_dotenv

load_dotenv()

# Configurações do .env
host = os.getenv("RABBITMQ_HOST")
port = int(os.getenv("RABBITMQ_PORT"))
user = os.getenv("RABBITMQ_USER")
password = os.getenv("RABBITMQ_PASSWORD")
queue_name = os.getenv("RABBITMQ_QUEUE_NAME")

# Política restritiva: Lista de IMEIs permitidos
# Você pode adicionar os IMEIs aqui ou carregar de uma variável de ambiente
# ALLOWED_IMEIS = [
#     "869247060366033",
#     "869247060364384",
#     "865478070171196",
#     "869247060364376",
#     "869247060359772",
#     # Adicione outros IMEIs conforme necessário
# ]

db_config = {
    'host': os.getenv("DB_HOST"),
    'port': os.getenv("DB_PORT"),
    'user': os.getenv("DB_USER"),
    'password': os.getenv("DB_PASSWORD"),
    'database': os.getenv("DB_NAME")
}

def get_alarm_files(occurrence_id):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # Query para pegar os arquivos de todos os alarmes vinculados a essa ocorrência
        query = """
            SELECT af.file_name, a.device_imei
            FROM yuv_main.occurrence_alarms oa
            JOIN yuv_main.alarms a ON oa.alarm_id = a.id
            JOIN yuv_main.alarm_files af ON a.id = af.alarm_id
            WHERE oa.occurrence_id = %s
        """
        cursor.execute(query, (occurrence_id,))
        results = cursor.fetchall()
        
        cursor.close()
        conn.close()
        return results
    except Exception as e:
        print(f" [!] Erro ao consultar banco de dados: {e}")
        return []

def download_video(imei, file_name):
    # Removendo extensões extras ou ajustando o nome se necessário
    # A URL base fornecida: https://grxwzzpo0ewx.compat.objectstorage.sa-saopaulo-1.oraclecloud.com/yuv-dvr-media/{IMEI}/{AlarmName}
    url = f"https://grxwzzpo0ewx.compat.objectstorage.sa-saopaulo-1.oraclecloud.com/yuv-dvr-media/{imei}/{file_name}"
    
    print(f" [->] Baixando vídeo: {url}")
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            # Cria pasta local se não existir
            os.makedirs("downloads", exist_ok=True)
            local_path = os.path.join("downloads", f"{imei}_{file_name}")
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

def callback(ch, method, properties, body):
    print(f"\n [x] Recebido: {body}")
    
    try:
        data = json.loads(body)
        occurrence_id = data.get('id')
        
        if occurrence_id:
            print(f" [*] Processando ocorrência ID: {occurrence_id}")
            
            # 1. Buscar arquivos no banco
            files = get_alarm_files(occurrence_id)
            
            if not files:
                print(f" [?] Nenhum arquivo encontrado para a ocorrência {occurrence_id}")
            
            for f in files:
                imei = f['device_imei']
                file_name = f['file_name']
                
                # Política restritiva: Verifica se o IMEI está na lista permitida
                if imei not in ALLOWED_IMEIS:
                    print(f" [!] IMEI {imei} não está na lista permitida. Ignorando download.")
                    continue
                
                # 2. Montar URL e Baixar vídeo
                video_path = download_video(imei, file_name)
                
                if video_path:
                    print(f" [READY] Vídeo pronto para inferência: {video_path}")
                    # Aqui entrará a lógica de inferência futuramente
        
    except Exception as e:
        print(f" [!] Erro ao processar mensagem: {e}")
    
    # IMPORTANTE: Mantendo na fila (requeue=True) conforme solicitado
    ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)
    print(" [!] Mensagem processada e devolvida para a fila (requeue=True).")

channel.basic_consume(queue=queue_name, on_message_callback=callback, auto_ack=False)

print(' [*] Aguardando mensagens. Para sair pressione CTRL+C')
channel.start_consuming()