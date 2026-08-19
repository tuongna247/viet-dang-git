# Bài 5 — Thực hành trên Terminal: các dòng lệnh Git

## Mở Terminal / Console

| Hệ điều hành | Cách mở |
|--------------|---------|
| macOS | `Cmd + Space` → gõ `Terminal` → Enter |
| Windows | Chuột phải trong thư mục repo → **Git Bash Here** |
| Linux | `Ctrl + Alt + T` |
| VS Code | `Ctrl + \`` (phím dấu huyền, dưới phím Esc) |

Sau khi mở, di chuyển vào thư mục repo:

```bash
cd ~/Desktop/Projects/viet-dang-git
pwd     # in ra đường dẫn hiện tại để chắc chắn đã đúng chỗ
```

---

## 1. `git status` — Tôi đang ở đâu, có gì thay đổi?

Lệnh chạy nhiều nhất trong ngày. Chạy trước và sau **mọi** thao tác.

```bash
git status
git status -s      # dạng rút gọn, 1 file 1 dòng
```

**Đọc kết quả:**

```
On branch main                              <-- đang ở nhánh main
Your branch is up to date with 'origin/main'.

Untracked files:                            <-- ĐỎ: file mới, Git chưa quản lý
        Nguyen Van A.txt

Changes not staged for commit:              <-- ĐỎ: file đã sửa, chưa git add
        modified:   README.md

Changes to be committed:                    <-- XANH: đã git add, sẵn sàng commit
        new file:   Nguyen Van A.txt
```

Khi mọi thứ sạch sẽ:

```
nothing to commit, working tree clean
```

Ký hiệu của `git status -s`: `??` = file mới · `A` = đã add · `M` = đã sửa · `D` = đã xoá

---

## 2. `git add` — Chọn thay đổi để commit

```bash
git add "Nguyen Van A.txt"    # thêm 1 file (tên có khoảng trắng thì bọc nháy kép)
git add .                     # thêm TẤT CẢ thay đổi trong thư mục hiện tại
git add *.txt                 # thêm tất cả file .txt

git restore --staged file.txt # bỏ file ra khỏi staging (làm ngược lại git add)
```

> Thói quen tốt: chạy `git status` trước khi `git add .` để biết chắc mình đang thêm những gì.

---

## 3. `git commit` — Lưu lại một mốc lịch sử

```bash
git commit -m "Nguyen Van A 0912345678"
```

### ⚠️ Lỗi cú pháp cực kỳ phổ biến

```bash
git commit m ''      # ❌ SAI: thiếu dấu gạch ngang, và message rỗng
git commit -m ''     # ❌ SAI: message rỗng, Git sẽ từ chối commit
git commit -m ""     # ❌ SAI: tương tự
git commit -m "Nguyen Van A 0912345678"   # ✅ ĐÚNG
```

Giải thích:
- **Phải có dấu `-`** trước chữ `m`. Viết `m` không có gạch, Git hiểu `m` là *tên file cần commit* và báo `pathspec 'm' did not match any files`.
- **Message không được rỗng**. Git báo `Aborting commit due to empty commit message.`

### Các biến thể hữu ích

```bash
git commit -am "message"     # add + commit các file ĐÃ ĐƯỢC theo dõi (không áp dụng cho file mới)
git commit --amend -m "message moi"   # sửa lại message của commit VỪA tạo (chưa push)
```

### Quy tắc viết commit message tốt

- Ngắn gọn, dưới 72 ký tự.
- Mô tả **làm gì**, không mô tả *đã sửa file nào* (Git đã biết rồi).
- Theo quy ước của team này: `Họ Tên Số điện thoại`.

---

## 4. `git push` — Đẩy commit lên GitHub

```bash
git push                      # đẩy nhánh hiện tại lên remote đã liên kết
git push origin main          # nói rõ remote và nhánh
git push -u origin main       # lần đầu: liên kết nhánh, các lần sau chỉ cần "git push"
```

Kết quả thành công:

```
Enumerating objects: 4, done.
Writing objects: 100% (3/3), 320 bytes | 320.00 KiB/s, done.
To github.com:tuongna247/viet-dang-git.git
   7d2e1b0..a3f9c21  main -> main
```

> **Nhớ**: `commit` chỉ lưu trên máy bạn. Đồng nghiệp **không thấy gì** cho tới khi bạn `push`.

---

## 5. `git pull` — Lấy code mới nhất về

