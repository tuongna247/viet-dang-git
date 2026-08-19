# Bài 11 — Kịch bản cho người đứng lớp

> Tài liệu này dành cho **giảng viên**, không phát cho học viên.

---

## 1. Chuẩn bị trước buổi học (làm trước ít nhất 1 ngày)

- [ ] Thêm toàn bộ học viên làm **collaborator** của repo `tuongna247/viet-dang-git`
      (Settings → Collaborators → Add people). Không có bước này, học viên clone được nhưng **push sẽ lỗi**.
- [ ] Gửi trước cho học viên: link cài Git, link tải GitKraken/Fork/SourceTree, yêu cầu tạo tài khoản GitHub.
- [ ] Tự chạy thử toàn bộ Bài Thực Hành 1 và 2 trên máy sạch để biết chỗ nào dễ kẹt.
- [ ] Chuẩn bị sẵn file `DANH-SACH-TEAM.txt` trên `main` (xem [10-thuc-hanh-2-conflict.md](10-thuc-hanh-2-conflict.md#a1-chuẩn-bị-giảng-viên-làm-trước-1-lần)).
- [ ] Kiểm tra mạng phòng học **có chặn SSH port 22 không** — xem mục 5 bên dưới.
- [ ] Chuẩn bị 1 máy dự phòng cho học viên gặp sự cố cài đặt.
- [ ] Gửi trước học viên script [`tai-nguyen/kiem-tra-cai-dat.sh`](../tai-nguyen/kiem-tra-cai-dat.sh)
      và yêu cầu chạy ở nhà — mọi mục phải `[ĐẠT]` trước khi tới lớp. Đây là cách tiết kiệm
      thời gian nhất: phần cài đặt và SSH thường ngốn hơn nửa buổi nếu để tới lớp mới làm.
- [ ] In [`BANG-TRA-CUU.md`](../tai-nguyen/BANG-TRA-CUU.md) phát cho mỗi học viên 1 bản.
- [ ] Copy sẵn file mẫu [`tai-nguyen/Nguyen Van A.txt`](../tai-nguyen/) để chiếu lên màn hình.

---

## 2. Bảng timing

### Buổi 1 — Nền tảng (3 tiếng)

| Thời gian | Nội dung | Hình thức | Bài |
|---|---|---|---|
| 0:00–0:15 | Git giải quyết vấn đề gì, 4 khu vực | Giảng + vẽ bảng | [00](00-tong-quan.md) |
| 0:15–0:30 | Cài đặt, `git config` danh tính | Học viên làm trên máy | [01](01-cai-dat-va-cau-hinh.md) |
| 0:30–0:55 | **Tạo SSH key** | Học viên làm, GV đi vòng kiểm tra | [02](02-tao-ssh-key.md) |
| 0:55–1:05 | ☕ Nghỉ | | |
| 1:05–1:25 | Clone repo (CLI + GUI) | Học viên làm | [03](03-ket-noi-repository.md) |
| 1:25–1:55 | **Bài Thực Hành số 1** | Học viên làm độc lập | [04](04-thuc-hanh-1.md) |
| 1:55–2:25 | Các lệnh terminal | Giảng + gõ theo | [05](05-lenh-terminal.md) |
| 2:25–2:45 | `git init` từ số 0 | Demo + học viên làm theo | [08](08-git-init.md) |
| 2:45–3:00 | Hỏi đáp, checklist | | [07](07-checklist.md) |

### Buổi 2 — Làm việc nhóm (2 tiếng)

| Thời gian | Nội dung | Hình thức | Bài |
|---|---|---|---|
| 0:00–0:15 | Ôn tập, kiểm tra bài về nhà | Gọi ngẫu nhiên | |
| 0:15–0:45 | Branch + Pull Request | Giảng + demo | [09](09-branch-va-pull-request.md) |
| 0:45–1:15 | Bài 9.1 — làm PR, review chéo | Học viên làm theo cặp | [09](09-branch-va-pull-request.md) |
| 1:15–1:25 | ☕ Nghỉ | | |
| 1:25–1:55 | **Bài Thực Hành số 2** — conflict | Chia cặp A/B | [10](10-thuc-hanh-2-conflict.md) |
| 1:55–2:10 | `.gitignore`, `git stash` | Giảng nhanh + làm | [10](10-thuc-hanh-2-conflict.md) |
| 2:10–2:20 | Lỗi thường gặp, hỏi đáp | | [06](06-loi-thuong-gap.md) |

> Lớp trên 10 người: cộng thêm 15–20 phút cho phần SSH — đây luôn là phần tốn thời gian nhất.

---

## 3. Những chỗ học viên chắc chắn bị kẹt

Giảng viên nên **đi vòng quanh lớp** ở các mốc này thay vì đứng trên bục.

| Mốc | Lỗi điển hình | Cách nhận biết nhanh | Xử lý |
|---|---|---|---|
| Sau `git config` | Bỏ qua bước này | `git config user.email` không ra gì | Chạy lại lệnh config |
| `ssh-keygen` | Sợ, không dám nhấn Enter | Học viên ngồi im nhìn màn hình | Nói rõ: "cứ Enter 3 lần" |
| Copy public key | Copy nhầm **private key** | Nội dung có `BEGIN OPENSSH PRIVATE KEY` | Nhấn mạnh: **chỉ file `.pub`** |
| Dán key lên GitHub | Dán thiếu ký tự đầu/cuối | `ssh -T` báo `Permission denied` | Xoá key trên GitHub, dán lại |
| `ssh -T` | Tưởng `does not provide shell access` là lỗi | Học viên gọi GV | Giải thích: đó là bình thường |
| `git clone` | Đứng sai thư mục | `pwd` ra chỗ lạ | `pwd` rồi `cd` lại |
| Tạo file | Tên file có dấu tiếng Việt | Tên file lạ khi `ls` | Quy định: **không dấu** |
| `git add` | Tên file có khoảng trắng, không bọc nháy | `did not match any files` | Dùng `git add .` hoặc bọc `"..."` |
| `git commit` | Gõ `git commit m ''` | `pathspec 'm' did not match` | Chỉ vào dấu `-` còn thiếu |
| `git commit` | Rơi vào Vim khi quên `-m` | Màn hình đầy chữ, gõ gì cũng không được | `Esc` → `:wq` → Enter |
| `git push` | Chưa được add collaborator | `Permission to ... denied` | GV add ngay trên GitHub |
| `git push` | Người khác push trước | `rejected — fetch first` | `git pull` rồi push lại |

---

## 4. Câu hỏi chốt sau mỗi phần

Gọi **ngẫu nhiên**, không nhận câu trả lời đồng thanh.

**Sau Bài 0–1**
- 4 khu vực của Git là gì? Lệnh nào chuyển giữa từng cặp?
- Vì sao phải `git config user.email` trước khi commit?

**Sau Bài 2 (SSH)**
- File nào dán lên GitHub? File nào tuyệt đối không được chia sẻ?
- `ssh -T git@github.com` in ra gì thì gọi là thành công?

**Sau Bài 3–4**
- `git clone` khác `git init` chỗ nào?
- Commit rồi mà chưa push thì đồng nghiệp có thấy không? Vì sao?

**Sau Bài 5**
- `git add` khác `git commit` chỗ nào?
- `git commit m ''` sai mấy chỗ?
- Vì sao phải `git pull` trước khi `git push`?

**Sau Bài 9–10**
- Vì sao không nên commit thẳng vào `main`?
- Thấy `<<<<<<< HEAD` nghĩa là gì? Phần nào là của mình?
- Lỡ commit `.env` chứa mật khẩu rồi thì phải làm gì? *(đáp án bắt buộc: **đổi mật khẩu ngay**, không chỉ xoá file)*

---

## 5. Dự phòng: mạng công ty chặn SSH port 22

Rất phổ biến ở văn phòng và một số nhà mạng VN. Dấu hiệu: `ssh -T git@github.com` **treo rất lâu** rồi báo:

```
ssh: connect to host github.com port 22: Connection timed out
```

### Cách 1 — Dùng SSH qua port 443 (khuyên dùng, giữ nguyên SSH key)

Kiểm tra port 443 có thông không:

```bash
ssh -T -p 443 git@ssh.github.com
```

Thấy `Hi <username>! You've successfully authenticated` là được. Cấu hình để dùng vĩnh viễn:

```bash
cat >> ~/.ssh/config <<'CFG'
Host github.com
  HostName ssh.github.com
  Port 443
  User git
CFG

ssh -T git@github.com     # kiểm tra lại
```

Từ giờ mọi lệnh `git clone/push/pull` với địa chỉ `git@github.com:...` vẫn chạy bình thường.

### Cách 2 — Chuyển sang HTTPS + Personal Access Token

Dùng khi cả port 22 lẫn 443 SSH đều bị chặn.

**Tạo token:**
1. https://github.com/settings/tokens → **Generate new token (classic)**
2. **Note**: `Git tren may lam viec`
3. **Expiration**: 90 days
4. **Scopes**: tick **`repo`**
5. **Generate token** → **copy ngay** (chuỗi `ghp_...`). Đóng trang là **không xem lại được nữa**.

**Dùng token:**

```bash
# Đổi remote từ SSH sang HTTPS
git remote set-url origin https://github.com/tuongna247/viet-dang-git.git

git push
# Username: tuongna247
# Password: DÁN TOKEN vào đây, KHÔNG phải mật khẩu GitHub
```

**Lưu token để khỏi nhập lại:**

```bash
# macOS
git config --global credential.helper osxkeychain

# Windows
git config --global credential.helper manager

# Linux (lưu 1 tiếng trong RAM)
git config --global credential.helper 'cache --timeout=3600'
```

> ⚠️ Token có quyền như mật khẩu. Không dán vào chat nhóm, không commit vào code.
> Đặt hạn dùng và thu hồi khi không cần.

### Bảng chọn nhanh

| Tình huống | Giải pháp |
|---|---|
| Mạng bình thường | SSH port 22 (Bài 2) |
| Chặn port 22 | SSH qua port 443 — Cách 1 |
| Chặn cả SSH | HTTPS + Token — Cách 2 |
| Máy dùng chung / máy khách | HTTPS + Token, **không lưu credential** |

---

## 6. Sau buổi học

**Bài về nhà**
1. Tạo repo cá nhân mới bằng `git init` và push lên GitHub (Bài 8).
2. Tạo 3 commit trên repo đó với message có nghĩa.
3. Nộp link repo vào group.

**Tài liệu gửi kèm**
- Link thư mục bài học này
- [05-lenh-terminal.md](05-lenh-terminal.md) mục 9 — bảng tra cứu, khuyến khích in ra dán bàn
- [06-loi-thuong-gap.md](06-loi-thuong-gap.md) — bảo học viên mở file này **trước khi** hỏi

**Quy ước chốt cho team** (thống nhất và ghi vào README của repo thật)
- Format commit message
- Quy ước đặt tên branch
- Bắt buộc PR hay được push thẳng `main`?
- Số reviewer tối thiểu cho mỗi PR
