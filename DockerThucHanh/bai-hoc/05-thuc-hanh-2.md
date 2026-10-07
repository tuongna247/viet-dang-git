# Bài Thực Hành số 2 — Tự đóng gói ứng dụng

> **Thời lượng**: 45 phút · **Mục tiêu**: tự viết Dockerfile từ đầu, build, chạy, và sửa 3 lỗi kinh điển.

---

## Phần A — Build app demo

```bash
cd ~/Desktop/Projects/DockerThucHanh/tai-nguyen/app-demo
ls -a                     # main.py, requirements.txt, Dockerfile, .dockerignore

docker build -t app-demo:1.0 .
```

Đọc kỹ output — Docker in ra từng bước theo đúng thứ tự trong Dockerfile.

```bash
docker images app-demo
docker run -d -p 8000:8000 --name app -e APP_ENV=hoc-docker app-demo:1.0

curl http://localhost:8000/
curl http://localhost:8000/health
```

Kết quả mong đợi:

```json
{"message":"Xin chào từ trong container!","hostname":"8e8fc53b9171","moi_truong":"hoc-docker"}
{"status":"ok"}
```

### Kiểm tra các điểm tốt của Dockerfile

```bash
docker exec app whoami                                  # appuser, KHÔNG phải root
docker inspect app --format '{{.State.Health.Status}}'  # healthy
docker ps --format "table {{.Names}}\t{{.Status}}"      # Up ... (healthy)
```

---

## Phần B — Tự viết Dockerfile từ số 0

Xoá Dockerfile đi và viết lại bằng trí nhớ. Đây là phần học thật sự.

```bash
mkdir -p ~/docker-tu-viet && cd ~/docker-tu-viet

cat > app.py <<'PY'
from fastapi import FastAPI
app = FastAPI()

@app.get("/")
def root():
    return {"tac_gia": "Nguyen Van A", "bai": "thuc hanh so 2"}
PY

cat > requirements.txt <<'REQ'
fastapi==0.115.6
uvicorn[standard]==0.34.0
REQ
```

Giờ tự viết `Dockerfile`. Yêu cầu bắt buộc:

- [ ] Dùng image nền `python:3.12-slim`
- [ ] Thư mục làm việc `/app`
- [ ] Copy `requirements.txt` **trước**, cài thư viện, **rồi** mới copy code
- [ ] Tạo user thường và `USER` sang user đó
- [ ] `EXPOSE 8000`
- [ ] `CMD` chạy uvicorn với `--host 0.0.0.0`
- [ ] Có `.dockerignore`

<details>
<summary>Đáp án — chỉ mở sau khi đã tự làm</summary>

```dockerfile
FROM python:3.12-slim

RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

`.dockerignore`:
```
__pycache__/
*.pyc
.venv/
.env
.git/
```
</details>

```bash
docker build -t app-tu-viet:1.0 .
docker run -d -p 8010:8000 --name tu-viet app-tu-viet:1.0
curl http://localhost:8010/
docker exec tu-viet whoami
```

---

## Phần C — Gây ra 3 lỗi kinh điển rồi tự sửa

Mục đích: khi gặp ngoài đời, bạn nhận ra ngay thay vì mất nửa buổi mò mẫm.

### Lỗi 1 — Quên `--host 0.0.0.0`

```bash
docker run -d -p 8011:8000 --name loi1 app-tu-viet:1.0 \
  uvicorn app:app --port 8000

sleep 3
curl --max-time 5 http://localhost:8011/     # ← RỖNG, không trả về gì
docker ps --filter name=loi1                 # nhưng container vẫn "Up"!
docker logs loi1 | tail -2
```

Log:
```
INFO:     Uvicorn running on http://127.0.0.1:8000
```

**Dấu hiệu nhận biết**: container `Up`, log không có ERROR, nhưng gọi không được → nhìn dòng `Running on`, thấy `127.0.0.1` là sai.

```bash
docker rm -f loi1
```

### Lỗi 2 — Nhầm thứ tự cổng

```bash
docker run -d -p 8000:8012 --name loi2 app-tu-viet:1.0   # ❌ ngược
sleep 2
curl --max-time 5 http://localhost:8012/                  # không vào được
docker rm -f loi2
```

Nhớ: **`-p MÁY_BẠN:CONTAINER`**. Vế phải phải khớp cổng app thật sự lắng nghe.

### Lỗi 3 — Sai thứ tự layer

```bash
cat > Dockerfile.sai <<'DF'
FROM python:3.12-slim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
DF

docker build -f Dockerfile.sai -t app-sai:1.0 .

# Sửa 1 dòng code rồi build lại cả hai, bấm giờ
echo "# them mot dong" >> app.py

time docker build -t app-tu-viet:1.0 .           # bản ĐÚNG
echo "# them dong nua" >> app.py
time docker build -f Dockerfile.sai -t app-sai:1.0 .   # bản SAI
```

Số đo thật trên máy giảng viên: **1 giây** so với **21 giây**. Trên dự án thật với hàng trăm thư viện, khác biệt là vài giây so với vài phút — nhân với số lần build mỗi ngày.

---

## Phần D — Dọn dẹp

```bash
docker rm -f app tu-viet 2>/dev/null
docker rmi app-tu-viet:1.0 app-sai:1.0 2>/dev/null
docker system df
```

---

## Tiêu chí hoàn thành

- [ ] Build và chạy được app demo
- [ ] `docker exec ... whoami` trả về `appuser`, không phải `root`
- [ ] Healthcheck báo `healthy`
- [ ] **Tự viết** được Dockerfile từ đầu, không copy đáp án
- [ ] Gây ra và giải thích được cả 3 lỗi kinh điển
- [ ] Đo được chênh lệch thời gian build giữa đúng và sai thứ tự layer

## Câu hỏi

1. `RUN` và `CMD` chạy ở thời điểm nào? Khác nhau ra sao?
2. `EXPOSE 8000` có mở cổng cho bên ngoài truy cập không?
3. Vì sao phải copy `requirements.txt` trước `COPY . .`?
4. Container `Up` nhưng `curl` không ra gì — kiểm tra đầu tiên là gì?
