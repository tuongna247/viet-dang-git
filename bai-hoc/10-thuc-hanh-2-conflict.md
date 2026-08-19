# Bài Thực Hành số 2 — Xử lý Conflict, `.gitignore` và `git stash`

> **Thời lượng**: 40 phút · **Hình thức**: chia cặp 2 người (A và B)

---

# Phần A — Cố ý tạo conflict rồi tự xử lý

Bài 6 đã *giải thích* conflict. Phần này bắt buộc bạn **gây ra** một conflict thật rồi tự gỡ —
đây là cách duy nhất để hết sợ nó.

## A1. Chuẩn bị (giảng viên làm trước, 1 lần)

Tạo sẵn file dùng chung trên `main`:

```bash
cd ~/Desktop/Projects/viet-dang-git
git checkout main && git pull

cat > DANH-SACH-TEAM.txt <<'DS'
DANH SÁCH THÀNH VIÊN TEAM
=========================
1.
2.
3.
DS

git add DANH-SACH-TEAM.txt
git commit -m "Tao file danh sach team"
git push
```

## A2. Cả hai người cùng lấy file về

**A và B đều chạy:**

```bash
git checkout main
git pull
cat DANH-SACH-TEAM.txt      # cả hai phải thấy nội dung giống hệt nhau
```

## A3. Hai người cùng sửa **dòng số 3** — nguồn gốc của conflict

**Người A** — mở `DANH-SACH-TEAM.txt`, sửa dòng `1.` thành tên mình, rồi:

```bash
git add DANH-SACH-TEAM.txt
git commit -m "Nguyen Van A 0912345678 - them ten vao danh sach"
git push
```

→ A push **thành công**.

**Người B** — cũng sửa đúng dòng `1.` đó thành tên mình, rồi:

```bash
git add DANH-SACH-TEAM.txt
git commit -m "Tran Thi B 0987654321 - them ten vao danh sach"
git push
```

→ B **bị từ chối**:

```
! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'github.com:tuongna247/viet-dang-git.git'
hint: Updates were rejected because the remote contains work that you do not have locally.
```

## A4. Người B pull về và gặp conflict

```bash
git pull
```

```
Auto-merging DANH-SACH-TEAM.txt
CONFLICT (content): Merge conflict in DANH-SACH-TEAM.txt
Automatic merge failed; fix conflicts and then commit the result.
```

Kiểm tra tình hình:

```bash
git status
```

```
You have unmerged paths.
Unmerged paths:
        both modified:   DANH-SACH-TEAM.txt
```

## A5. Đọc dấu hiệu conflict

Mở file, B sẽ thấy:

```
DANH SÁCH THÀNH VIÊN TEAM
=========================
<<<<<<< HEAD
1. Trần Thị B
=======
1. Nguyễn Văn A
>>>>>>> a3f9c21bc8e4f2d1a9b7c3e5f8d2a1b4c6e9f7a3
2.
3.
```

Cách đọc 3 ký hiệu:

| Ký hiệu | Ý nghĩa |
|---|---|
| `<<<<<<< HEAD` | Bắt đầu phần **của bạn** (commit trên máy bạn) |
| `=======` | Vạch ngăn giữa hai phiên bản |
| `>>>>>>> a3f9c21...` | Kết thúc phần **kéo từ server về** (commit của người khác) |

## A6. Giải quyết

Ở đây cả hai tên đều đúng và cần giữ lại. B sửa file thành:

```
DANH SÁCH THÀNH VIÊN TEAM
=========================
1. Nguyễn Văn A
2. Trần Thị B
3.
```

**Bắt buộc**: xoá sạch cả 3 dòng `<<<<<<<`, `=======`, `>>>>>>>`. Còn sót một dòng là code hỏng.

Kiểm tra không còn ký hiệu nào:

```bash
grep -n '<<<<<<<\|=======\|>>>>>>>' DANH-SACH-TEAM.txt
# không in ra gì = sạch
```

## A7. Hoàn tất merge

```bash
git add DANH-SACH-TEAM.txt
git status                    # "All conflicts fixed but you are still merging"
git commit -m "Tran Thi B 0987654321 - giai quyet conflict danh sach team"
git push
git log --oneline --graph -5
```

`git log --graph` sẽ cho thấy hai nhánh chụm lại — đó chính là commit merge bạn vừa tạo.

## A8. Người A xác nhận

```bash
git pull
cat DANH-SACH-TEAM.txt        # thấy đủ cả hai tên
```

## A9. Ba lệnh cứu hộ khi rối

```bash
git merge --abort        # HUỶ merge, quay lại trạng thái trước khi pull — an toàn nhất khi hoảng
git checkout --ours DANH-SACH-TEAM.txt      # lấy TOÀN BỘ bản của mình
git checkout --theirs DANH-SACH-TEAM.txt    # lấy TOÀN BỘ bản của người kia
```

> Rối quá thì cứ `git merge --abort` rồi làm lại từ đầu. Không mất gì cả.

## A10. Đổi vai

Làm lại A3–A8 với vai trò ngược lại: lần này **B push trước, A bị conflict**.

---

# Phần B — `.gitignore`

## B1. Vì sao cần?

Không phải file nào cũng nên đưa lên Git:

