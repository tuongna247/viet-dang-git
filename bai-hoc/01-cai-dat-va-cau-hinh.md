# Bài 1 — Cài đặt & cấu hình Git

## 1. Kiểm tra Git đã có chưa

```bash
git --version
```

Kết quả mong đợi: `git version 2.39.0` (hoặc số version bất kỳ).

Nếu báo `command not found`:

| Hệ điều hành | Cách cài |
|--------------|----------|
| macOS | `xcode-select --install` hoặc `brew install git` |
| Windows | Tải tại https://git-scm.com/download/win (cài kèm **Git Bash**) |
| Ubuntu / Debian | `sudo apt update && sudo apt install git` |

## 2. Cấu hình danh tính (BẮT BUỘC làm trước khi commit)

Tên và email này sẽ hiện trong mọi commit của bạn — hãy dùng **tên thật** và **email đăng ký GitHub**.

```bash
git config --global user.name "Nguyen Van A"
git config --global user.email "nguyenvana@example.com"
```

## 3. Cấu hình khuyến nghị thêm

```bash
# Đặt tên nhánh mặc định là main
git config --global init.defaultBranch main

# Khi git pull thì gộp bằng merge (tránh cảnh báo)
git config --global pull.rebase false

# Bật màu cho dễ đọc
git config --global color.ui auto
```

## 4. Kiểm tra lại cấu hình

```bash
git config --list
# hoặc xem riêng:
git config user.name
git config user.email
```

> **Lưu ý cho Windows**: nếu commit bị lỗi ký tự xuống dòng, chạy thêm
> `git config --global core.autocrlf true`

---

## 5. Kiểm tra nhanh toàn bộ bằng script

Thay vì gõ từng lệnh kiểm tra, chạy script có sẵn:

```bash
cd ~/Desktop/Projects/GitThucHanh
bash tai-nguyen/kiem-tra-cai-dat.sh
```

Script kiểm tra một lượt: Git đã cài chưa, danh tính đã cấu hình chưa, SSH key có chưa,
kết nối GitHub được không. Mỗi mục hỏng đều kèm lệnh sửa cụ thể.

Script **chỉ đọc thông tin**, không thay đổi gì trên máy bạn.
