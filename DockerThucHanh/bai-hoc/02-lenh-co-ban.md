# Bài 2 — Các lệnh Docker căn bản

> Bài này là phần tra cứu quan trọng nhất khoá học. Học viên nên mở song song khi làm bài thực hành.

---

## 1. Làm việc với IMAGE

```bash
docker pull postgres:16-alpine     # tải image về máy
docker images                       # liệt kê image đang có
docker images -q                    # chỉ in ID, dùng để ghép lệnh
docker rmi nginx:alpine             # xoá 1 image
docker image prune                  # xoá image rác (dangling)
docker history app-demo:1.0         # xem image gồm những tầng nào, tầng nào nặng
```

`docker history` rất hữu ích khi image bị phình — nó cho thấy chính xác lệnh nào trong Dockerfile tạo ra tầng nặng nhất.

---

## 2. Chạy CONTAINER

```bash
docker run nginx:alpine                          # chạy, chiếm terminal
docker run -d nginx:alpine                       # chạy nền
docker run -d -p 8080:80 nginx:alpine            # nối cổng
docker run -d --name web nginx:alpine            # đặt tên
docker run --rm alpine echo "xin chao"           # chạy xong TỰ XOÁ container
docker run -it ubuntu bash                       # mở shell tương tác bên trong
docker run -d -e APP_ENV=production app-demo:1.0 # truyền biến môi trường
docker run -d -v $(pwd):/app app-demo:1.0        # gắn thư mục từ máy vào
```

### Các cờ hay dùng

| Cờ | Viết đầy đủ | Ý nghĩa |
|----|-------------|---------|
| `-d` | `--detach` | Chạy nền |
| `-p 8080:80` | `--publish` | Cổng máy bạn : cổng container |
| `-e KEY=value` | `--env` | Truyền biến môi trường |
| `-v ngoai:trong` | `--volume` | Gắn thư mục / volume |
| `--name ten` | | Đặt tên container |
| `--rm` | | Tự xoá container khi dừng |
| `-it` | `-i -t` | Tương tác + cấp terminal (dùng khi mở shell) |
| `--restart unless-stopped` | | Tự khởi động lại khi máy reboot hoặc app crash |

> `--rm` rất nên dùng khi thử nghiệm — nếu không, sau một buổi học bạn sẽ có hàng chục container chết nằm rác trong máy.

---

## 3. Xem và quản lý container

```bash
docker ps                          # container ĐANG CHẠY
docker ps -a                       # TẤT CẢ, kể cả đã dừng
docker ps -a --filter status=exited   # chỉ container đã thoát

docker stop web                    # dừng nhẹ nhàng
docker start web                   # chạy lại
docker restart web                 # khởi động lại
docker kill web                    # dừng cưỡng chế ngay
docker rm web                      # xoá (phải dừng trước)
docker rm -f web                   # dừng và xoá luôn

docker stop $(docker ps -q)        # dừng TẤT CẢ container đang chạy
docker rm $(docker ps -aq)         # ⚠️ xoá TẤT CẢ container
```

Hiển thị gọn hơn:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## 4. Xem chuyện gì đang xảy ra bên trong

Đây là nhóm lệnh dùng khi **debug** — quan trọng nhất trong công việc thật.

```bash
docker logs web                    # xem log
docker logs -f web                 # theo dõi log trực tiếp (Ctrl+C để thoát)
docker logs --tail 50 web          # 50 dòng cuối
docker logs --since 10m web        # log 10 phút gần đây

docker exec -it web sh             # mở shell BÊN TRONG container đang chạy
docker exec web ls -la /app        # chạy 1 lệnh rồi thoát
docker exec -it db psql -U appuser appdb   # vào thẳng psql của container database

docker inspect web                 # toàn bộ cấu hình dạng JSON
docker inspect web --format '{{.State.Status}}'
docker inspect web --format '{{.NetworkSettings.IPAddress}}'

docker stats                       # CPU / RAM theo thời gian thực
docker top web                     # tiến trình đang chạy trong container
docker port web                    # container đang mở cổng nào
```

> **`docker logs` + `docker exec -it ... sh` giải quyết được khoảng 80% sự cố.**
> App lỗi mà không biết vì sao → xem log trước. Log không rõ → chui vào trong xem tận nơi.

Ảnh Alpine không có `bash`, chỉ có `sh`:

```bash
docker exec -it web sh       # ảnh alpine
docker exec -it web bash     # ảnh debian/ubuntu
```

---

## 5. Chép file giữa máy và container

```bash
docker cp web:/etc/nginx/nginx.conf ./nginx.conf   # từ container ra máy
docker cp ./nginx.conf web:/etc/nginx/nginx.conf   # từ máy vào container
```

---

## 6. Dọn dẹp

```bash
docker system df                   # xem đang chiếm bao nhiêu dung lượng

docker container prune             # xoá container đã dừng
docker image prune                 # xoá image rác
docker volume prune                # ⚠️ xoá volume không dùng — MẤT DỮ LIỆU
docker network prune               # xoá network không dùng

docker system prune                # gộp 4 lệnh trên (trừ volume)
docker system prune -a --volumes   # ⚠️⚠️ xoá sạch mọi thứ không đang dùng
```

---

## 7. Bảng tra cứu nhanh

| Muốn gì | Lệnh |
|---------|------|
| Chạy container nền, mở cổng | `docker run -d -p 8080:80 --name web nginx:alpine` |
| Xem đang chạy gì | `docker ps` |
| Xem log | `docker logs -f web` |
| Chui vào trong container | `docker exec -it web sh` |
| Dừng và xoá | `docker rm -f web` |
| Xem image có gì | `docker images` |
| Xem chiếm bao nhiêu ổ | `docker system df` |
| Dọn rác | `docker system prune` |

---

## 8. Bài tập

Làm lần lượt, tự đoán kết quả trước khi gõ Enter:

```bash
# 1. Chạy nginx, đặt tên, mở cổng 8080
docker run -d -p 8080:80 --name bai-tap-web nginx:alpine

# 2. Kiểm tra nó có chạy không
docker ps

# 3. Xem log
docker logs bai-tap-web

# 4. Vào bên trong, xem file index.html của nginx
docker exec -it bai-tap-web sh
#    (trong container)  cat /usr/share/nginx/html/index.html
#    (trong container)  exit

# 5. Sửa trang chủ từ bên ngoài
echo "<h1>Xin chao tu Docker</h1>" > index.html
docker cp index.html bai-tap-web:/usr/share/nginx/html/index.html
#    Tải lại http://localhost:8080 — thấy dòng chữ mới

# 6. Xem container ăn bao nhiêu RAM
docker stats --no-stream bai-tap-web

# 7. Dọn dẹp
docker rm -f bai-tap-web
```

**Câu hỏi**

1. `docker ps` và `docker ps -a` khác nhau chỗ nào?
2. Trong `-p 8080:80`, số nào là cổng trên máy bạn?
3. `docker stop` khác `docker kill` thế nào?
4. Vì sao image alpine thường phải dùng `sh` thay vì `bash`?