| Loại file | Ví dụ | Vì sao không commit |
|---|---|---|
| Thư viện tải về | `node_modules/`, `vendor/` | Nặng hàng trăm MB, ai cũng tự cài lại được |
| Bí mật | `.env`, `*.key`, `credentials.json` | **Lộ mật khẩu, API key** — sự cố bảo mật |
| File hệ điều hành | `.DS_Store`, `Thumbs.db` | Rác, gây conflict vô nghĩa |
| Kết quả build | `dist/`, `build/`, `*.class` | Sinh lại được từ source |
| File tạm của IDE | `.idea/`, `.vscode/`, `*.swp` | Cấu hình riêng từng máy |

## B2. Tạo `.gitignore`

Đặt ở **thư mục gốc** của repo:

```bash
cd ~/Desktop/Projects/viet-dang-git

cat > .gitignore <<'IGNORE'
# Hệ điều hành
.DS_Store
Thumbs.db

# Thư viện
node_modules/
vendor/

# Biến môi trường và bí mật
.env
.env.local
*.key
*.pem

# Kết quả build
dist/
build/
out/

# Log và file tạm
*.log
*.tmp
~$*

# IDE
.idea/
.vscode/
*.swp
IGNORE

git add .gitignore
git commit -m "Them .gitignore cho du an"
git push
```

## B3. Cú pháp

```gitignore
ten-file.txt        # bỏ qua đúng file này
*.log               # bỏ qua mọi file đuôi .log
thu-muc/            # bỏ qua cả thư mục (dấu / ở cuối)
/chi-o-goc.txt      # chỉ bỏ qua file ở thư mục gốc, không áp dụng thư mục con
!quan-trong.log     # NGOẠI LỆ: vẫn theo dõi file này dù đã bị *.log loại
# dòng bắt đầu bằng # là ghi chú
```

## B4. Kiểm tra

```bash
git status --ignored          # xem file nào đang bị bỏ qua
git check-ignore -v .env      # kiểm tra .env bị bỏ qua bởi luật nào
```

## B5. ⚠️ Trường hợp lỡ commit file rồi mới thêm `.gitignore`

`.gitignore` **chỉ có tác dụng với file Git chưa theo dõi**. File đã commit thì vẫn tiếp tục bị theo dõi.

```bash
# Gỡ khỏi Git nhưng GIỮ file trên máy
git rm --cached .env
git rm -r --cached node_modules/

git commit -m "Go .env va node_modules khoi git"
git push
```

> **Quan trọng**: file vẫn nằm trong **lịch sử các commit cũ**. Nếu `.env` chứa mật khẩu thật,
> **bắt buộc phải đổi toàn bộ mật khẩu / API key đó ngay** — coi như đã bị lộ. Việc xoá hẳn khỏi
> lịch sử cần `git filter-repo` hoặc BFG Repo-Cleaner, và phải báo cả team vì lịch sử bị viết lại.

---

# Phần C — `git stash`: cất tạm việc đang làm dở

## C1. Tình huống

Bạn đang sửa code dở dang thì sếp bảo sửa gấp lỗi khác. Code chưa xong, chưa muốn commit,
nhưng `git pull` hay `git checkout` lại báo lỗi:

```
error: Your local changes to the following files would be overwritten by merge
```

## C2. Cách dùng

```bash
git stash                            # cất toàn bộ thay đổi, thư mục trở về sạch
git stash push -m "dang sua trang login"   # cất kèm ghi chú (nên dùng)

git stash list                       # xem danh sách đã cất
# stash@{0}: On main: dang sua trang login
# stash@{1}: WIP on main: 7d2e1b0 ...

git stash pop                        # lấy lại cái gần nhất VÀ xoá khỏi danh sách
git stash apply stash@{1}            # lấy lại một cái cụ thể, VẪN GIỮ trong danh sách

git stash drop stash@{0}             # xoá 1 mục
git stash clear                      # ⚠️ xoá sạch mọi stash
git stash show -p stash@{0}          # xem trước nội dung đã cất
```

## C3. Bài tập C

```bash
# 1. Sửa file nhưng chưa commit
echo "dang viet do dang..." >> "Nguyen Van A.txt"
git status                  # modified

# 2. Cất đi
git stash push -m "viet do dang thong tin ca nhan"
git status                  # working tree clean — sạch bong

# 3. Giờ pull được rồi
git pull

# 4. Lấy lại việc đang làm dở
git stash pop
git status                  # modified trở lại

# 5. Làm nốt và commit
git add "Nguyen Van A.txt"
git commit -m "Nguyen Van A 0912345678 - hoan thien thong tin"
git push
```

---

## Tiêu chí hoàn thành Bài Thực Hành số 2

- [ ] Đã tự gây ra ít nhất 1 conflict thật
- [ ] Đọc và giải thích được 3 ký hiệu `<<<<<<<`, `=======`, `>>>>>>>`
- [ ] Giải quyết conflict, commit merge và push thành công
- [ ] `grep` xác nhận file không còn ký hiệu conflict nào
- [ ] Đã đổi vai và làm lại lần 2
- [ ] Biết dùng `git merge --abort` để thoát hiểm
- [ ] Đã tạo `.gitignore` và commit
- [ ] Giải thích được vì sao `.env` không được lên Git
- [ ] Dùng được `git stash` / `git stash pop`
