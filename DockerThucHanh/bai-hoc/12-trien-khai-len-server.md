# Bài 12 — Triển khai lên server thật

---

## 1. Dev khác Production ở đâu?

| | Dev (máy bạn) | Production (server) |
|---|---|---|
| Code | Bind mount `./:/app` | **Nằm trong image**, không mount |
| Reload | `--reload` | **Tắt**, dùng nhiều worker |
| Cổng database | Mở `5432` ra ngoài | **Đóng hoàn toàn** |
| Image | Build tại chỗ | **Pull từ registry** |
| Log | In ra terminal | Có giới hạn dung lượng, xoay vòng |
| Bí mật | File `.env` | Secret manager / `.env` phân quyền chặt |
| Khởi động lại | Tay | `restart: unless-stopped` |
| HTTPS | Không | **Bắt buộc** |

---

## 2. File compose cho production

Không viết lại từ đầu — chỉ khai báo phần **khác** với dev, rồi đè lên:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

[`docker-compose.prod.yml`](../tai-nguyen/app-demo/docker-compose.prod.yml):

```yaml
services:
  app:
    image: ghcr.io/tuongna247/app-demo:1.0.0   # pull, không build trên server
    build: null
    environment:
      APP_ENV: production
    volumes: []                                 # BỎ bind mount code
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 512M
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"

  db:
    ports: []          # ⚠️ QUAN TRỌNG NHẤT: không mở database ra internet
    logging:
      driver: json-file
      options: { max-size: "10m", max-file: "3" }
```

### Ba điểm sống còn

**a) `ports: []` cho database.** Để nguyên `5432:5432` là database của bạn **mở ra toàn internet**. Bot quét cổng 5432 liên tục; mật khẩu yếu là mất dữ liệu trong vài giờ. App gọi database qua network nội bộ của Compose, **không cần** publish cổng.

**b) Giới hạn log.** Không giới hạn, file log lớn dần tới khi **đầy ổ cứng** rồi kéo sập cả server. Đây là nguyên nhân sự cố production rất phổ biến.

**c) Giới hạn tài nguyên.** Một container rò rỉ bộ nhớ có thể ăn hết RAM và làm chết các service khác.

---

## 3. Chuẩn bị server

```bash
ssh user@server-cua-ban

# Cài Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# đăng xuất, đăng nhập lại

docker --version
docker compose version
```

### Tường lửa

```bash
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw enable
sudo ufw status
```

> ⚠️ Docker **ghi trực tiếp vào iptables** và có thể đi vòng qua UFW. Một cổng bạn publish bằng `-p`
> có thể mở ra internet **dù UFW đang chặn**. Vì vậy cách an toàn nhất vẫn là **không publish** cổng
> database ngay từ đầu. Nếu buộc phải publish, hãy khoá vào localhost: `-p 127.0.0.1:5432:5432`.

---

## 4. Quy trình triển khai

```bash
# TRÊN SERVER
mkdir -p ~/app-demo && cd ~/app-demo

# 1. Lấy file compose và env mẫu
scp user@may-ban:~/app-demo/docker-compose*.yml .
cp .env.mau .env
nano .env            # điền mật khẩu THẬT, mạnh
chmod 600 .env       # chỉ chủ sở hữu đọc được

# 2. Đăng nhập registry
echo "$GHCR_TOKEN" | docker login ghcr.io -u tuongna247 --password-stdin

# 3. Kéo image và chạy
docker compose -f docker-compose.yml -f docker-compose.prod.yml pull
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 4. Kiểm tra
docker compose ps
docker compose logs -f app
curl http://localhost:8000/health
```

### Script deploy

