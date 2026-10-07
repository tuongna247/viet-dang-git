# Bài 1 — Cài đặt Docker

## 1. Chọn bản cài

| Hệ điều hành | Cài gì |
|--------------|--------|
| **macOS** | Docker Desktop — https://docs.docker.com/desktop/install/mac-install/ (chọn đúng chip Apple Silicon hay Intel) |
| **Windows** | Docker Desktop + WSL 2 — https://docs.docker.com/desktop/install/windows-install/ |
| **Linux (Ubuntu)** | Docker Engine — xem lệnh bên dưới |

### Ubuntu / Debian

```bash
curl -fsSL https://get.docker.com | sh

# Cho phép chạy docker không cần sudo
sudo usermod -aG docker $USER
# ĐĂNG XUẤT rồi đăng nhập lại để nhóm có hiệu lực
```

### Windows — lưu ý về WSL 2

Docker Desktop trên Windows chạy nền trên WSL 2. Nếu báo lỗi WSL:

```powershell
wsl --install
wsl --update
```

Rồi khởi động lại máy.

---

## 2. Kiểm tra cài đặt

```bash
docker --version           # Docker version 29.6.2, build dfc4efb
docker compose version     # Docker Compose version v5.3.1
docker info                # thông tin chi tiết về daemon
```

> **Lưu ý cú pháp**: bản mới dùng `docker compose` (hai từ, có dấu cách).
> Cú pháp cũ `docker-compose` (có gạch nối) đã lỗi thời — tài liệu cũ trên mạng hay dùng bản này.

Nếu `docker info` báo:

```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

→ Docker chưa chạy. macOS/Windows: mở ứng dụng **Docker Desktop**. Linux: `sudo systemctl start docker`.

---

## 3. Container đầu tiên

```bash
docker run hello-world
```

Kết quả:

```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
...
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

**Điều vừa xảy ra**, đọc kỹ vì đây là toàn bộ cơ chế Docker:

1. Docker tìm image `hello-world` trên máy → **không có**
2. Tự động tải từ Docker Hub về
3. Tạo container từ image đó
4. Container chạy, in ra dòng chữ, rồi kết thúc

---

## 4. Thử một app thật — Nginx

```bash
docker run -d -p 8080:80 --name web-thu-nghiem nginx:alpine
```

Mở trình duyệt vào http://localhost:8080 — thấy trang "Welcome to nginx!".

Giải thích từng cờ:

| Cờ | Ý nghĩa |
|----|---------|
| `-d` | **detached** — chạy nền, trả lại terminal cho bạn |
| `-p 8080:80` | Nối cổng **8080 trên máy bạn** → **80 trong container** |
| `--name web-thu-nghiem` | Đặt tên container để gọi cho dễ (không có thì Docker tự đặt tên ngẫu nhiên) |
| `nginx:alpine` | Image dùng — `alpine` là bản Linux siêu nhẹ |

> 🔑 **Nhớ kỹ thứ tự của `-p`: `MÁY_BẠN:CONTAINER`** — bên trái là cổng bạn gõ vào trình duyệt.
> Nhầm thứ tự là lỗi phổ biến nhất của người mới.

Dọn dẹp:

```bash
docker stop web-thu-nghiem
docker rm web-thu-nghiem
```

---

## 5. Kiểm tra nhanh bằng script

```bash
cd ~/Desktop/Projects/DockerThucHanh
bash tai-nguyen/kiem-tra-cai-dat.sh
```

Script kiểm tra: Docker đã cài chưa, daemon có chạy không, Compose có sẵn không, tải image được không, còn đủ dung lượng đĩa không.

---

## 6. Docker chiếm bao nhiêu ổ cứng?

Docker âm thầm ăn rất nhiều dung lượng. Kiểm tra định kỳ:

```bash
docker system df          # xem image/container/volume đang chiếm bao nhiêu
```

Dọn dẹp:

```bash
docker system prune              # xoá container đã dừng, network và image rác
docker system prune -a           # ⚠️ xoá cả image không dùng bởi container nào
docker system prune -a --volumes # ⚠️⚠️ XOÁ CẢ VOLUME — MẤT DỮ LIỆU DATABASE
```

> Dòng thứ ba xoá luôn dữ liệu database trong volume. Đọc kỹ trước khi gõ.
