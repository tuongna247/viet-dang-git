# Bài 10 — Biến môi trường và Secret

> Bài ngắn nhưng là bài **dễ gây sự cố thật nhất** nếu làm sai.

---

## 1. Vì sao cần biến môi trường?

Cùng một image phải chạy được ở dev, staging và production — chỉ khác nhau ở **cấu hình**. Nếu nhét mật khẩu vào code thì mỗi môi trường phải build một image riêng, và image mất luôn ý nghĩa.

**Nguyên tắc: image chứa CODE, biến môi trường chứa CẤU HÌNH.**

---

## 2. Ba cách truyền biến

```bash
# a) Từng biến một
docker run -e APP_ENV=production -e DB_HOST=db app-demo:1.0

# b) Từ file
docker run --env-file .env app-demo:1.0

# c) Trong docker-compose.yml
```

```yaml
services:
  app:
    environment:
      APP_ENV: production
      DB_HOST: db
    # hoặc:
    env_file:
      - .env
```

Đọc trong Python:

```python
import os
db_host = os.getenv("DB_HOST", "localhost")     # có giá trị mặc định
db_pass = os.environ["DB_PASSWORD"]             # thiếu là lỗi ngay — nên dùng cho biến bắt buộc
```

---

## 3. `ENV` trong Dockerfile — cẩn thận

```dockerfile
ENV APP_ENV=production        # ✅ cấu hình không bí mật
ENV DB_PASSWORD=matkhau123    # ❌ TUYỆT ĐỐI KHÔNG
```

`ENV` ghi giá trị **vĩnh viễn vào image**. Ai cũng đọc được:

```bash
docker inspect app-demo:1.0 --format '{{json .Config.Env}}'
docker history --no-trunc app-demo:1.0
```

Chỉ dùng `ENV` cho giá trị **không bí mật**: `PYTHONUNBUFFERED=1`, `TZ=Asia/Ho_Chi_Minh`.

---

## 4. Quy tắc vàng về secret

| Việc | Đúng / Sai |
|------|-----------|
| Ghi mật khẩu vào `Dockerfile` bằng `ENV` | ❌ nằm vĩnh viễn trong image |
| Ghi mật khẩu vào `docker-compose.yml` rồi commit | ❌ lộ trên Git |
| Truyền qua `--build-arg` | ❌ vẫn thấy trong `docker history` |
| Để trong `.env`, `.env` nằm trong `.gitignore` | ✅ |
| Dùng Docker secrets / vault trên production | ✅ tốt nhất |

### Bộ ba file bắt buộc

```
.env          ← giá trị THẬT, KHÔNG commit
.env.mau      ← file mẫu, CÓ commit, không chứa giá trị thật
.gitignore    ← chứa dòng ".env"
```

`.env.mau`:

```bash
DB_NAME=appdb
DB_USER=appuser
DB_PASSWORD=doi-mat-khau-nay-di
```

`.gitignore`:

```
.env
.env.local
```

Đồng nghiệp mới: `cp .env.mau .env` rồi điền giá trị thật.

### Bắt buộc phải có biến

```yaml
DB_PASSWORD: ${DB_PASSWORD:?Thieu DB_PASSWORD - hay tao file .env}
```

Thiếu biến, Compose dừng ngay với thông báo rõ ràng — tốt hơn nhiều so với chạy được rồi lỗi mơ hồ về sau.

---

## 5. Lỡ commit `.env` rồi thì sao?

```bash
git rm --cached .env
echo ".env" >> .gitignore
git commit -m "Go .env khoi git"
git push
```

> ⚠️ **Chưa xong.** File vẫn nằm trong **lịch sử các commit cũ**. Bất cứ ai clone repo đều đọc được.
> **Bắt buộc phải đổi toàn bộ mật khẩu và API key đó ngay** — coi như đã bị lộ.
> Xoá hẳn khỏi lịch sử cần `git filter-repo` hoặc BFG Repo-Cleaner, và phải báo cả team vì lịch sử bị viết lại.

---

## 6. Docker secrets (Swarm / production)

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

Secret được gắn vào container dưới dạng file trong `/run/secrets/`, **không nằm trong image, không hiện trong `docker inspect`**. Nhiều image chính thức (PostgreSQL, MySQL) hỗ trợ sẵn hậu tố `_FILE`.

---

## 7. Bài tập

```bash
cd tai-nguyen/app-demo

# 1. Xem image có lỡ chứa secret không
docker inspect app-demo:1.0 --format '{{json .Config.Env}}' | python3 -m json.tool

# 2. Thử thiếu biến bắt buộc
mv .env .env.giu
docker compose up -d
#    → Compose báo: "Thieu DB_PASSWORD - hay tao file .env"
mv .env.giu .env

# 3. Truyền biến lúc chạy và kiểm chứng
docker run --rm -e APP_ENV=kiem-tra -p 8020:8000 -d --name t app-demo:1.0
sleep 3 && curl http://localhost:8020/     # trường "moi_truong" đổi theo
docker rm -f t

# 4. Kiểm tra .env đã bị Git bỏ qua chưa
git check-ignore -v .env
```

**Câu hỏi**

1. Vì sao không được dùng `ENV DB_PASSWORD=...` trong Dockerfile?
2. `.env` và `.env.mau` — cái nào commit, cái nào không?
3. `${DB_PASSWORD:?...}` khác `${DB_PASSWORD:-mac-dinh}` chỗ nào?
4. Lỡ commit `.env` chứa mật khẩu production — việc **đầu tiên** phải làm là gì?
