# BẢNG TRA CỨU GIT — IN RA DÁN BÀN

> Một trang. In 2 mặt hoặc dán cạnh màn hình.

---

## ⭐ QUY TRÌNH HẰNG NGÀY — HỌC THUỘC

```bash
git pull                        # 1. Lấy code mới nhất TRƯỚC KHI làm gì
# ... sửa code ...
git status                      # 2. Xem mình đã thay đổi gì
git add .                       # 3. Chọn thay đổi
git commit -m "mo ta thay doi"  # 4. Lưu mốc
git pull                        # 5. Đồng bộ lần cuối
git push                        # 6. Đẩy lên
```

---

## 4 KHU VỰC CỦA GIT

```
 Working Directory      Staging Area        Local Repo        Remote (GitHub)
 (file đang sửa)        (khu chờ commit)    (lịch sử máy)     (lịch sử server)
       │                      │                   │                  │
       │─── git add ────────▶ │                   │                  │
       │                      │─ git commit ────▶ │                  │
       │                      │                   │─ git push ─────▶ │
       │◀────────────────── git pull ────────────────────────────────│
```

---

## LỆNH HAY DÙNG NHẤT

| Lệnh | Công dụng |
|------|-----------|
| `git status` | **Chạy nhiều nhất.** Xem đang có gì thay đổi |
| `git status -s` | Bản rút gọn, mỗi file 1 dòng |
| `git add .` | Đưa tất cả thay đổi vào staging |
| `git add "Ten File.txt"` | Đưa 1 file (tên có khoảng trắng → bọc nháy kép) |
| `git commit -m "message"` | Tạo commit |
| `git push` | Đẩy commit lên GitHub |
| `git pull` | Kéo commit từ GitHub về |
| `git log --oneline` | Xem lịch sử, mỗi commit 1 dòng |
| `git diff` | Xem thay đổi **chưa** `git add` |
| `git diff --staged` | Xem thay đổi **đã** `git add` |

## BRANCH

| Lệnh | Công dụng |
|------|-----------|
| `git branch` | Liệt kê nhánh (`*` = đang đứng) |
| `git checkout -b feature/abc` | Tạo nhánh mới + chuyển sang luôn |
| `git checkout main` | Chuyển về nhánh main |
| `git push -u origin feature/abc` | Push nhánh mới lần đầu |
| `git branch -d feature/abc` | Xoá nhánh đã merge |
| `git merge main` | Gộp main vào nhánh đang đứng |

## HOÀN TÁC

| Lệnh | Công dụng |
|------|-----------|
| `git restore file.txt` | Bỏ thay đổi chưa `add` |
| `git restore --staged file.txt` | Bỏ khỏi staging (giữ nội dung sửa) |
| `git commit --amend -m "moi"` | Sửa message commit cuối *(chỉ khi CHƯA push)* |
| `git revert <id>` | Đảo ngược 1 commit — **an toàn sau khi đã push** |
| `git merge --abort` | Huỷ merge, quay lại trước khi `pull` |
| `git reset --hard HEAD` | ⚠️ **XOÁ SẠCH** thay đổi chưa commit, không cứu được |

## STASH — cất tạm việc dở

| Lệnh | Công dụng |
|------|-----------|
| `git stash push -m "ghi chu"` | Cất thay đổi, working tree về sạch |
| `git stash list` | Xem danh sách đã cất |
| `git stash pop` | Lấy lại cái gần nhất |

## KHỞI TẠO

| Lệnh | Công dụng |
|------|-----------|
| `git clone <url>` | Tải repo về, tạo thư mục con |
| `git clone <url> .` | Tải repo vào **thư mục hiện tại**, không cần `cd` |
| `git init` | Tạo repo mới từ thư mục trống |
| `git remote add origin <url>` | Nối repo local với GitHub |
| `git remote -v` | Xem địa chỉ remote |
| `git push -u origin main` | Push lần đầu (`-u` để lần sau chỉ cần `git push`) |

---

## ❌ 5 LỖI GÕ SAI HAY GẶP NHẤT

| Gõ sai | Đúng phải là |
|--------|--------------|
| `git commit m ''` | `git commit -m "noi dung"` ← **thiếu dấu `-`** |
| `git commit -m ''` | `git commit -m "noi dung"` ← message **không được rỗng** |
| `git add Nguyen Van A.txt` | `git add "Nguyen Van A.txt"` ← bọc nháy kép |
| `git push` (bị rejected) | `git pull` trước, rồi `git push` |
| `git commit` (rơi vào Vim) | Nhấn `Esc` → gõ `:wq` → Enter |

---

## 🆘 THOÁT HIỂM

| Tình huống | Làm gì |
|-----------|--------|
| Màn hình `git log` hiện `:` ở cuối | Nhấn **`q`** |
| Rơi vào Vim, gõ gì cũng không được | **`Esc`** → **`:wq`** → **Enter** |
| Terminal treo, có dấu `>` | **`Ctrl + C`** |
| Đang conflict, rối quá | `git merge --abort` — an toàn, không mất gì |
| Không biết mình đang ở đâu | `pwd` và `git status` |

---

## 🔥 CONFLICT — ĐỌC 3 KÝ HIỆU

```
<<<<<<< HEAD
Nội dung CỦA BẠN
=======
Nội dung TRÊN SERVER
>>>>>>> a3f9c21
```

**Cách xử lý:** sửa file thành nội dung đúng → **xoá cả 3 dòng ký hiệu** → `git add` → `git commit` → `git push`

Kiểm tra đã sạch chưa: `grep -n '<<<<<<<\|=======\|>>>>>>>' ten-file.txt`

---

## 🔑 SSH — 6 LỆNH TẠO KEY

```bash
ssh-keygen -t ed25519 -C "email@example.com"   # 1. Tạo key → Enter 3 lần
eval "$(ssh-agent -s)"                          # 2. Bật agent
ssh-add ~/.ssh/id_ed25519                       # 3. Nạp key
pbcopy < ~/.ssh/id_ed25519.pub                  # 4. Copy (macOS)
                                                #    Windows: clip < ~/.ssh/id_ed25519.pub
# 5. Dán vào https://github.com/settings/keys
ssh -T git@github.com                           # 6. Kiểm tra
```

**Thành công khi thấy:** `Hi <tên bạn>! You've successfully authenticated`
*(câu "does not provide shell access" phía sau là bình thường, không phải lỗi)*

⚠️ Chỉ dán file **`.pub`**. File không có `.pub` là **private key — không bao giờ chia sẻ**.

---

## 📌 QUY ƯỚC CỦA TEAM

| Hạng mục | Quy định |
|----------|----------|
| Tên file cá nhân | `Ho Ten.txt` — **không dấu**, viết hoa chữ cái đầu |
| Commit message | `Họ Tên Số điện thoại` |
| Tên nhánh | `feature/mo-ta` · `fix/mo-ta` · `hotfix/mo-ta` |
| Repo | `git@github.com:tuongna247/viet-dang-git.git` |
