import mysql.connector
import time
from core.config import settings
def get_alarm_files(occurrence_id, retries=3, delay=5):
    db_config = {'host': settings.DB_HOST, 'port': settings.DB_PORT, 'user': settings.DB_USER, 'password': settings.DB_PASSWORD, 'database': settings.DB_NAME}
    query = "SELECT af.file_name, a.device_imei, at.name as alarm_type FROM yuv_main.occurrence_alarms oa JOIN yuv_main.alarms a ON oa.alarm_id = a.id JOIN yuv_main.alarm_files af ON a.id = af.alarm_id JOIN yuv_main.alarm_types at ON a.alarm_type_id = at.id WHERE oa.occurrence_id = %s"
    for attempt in range(retries):
        try:
            conn = mysql.connector.connect(**db_config)
            cursor = conn.cursor(dictionary=True)
            cursor.execute(query, (occurrence_id,))
            results = cursor.fetchall()
            cursor.close()
            conn.close()
            if results: return results
            time.sleep(delay)
        except Exception: pass
    return []