```bash
cat > deploy.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail

PHIEN_BAN="${1:?Cach dung: ./deploy.sh 1.0.0}"
COMPOSE="docker compose -f docker-compose.yml -f docker-compose.prod.yml"

echo "▶ Trien khai phien ban $PHIEN_BAN"

export IMAGE_TAG="$PHIEN_BAN"
$COMPOSE pull
$COMPOSE up -d

echo "▶ Cho app san sang..."
for i in $(seq 1 30); do
  if curl -fs http://localhost:8000/health >/dev/null 2>&1; then
    echo "✅ Trien khai thanh cong: $PHIEN_BAN"
    $COMPOSE ps
    exit 0
  fi
  sleep 2
done

echo "❌ Health check that bai — dang xem log:"
$COMPOSE logs --tail 50 app
exit 1
SH
chmod +x deploy.sh

./deploy.sh 1.0.0
```

Để `IMAGE_TAG` dùng được, sửa `docker-compose.prod.yml`:

```yaml
    image: ghcr.io/tuongna247/app-demo:${IMAGE_TAG:-latest}
```

### Rollback

Đây là lý do phải gắn tag phiên bản thay vì `latest`:

```bash
./deploy.sh 0.9.0        # quay lại bản trước, mất vài giây
```

---

## 5. HTTPS bằng Caddy

Caddy tự xin và tự gia hạn chứng chỉ Let's Encrypt, cấu hình ngắn hơn Nginx nhiều.

Thêm vào `docker-compose.prod.yml`:

```yaml
  caddy:
    image: caddy:2-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy-data:/data
      - caddy-config:/config
    depends_on:
      - app
    restart: unless-stopped

volumes:
  caddy-data:
  caddy-config:
```

`Caddyfile`:

```
app.tenmiencuaban.com {
    reverse_proxy app:8000
    encode gzip
    log {
        output file /data/access.log
        format json
    }
}
```

Sau đó **bỏ `ports` của service `app`** — chỉ Caddy được tiếp xúc với internet, app nằm sau nó.

> Điều kiện: tên miền đã trỏ bản ghi A về IP server, và cổng 80/443 đang mở.

---

## 6. Vận hành hằng ngày

```bash
docker compose ps
docker compose logs -f --tail 100 app
docker stats --no-stream
docker system df

# Sao lưu database — nên đặt cron chạy hằng ngày
docker compose exec -T db pg_dump -U appuser appdb | gzip > backup-$(date +%F).sql.gz

# Khôi phục
gunzip -c backup-2026-08-19.sql.gz | docker compose exec -T db psql -U appuser appdb

# Dọn image cũ (KHÔNG đụng volume)
docker image prune -a -f
```

Cron sao lưu hằng ngày lúc 2 giờ sáng:

```bash
crontab -e
# 0 2 * * * cd ~/app-demo && docker compose exec -T db pg_dump -U appuser appdb | gzip > ~/backup/db-$(date +\%F).sql.gz
```

> ⚠️ **Bản sao lưu chưa từng khôi phục thử thì chưa phải bản sao lưu.** Mỗi tháng khôi phục thử một lần lên môi trường test.

---

## 7. Checklist trước khi lên production

- [ ] `ports: []` cho database và mọi service nội bộ
- [ ] Giới hạn log (`max-size`, `max-file`)
- [ ] Giới hạn CPU / RAM
- [ ] `restart: unless-stopped`
- [ ] Image ghim **phiên bản cụ thể**, không phải `latest`
- [ ] `.env` với mật khẩu mạnh, `chmod 600`, không nằm trong Git
- [ ] Container chạy bằng user thường, không phải root
- [ ] Có `HEALTHCHECK`
- [ ] HTTPS qua reverse proxy
- [ ] Tường lửa chỉ mở 22, 80, 443
- [ ] Sao lưu database tự động **và đã khôi phục thử thành công**
- [ ] Biết cách rollback và **đã thử rollback ít nhất 1 lần**

---

## 8. Câu hỏi

1. Vì sao production phải bỏ bind mount code?
2. Để `ports: 5432:5432` cho database trên server có hại gì?
3. Không giới hạn log thì chuyện gì xảy ra sau vài tháng?
4. Vì sao phải ghim tag phiên bản thay vì `latest`?
5. UFW đã chặn cổng 5432 thì database có an toàn không? Vì sao?
