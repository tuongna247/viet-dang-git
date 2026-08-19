# Bài 7 — Checklist chấm bài

## Checklist cho học viên (tự kiểm tra trước khi báo cáo)

```bash
# 1. Đúng thư mục repo?
pwd && git remote -v

# 2. Working tree sạch?
git status
#    -> phải thấy: nothing to commit, working tree clean

# 3. Commit của mình đã lên chưa?
git log --oneline -5

# 4. Đã đồng bộ với server chưa?
git fetch && git status
#    -> phải thấy: Your branch is up to date with 'origin/main'
```

| # | Hạng mục | Đạt |
|---|----------|-----|
| 1 | `git --version` chạy được | ☐ |
| 2 | `git config user.name` và `user.email` đã cấu hình đúng | ☐ |
| 3 | Có file `~/.ssh/id_ed25519` và `~/.ssh/id_ed25519.pub` | ☐ |
| 4 | Public key đã thêm vào github.com/settings/keys | ☐ |
| 5 | `ssh -T git@github.com` trả về `successfully authenticated` | ☐ |
| 6 | Đã clone repo `viet-dang-git` về máy | ☐ |
| 7 | Đã tạo file `Họ Tên.txt` có họ tên + năm sinh | ☐ |
| 8 | Commit message đúng format `Họ Tên Số điện thoại` | ☐ |
| 9 | `git push` thành công | ☐ |
| 10 | File hiển thị trên giao diện web GitHub | ☐ |
| 11 | Chạy được `git status`, `git pull` và hiểu kết quả | ☐ |

---

## Câu hỏi kiểm tra kiến thức

1. Khác nhau giữa `git add` và `git commit` là gì?
2. Sau khi `git commit`, đồng nghiệp có thấy thay đổi của bạn không? Vì sao?
3. Vì sao phải `git pull` trước khi `git push`?
4. Lệnh `git commit m ''` sai ở mấy chỗ? Kể ra.
5. File nào trong cặp SSH key được dán lên GitHub? File nào tuyệt đối không được chia sẻ?
6. `git clone` và `git init` khác nhau thế nào?
7. Khi thấy `nothing to commit, working tree clean` nghĩa là gì?

<details>
<summary>Đáp án</summary>

1. `git add` đưa thay đổi vào staging area (chọn nội dung sẽ commit); `git commit` mới thực sự lưu thành một mốc trong lịch sử local.
2. Không. Commit chỉ nằm trên máy bạn, phải `git push` mới lên server để người khác thấy.
3. Để lấy commit mới của đồng nghiệp về, tránh bị GitHub từ chối push (`rejected — fetch first`) và phát hiện conflict sớm.
4. Hai chỗ: thiếu dấu `-` trước `m` (Git hiểu `m` là tên file), và message rỗng `''` (Git từ chối commit).
5. Dán file `.pub` (public key) lên GitHub. File không có đuôi `.pub` là private key — tuyệt đối không chia sẻ, không commit.
6. `git clone` tải một repo đã tồn tại từ server về; `git init` tạo repo Git mới từ thư mục trống trên máy.
7. Mọi thay đổi đã được commit hết, không còn file nào đang sửa dở hay chờ commit.

</details>
