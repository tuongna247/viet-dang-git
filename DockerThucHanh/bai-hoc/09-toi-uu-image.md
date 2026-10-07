# Bài 9 — Tối ưu image

> Bài này dựa trên **số đo thật** trên máy giảng viên (Docker 29.6.2, Apple Silicon), không phải lý thuyết.

---

## 1. Nguyên tắc đầu tiên: ĐO, đừng đoán

Nhiều hướng dẫn trên mạng nói "cứ dùng multi-stage là image nhỏ đi". **Không phải lúc nào cũng đúng.**

Đây là kết quả đo thật với chính app demo của khoá học:

| Dockerfile | Kích thước |
|-----------|-----------|
| 1 tầng, đơn giản | **285 MB** |
| Multi-stage (builder + runtime) | **292 MB** ← *lớn hơn!* |

**Vì sao multi-stage lại to hơn?** App này dùng `psycopg2-binary` — gói đã có sẵn wheel dựng sẵn, **không cần trình biên dịch**. Nên tầng builder chẳng tiết kiệm được gì, trong khi tầng runtime lại phải cài thêm `libpq5` và `curl`.

**Bài học**: multi-stage chỉ có ích khi build **thật sự cần công cụ mà lúc chạy không cần** — trình biên dịch Go/Rust/Java, `gcc` cho thư viện C, `node_modules` dev-only. Với Python dùng wheel dựng sẵn, nó không giúp gì.

Lệnh để tự đo:

```bash
docker images ten-image --format "{{.Tag}}\t{{.Size}}"
docker history ten-image:tag        # xem tầng nào nặng nhất
```

---

## 2. Thứ THỰC SỰ quan trọng: layer cache

Đây mới là tối ưu đáng giá nhất hằng ngày.

### Cơ chế

Mỗi chỉ thị trong Dockerfile tạo một **tầng (layer)**. Docker cache lại từng tầng. Khi build lại, nó **dùng cache tới tầng đầu tiên bị thay đổi**, rồi build lại **tất cả tầng phía sau**.

Nên: **thứ ít thay đổi để lên trên, thứ hay thay đổi để xuống dưới.**

Code thay đổi mỗi ngày. Danh sách thư viện thì hàng tháng mới đổi một lần.

### ❌ Sai

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY . .                                        # code đổi → tầng này vỡ cache
RUN pip install --no-cache-dir -r requirements.txt   # → phải cài lại TOÀN BỘ thư viện
```

### ✅ Đúng

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .                          # chỉ đổi khi thêm thư viện
RUN pip install --no-cache-dir -r requirements.txt   # cache giữ được
COPY . .                                         # code đổi chỉ vỡ tầng cuối
```

### Số đo thật — sửa 1 dòng code rồi build lại

| Dockerfile | Thời gian rebuild |
|-----------|-------------------|
| Đúng thứ tự | **1 giây** |
| Sai thứ tự | **21 giây** |

Chênh **21 lần**. Trên dự án thật hàng trăm thư viện, đó là khác biệt giữa vài giây và vài phút — nhân với số lần build mỗi ngày, mỗi người, và mỗi lần chạy CI.

Tự đo:

```bash
cd tai-nguyen/app-demo
echo "# thay doi nho" >> main.py
time docker build -t thu:dung .
echo "# thay doi nua" >> main.py
time docker build -f Dockerfile.sai-thu-tu -t thu:sai .
```

---

## 3. `.dockerignore`

Không có nó, `docker build` gửi **toàn bộ** thư mục tới daemon — kể cả `.git/` (thường hàng trăm MB), `.venv/`, `node_modules/`.

```
__pycache__/
*.pyc
.venv/
venv/
.env
.env.*
.git/
.pytest_cache/
.vscode/
.idea/
*.md
Dockerfile
docker-compose*.yml
```

### Số đo thật

Thử với thư mục app-demo có thêm một `.venv` nặng 120 MB (rất bình thường ở dự án Python):

| | Build context gửi đi | Kích thước image |
|---|---|---|
| **Có** `.dockerignore` | **367 B** | **305 MB** |
| **Không** có | **125.87 MB** | **557 MB** |

Không chỉ chậm — cái `.venv` bị **nướng thẳng vào image**, làm image phình thêm 252 MB
mà chẳng để làm gì (thư viện đã được `pip install` riêng bên trong rồi).

Lệnh tự đo — nhìn dòng `transferring context` ở đầu output:

```bash
docker build -t thu:co .
mv .dockerignore .dockerignore.tam
docker build -t thu:khong .
mv .dockerignore.tam .dockerignore
docker images thu --format "{{.Tag}}\t{{.Size}}"
```

