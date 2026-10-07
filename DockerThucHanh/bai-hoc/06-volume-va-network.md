# Bài 6 — Volume và Network

Hai thứ khiến container trở nên dùng được thật: **giữ được dữ liệu** và **nói chuyện được với nhau**.

---

# PHẦN 1 — VOLUME: giữ dữ liệu

## 1.1 Vấn đề

Container có tầng ghi riêng, **xoá container là mất sạch**. Database chạy trong container mà không có volume = mất toàn bộ dữ liệu mỗi lần deploy.

## 1.2 Ba cách gắn dữ liệu

| Cách | Cú pháp | Dùng khi nào |
|------|---------|--------------|
| **Named volume** | `-v ten-volume:/duong/dan` | **Dữ liệu production** — database, file upload |
| **Bind mount** | `-v $(pwd):/app` | **Lúc dev** — sửa code trên máy, container thấy ngay |
| **tmpfs** | `--tmpfs /tmp` | Dữ liệu tạm, chỉ nằm trong RAM |

### Named volume — Docker tự quản lý

```bash
docker volume create du-lieu-db
docker run -d -v du-lieu-db:/var/lib/postgresql/data postgres:16-alpine

docker volume ls
docker volume inspect du-lieu-db
docker volume rm du-lieu-db          # ⚠️ xoá là mất dữ liệu
```

### Bind mount — trỏ thẳng vào thư mục trên máy

```bash
docker run -d -v $(pwd):/app -p 8000:8000 app-demo:1.0
```

Sửa file trên máy → container thấy ngay, không cần build lại. **Cực kỳ tiện lúc dev**, kết hợp với `--reload`:

```bash
docker run -d -v $(pwd):/app -p 8000:8000 app-demo:1.0 \
  uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

> ⚠️ **Không dùng bind mount code trên production.** Ở đó phải dùng code đã đóng gói sẵn trong image,
> nếu không thì image mất hết ý nghĩa "chạy giống nhau ở mọi nơi".

### Chỉ đọc

```bash
docker run -v $(pwd)/config:/app/config:ro app-demo:1.0
```

Thêm `:ro` để container không sửa được file — nên dùng cho file cấu hình.

## 1.3 Sao lưu volume

```bash
# Sao lưu ra file .tar.gz
docker run --rm \
  -v du-lieu-db:/du-lieu \
  -v $(pwd):/sao-luu \
  alpine tar czf /sao-luu/backup-db.tar.gz -C /du-lieu .

# Khôi phục
docker run --rm \
  -v du-lieu-db:/du-lieu \
  -v $(pwd):/sao-luu \
  alpine sh -c "cd /du-lieu && tar xzf /sao-luu/backup-db.tar.gz"
```

Với database, cách chuẩn hơn là dùng công cụ của chính nó:

```bash
docker exec db pg_dump -U appuser appdb > backup.sql
cat backup.sql | docker exec -i db psql -U appuser appdb
```

---

# PHẦN 2 — NETWORK: container nói chuyện với nhau

## 2.1 Vấn đề

Mặc định mỗi container nằm trên network `bridge` chung, **chỉ gọi nhau được bằng IP** — mà IP thay đổi mỗi lần khởi động lại. Không dùng được.

## 2.2 Giải pháp: tạo network riêng

Trên network do bạn tạo, Docker bật sẵn **DNS nội bộ**: container gọi nhau bằng **tên container**.

```bash
# 1. Tạo network
docker network create mang-du-an

# 2. Cho các container vào cùng network đó
docker run -d --name db --network mang-du-an \
  -e POSTGRES_USER=appuser -e POSTGRES_PASSWORD=matkhau123 -e POSTGRES_DB=appdb \
  postgres:16-alpine

docker run -d --name cache --network mang-du-an redis:7-alpine

docker run -d --name app --network mang-du-an -p 8000:8000 \
  -e DB_HOST=db -e DB_PASSWORD=matkhau123 -e REDIS_HOST=cache \
  app-demo:1.0
```

App gọi database bằng đúng chữ **`db`** — không cần biết IP:

```python
psycopg2.connect(host="db", ...)     # "db" chính là tên container
```

Kiểm chứng:

```bash
docker exec app ping -c 2 db
docker exec app getent hosts cache
curl http://localhost:8000/db
```

## 2.3 Các lệnh network

```bash
docker network ls
docker network create mang-du-an
docker network inspect mang-du-an        # xem container nào đang trong đó
docker network connect mang-du-an web    # thêm container có sẵn vào network
docker network disconnect mang-du-an web
docker network rm mang-du-an
docker network prune
```

## 2.4 ⚠️ Bẫy lớn nhất: cổng nội bộ khác cổng publish

```bash
docker run -d --name db --network mang-du-an -p 5433:5432 postgres:16-alpine
```

| Gọi từ đâu | Địa chỉ đúng |
|------------|--------------|
| Từ container khác **trong cùng network** | `db:5432` ← cổng **gốc**, không phải 5433 |
| Từ máy bạn (ngoài Docker) | `localhost:5433` ← cổng đã publish |

Cờ `-p` **chỉ để bạn truy cập từ máy**. Container gọi nhau **không đi qua `-p`**, mà dùng thẳng cổng gốc.

Sai lầm phổ biến: app trong container cấu hình `DB_HOST=localhost` → không bao giờ chạy, vì `localhost` bên trong container là **chính container đó**, không phải máy bạn.

| Sai | Đúng |
|-----|------|
| `DB_HOST=localhost` | `DB_HOST=db` |
| `DB_HOST=127.0.0.1` | `DB_HOST=db` |
| `DB_PORT=5433` | `DB_PORT=5432` |

---

## 3. Bài tập

```bash
# 1. Tạo network và dựng 3 container
docker network create mang-bai-tap
docker run -d --name db-bt --network mang-bai-tap \
  -e POSTGRES_USER=appuser -e POSTGRES_PASSWORD=matkhau123 -e POSTGRES_DB=appdb \
  -v vol-bai-tap:/var/lib/postgresql/data postgres:16-alpine
docker run -d --name cache-bt --network mang-bai-tap redis:7-alpine
docker run -d --name app-bt --network mang-bai-tap -p 8000:8000 \
  -e DB_HOST=db-bt -e DB_PASSWORD=matkhau123 -e REDIS_HOST=cache-bt app-demo:1.0

# 2. Kiểm tra kết nối
curl http://localhost:8000/db
curl http://localhost:8000/cache
curl http://localhost:8000/cache      # số đếm tăng lên

# 3. THỬ NGHIỆM: xoá app và cache, giữ volume database
docker rm -f app-bt cache-bt

# 4. Dựng lại — dữ liệu database còn không?
docker run -d --name app-bt --network mang-bai-tap -p 8000:8000 \
  -e DB_HOST=db-bt -e DB_PASSWORD=matkhau123 -e REDIS_HOST=cache-bt app-demo:1.0
curl http://localhost:8000/db

# 5. Dọn dẹp
docker rm -f app-bt db-bt cache-bt 2>/dev/null
docker network rm mang-bai-tap
docker volume rm vol-bai-tap
```

**Câu hỏi**

1. Named volume và bind mount khác nhau ở đâu? Cái nào dùng cho production?
2. Vì sao phải tạo network riêng thay vì dùng bridge mặc định?
3. App trong container muốn gọi database, `DB_HOST` phải điền gì?
4. Container A gọi container B đã publish `-p 5433:5432` thì dùng cổng nào?
5. Vì sao `DB_HOST=localhost` không bao giờ chạy được trong container?
