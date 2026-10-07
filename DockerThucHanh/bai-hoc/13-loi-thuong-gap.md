# Bài 13 — Lỗi thường gặp và cách xử lý

> Bảo học viên mở file này **trước khi** hỏi. Khoảng 90% sự cố nằm ở đây.

---

## 1. `Cannot connect to the Docker daemon`

```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock.
Is the docker daemon running?
```

Docker chưa chạy.

| Hệ điều hành | Xử lý |
|---|---|
| macOS / Windows | Mở ứng dụng **Docker Desktop**, đợi biểu tượng cá voi ngừng nhấp nháy |
| Linux | `sudo systemctl start docker` |

---

## 2. `permission denied ... docker.sock` (Linux)

```bash
sudo usermod -aG docker $USER
# ĐĂNG XUẤT rồi đăng nhập lại — bắt buộc, nhóm mới có hiệu lực
```

Đừng dùng `sudo docker` để né — sẽ sinh ra file thuộc root, rắc rối về sau.

---

## 3. `port is already allocated`

```
Bind for 0.0.0.0:8000 failed: port is already allocated
```

```bash
docker ps --filter publish=8000        # container nào đang chiếm
lsof -i :8000                          # hoặc tiến trình ngoài Docker
```

Xử lý: đổi sang cổng khác (`-p 8001:8000`), hoặc dừng cái đang chiếm.

---

## 4. Container `Up` nhưng gọi không được

**Lỗi phổ biến nhất của khoá học.** Kiểm tra theo thứ tự:

```bash
# 1. App bind vào đâu?
docker logs ten-container | grep -i "running on"
```

| Log ghi | Kết luận |
|---|---|
| `Running on http://127.0.0.1:8000` | ❌ Sai — thêm `--host 0.0.0.0` |
| `Running on http://0.0.0.0:8000` | ✅ Đúng |

```bash
# 2. Ánh xạ cổng đúng chưa?
docker port ten-container
```

Nhớ: `-p MÁY_BẠN:CONTAINER`. Vế phải phải khớp cổng app thật sự nghe.

```bash
# 3. Thử từ BÊN TRONG container
docker exec ten-container curl -s localhost:8000/health
```

Trong container gọi được mà ngoài không → vấn đề ở `-p` hoặc `--host`.

---

## 5. Container khởi động rồi tắt ngay

```bash
docker ps -a                       # STATUS: Exited (1) 2 seconds ago
docker logs ten-container          # LUÔN xem log trước
docker inspect ten-container --format '{{.State.ExitCode}}'
```

| Exit code | Nghĩa là |
|---|---|
| `0` | Chạy xong bình thường (lệnh kết thúc, không phải service chạy dài) |
| `1` | Lỗi ứng dụng — đọc log |
| `125` | Lệnh `docker run` sai cú pháp |
| `126` | Lệnh không chạy được (thiếu quyền thực thi) |
| `127` | Không tìm thấy lệnh — sai đường dẫn hoặc thiếu gói |
| `137` | Bị `kill -9`, **thường là hết RAM (OOM)** |
| `143` | Bị `docker stop` bình thường |

Với `137`, tăng giới hạn RAM hoặc tìm chỗ rò rỉ bộ nhớ:

```bash
docker inspect ten-container --format '{{.State.OOMKilled}}'
```

Debug bằng cách bỏ qua `CMD`:

```bash
docker run -it --entrypoint sh ten-image:tag
```

---

## 6. `no such file or directory` khi build

```
COPY failed: file not found in build context
```

Nguyên nhân thường gặp:

1. **Sai build context**: `docker build -t ten .` — dấu chấm là thư mục gốc. `COPY` chỉ lấy được file **bên trong** thư mục đó, **không** lên được thư mục cha (`COPY ../file .` luôn lỗi).
2. **File bị `.dockerignore` loại**: kiểm tra lại file đó có bị chặn không.

---