```bash
git pull                      # = git fetch + git merge
git pull origin main
```

**Quy tắc vàng: `git pull` MỖI khi bắt đầu làm việc**, và trước khi `git push`.

Nếu bỏ qua bước này, khi push bạn sẽ gặp:

```
! [rejected]  main -> main (fetch first)
error: failed to push some refs
```

Cách xử lý: `git pull` → giải quyết conflict (nếu có) → `git push` lại.

---

## 6. Các lệnh xem lịch sử

```bash
git log                       # lịch sử đầy đủ (nhấn q để thoát)
git log --oneline             # mỗi commit 1 dòng
git log --oneline --graph --all   # dạng cây, thấy cả các nhánh
git log -3                    # 3 commit gần nhất
git log -p "Nguyen Van A.txt" # lịch sử thay đổi của riêng 1 file

git show a3f9c21              # xem chi tiết 1 commit
git diff                      # xem thay đổi chưa git add
git diff --staged             # xem thay đổi đã git add, chuẩn bị commit
```

---

## 7. Lệnh hoàn tác

```bash
git restore file.txt              # bỏ thay đổi chưa add, quay về bản commit gần nhất
git restore --staged file.txt     # bỏ file khỏi staging (vẫn giữ nội dung đã sửa)
git commit --amend -m "moi"       # sửa message commit cuối (chỉ khi CHƯA push)
git revert a3f9c21                # tạo commit mới đảo ngược commit cũ (an toàn, dùng được sau khi đã push)
git reset --hard HEAD             # ⚠️ XOÁ SẠCH mọi thay đổi chưa commit — KHÔNG khôi phục được
```

---

## 7b. `git stash` — Cất tạm việc đang làm dở

Khi đang sửa code dở dang mà cần `git pull` hoặc chuyển nhánh gấp, Git sẽ chặn lại:

```
error: Your local changes to the following files would be overwritten by merge
```

```bash
git stash                              # cất mọi thay đổi, working tree trở về sạch
git stash push -m "dang sua trang login"   # cất kèm ghi chú (nên dùng)
git stash list                         # xem danh sách đã cất
git stash pop                          # lấy lại cái gần nhất và xoá khỏi danh sách
git stash apply stash@{1}              # lấy lại 1 cái cụ thể, vẫn giữ trong danh sách
git stash drop stash@{0}               # xoá 1 mục
git stash clear                        # ⚠️ xoá sạch mọi stash
```

Luồng hay dùng nhất:

```bash
git stash push -m "dang lam do"
git pull
git stash pop
```

Chi tiết và bài tập: [10-thuc-hanh-2-conflict.md](10-thuc-hanh-2-conflict.md#phần-c--git-stash-cất-tạm-việc-đang-làm-dở)

---

## 8. Quy trình chuẩn hằng ngày (học thuộc)

```bash
cd ~/Desktop/Projects/viet-dang-git

git pull                      # 1. Lấy code mới nhất
# ... sửa code ...
git status                    # 2. Xem mình đã thay đổi gì
git add .                     # 3. Chọn thay đổi
git status                    # 4. Kiểm tra lại lần nữa
git commit -m "mo ta thay doi" # 5. Lưu mốc
git pull                      # 6. Đồng bộ lần cuối trước khi đẩy
git push                      # 7. Đẩy lên
git log --oneline -3          # 8. Xác nhận
```

---

## 9. Bảng tra cứu nhanh

| Lệnh | Công dụng |
|------|-----------|
| `git clone <url>` | Tải repo về máy (làm 1 lần) |
| `git init` | Khởi tạo repo mới từ thư mục trống |
| `git status` | Xem trạng thái hiện tại |
| `git add <file>` | Đưa thay đổi vào staging |
| `git add .` | Đưa tất cả thay đổi vào staging |
| `git commit -m "msg"` | Tạo commit |
| `git push` | Đẩy commit lên remote |
| `git pull` | Kéo commit từ remote về |
| `git log --oneline` | Xem lịch sử ngắn gọn |
| `git diff` | Xem nội dung đã thay đổi |
| `git branch` | Liệt kê các nhánh |
| `git checkout -b <ten>` | Tạo và chuyển sang nhánh mới |
| `git remote -v` | Xem địa chỉ remote |
| `git restore <file>` | Hoàn tác thay đổi chưa commit |
| `git stash` / `git stash pop` | Cất tạm / lấy lại việc đang làm dở |
