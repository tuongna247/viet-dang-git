# Khoá Thực Hành Git Cho Team

Repository thực hành: `git@github.com:tuongna247/viet-dang-git.git`

## Mục tiêu

Kết thúc khoá học, mỗi thành viên có thể:

1. Cài đặt Git và cấu hình danh tính (name / email) trên máy của mình.
2. Tạo SSH key và gắn vào tài khoản GitHub để xác thực không cần nhập mật khẩu.
3. Clone repository của team về máy bằng GUI tool hoặc dòng lệnh.
4. Khởi tạo repo mới từ số 0 bằng `git init` và đẩy lên GitHub.
5. Tạo file, commit và push code đúng quy ước của team.
6. Làm việc trên branch riêng và mở Pull Request để review chéo.
7. Tự xử lý merge conflict mà không cần gọi người khác.

---

## BUỔI 1 — Nền tảng (3 tiếng)

| # | Nội dung | File | Thời lượng |
|---|----------|------|-----------|
| 0 | Git là gì — các khái niệm nền tảng | [00-tong-quan.md](bai-hoc/00-tong-quan.md) | 15 phút |
| 1 | Cài đặt & cấu hình Git | [01-cai-dat-va-cau-hinh.md](bai-hoc/01-cai-dat-va-cau-hinh.md) | 15 phút |
| 2 | **Tạo SSH key** để xác thực với GitHub | [02-tao-ssh-key.md](bai-hoc/02-tao-ssh-key.md) | 25 phút |
| 3 | Kết nối repository — clone bằng CLI / GitKraken / Fork / SourceTree | [03-ket-noi-repository.md](bai-hoc/03-ket-noi-repository.md) | 20 phút |
| 4 | **Bài Thực Hành số 1** — tạo file cá nhân, commit, push | [04-thuc-hanh-1.md](bai-hoc/04-thuc-hanh-1.md) | 30 phút |
| 5 | **Các dòng lệnh Git** — status / add / commit / push / pull / log / stash | [05-lenh-terminal.md](bai-hoc/05-lenh-terminal.md) | 30 phút |
| 8 | **`git init`** — khởi tạo repo từ số 0 và push lên GitHub | [08-git-init.md](bai-hoc/08-git-init.md) | 20 phút |
| 7 | Checklist chấm bài + câu hỏi kiểm tra | [07-checklist.md](bai-hoc/07-checklist.md) | 15 phút |

## BUỔI 2 — Làm việc nhóm (2 tiếng)

| # | Nội dung | File | Thời lượng |
|---|----------|------|-----------|
| 9 | Branch và Pull Request — quy trình của dự án thật | [09-branch-va-pull-request.md](bai-hoc/09-branch-va-pull-request.md) | 60 phút |
| 10 | **Bài Thực Hành số 2** — cố ý tạo conflict và tự xử lý, `.gitignore`, `git stash` | [10-thuc-hanh-2-conflict.md](bai-hoc/10-thuc-hanh-2-conflict.md) | 45 phút |
| 6 | Lỗi thường gặp và cách xử lý | [06-loi-thuong-gap.md](bai-hoc/06-loi-thuong-gap.md) | 15 phút |

## BUỔI 3 — Làm chủ thay đổi (Thứ Tư 26/08/2026)

> 📌 **Đọc [15-phan-mem-can-cai.md](bai-hoc/15-phan-mem-can-cai.md) và cài đặt xong TRƯỚC buổi học.**
> Buổi này đi thẳng vào thực hành, không dành thời gian cho cài đặt.

| # | Nội dung | File | Thời lượng |
|---|----------|------|-----------|
| 15 | **Phần mềm cần cài** — làm trước ở nhà | [15-phan-mem-can-cai.md](bai-hoc/15-phan-mem-can-cai.md) | ở nhà |
| 12 | **Theo dõi thay đổi & discard từng dòng** — `git diff`, hunk, `git add -p`, `git restore -p` | [12-theo-doi-va-discard-thay-doi.md](bai-hoc/12-theo-doi-va-discard-thay-doi.md) | 50 phút |
| 14 | **Compare tool** — cắm công cụ so sánh vào Git, xử lý conflict bằng giao diện 3 cột | [14-compare-tool.md](bai-hoc/14-compare-tool.md) | 40 phút |
| 13 | **Pull Request hiệu quả** — PR nhỏ, tự review, cách góp ý, bảo vệ nhánh `main` | [13-pull-request-hieu-qua.md](bai-hoc/13-pull-request-hieu-qua.md) | 50 phút |

