# Bài Thực Hành số 3 — Dựng cả hệ thống bằng Compose

> **Thời lượng**: 50 phút · **Mục tiêu**: từ repo trống tới hệ thống 3 service chạy được, chỉ bằng 1 lệnh.

---

## Phần A — Khởi động toàn bộ hệ thống

```bash
cd ~/Desktop/Projects/DockerThucHanh/tai-nguyen/app-demo

# 1. Tạo file .env từ mẫu
cp .env.mau .env
# Mở .env, đổi DB_PASSWORD

# 2. Kiểm tra file YAML hợp lệ trước khi chạy
docker compose config >/dev/null && echo "YAML OK"

# 3. Dựng toàn bộ
docker compose up -d

# 4. Xem trạng thái
docker compose ps
```

Đợi tới khi cả `app` và `db` đều `(healthy)`:

```
SERVICE   STATUS
app       Up 8 seconds (healthy)
cache     Up 14 seconds
db        Up 14 seconds (healthy)
```

```bash
curl http://localhost:8000/
curl http://localhost:8000/db
curl http://localhost:8000/cache
curl http://localhost:8000/cache      # số đếm phải TĂNG
```

---

## Phần B — Quan sát Compose làm gì phía sau

```bash
docker compose ps
docker ps                        # tên container có tiền tố "app-demo-"
docker network ls | grep app-demo    # Compose tự tạo network
docker volume ls | grep app-demo     # Compose tự tạo volume
```

Compose đã tự làm hộ bạn: tạo network, tạo volume, build image, khởi động đúng thứ tự, nối các service với nhau.

Kiểm chứng DNS nội bộ:

```bash
docker compose exec app getent hosts db
docker compose exec app getent hosts cache
```

---

## Phần C — Hot reload: sửa code thấy ngay

```bash
# Thêm endpoint mới vào main.py
cat >> main.py <<'PY'


@app.get("/gioi-thieu")
def gioi_thieu():
    return {"ho_ten": "Nguyen Van A", "nam_sinh": 1995, "khoa": "Docker"}
PY

# KHÔNG build lại, KHÔNG restart
curl http://localhost:8000/gioi-thieu
```

Có kết quả ngay. Hai thứ phối hợp làm được điều này:

- `volumes: - ./:/app` — bind mount code từ máy vào container
- `command: uvicorn ... --reload` — uvicorn tự nạp lại khi file đổi

```bash
docker compose logs app | tail -5     # thấy dòng "Reloading..."
```

> ⚠️ Đây là cấu hình **dev**. Trên production **không** dùng bind mount và **không** bật `--reload`.

---

## Phần D — Dữ liệu sống sót tới đâu?

Làm đúng thứ tự và ghi lại kết quả từng bước.

```bash
# 1. Ghi dữ liệu
docker compose exec db psql -U appuser -d appdb -c \
  "CREATE TABLE hoc_vien (id SERIAL PRIMARY KEY, ho_ten TEXT);
   INSERT INTO hoc_vien (ho_ten) VALUES ('Nguyen Van A'), ('Tran Thi B');"

docker compose exec db psql -U appuser -d appdb -c "SELECT * FROM hoc_vien;"
curl http://localhost:8000/cache      # ghi nhớ số đếm Redis

# 2. THỬ 1: restart
docker compose restart
docker compose exec db psql -U appuser -d appdb -c "SELECT * FROM hoc_vien;"
#    → CÒN dữ liệu

# 3. THỬ 2: down rồi up (xoá container, GIỮ volume)
docker compose down
docker compose up -d
sleep 8
docker compose exec db psql -U appuser -d appdb -c "SELECT * FROM hoc_vien;"
#    → VẪN CÒN, vì volume không bị xoá

# 4. THỬ 3: down -v (xoá cả volume)
docker compose down -v
docker compose up -d
sleep 8
docker compose exec db psql -U appuser -d appdb -c "SELECT * FROM hoc_vien;"
#    → ERROR: relation "hoc_vien" does not exist — MẤT SẠCH
```

**Ghi vào sổ:** `down` an toàn, `down -v` xoá dữ liệu. Trên server production, gõ nhầm `-v` là mất database.

---

## Phần E — Đọc log khi có sự cố

```bash
docker compose logs                  # tất cả
docker compose logs -f app           # theo dõi trực tiếp 1 service
docker compose logs --tail 20 db
docker compose logs --since 5m
```

Gây lỗi cố ý để tập chẩn đoán:

```bash
# Sửa .env, đổi DB_PASSWORD thành mật khẩu sai
sed -i '' 's/^DB_PASSWORD=.*/DB_PASSWORD=mat-khau-sai/' .env
docker compose up -d
curl http://localhost:8000/db
```

Kết quả:

```json
{"ket_noi":"that bai","loi":"connection to server ... FATAL:  password authentication failed"}
```

> Chú ý: đổi mật khẩu trong `.env` **không** đổi mật khẩu database đã tạo — volume đã lưu mật khẩu cũ.
> Muốn đổi thật phải `docker compose down -v` để tạo lại database từ đầu.

Khôi phục:

```bash
cp .env.mau .env
# đổi lại DB_PASSWORD như ban đầu
docker compose down -v && docker compose up -d
```

---

## Phần F — Thêm một service mới

Thêm pgAdmin vào `docker-compose.yml`:

```yaml
  pgadmin:
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@example.com
      PGADMIN_DEFAULT_PASSWORD: ${DB_PASSWORD:?}
      PGADMIN_CONFIG_SERVER_MODE: "False"
    ports:
      - "5050:80"
    depends_on:
      - db
    restart: unless-stopped
```

```bash
docker compose up -d          # chỉ service MỚI được dựng, các service cũ giữ nguyên
docker compose ps
```

Mở http://localhost:5050 → thêm server mới:

- **Host**: `db` ← tên service, **không phải** `localhost`
- **Port**: `5432` ← cổng gốc, không phải cổng publish
- **Username** / **Password**: theo `.env`

---

## Dọn dẹp

```bash
docker compose down -v
docker system df
```

---

## Tiêu chí hoàn thành

- [ ] `docker compose up -d` dựng được cả 3 service, tất cả `healthy`
- [ ] Cả 3 endpoint `/`, `/db`, `/cache` đều trả về `thanh cong`
- [ ] Sửa code thấy ngay không cần build lại, và giải thích được vì sao
- [ ] Làm đủ 3 thử nghiệm ở Phần D, ghi lại kết quả từng cái
- [ ] Giải thích được khác nhau giữa `down` và `down -v`
- [ ] Đọc log chẩn đoán được lỗi sai mật khẩu
- [ ] Thêm được service pgAdmin và kết nối vào database

## Câu hỏi

1. Vì sao sửa `main.py` mà không cần `docker compose build`?
2. `restart`, `down`, `down -v` — cái nào làm mất dữ liệu?
3. Trong pgAdmin, ô Host điền `db` hay `localhost`? Vì sao?
4. Đổi `DB_PASSWORD` trong `.env` rồi `up -d` mà vẫn lỗi mật khẩu — vì sao?
