# Bài 0 — Tổng quan: Git là gì?

## 1. Git giải quyết vấn đề gì?

Không có Git, team thường làm việc kiểu:

```
baocao.docx
baocao_v2.docx
baocao_v2_final.docx
baocao_v2_final_sua_lai.docx   <-- ai sửa? sửa gì? khi nào?
```

Git ghi lại **từng thay đổi**, **ai làm**, **lúc nào**, **vì sao** — và cho phép quay ngược về bất kỳ thời điểm nào.

## 2. Bốn khu vực cần nhớ

```
  Working Directory        Staging Area          Local Repo           Remote (GitHub)
  (file bạn đang sửa)      (khu chờ commit)      (lịch sử trên máy)   (lịch sử trên server)
        │                        │                     │                      │
        │──── git add ─────────▶ │                     │                      │
        │                        │──── git commit ───▶ │                      │
        │                        │                     │──── git push ──────▶ │
        │◀───────────────────────────── git pull ──────────────────────────── │
```

| Khu vực | Ý nghĩa |
|---------|---------|
| Working Directory | Thư mục thật trên máy, nơi bạn tạo/sửa file |
| Staging Area (Index) | Nơi "gom" các thay đổi bạn muốn đưa vào commit tiếp theo |
| Local Repository | Thư mục `.git`, lưu toàn bộ lịch sử commit trên máy bạn |
| Remote Repository | Bản trên GitHub, để cả team cùng dùng |

## 3. Thuật ngữ tối thiểu

- **Repository (repo)**: kho chứa code + toàn bộ lịch sử.
- **Clone**: tải repo từ server về máy (chỉ làm 1 lần cho mỗi repo).
- **Commit**: một "ảnh chụp" trạng thái code kèm thông điệp mô tả.
- **Branch**: nhánh làm việc song song. Nhánh chính thường tên `main`.
- **Remote**: địa chỉ repo trên server, mặc định tên là `origin`.
- **Push / Pull**: đẩy commit lên server / kéo commit từ server về.

## 4. Hai cách khởi tạo repo

| Tình huống | Lệnh |
|-----------|------|
| Bắt đầu dự án mới, chưa có gì trên server | `git init` |
| Dự án đã có sẵn trên GitHub (trường hợp của buổi học này) | `git clone` |

> Trong buổi học này team dùng **`git clone`**, vì repo `viet-dang-git` đã tồn tại trên GitHub.
