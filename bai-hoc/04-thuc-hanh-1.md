# Bài Thực Hành số 1 — Tạo file cá nhân, Commit và Push

> **Thời lượng**: 30 phút · **Hình thức**: mỗi học viên làm trên máy của mình

## Mục tiêu

Mỗi thành viên tạo 1 file thông tin cá nhân trong repo của team, commit đúng quy ước và push thành công lên GitHub.

---

## Yêu cầu đề bài

| Hạng mục | Quy định | Ví dụ |
|----------|----------|-------|
| Tên file | `Họ Tên.txt` — viết đầy đủ họ tên, **không dấu**, mỗi từ viết hoa chữ cái đầu | `Nguyen Van A.txt` |
| Nội dung | Họ tên, năm sinh (khuyến khích thêm SĐT, email, vị trí) | xem mẫu bên dưới |
| Commit message | `Họ Tên Số điện thoại` | `Nguyen Van A 0912345678` |
| Kết quả | File xuất hiện trên GitHub, nhánh `main` | |

### Mẫu nội dung file

```
Họ và tên: Nguyễn Văn A
Năm sinh: 1995
Số điện thoại: 0912345678
Email: nguyenvana@example.com
Vị trí: Backend Developer
```

---

## Cách 1 — Làm bằng dòng lệnh (khuyến nghị)

```bash
# Bước 0: vào thư mục repo đã clone ở Bài 3
cd ~/Desktop/Projects/viet-dang-git

# Bước 1: LUÔN LUÔN pull trước khi làm gì, để lấy code mới nhất của team
git pull

# Bước 2: tạo file và nhập nội dung
#   Lưu ý: tên file có khoảng trắng nên PHẢI đặt trong dấu nháy kép
cat > "Nguyen Van A.txt" <<'NOIDUNG'
Họ và tên: Nguyễn Văn A
Năm sinh: 1995
Số điện thoại: 0912345678
Email: nguyenvana@example.com
Vị trí: Backend Developer
NOIDUNG

# Bước 3: kiểm tra Git đã thấy file chưa
git status
#   -> file sẽ nằm trong mục "Untracked files" (màu đỏ)

# Bước 4: đưa file vào staging area
git add "Nguyen Van A.txt"

# Bước 5: kiểm tra lại
git status
#   -> file chuyển sang "Changes to be committed" (màu xanh)

# Bước 6: commit theo đúng format "Họ tên" "Số điện thoại"
git commit -m "Nguyen Van A 0912345678"

# Bước 7: đẩy lên GitHub
git push

# Bước 8: xác nhận
git log --oneline -3
```

Bước 8 phải in ra commit của bạn ở dòng trên cùng, ví dụ:

```
a3f9c21 (HEAD -> main, origin/main) Nguyen Van A 0912345678
7d2e1b0 Tran Thi B 0987654321
1c8b4a5 Initial commit
```

Cuối cùng mở https://github.com/tuongna247/viet-dang-git và xác nhận file của bạn có ở đó.

---

## Cách 2 — Làm bằng GUI

### GitKraken
1. Tạo file `Nguyen Van A.txt` trong thư mục repo bằng trình soạn thảo bất kỳ (VS Code, Notepad, TextEdit), nhập nội dung, **lưu lại**.
2. Quay lại GitKraken → panel bên phải hiện **Unstaged Files** → bấm **Stage All Changes**.
3. Ô **Commit Message**: gõ `Nguyen Van A 0912345678`.
4. Bấm **Commit changes to 1 file**.
5. Bấm nút **Push** trên thanh công cụ.

### Fork
1. Tạo và lưu file như trên.
2. Tab **Changes** → tick chọn file → bấm **Stage**.
3. Nhập commit message → bấm **Commit**.
4. Bấm **Push** trên toolbar.

### SourceTree
1. Tạo và lưu file như trên.
2. Tab **File Status** → tick file trong **Unstaged files** → bấm **Stage Selected**.
3. Nhập commit message ở ô dưới → bấm **Commit**.
4. Bấm **Push** → chọn nhánh `main` → **Push**.

---

## Bài tập mở rộng (nếu còn thời gian)

**Mở rộng 1 — Sửa file và commit lần 2**

```bash
echo "Sở thích: đọc sách" >> "Nguyen Van A.txt"
git status                  # file ở trạng thái "modified", KHÔNG phải "untracked"
git diff                    # xem chính xác dòng nào được thêm
git add "Nguyen Van A.txt"
git commit -m "Nguyen Van A 0912345678 - bo sung so thich"
git push
```

**Mở rộng 2 — Lấy file của đồng nghiệp về**

```bash
git pull
ls -1 *.txt                 # thấy file của các thành viên khác
```

**Mở rộng 3 — Xem ai đã viết dòng nào**

```bash
git log --oneline --graph --all
git log -p "Nguyen Van A.txt"
```

---

## Tiêu chí hoàn thành

- [ ] File tên đúng cú pháp `Họ Tên.txt`
- [ ] Nội dung có đủ họ tên và năm sinh
- [ ] Commit message đúng format `Họ Tên Số điện thoại`
- [ ] `git push` chạy thành công, không báo lỗi
- [ ] File nhìn thấy được trên giao diện web GitHub
- [ ] `git status` trả về `nothing to commit, working tree clean`
