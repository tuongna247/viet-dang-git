# Bài 0 — Docker là gì và giải quyết vấn đề gì?

## 1. Câu nói kinh điển: "Máy tao chạy được mà!"

Tình huống quen thuộc:

- Máy bạn Python 3.12, máy đồng nghiệp Python 3.9 → code chạy chỗ này, lỗi chỗ kia.
- Server production thiếu một thư viện hệ thống → deploy xong mới phát hiện.
- Nhân viên mới mất **2 ngày** cài môi trường mới chạy được dự án.
- Dự án A cần PostgreSQL 14, dự án B cần PostgreSQL 16 → cài chung một máy là xung đột.

Docker giải quyết bằng cách **đóng gói ứng dụng cùng toàn bộ môi trường của nó** — hệ điều hành nền, thư viện, biến môi trường, mã nguồn — thành một gói duy nhất chạy giống hệt nhau ở mọi nơi.

Kết quả: nhân viên mới chỉ cần `docker compose up` là dự án chạy, không cần cài Python hay PostgreSQL trên máy.

---

## 2. Ba khái niệm cốt lõi — hiểu 3 cái này là hiểu Docker

| Khái niệm | Ví von | Thực tế |
|-----------|--------|---------|
| **Image** | Bản thiết kế / khuôn bánh | Gói chỉ-đọc chứa OS + thư viện + code. Không chạy được, chỉ để tạo container |
| **Container** | Chiếc bánh làm ra từ khuôn | Một tiến trình đang chạy, tạo ra từ image. Từ **1 image** tạo được **nhiều container** |
| **Dockerfile** | Công thức làm khuôn | File văn bản mô tả cách xây image |

```
Dockerfile  ──docker build──▶  Image  ──docker run──▶  Container (đang chạy)
 (công thức)                  (khuôn)                   (bánh)
                                 │
                                 ├──▶ Container 1
                                 ├──▶ Container 2      cùng 1 image
                                 └──▶ Container 3      tạo nhiều container
```

**Điểm quan trọng nhất cần nhớ:** container **không lưu dữ liệu**. Xoá container là mất sạch mọi thứ ghi bên trong nó. Muốn giữ dữ liệu phải dùng **volume** (Bài 6).

---

## 3. Docker khác máy ảo (VM) thế nào?

```
        MÁY ẢO (VM)                          DOCKER
┌───────┬───────┬───────┐          ┌───────┬───────┬───────┐
│ App A │ App B │ App C │          │ App A │ App B │ App C │
├───────┼───────┼───────┤          ├───────┴───────┴───────┤
│  OS   │  OS   │  OS   │ ← nặng   │    Docker Engine      │
├───────┴───────┴───────┤   vài GB ├───────────────────────┤
│      Hypervisor       │          │   OS của máy chủ      │
├───────────────────────┤          ├───────────────────────┤
│    OS của máy chủ     │          │      Phần cứng        │
└───────────────────────┘          └───────────────────────┘
```

| | Máy ảo | Docker |
|---|--------|--------|
| Mỗi app kèm | Nguyên một hệ điều hành | Chỉ thư viện cần thiết |
| Dung lượng | Vài GB | Vài chục–vài trăm MB |
| Thời gian khởi động | Vài phút | **Vài giây** |
| Số lượng chạy song song | Vài cái | Hàng chục–hàng trăm |

Container **dùng chung nhân (kernel) của máy chủ**, nên nhẹ hơn VM rất nhiều — đó là toàn bộ bí mật.

---

## 4. Registry — kho chứa image

**Docker Hub** (https://hub.docker.com) là kho image công cộng, giống GitHub nhưng cho image.

```bash
docker pull postgres:16-alpine     # tải image PostgreSQL về máy
```

Bạn không cần tự viết image cho PostgreSQL, Redis, Nginx, Python... — đã có sẵn image chính thức.

Cách đọc tên image:

```
        ghcr.io / tuongna247 / app-demo : 1.0
        └──┬──┘   └────┬────┘  └───┬──┘  └┬┘
        registry   chủ sở hữu    tên     tag
       (bỏ trống    (bỏ trống  của image (bỏ trống
     = Docker Hub) = image                = latest)
                     chính thức)
```

> ⚠️ **Không dùng tag `latest` trên production.** `latest` không có nghĩa là "mới nhất" mà chỉ là tag mặc định — hôm nay nó trỏ tới bản A, tháng sau trỏ bản B, và bạn không kiểm soát được. Luôn ghi rõ phiên bản: `postgres:16-alpine`, không phải `postgres:latest`.

---

## 5. Vòng đời một container

```
        docker run                docker stop            docker start
image ─────────────▶ ĐANG CHẠY ──────────────▶ ĐÃ DỪNG ──────────────▶ ĐANG CHẠY
                        │         docker kill      │
                        │                          │ docker rm
                        │                          ▼
                        └────────────────────▶  BỊ XOÁ (mất hết dữ liệu bên trong)
```

| Lệnh | Tác dụng |
|------|----------|
| `docker run` | Tạo container mới **và** khởi động |
| `docker stop` | Dừng nhẹ nhàng (gửi tín hiệu, chờ app đóng) |
| `docker kill` | Dừng cưỡng chế ngay lập tức |
| `docker start` | Chạy lại container đã dừng |
| `docker rm` | Xoá hẳn container |

---

## 6. Khoá học này đi tới đâu

| Buổi | Nội dung | Kết quả |
|------|----------|---------|
| 1 | Căn bản | Chạy được PostgreSQL, Redis, Nginx bằng container |
| 2 | Dockerfile + Compose | Đóng gói app FastAPI, dựng cả hệ thống bằng 1 lệnh |
| 3 | Tối ưu + Triển khai | Image gọn, đẩy lên registry, deploy lên server thật |

**Câu hỏi kiểm tra Bài 0**

1. Image và container khác nhau thế nào? Cái nào chạy được?
2. Vì sao container khởi động nhanh hơn máy ảo rất nhiều?
3. Xoá container thì dữ liệu bên trong còn không?
4. Vì sao không nên dùng tag `latest` trên production?
