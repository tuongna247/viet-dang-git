# Bài 14 — Checklist chấm bài và câu hỏi kiểm tra

## Checklist cho học viên

### Buổi 1 — Căn bản

| # | Hạng mục | Đạt |
|---|----------|-----|
| 1 | `docker --version` và `docker compose version` chạy được | ☐ |
| 2 | `docker run hello-world` thành công | ☐ |
| 3 | Chạy được nginx và mở được http://localhost:8080 | ☐ |
| 4 | Chạy PostgreSQL bằng container, tạo bảng, insert dữ liệu | ☐ |
| 5 | **Tự chứng kiến** dữ liệu mất khi xoá container không volume | ☐ |
| 6 | Dùng volume và chứng kiến dữ liệu sống sót | ☐ |
| 7 | Dùng thạo `docker ps`, `logs`, `exec -it`, `rm -f` | ☐ |
| 8 | Gây ra và tự xử lý lỗi trùng cổng | ☐ |

### Buổi 2 — Dockerfile & Compose

| # | Hạng mục | Đạt |
|---|----------|-----|
| 9 | **Tự viết** Dockerfile từ đầu, không copy đáp án | ☐ |
| 10 | Build và chạy được image của mình | ☐ |
| 11 | `docker exec ... whoami` trả về user thường, không phải root | ☐ |
| 12 | Có `.dockerignore` và giải thích được vì sao cần | ☐ |
| 13 | Gây ra và giải thích được 3 lỗi kinh điển ở Bài 5 | ☐ |
| 14 | `docker compose up -d` dựng được 3 service, tất cả healthy | ☐ |
| 15 | Cả `/`, `/db`, `/cache` đều trả về `thanh cong` | ☐ |
| 16 | Giải thích được khác nhau `down` và `down -v` | ☐ |
| 17 | Thêm được service mới vào compose | ☐ |

### Buổi 3 — Tối ưu & Triển khai

| # | Hạng mục | Đạt |
|---|----------|-----|
| 18 | Tự đo được chênh lệch build 1 giây / 21 giây | ☐ |
| 19 | Tự đo được tác dụng của `.dockerignore` | ☐ |
| 20 | Image có `HEALTHCHECK` và báo `healthy` | ☐ |
| 21 | Đẩy được image lên ghcr.io | ☐ |
| 22 | Pull image đó về máy khác và chạy được | ☐ |
| 23 | Tạo được GitHub Actions workflow build tự động | ☐ |
| 24 | Giải thích được vì sao production phải `ports: []` cho database | ☐ |
| 25 | Nêu được ít nhất 5 khác biệt giữa compose dev và prod | ☐ |

---

## Câu hỏi kiểm tra cuối khoá

### Phần A — Khái niệm

1. Image và container khác nhau thế nào? Cái nào chạy được?
2. Vì sao container khởi động nhanh hơn máy ảo rất nhiều?
3. Xoá container thì dữ liệu bên trong còn không? Làm sao giữ được?
4. `RUN` và `CMD` chạy ở thời điểm nào?
5. `EXPOSE 8000` có mở cổng cho bên ngoài không?

### Phần B — Thực hành

6. `-p 8080:80` — số nào là cổng trên máy bạn?
7. Container `Up` nhưng `curl` không ra gì — kiểm tra đầu tiên là gì?
8. App trong container gọi database, `DB_HOST` điền gì? Vì sao không phải `localhost`?
9. Container A gọi container B đã publish `-p 5433:5432` thì dùng cổng nào?
10. `docker compose down` và `down -v` khác nhau chỗ nào?

### Phần C — Tối ưu & Bảo mật

11. Vì sao phải `COPY requirements.txt` trước `COPY . .`?
12. Không có `.dockerignore` thì hại gì? Nêu 2 tác hại.
13. Vì sao không được `ENV DB_PASSWORD=...` trong Dockerfile?
14. Vì sao không nên chạy container bằng root?
15. Vì sao production không được để `ports: 5432:5432` cho database?
16. Vì sao không dùng tag `latest` trên production?

<details>
<summary>Đáp án</summary>

1. Image là gói chỉ-đọc (bản thiết kế), không chạy được. Container là tiến trình đang chạy tạo ra từ image. Một image tạo được nhiều container.
2. Container dùng chung kernel của máy chủ, không phải khởi động cả một hệ điều hành riêng như VM.
3. Mất sạch. Giữ được bằng volume (`-v ten-volume:/duong/dan`).
4. `RUN` chạy lúc **build image**, kết quả lưu vào image. `CMD` chạy lúc **container khởi động**, mỗi lần `docker run`.
5. Không. `EXPOSE` chỉ là ghi chú. Muốn truy cập từ ngoài vẫn phải `-p`.
6. Số **bên trái** (8080). Cú pháp là `MÁY_BẠN:CONTAINER`.
7. Xem `docker logs` tìm dòng `Running on ...`. Thấy `127.0.0.1` là thiếu `--host 0.0.0.0`.
8. Điền **tên service/container** (ví dụ `db`). `localhost` trong container trỏ về chính container đó, không phải máy chủ.
9. Cổng **gốc** `5432`. Container gọi nhau qua network nội bộ, không đi qua ánh xạ `-p`.
10. `down` xoá container và network, **giữ** volume. `down -v` xoá **cả volume** → mất dữ liệu database.
11. Để tận dụng layer cache: sửa code không làm Docker cài lại toàn bộ thư viện. Đo thật: 1 giây so với 21 giây.
12. (a) Build chậm và image phình — đo thật: build context 125.87MB thay vì 367B, image 557MB thay vì 305MB. (b) **Bảo mật**: `.env` chứa mật khẩu bị nhét vĩnh viễn vào image.
13. `ENV` ghi giá trị vĩnh viễn vào image, ai cũng đọc được bằng `docker inspect` hoặc `docker history`.
14. Kẻ tấn công chiếm được app sẽ có quyền root trong container, và có thể tìm đường thoát ra máy chủ.
15. Database sẽ mở ra toàn internet. Bot quét cổng 5432 liên tục; mật khẩu yếu là mất dữ liệu trong vài giờ. App gọi database qua network nội bộ, không cần publish.
16. `latest` chỉ là tag mặc định, không có nghĩa "mới nhất". Bạn không biết server đang chạy code nào và không rollback được.

</details>

---

## Bài tập về nhà

**Bắt buộc** — Đóng gói một dự án thật của bạn:

1. Viết `Dockerfile` và `.dockerignore`
2. Viết `docker-compose.yml` gồm app + database
3. Có `.env.mau`, `.env` nằm trong `.gitignore`
4. Chạy bằng user thường, có `HEALTHCHECK`
5. Đẩy image lên ghcr.io
6. Viết `README.md` hướng dẫn: người mới chỉ cần `docker compose up -d` là chạy được

**Nâng cao** — Tạo GitHub Actions workflow tự build và đẩy image mỗi khi push lên `main`.

Nộp link repo vào group.
