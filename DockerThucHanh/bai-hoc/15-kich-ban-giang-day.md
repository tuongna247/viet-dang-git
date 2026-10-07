# Bài 15 — Kịch bản cho người đứng lớp

> Tài liệu dành cho **giảng viên**, không phát cho học viên.

---

## 1. Chuẩn bị trước buổi học (làm trước ít nhất 2 ngày)

- [ ] Gửi học viên script [`tai-nguyen/kiem-tra-cai-dat.sh`](../tai-nguyen/kiem-tra-cai-dat.sh), yêu cầu chạy ở nhà và mọi mục phải `[ĐẠT]`.
      **Đây là việc tiết kiệm thời gian nhất** — cài Docker Desktop trên Windows có thể mất cả tiếng nếu WSL 2 chưa sẵn sàng.
- [ ] Yêu cầu học viên **tải trước các image** để không nghẽn mạng phòng học:
      ```bash
      docker pull python:3.12-slim
      docker pull postgres:16-alpine
      docker pull redis:7-alpine
      docker pull nginx:alpine
      ```
      Bốn image này khoảng 500 MB. Lớp 15 người tải cùng lúc là 7.5 GB — đủ làm sập mạng phòng.
- [ ] Kiểm tra máy học viên còn **ít nhất 10 GB trống**. Docker ăn ổ rất nhanh.
- [ ] In [`BANG-TRA-CUU.md`](../tai-nguyen/BANG-TRA-CUU.md) phát mỗi người 1 bản.
- [ ] Tự chạy lại toàn bộ 4 bài thực hành trên máy sạch.
- [ ] Chuẩn bị 1 server thật (VPS rẻ tiền cũng được) cho Buổi 3.

---

## 2. Bảng timing

### Buổi 1 — Căn bản (3 tiếng)

| Thời gian | Nội dung | Hình thức | Bài |
|---|---|---|---|
| 0:00–0:20 | Docker là gì, image vs container, so với VM | Giảng + vẽ bảng | [00](00-tong-quan.md) |
| 0:20–0:40 | Cài đặt, `hello-world`, nginx đầu tiên | Học viên làm | [01](01-cai-dat.md) |
| 0:40–1:10 | Các lệnh CLI căn bản | Giảng + gõ theo | [02](02-lenh-co-ban.md) |
| 1:10–1:20 | ☕ Nghỉ | | |
| 1:20–2:00 | **Thực hành 1** — PostgreSQL, Redis, nginx | Học viên làm | [03](03-thuc-hanh-1.md) |
| 2:00–2:40 | Volume và Network | Giảng + làm | [06](06-volume-va-network.md) |
| 2:40–3:00 | Hỏi đáp, checklist | | [14](14-checklist.md) |

### Buổi 2 — Dockerfile & Compose (3 tiếng)

| Thời gian | Nội dung | Hình thức | Bài |
|---|---|---|---|
| 0:00–0:15 | Ôn tập, kiểm tra bài về nhà | Gọi ngẫu nhiên | |
| 0:15–0:50 | Viết Dockerfile | Giảng + demo | [04](04-dockerfile.md) |
| 0:50–1:35 | **Thực hành 2** — tự đóng gói app | Học viên làm | [05](05-thuc-hanh-2.md) |
| 1:35–1:45 | ☕ Nghỉ | | |
| 1:45–2:15 | Docker Compose | Giảng | [07](07-docker-compose.md) |
| 2:15–3:00 | **Thực hành 3** — dựng cả hệ thống | Học viên làm | [08](08-thuc-hanh-3.md) |

### Buổi 3 — Tối ưu & Triển khai (3 tiếng)

| Thời gian | Nội dung | Hình thức | Bài |
|---|---|---|---|
| 0:00–0:40 | Tối ưu image — **đo tại chỗ** | Giảng + đo cùng lớp | [09](09-toi-uu-image.md) |
| 0:40–1:05 | Biến môi trường và secret | Giảng | [10](10-bien-moi-truong-va-secret.md) |
| 1:05–1:15 | ☕ Nghỉ | | |
| 1:15–1:55 | Registry và CI/CD | Demo + làm | [11](11-registry-va-cicd.md) |
| 1:55–2:40 | Triển khai lên server thật | Demo trên VPS | [12](12-trien-khai-len-server.md) |
| 2:40–3:00 | Lỗi thường gặp, tổng kết | | [13](13-loi-thuong-gap.md) |

---

## 3. Ba khoảnh khắc "à-ra-thế" — đừng bỏ lỡ

Đây là 3 điểm học viên thực sự *hiểu ra*, đáng dành thời gian làm chậm và kỹ.

### a) Dữ liệu mất khi xoá container — [Bài 3 phần B](03-thuc-hanh-1.md)

**Bắt buộc để học viên tự tay làm**, đừng chỉ giảng. Tạo bảng → xoá container → tạo lại → thấy `relation does not exist`. Khoảnh khắc đó dạy về volume hiệu quả hơn 20 phút giảng lý thuyết.

### b) Sửa code thấy ngay không cần build — [Bài 8 phần C](08-thuc-hanh-3.md)

Học viên vừa mất 30 giây build image xong, giờ sửa code thấy kết quả tức thì. Nhớ giải thích ngay **vì sao** (bind mount + `--reload`) và **vì sao production không làm vậy**.

