# Bài 4 — Viết Dockerfile

> Bài 3 dùng image người khác làm sẵn. Bài này bạn **tự đóng gói ứng dụng của mình**.

---

## 1. Dockerfile là gì?

Một file văn bản tên đúng `Dockerfile` (không đuôi), liệt kê các bước xây image — như công thức nấu ăn.

```
Dockerfile  ──docker build──▶  Image  ──docker run──▶  Container
```

---

## 2. Các chỉ thị cần biết

| Chỉ thị | Công dụng | Ví dụ |
|---------|-----------|-------|
| `FROM` | Image nền để bắt đầu. **Luôn là dòng đầu** | `FROM python:3.12-slim` |
| `WORKDIR` | Đặt thư mục làm việc (tự tạo nếu chưa có) | `WORKDIR /app` |
| `COPY` | Chép file từ máy vào image | `COPY requirements.txt .` |
| `RUN` | Chạy lệnh **lúc build** | `RUN pip install -r requirements.txt` |
| `ENV` | Đặt biến môi trường | `ENV APP_ENV=production` |
| `EXPOSE` | Khai báo cổng app dùng (chỉ là tài liệu) | `EXPOSE 8000` |
| `USER` | Đổi user chạy app | `USER appuser` |
| `HEALTHCHECK` | Cách Docker kiểm tra app còn sống | xem bên dưới |
| `CMD` | Lệnh chạy **khi container khởi động** | `CMD ["uvicorn", "main:app"]` |
| `ENTRYPOINT` | Giống CMD nhưng khó ghi đè hơn | |

### `RUN` khác `CMD` chỗ nào — câu hỏi hay bị nhầm nhất

- **`RUN`** chạy **lúc build image**, kết quả được lưu vào image. Chạy 1 lần.
- **`CMD`** chạy **lúc container khởi động**. Chạy mỗi lần `docker run`.

Một Dockerfile có thể có nhiều `RUN`, nhưng **chỉ `CMD` cuối cùng có tác dụng**.

### `EXPOSE` không mở cổng

`EXPOSE 8000` chỉ là ghi chú cho người đọc. Muốn truy cập được từ ngoài **vẫn phải** `-p 8000:8000` lúc `docker run`.

---

## 3. Dockerfile đầu tiên cho app FastAPI

App demo nằm ở [`tai-nguyen/app-demo/`](../tai-nguyen/app-demo/):

```
app-demo/
├── main.py            # FastAPI app
├── requirements.txt   # thư viện
├── Dockerfile
└── .dockerignore
```

Bản đơn giản nhất, hiểu từng dòng:

```dockerfile
# 1. Bắt đầu từ image Python chính thức, bản slim cho nhẹ
FROM python:3.12-slim

# 2. Mọi lệnh sau chạy trong /app bên trong container
WORKDIR /app

# 3. Copy danh sách thư viện TRƯỚC (lý do ở Bài 9 — cực quan trọng)
COPY requirements.txt .

# 4. Cài thư viện. --no-cache-dir để pip không giữ file tạm, image nhẹ hơn
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy toàn bộ code vào
COPY . .

# 6. Ghi chú: app dùng cổng 8000
EXPOSE 8000

# 7. Lệnh chạy khi container khởi động
#    --host 0.0.0.0 BẮT BUỘC, xem mục 6 bên dưới
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## 4. Build và chạy

```bash
cd tai-nguyen/app-demo

# Build image, đặt tên app-demo, tag 1.0. Dấu chấm = build context là thư mục hiện tại
docker build -t app-demo:1.0 .

docker images app-demo

docker run -d -p 8000:8000 --name app app-demo:1.0

