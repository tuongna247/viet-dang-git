"""App demo cho khoá học Docker — FastAPI + PostgreSQL + Redis."""
import os
from fastapi import FastAPI

app = FastAPI(title="App Demo Docker", version="1.0.0")


@app.get("/")
def trang_chu():
    return {
        "message": "Xin chào từ trong container!",
        "hostname": os.uname().nodename,
        "moi_truong": os.getenv("APP_ENV", "chua-dat"),
    }


@app.get("/health")
def health():
    """Endpoint cho Docker healthcheck."""
    return {"status": "ok"}


@app.get("/db")
def kiem_tra_db():
    """Kiểm tra kết nối PostgreSQL — dùng ở bài Compose."""
    import psycopg2

    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST", "db"),
            port=os.getenv("DB_PORT", "5432"),
            dbname=os.getenv("DB_NAME", "appdb"),
            user=os.getenv("DB_USER", "appuser"),
            password=os.getenv("DB_PASSWORD", ""),
            connect_timeout=3,
        )
        with conn.cursor() as cur:
            cur.execute("SELECT version()")
            phien_ban = cur.fetchone()[0]
        conn.close()
        return {"ket_noi": "thanh cong", "postgres": phien_ban}
    except Exception as e:
        return {"ket_noi": "that bai", "loi": str(e)}


@app.get("/cache")
def kiem_tra_redis():
    """Đếm số lượt truy cập bằng Redis — minh hoạ dữ liệu bền vững."""
    import redis

    try:
        r = redis.Redis(host=os.getenv("REDIS_HOST", "cache"), port=6379, socket_timeout=3)
        so_lan = r.incr("so_luot_truy_cap")
        return {"ket_noi": "thanh cong", "so_luot_truy_cap": so_lan}
    except Exception as e:
        return {"ket_noi": "that bai", "loi": str(e)}
