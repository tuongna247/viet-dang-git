# Dockerfile cho app demo — giải thích từng dòng: bai-hoc/04-dockerfile.md
# Phần tối ưu: bai-hoc/09-toi-uu-image.md

FROM python:3.12-slim

# Thư viện hệ thống cần lúc CHẠY (libpq5 cho psycopg2, curl cho healthcheck)
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq5 curl \
    && rm -rf /var/lib/apt/lists/*

# Không chạy container bằng root
RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

# ⚠️ THỨ TỰ QUAN TRỌNG: copy requirements.txt TRƯỚC, cài thư viện, RỒI mới copy code.
# Nhờ vậy sửa code không làm Docker cài lại toàn bộ thư viện (xem Bài 9).
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
