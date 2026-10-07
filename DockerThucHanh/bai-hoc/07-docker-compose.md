# Bài 7 — Docker Compose

## 1. Vấn đề Compose giải quyết

Bài 6 dựng 3 container bằng tay:

```bash
docker network create mang-du-an
docker volume create du-lieu-db
docker run -d --name db --network mang-du-an -e POSTGRES_USER=... -v du-lieu-db:/var/lib/...
docker run -d --name cache --network mang-du-an redis:7-alpine
docker run -d --name app --network mang-du-an -p 8000:8000 -e DB_HOST=db -e ...
```

Năm lệnh dài, phải nhớ đúng thứ tự, gõ lại mỗi lần. Chia sẻ cho đồng nghiệp thì phải chép cả đoạn hướng dẫn.

**Compose gói tất cả vào một file YAML, chạy bằng một lệnh:**

```bash
docker compose up -d
```

Nhân viên mới vào dự án: `git clone` → `docker compose up -d` → xong. Không cài Python, không cài PostgreSQL.

---

## 2. File `docker-compose.yml`

File thật của app demo — [`tai-nguyen/app-demo/docker-compose.yml`](../tai-nguyen/app-demo/docker-compose.yml):

```yaml
services:
  app:
    build: .                    # build từ Dockerfile trong thư mục này
    ports:
      - "8000:8000"
    environment:
      APP_ENV: development
      DB_HOST: db               # gọi service "db" bằng tên
      DB_PASSWORD: ${DB_PASSWORD:?Thieu DB_PASSWORD - hay tao file .env}
      REDIS_HOST: cache
    volumes:
      - ./:/app                 # bind mount: sửa code thấy ngay
    depends_on:
      db:
        condition: service_healthy   # ĐỢI db sẵn sàng mới khởi động app
      cache:
        condition: service_started
    restart: unless-stopped
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${DB_NAME:-appdb}
      POSTGRES_USER: ${DB_USER:-appuser}
      POSTGRES_PASSWORD: ${DB_PASSWORD:?Thieu DB_PASSWORD}
    volumes:
      - du-lieu-postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-appuser} -d ${DB_NAME:-appdb}"]
      interval: 5s
      timeout: 3s
      retries: 5
    restart: unless-stopped

  cache:
    image: redis:7-alpine
    volumes:
      - du-lieu-redis:/data
    restart: unless-stopped

volumes:
  du-lieu-postgres:
  du-lieu-redis:
```

> **Compose tự tạo network** cho các service trong file, nên chúng gọi nhau bằng **tên service**
> (`db`, `cache`) mà bạn không phải khai báo gì thêm.

---

## 3. Giải thích các khoá quan trọng

| Khoá | Ý nghĩa |
|------|---------|
| `services` | Mỗi mục con là một container |
| `build: .` | Build từ Dockerfile tại thư mục này |
| `image: postgres:16-alpine` | Dùng image có sẵn thay vì build |
| `ports` | `"máy_bạn:container"` — giống `-p` |
| `environment` | Biến môi trường |
| `volumes` | Gắn dữ liệu |
| `depends_on` | Thứ tự khởi động |
| `restart: unless-stopped` | Tự chạy lại khi crash hoặc reboot máy |
| `healthcheck` | Cách kiểm tra service đã sẵn sàng |
| `command` | Ghi đè `CMD` trong Dockerfile |

### ⚠️ `depends_on` thường bị hiểu sai

```yaml
depends_on:
  - db                       # ❌ chỉ đợi container KHỞI ĐỘNG, không đợi database SẴN SÀNG
```

PostgreSQL mất vài giây khởi tạo. Container `db` đã "chạy" nhưng chưa nhận kết nối → app khởi động, kết nối thất bại, crash.

```yaml
depends_on:
  db:
    condition: service_healthy    # ✅ đợi healthcheck báo healthy mới chạy app
```

Cách này chỉ hoạt động khi service `db` **có khai báo `healthcheck`**.

### Cú pháp biến môi trường

| Cú pháp | Ý nghĩa |
|---------|---------|
| `${DB_USER}` | Lấy từ file `.env`, không có thì rỗng |
| `${DB_USER:-appuser}` | Không có thì dùng mặc định `appuser` |
| `${DB_PASSWORD:?Thieu DB_PASSWORD}` | **Bắt buộc phải có**, thiếu thì Compose báo lỗi và dừng |

