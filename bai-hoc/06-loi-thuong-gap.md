# Bài 6 — Lỗi thường gặp & cách xử lý

## 1. `Permission denied (publickey)`

```
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
```

**Nguyên nhân**: GitHub không nhận diện được SSH key của bạn.

**Xử lý theo thứ tự:**

```bash
# a) Key đã tồn tại chưa?
ls -al ~/.ssh

# b) Key đã nạp vào agent chưa?
ssh-add -l
# Nếu báo "The agent has no identities":
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# c) Kiểm tra kết nối chi tiết
ssh -vT git@github.com
```

- Nếu vẫn lỗi: kiểm tra lại public key trên https://github.com/settings/keys — có thể bạn dán thiếu ký tự, hoặc lỡ dán nhầm **private key**.
- Kiểm tra bạn đã được chủ repo thêm làm collaborator chưa.

---

## 2. `fatal: not a git repository`

```
fatal: not a git repository (or any of the parent directories): .git
```

**Nguyên nhân**: bạn đang đứng ở thư mục không phải repo Git.

```bash
pwd                              # xem đang ở đâu
cd ~/Desktop/Projects/viet-dang-git   # vào đúng thư mục repo
ls -a                            # phải nhìn thấy thư mục .git
```

---

## 3. `error: pathspec 'm' did not match any files`

**Nguyên nhân**: gõ `git commit m ''` — thiếu dấu gạch ngang.

```bash
git commit -m "noi dung message"   # ✅ đúng
```

---

## 4. `Aborting commit due to empty commit message`

**Nguyên nhân**: message rỗng — `git commit -m ''`.

```bash
git commit -m "Nguyen Van A 0912345678"
```

---

## 5. `Please tell me who you are`

```
*** Please tell me who you are.
fatal: unable to auto-detect email address
```

**Nguyên nhân**: chưa cấu hình danh tính.

```bash
git config --global user.name "Nguyen Van A"
git config --global user.email "nguyenvana@example.com"
```

---

## 6. `Updates were rejected` khi push

```
! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'github.com:...'
```

**Nguyên nhân**: đồng nghiệp đã push trước, remote có commit mà máy bạn chưa có.

```bash
git pull        # kéo về và gộp
# nếu có conflict thì xử lý theo mục 7
git push
```

---

## 7. Merge conflict

```
CONFLICT (content): Merge conflict in "Nguyen Van A.txt"
Automatic merge failed; fix conflicts and then commit the result.
```

Mở file, bạn sẽ thấy:

```
<<<<<<< HEAD
Nội dung phiên bản CỦA BẠN
=======
Nội dung phiên bản TRÊN SERVER
>>>>>>> a3f9c21
```

**Cách xử lý:**
1. Xoá 3 dòng ký hiệu `<<<<<<<`, `=======`, `>>>>>>>`.
2. Giữ lại nội dung đúng (có thể giữ một bên, hoặc gộp cả hai).
3. Lưu file, rồi:

```bash
git add "Nguyen Van A.txt"
git commit -m "Giai quyet conflict"
git push
```

> Với xung đột phức tạp, dùng giao diện merge của GitKraken / Fork / SourceTree sẽ dễ nhìn hơn nhiều.

---

## 8. Lỡ commit nhầm

| Tình huống | Lệnh |
|-----------|------|
| Sai message, **chưa push** | `git commit --amend -m "message dung"` |
| Muốn bỏ commit cuối, **giữ lại code** | `git reset --soft HEAD~1` |
| Muốn bỏ commit cuối, **xoá cả code** ⚠️ | `git reset --hard HEAD~1` |
| Đã push rồi, muốn đảo ngược an toàn | `git revert <commit-id>` |

> Sau khi đã push, **không dùng** `reset --hard` + `push --force` trên nhánh chung — sẽ xoá mất commit của đồng nghiệp.

---

## 9. Tên file có khoảng trắng

```bash
git add Nguyen Van A.txt        # ❌ Git hiểu là 3 file riêng biệt
git add "Nguyen Van A.txt"      # ✅ đúng
git add .                       # ✅ cũng được
```

---

## 10. Thoát khỏi màn hình lạ

| Màn hình | Cách thoát |
|----------|-----------|
| `git log` hiện dấu `:` ở cuối | Nhấn `q` |
| Trình soạn thảo Vim (khi `git commit` không có `-m`) | Nhấn `Esc`, gõ `:wq`, Enter |
| Terminal treo với dấu `>` | Nhấn `Ctrl + C` |