## Dành riêng cho người đứng lớp

| # | Nội dung | File |
|---|----------|------|
| 11 | Kịch bản giảng dạy — timing, chỗ học viên hay kẹt, câu hỏi chốt, **dự phòng khi mạng chặn SSH** | [11-kich-ban-giang-day.md](bai-hoc/11-kich-ban-giang-day.md) |

---

## Tài nguyên dùng khi dạy

| File | Dùng để làm gì |
|------|----------------|
| [BANG-TRA-CUU.md](tai-nguyen/BANG-TRA-CUU.md) | **Bảng tra cứu 1 trang** — in ra phát cho học viên dán bàn |
| [tai-nguyen/kiem-tra-cai-dat.sh](tai-nguyen/kiem-tra-cai-dat.sh) | Script kiểm tra máy đã sẵn sàng chưa (Git, danh tính, SSH key, kết nối GitHub). Gửi học viên chạy **trước buổi học** |
| [tai-nguyen/DANH-SACH-TEAM.txt](tai-nguyen/DANH-SACH-TEAM.txt) | File dùng chung để cố ý tạo conflict ở Bài Thực Hành số 2 |
| [tai-nguyen/Nguyen Van A.txt](tai-nguyen/Nguyen%20Van%20A.txt) | File mẫu thông tin cá nhân — chiếu lên cho học viên xem format |
| [tai-nguyen/gitignore-mau.txt](tai-nguyen/gitignore-mau.txt) | Nội dung `.gitignore` mẫu, copy vào repo thật khi cần |

### Chạy script kiểm tra

```bash
bash tai-nguyen/kiem-tra-cai-dat.sh
```

Script chỉ đọc thông tin, không thay đổi gì trên máy. Mỗi mục hỏng đều kèm dòng `→ Sửa:` với lệnh cụ thể.

---

## Chuẩn bị trước buổi học

**Học viên**
- Có tài khoản GitHub và đã được thêm làm collaborator của repo `tuongna247/viet-dang-git`.
- Đã cài 1 trong 3 tool: **GitKraken**, **Fork**, hoặc **SourceTree**.
- Máy đã cài Git — kiểm tra bằng `git --version`.

**Giảng viên** — xem đầy đủ checklist ở [11-kich-ban-giang-day.md](bai-hoc/11-kich-ban-giang-day.md#1-chuẩn-bị-trước-buổi-học-làm-trước-ít-nhất-1-ngày).

---

## Tra cứu nhanh

| Cần gì | Xem ở đâu |
|--------|-----------|
| Quên lệnh Git | [Bảng tra cứu — 05-lenh-terminal.md, mục 9](bai-hoc/05-lenh-terminal.md#9-bảng-tra-cứu-nhanh) |
| Gặp lỗi khi push/pull | [06-loi-thuong-gap.md](bai-hoc/06-loi-thuong-gap.md) |
| Lỗi `Permission denied (publickey)` | [06-loi-thuong-gap.md, mục 1](bai-hoc/06-loi-thuong-gap.md#1-permission-denied-publickey) |
| Mạng công ty chặn SSH | [11-kich-ban-giang-day.md, mục 5](bai-hoc/11-kich-ban-giang-day.md#5-dự-phòng-mạng-công-ty-chặn-ssh-port-22) |
| Đang có conflict, không biết làm gì | [10-thuc-hanh-2-conflict.md, mục A5–A9](bai-hoc/10-thuc-hanh-2-conflict.md#a5-đọc-dấu-hiệu-conflict) |

---

## Bắt đầu từ đâu?

Học viên mới vào repo này, làm theo đúng thứ tự:

```bash
# 1. Clone repo về (cần SSH key — xem Bài 2 nếu chưa có)
git clone git@github.com:tuongna247/viet-dang-git.git

# 2. Kiểm tra máy đã sẵn sàng chưa
bash tai-nguyen/kiem-tra-cai-dat.sh

# 3. Đọc bài học theo thứ tự trong bảng ở trên, bắt đầu từ Bài 0
```

Gặp lỗi thì mở [06-loi-thuong-gap.md](bai-hoc/06-loi-thuong-gap.md) **trước khi** hỏi.
Quên lệnh thì tra [tai-nguyen/BANG-TRA-CUU.md](tai-nguyen/BANG-TRA-CUU.md) — nên in ra dán bàn.