Dạng thứ ba rất đáng dùng cho mật khẩu — thiếu thì hỏng ngay lúc khởi động, thay vì chạy được rồi lỗi khó hiểu về sau.

---

## 4. Các lệnh Compose

```bash
docker compose up -d              # dựng và chạy nền tất cả service
docker compose up -d --build      # build lại image trước khi chạy
docker compose ps                 # xem trạng thái
docker compose logs -f            # log tất cả service
docker compose logs -f app        # log riêng 1 service
docker compose exec app sh        # chui vào container app
docker compose restart app        # khởi động lại 1 service
docker compose stop               # dừng, KHÔNG xoá
docker compose start              # chạy lại
docker compose down               # dừng và XOÁ container + network
docker compose down -v            # ⚠️ xoá cả VOLUME — MẤT DỮ LIỆU
docker compose config             # kiểm tra file YAML có hợp lệ không
docker compose pull               # tải image mới nhất
docker compose build              # chỉ build, không chạy
```

> **Nhớ kỹ sự khác nhau:**
> `docker compose down` → xoá container, **giữ** volume (dữ liệu còn).
> `docker compose down -v` → **xoá luôn volume**, mất sạch database.

---

## 5. Chạy thử

```bash
cd ~/Desktop/Projects/DockerThucHanh/tai-nguyen/app-demo

cp .env.mau .env
# Mở .env, đổi DB_PASSWORD thành mật khẩu của bạn

docker compose up -d
docker compose ps
```

Kết quả thật:

```
SERVICE   STATUS
app       Up 8 seconds (healthy)
cache     Up 14 seconds
db        Up 14 seconds (healthy)
```

Kiểm tra:

```bash
curl http://localhost:8000/
curl http://localhost:8000/db
curl http://localhost:8000/cache
```

```json
{"ket_noi":"thanh cong","postgres":"PostgreSQL 16.15 on aarch64-unknown-linux-musl, ..."}
{"ket_noi":"thanh cong","so_luot_truy_cap":1}
```

---

## 6. Nhiều file compose — dev và production

Thay vì duy trì 2 file riêng dễ lệch nhau, dùng file **đè lên**:

```bash
# Dev — chỉ dùng file mặc định
docker compose up -d

# Production — file sau ĐÈ LÊN file trước
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

[`docker-compose.prod.yml`](../tai-nguyen/app-demo/docker-compose.prod.yml) chỉ khai báo phần **khác** với dev:

```yaml
services:
  app:
    image: ghcr.io/tuongna247/app-demo:latest
    build: null                # không build trên server, dùng image dựng sẵn
    volumes: []                # bỏ bind mount code
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4   # bỏ --reload
  db:
    ports: []                  # KHÔNG mở database ra internet
```

Chi tiết ở [Bài 12 — Triển khai](12-trien-khai-len-server.md).

---

## 7. Bài tập

1. Thêm service **pgAdmin** vào `docker-compose.yml`:
   ```yaml
     pgadmin:
       image: dpage/pgadmin4:latest
       environment:
         PGADMIN_DEFAULT_EMAIL: admin@example.com
         PGADMIN_DEFAULT_PASSWORD: ${DB_PASSWORD:?}
       ports:
         - "5050:80"
       depends_on:
         - db
   ```
   Mở http://localhost:5050, kết nối tới host `db`, port `5432`.

2. Sửa `main.py` thêm endpoint mới → tải lại trình duyệt. Vì sao **không cần build lại**?

3. Chạy `docker compose down` rồi `up -d` — dữ liệu database còn không? Vì sao?

4. Chạy `docker compose down -v` rồi `up -d` — lần này còn không? Vì sao?

5. Xoá dòng `DB_PASSWORD` trong `.env` rồi `docker compose up` — Compose báo gì?

**Câu hỏi**

1. Compose tạo network cho các service không? Chúng gọi nhau bằng gì?
2. `depends_on: - db` và `depends_on: db: condition: service_healthy` khác nhau ra sao?
3. `docker compose down` và `down -v` khác nhau chỗ nào? Cái nào nguy hiểm?
4. `${DB_PASSWORD:?...}` có tác dụng gì?