curl http://localhost:8000/
```

Kết quả thật:

```json
{"message":"Xin chào từ trong container!","hostname":"8e8fc53b9171","moi_truong":"chua-dat"}
```

`hostname` chính là **ID container** — bằng chứng code đang chạy bên trong container chứ không phải trên máy bạn.

---

## 5. `.dockerignore` — đừng bỏ qua

Giống `.gitignore` nhưng cho `docker build`. Không có nó, Docker gửi **toàn bộ** thư mục (kể cả `.git/`, `.venv/`, `node_modules/`) tới daemon → build chậm, image phình, và **có thể lộ file `.env`**.

```
__pycache__/
*.pyc
.venv/
.env
.env.*
.git/
.pytest_cache/
*.md
```

> ⚠️ Bảo mật: nếu `.env` chứa mật khẩu và bạn `COPY . .` mà không có `.dockerignore`,
> mật khẩu sẽ **nằm vĩnh viễn trong image**. Ai `docker pull` image đó đều đọc được.

---

## 6. Ba lỗi kinh điển của người mới

### Lỗi 1 — Quên `--host 0.0.0.0`

```dockerfile
CMD ["uvicorn", "main:app", "--port", "8000"]        # ❌
```

Mặc định uvicorn chỉ nghe `127.0.0.1` — tức "chỉ chính container này". Từ ngoài không vào được, dù `docker ps` báo container vẫn chạy bình thường.

Đây là kết quả chạy thật khi thiếu cờ này:

```bash
$ curl http://localhost:8877/
                               # ← rỗng, không có gì trả về

$ docker logs test-host | tail -2
INFO:     Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:8000     # ← thủ phạm nằm ở đây
```

Container "khoẻ", log không có chữ ERROR nào, nhưng không ai gọi được. **Mẹo chẩn đoán: luôn đọc dòng `Running on ...` trong log.** Thấy `127.0.0.1` là sai, phải là `0.0.0.0`.

```dockerfile
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]   # ✅
```

Áp dụng cho mọi framework: Flask, Django, Node/Express đều cần bind `0.0.0.0`.

### Lỗi 2 — `COPY . .` trước khi cài thư viện

```dockerfile
COPY . .                                       # ❌
RUN pip install --no-cache-dir -r requirements.txt
```

Sửa một dòng code là Docker phải cài lại **toàn bộ** thư viện. Đo thật ở Bài 9: **1 giây** so với **21 giây**.

### Lỗi 3 — Chạy bằng root

Mặc định container chạy bằng `root`. Kẻ tấn công chiếm được app là có quyền root trong container.

```dockerfile
RUN useradd --create-home --shell /bin/bash appuser
COPY --chown=appuser:appuser . .
USER appuser
```

Kiểm chứng:

```bash
docker exec app whoami     # phải in ra "appuser", không phải "root"
```

---

## 7. Chọn image nền

Số đo thật trên máy giảng viên (`docker images python`):

| Image nền | Kích thước | Khi nào dùng |
|-----------|-----------|--------------|
| `python:3.12` | **1.62 GB** | Cần nhiều công cụ hệ thống — hiếm khi thật sự cần |
| `python:3.12-slim` | **205 MB** | **Mặc định nên chọn** |
| `python:3.12-alpine` | **79.5 MB** | Nhẹ nhất, nhưng dùng musl thay glibc — nhiều thư viện Python không có wheel dựng sẵn cho musl, phải biên dịch: build lâu và hay lỗi |

> Với Python, **`slim` gần như luôn là lựa chọn đúng**. `alpine` nghe hấp dẫn vì nhẹ,
> nhưng thường khiến build lâu hơn và phát sinh lỗi khó chịu với `psycopg2`, `numpy`, `pandas`.

---

## 8. Bài tập

1. Sửa `main.py`, thêm endpoint `/gioi-thieu` trả về tên bạn.
2. Build lại: `docker build -t app-demo:1.1 .`
3. Chạy song song cả 2 phiên bản trên 2 cổng khác nhau, so sánh kết quả:
   ```bash
   docker run -d -p 8000:8000 --name v10 app-demo:1.0
   docker run -d -p 8001:8000 --name v11 app-demo:1.1
   curl http://localhost:8000/gioi-thieu    # 404
   curl http://localhost:8001/gioi-thieu    # ra tên bạn
   ```
4. Xoá `.dockerignore` rồi build lại, quan sát dòng `transferring context` thay đổi thế nào.
5. Bỏ dòng `USER appuser`, build lại, chạy `docker exec ... whoami` để thấy khác biệt.