> 🔒 **Đây còn là vấn đề bảo mật.** `COPY . .` không có `.dockerignore` sẽ nhét `.env`
> chứa mật khẩu vào image. Ai `docker pull` image đó đều đọc được, kể cả khi bạn xoá file sau đó —
> vì nó nằm trong tầng cũ của image.

Kiểm tra image có lỡ chứa secret không:

```bash
docker run --rm ten-image:tag sh -c "ls -la /app | grep -i env"
docker history --no-trunc ten-image:tag | grep -i -E "password|secret|key"
```

---

## 4. Không chạy bằng root

Mặc định container chạy `root`. Kẻ tấn công chiếm được app là có quyền root bên trong container — và nếu container cấu hình lỏng lẻo thì có đường thoát ra máy chủ.

```dockerfile
RUN useradd --create-home --shell /bin/bash appuser
COPY --chown=appuser:appuser . .
USER appuser
```

Kiểm chứng:

```bash
docker run --rm app-demo:1.0 whoami      # appuser  ✅
docker run --rm app-demo:sai whoami      # root     ❌
```

---

## 5. Healthcheck

Không có healthcheck, Docker chỉ biết "tiến trình còn sống". App treo, không trả lời request nào, Docker vẫn báo `Up`.

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
```

| Tham số | Ý nghĩa |
|---------|---------|
| `--interval` | Bao lâu kiểm tra một lần |
| `--timeout` | Chờ tối đa bao lâu cho mỗi lần kiểm tra |
| `--start-period` | Thời gian ân hạn lúc khởi động, chưa tính là thất bại |
| `--retries` | Thất bại liên tiếp bao nhiêu lần thì báo `unhealthy` |

```bash
docker ps                                            # cột STATUS hiện (healthy)
docker inspect app --format '{{.State.Health.Status}}'
docker inspect app --format '{{json .State.Health}}' | python3 -m json.tool
```

Giá trị thật của nó là ở Compose: `depends_on: condition: service_healthy` chỉ hoạt động khi có healthcheck.

---

## 6. Gộp lệnh `RUN` và dọn cache trong cùng một tầng

```dockerfile
# ❌ 3 tầng, cache apt nằm lại trong image
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# ✅ 1 tầng, cache bị xoá TRƯỚC khi tầng được đóng lại
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/*
```

Điểm mấu chốt: **xoá file ở tầng sau không làm image nhỏ đi**, vì tầng trước vẫn còn nguyên trong lịch sử image. Phải xoá **trong cùng tầng đã tạo ra nó**.

Tương tự với pip: dùng `--no-cache-dir`.

---

## 7. Ghim phiên bản

```dockerfile
FROM python:3.12-slim        # ✅ biết chắc chạy bản nào
FROM python:latest           # ❌ hôm nay 3.12, tháng sau 3.14, code gãy mà không hiểu vì sao
```

Tương tự trong `requirements.txt`:

```
fastapi==0.115.6      # ✅
fastapi              # ❌
```

---

## 8. Checklist tối ưu

| # | Việc | Lợi ích |
|---|------|---------|
| 1 | `.dockerignore` đầy đủ | Build nhanh, **không lộ secret** |
| 2 | `COPY requirements.txt` trước `COPY . .` | Rebuild **21 lần** nhanh hơn |
| 3 | Image nền `-slim` | **1.62 GB → 205 MB**, tiết kiệm ~1.4 GB |
| 4 | `pip install --no-cache-dir` | Bớt vài chục MB |
| 5 | Gộp `RUN` + `rm -rf /var/lib/apt/lists/*` | Bớt ~40 MB |
| 6 | `USER appuser` | Bảo mật |
| 7 | `HEALTHCHECK` | Phát hiện app treo, cần cho `depends_on` |
| 8 | Ghim phiên bản, không dùng `latest` | Chạy giống nhau, tránh gãy bất ngờ |
| 9 | Multi-stage | **Chỉ khi** build cần công cụ mà chạy không cần — hãy đo trước |

---

## 9. Bài tập

1. Đo image demo: `docker images app-demo` và `docker history app-demo:1.0`. Tầng nào nặng nhất?
2. Bỏ `.dockerignore`, build lại, so sánh dòng `transferring context`.
3. Đổi `python:3.12-slim` sang `python:3.12`, build lại, so sánh kích thước.
4. Tự đo lại con số 1 giây / 21 giây trên máy mình.
5. Bỏ `USER appuser`, build lại, chạy `whoami` để thấy khác biệt.
6. Thử `python:3.12-alpine` — có build được không? Nếu lỗi, lỗi ở gói nào? (Gợi ý: xem lại Bài 4 mục 7.)
