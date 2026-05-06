import psycopg2
from psycopg2.extras import RealDictCursor
import json
import time
from core.config import settings

def get_connection(retries=5, delay=2):
    for attempt in range(retries):
        try:
            conn = psycopg2.connect(
                host=settings.TS_DB_HOST,
                port=settings.TS_DB_PORT,
                user=settings.TS_DB_USER,
                password=settings.TS_DB_PASSWORD,
                dbname=settings.TS_DB_NAME
            )
            return conn
        except psycopg2.OperationalError as e:
            if attempt < retries - 1:
                time.sleep(delay)
            else:
                print(f" [TS_DB ERROR] Could not connect to TimescaleDB: {e}")
                return None

def init_db():
    conn = get_connection()
    if not conn:
        return
    try:
        cursor = conn.cursor()
        
        # Create extension if not exists
        cursor.execute("CREATE EXTENSION IF NOT EXISTS timescaledb;")
        
        # Create events_log table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS events_log (
                time TIMESTAMPTZ NOT NULL,
                occurrence_id VARCHAR(100),
                imei VARCHAR(50),
                alarm_type VARCHAR(100),
                yolo_conf FLOAT,
                status VARCHAR(50),
                vlm_reason TEXT,
                processing_time_ms INTEGER
            );
        """)
        
        # Convert events_log to hypertable if it isn't already
        cursor.execute("""
            SELECT create_hypertable('events_log', by_range('time', INTERVAL '1 day'), if_not_exists => TRUE);
        """)

        # Create imei_permissions table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS imei_permissions (
                imei VARCHAR(50) PRIMARY KEY,
                use_yolo BOOLEAN NOT NULL DEFAULT TRUE,
                use_vlm BOOLEAN NOT NULL DEFAULT FALSE,
                allowed_models JSONB NOT NULL DEFAULT '[]'::jsonb,
                updated_at TIMESTAMPTZ DEFAULT NOW()
            );
        """)
        
        # Insert GLOBAL_DEFAULT if it doesn't exist
        cursor.execute("""
            INSERT INTO imei_permissions (imei, use_yolo, use_vlm, allowed_models)
            VALUES ('GLOBAL_DEFAULT', true, false, '["Fadiga", "Bocejo", "Uso de Celular", "Distração", "Cinto de Segurança", "Olhos Fechados", "Blur Face", "Blur Placa", "Frenagem Brusca"]'::jsonb)
            ON CONFLICT (imei) DO NOTHING;
        """)

        conn.commit()
        cursor.close()
    except Exception as e:
        print(f" [TS_DB ERROR] Failed to initialize TimescaleDB: {e}")
    finally:
        conn.close()

def log_event(data):
    conn = get_connection()
    if not conn:
        return
    try:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO events_log (time, occurrence_id, imei, alarm_type, yolo_conf, status, vlm_reason, processing_time_ms)
            VALUES (NOW(), %s, %s, %s, %s, %s, %s, %s)
        """, (
            data.get("occurrence_id"),
            data.get("imei", "Desconhecido"),
            data.get("alarm_type"),
            data.get("yolo_conf", 0.0),
            data.get("status"),
            data.get("vlm_reason", ""),
            data.get("processing_time_ms", 0)
        ))
        conn.commit()
        cursor.close()
    except Exception as e:
        print(f" [TS_DB ERROR] Failed to log event: {e}")
    finally:
        conn.close()

def get_recent_events(limit=50):
    conn = get_connection()
    if not conn:
        return []
    try:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute("""
            SELECT time as timestamp, occurrence_id, imei, alarm_type, yolo_conf, status, vlm_reason, processing_time_ms
            FROM events_log
            ORDER BY time DESC
            LIMIT %s
        """, (limit,))
        
        results = cursor.fetchall()
        
        formatted_results = []
        for r in results:
            item = dict(r)
            if item["timestamp"]:
                item["timestamp"] = item["timestamp"].strftime("%d/%m/%Y %H:%M:%S")
            formatted_results.append(item)
            
        return formatted_results
    except Exception as e:
        print(f" [TS_DB ERROR] Failed to get events: {e}")
        return []
    finally:
        if conn:
            cursor.close()
            conn.close()

def get_stats():
    conn = get_connection()
    if not conn:
        return {"total": 0, "valid": 0, "invalid": 0, "avg_time_ms": 0}
    try:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute("""
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN status = 'valid' THEN 1 ELSE 0 END) as valid,
                SUM(CASE WHEN status != 'valid' THEN 1 ELSE 0 END) as invalid,
                COALESCE(AVG(processing_time_ms), 0) as avg_time_ms
            FROM events_log
        """)
        row = cursor.fetchone()
        return {
            "total": row["total"] or 0,
            "valid": row["valid"] or 0,
            "invalid": row["invalid"] or 0,
            "avg_time_ms": round(row["avg_time_ms"] or 0, 2)
        }
    except Exception as e:
        print(f" [TS_DB ERROR] Failed to get stats: {e}")
        return {"total": 0, "valid": 0, "invalid": 0, "avg_time_ms": 0}
    finally:
        if conn:
            cursor.close()
            conn.close()

def get_all_permissions():
    conn = get_connection()
    if not conn:
        return {}
    try:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute("SELECT imei, use_yolo, use_vlm, allowed_models FROM imei_permissions")
        rows = cursor.fetchall()
        perms = {}
        for r in rows:
            perms[r['imei']] = {
                "use_yolo": r['use_yolo'],
                "use_vlm": r['use_vlm'],
                "allowed_models": r['allowed_models'] if isinstance(r['allowed_models'], list) else json.loads(r['allowed_models'])
            }
        return perms
    except Exception as e:
        print(f" [TS_DB ERROR] Failed to get permissions: {e}")
        return {}
    finally:
        if conn:
            cursor.close()
            conn.close()

def save_permissions(data):
    conn = get_connection()
    if not conn:
        return
    try:
        cursor = conn.cursor()
        
        # Sync: first delete those not in data (except GLOBAL_DEFAULT if it's there)
        imeis = list(data.keys())
        if imeis:
            cursor.execute("DELETE FROM imei_permissions WHERE imei != ALL(%s)", (imeis,))
        else:
            cursor.execute("DELETE FROM imei_permissions")

        # Insert or update
        for imei, conf in data.items():
            cursor.execute("""
                INSERT INTO imei_permissions (imei, use_yolo, use_vlm, allowed_models, updated_at)
                VALUES (%s, %s, %s, %s::jsonb, NOW())
                ON CONFLICT (imei) DO UPDATE 
                SET use_yolo = EXCLUDED.use_yolo,
                    use_vlm = EXCLUDED.use_vlm,
                    allowed_models = EXCLUDED.allowed_models,
                    updated_at = NOW();
            """, (
                imei, 
                conf.get("use_yolo", True), 
                conf.get("use_vlm", False), 
                json.dumps(conf.get("allowed_models", []))
            ))
            
        conn.commit()
        cursor.close()
    except Exception as e:
        print(f" [TS_DB ERROR] Failed to save permissions: {e}")
    finally:
        if conn:
            conn.close()