## 7. App không kết nối được database

```
could not translate host name "localhost" to address
```

| Sai | Đúng | Vì sao |
|---|---|---|
| `DB_HOST=localhost` | `DB_HOST=db` | `localhost` trong container = **chính container đó** |
| `DB_HOST=127.0.0.1` | `DB_HOST=db` | như trên |
| `DB_PORT=5433` (cổng publish) | `DB_PORT=5432` | container gọi nhau dùng **cổng gốc**, không qua `-p` |

```bash
docker network ls
docker network inspect ten-network       # cả 2 container có cùng network không?
docker compose exec app getent hosts db  # phân giải được tên không?
```

---

## 8. App khởi động trước khi database sẵn sàng

```
connection refused ... FATAL: the database system is starting up
```

```yaml
depends_on:
  - db                          # ❌ chỉ đợi container chạy
```

```yaml
depends_on:
  db:
    condition: service_healthy  # ✅ đợi healthcheck báo healthy
```

Yêu cầu service `db` phải có khai báo `healthcheck`.

---

## 9. Đổi mật khẩu trong `.env` mà vẫn báo sai mật khẩu

```
FATAL:  password authentication failed for user "appuser"
```

PostgreSQL chỉ đọc `POSTGRES_PASSWORD` **lần đầu tiên khởi tạo database**. Volume đã lưu mật khẩu cũ, đổi biến môi trường không đổi được nó.

```bash
docker compose down -v      # ⚠️ XOÁ volume, mất dữ liệu
docker compose up -d
```

Muốn giữ dữ liệu, đổi mật khẩu bằng SQL:

```bash
docker compose exec db psql -U appuser -d appdb -c "ALTER USER appuser WITH PASSWORD 'matkhau-moi';"
```

---

## 10. Hết dung lượng ổ cứng

```
no space left on device
```

```bash
docker system df                 # xem cái gì chiếm chỗ
docker system prune              # dọn container/network/image rác
docker image prune -a            # xoá image không dùng
docker builder prune             # xoá cache build (thường rất lớn)

docker system prune -a --volumes # ⚠️⚠️ XOÁ CẢ VOLUME — MẤT DATABASE
```

Trên server, thủ phạm thường là **log không giới hạn** — xem Bài 12 mục 2.

---

## 11. Build chậm bất thường

| Nguyên nhân | Xử lý |
|---|---|
| Thiếu `.dockerignore` | Thêm vào — đo thật: 125.87MB → 367B build context |
| `COPY . .` trước `pip install` | Đảo thứ tự — đo thật: 21 giây → 1 giây |
| Không có cache trong CI | Thêm `cache-from/to: type=gha` |

---

## 12. `exec format error`

```
exec /usr/local/bin/uvicorn: exec format error
```

Image build cho kiến trúc khác (build trên Mac Apple Silicon `arm64`, chạy trên server `amd64`).

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t ten:tag --push .
```

Hoặc build đúng một kiến trúc đích:

```bash
docker build --platform linux/amd64 -t ten:tag .
```

---

## 13. Lệnh chẩn đoán vạn năng

Gặp sự cố không rõ, chạy theo thứ tự này:

```bash
docker ps -a                                       # 1. Còn chạy không? Exit code bao nhiêu?
docker logs --tail 50 ten-container                # 2. Log nói gì?
docker inspect ten-container --format '{{.State.Status}} {{.State.ExitCode}}'
docker exec -it ten-container sh                   # 3. Chui vào xem tận nơi
docker port ten-container                          # 4. Cổng ánh xạ đúng chưa?
docker network inspect ten-network                 # 5. Có cùng network không?
docker stats --no-stream                           # 6. Hết RAM chưa?
docker system df                                   # 7. Hết ổ chưa?
```

> **`docker logs` rồi `docker exec -it ... sh` giải quyết khoảng 80% sự cố.** Luôn bắt đầu từ hai lệnh này.