### c) Đo 1 giây so với 21 giây — [Bài 9](09-toi-uu-image.md)

Đo **trực tiếp trên máy chiếu** trước cả lớp. Nói lý thuyết layer cache thì học viên gật đầu rồi quên; nhìn `time` chạy ra 21 giây thì nhớ mãi.

---

## 4. Những chỗ học viên chắc chắn bị kẹt

| Mốc | Lỗi điển hình | Dấu hiệu nhận biết | Xử lý |
|---|---|---|---|
| Cài đặt | Docker Desktop chưa mở | `Cannot connect to the Docker daemon` | Mở app, đợi cá voi ngừng nhấp nháy |
| Cài đặt (Win) | WSL 2 chưa cài | Docker Desktop không khởi động | `wsl --install`, khởi động lại máy |
| Cài đặt (Linux) | Chưa vào nhóm docker | `permission denied ... docker.sock` | `usermod -aG docker $USER` rồi **đăng xuất/đăng nhập lại** |
| Bài 1 | Nhầm thứ tự `-p` | Trình duyệt không vào được | Nhắc: **MÁY_BẠN:CONTAINER** |
| Bài 3 | Chưa đợi PostgreSQL khởi động | `connection refused` | `docker logs`, chờ `ready to accept connections` |
| Bài 3 | Trùng cổng 5432 với PostgreSQL cài sẵn trên máy | `port is already allocated` | Đổi `-p 5433:5432` |
| Bài 4 | Quên `--host 0.0.0.0` | Container `Up` nhưng curl rỗng | Xem log dòng `Running on` |
| Bài 4 | Đặt tên file `dockerfile.txt` | `Dockerfile not found` | Tên đúng: `Dockerfile`, **không có đuôi** |
| Bài 5 | Sửa Dockerfile nhưng quên build lại | Không thấy thay đổi | `docker build` lại |
| Bài 7 | Thụt lề YAML sai | `yaml: line X: did not find expected key` | YAML dùng **dấu cách**, không dùng Tab |
| Bài 7 | Quên tạo `.env` | `Thieu DB_PASSWORD` | `cp .env.mau .env` |
| Bài 8 | Gõ `down -v` nhầm | Mất dữ liệu vừa tạo | Nhắc lại sự khác biệt, coi như bài học |
| Bài 11 | Token thiếu scope | `denied: permission_denied` | Tạo lại token với `write:packages` |
| Mọi lúc | Hết dung lượng ổ | `no space left on device` | `docker system prune -a` |

---

## 5. Câu hỏi chốt sau mỗi phần

Gọi **ngẫu nhiên**, không nhận trả lời đồng thanh.

**Sau Bài 0–2**
- Image và container khác nhau thế nào?
- Trong `-p 8080:80`, số nào là cổng máy bạn?
- Xoá container thì dữ liệu còn không?

**Sau Bài 3–6**
- Vì sao `DB_HOST=localhost` không bao giờ chạy trong container?
- Named volume và bind mount, cái nào dùng cho production?
- Container A gọi container B đã publish `-p 5433:5432` thì dùng cổng nào?

**Sau Bài 4–5**
- `RUN` và `CMD` chạy lúc nào?
- Container `Up` mà curl không ra gì — kiểm tra gì đầu tiên?
- Vì sao copy `requirements.txt` trước `COPY . .`?

**Sau Bài 7–8**
- `down` và `down -v` khác nhau chỗ nào? Cái nào nguy hiểm?
- `depends_on: - db` đủ để đợi database sẵn sàng chưa?

**Sau Bài 9–12**
- Không có `.dockerignore` thì hại gì? *(đáp án bắt buộc phải nêu **cả** vấn đề bảo mật, không chỉ dung lượng)*
- Vì sao production phải `ports: []` cho database?
- Vì sao không dùng `latest` trên production?

---

## 6. Lưu ý riêng cho phòng học

**Mạng.** Đây là rủi ro lớn nhất. Ba phương án dự phòng:
1. Yêu cầu tải image trước ở nhà (tốt nhất)
2. Dựng registry cache nội bộ: `docker run -d -p 5000:5000 --name cache-registry registry:2`
3. Xuất image ra USB: `docker save postgres:16-alpine | gzip > pg.tar.gz`, học viên `docker load < pg.tar.gz`

**Máy Windows.** Luôn tốn thời gian gấp đôi macOS/Linux. Nếu lớp đông máy Windows, cộng thêm 30 phút cho Buổi 1.

**Buổi 3 cần server thật.** Một VPS 5 USD/tháng là đủ. Không có thì dùng máy ảo trên máy giảng viên, nhưng phần HTTPS/tên miền sẽ chỉ demo được trên lý thuyết.

---

## 7. Sau khoá học

**Quy ước cần chốt cho team** (ghi vào README của repo thật):
- Registry dùng cái nào, quy ước đặt tên và tag image
- Ai được quyền deploy production
- Quy trình rollback
- Lịch sao lưu database và **ai chịu trách nhiệm kiểm tra bản sao lưu**

**Tài liệu gửi kèm**
- [`BANG-TRA-CUU.md`](../tai-nguyen/BANG-TRA-CUU.md) — bảo học viên in ra dán bàn
- [`13-loi-thuong-gap.md`](13-loi-thuong-gap.md) — mở file này **trước khi** hỏi
