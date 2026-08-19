# Bài 2 — Tạo SSH key để xác thực với GitHub

## 1. Vì sao cần SSH key?

Địa chỉ repo của team là dạng SSH:

```
git@github.com:tuongna247/viet-dang-git.git
```

Với SSH, GitHub xác thực bạn bằng **cặp khoá** thay vì mật khẩu:

- **Khoá riêng (private key)** — `id_ed25519` — nằm trên máy bạn, **TUYỆT ĐỐI KHÔNG chia sẻ, không commit lên repo**.
- **Khoá công khai (public key)** — `id_ed25519.pub` — dán lên GitHub.

Lợi ích: push/pull không phải nhập mật khẩu, an toàn hơn, và GitHub đã bỏ xác thực bằng mật khẩu tài khoản từ 2021.

---

## 2. Kiểm tra xem đã có key chưa

```bash
ls -al ~/.ssh
```

Nếu thấy cặp file `id_ed25519` và `id_ed25519.pub` (hoặc `id_rsa` / `id_rsa.pub`) thì bạn **đã có key**, bỏ qua bước 3, nhảy sang bước 5.

---

## 3. Tạo SSH key mới

```bash
ssh-keygen -t ed25519 -C "nguyenvana@example.com"
```

> Máy cũ không hỗ trợ ed25519 thì dùng:
> `ssh-keygen -t rsa -b 4096 -C "nguyenvana@example.com"`

Terminal sẽ hỏi 3 câu — **cứ nhấn Enter cả 3 lần** là được:

```
Enter file in which to save the key (/Users/ban/.ssh/id_ed25519):   <-- Enter (dùng đường dẫn mặc định)
Enter passphrase (empty for no passphrase):                          <-- Enter (hoặc đặt mật khẩu bảo vệ key)
Enter same passphrase again:                                         <-- Enter
```

Kết quả:

```
Your identification has been saved in /Users/ban/.ssh/id_ed25519
Your public key has been saved in /Users/ban/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx nguyenvana@example.com
```

---

## 4. Thêm key vào ssh-agent

```bash
# Khởi động ssh-agent
eval "$(ssh-agent -s)"

# Thêm private key vào agent
ssh-add ~/.ssh/id_ed25519
```

**Riêng macOS** — để lưu key vào Keychain, không phải add lại sau mỗi lần khởi động máy:

```bash
cat >> ~/.ssh/config <<'CFG'
Host github.com
  HostName github.com
  User git
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
CFG

ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

---

## 5. Copy public key

| Hệ điều hành | Lệnh |
|--------------|------|
| macOS | `pbcopy < ~/.ssh/id_ed25519.pub` |
| Windows (Git Bash) | `clip < ~/.ssh/id_ed25519.pub` |
| Linux | `xclip -sel clip < ~/.ssh/id_ed25519.pub` |
| Cách nào cũng được | `cat ~/.ssh/id_ed25519.pub` rồi bôi đen copy tay |

Nội dung copy được có dạng:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...rất dài... nguyenvana@example.com
```

> ⚠️ Chỉ copy file **`.pub`**. Nếu bạn mở file không có đuôi `.pub` và thấy dòng
> `-----BEGIN OPENSSH PRIVATE KEY-----` thì đó là khoá riêng — **dừng lại, không dán đi đâu cả**.

---

## 6. Dán key lên GitHub

1. Đăng nhập GitHub → click avatar góc phải trên → **Settings**
2. Menu trái → **SSH and GPG keys**
3. Bấm nút **New SSH key**
4. Điền:
   - **Title**: đặt tên nhận biết máy, ví dụ `Macbook cua Nguyen Van A`
   - **Key type**: `Authentication Key`
   - **Key**: dán nội dung vừa copy
5. Bấm **Add SSH key** → nhập mật khẩu GitHub để xác nhận

Link nhanh: https://github.com/settings/keys

---

## 7. Kiểm tra kết nối

```bash
ssh -T git@github.com
```

Lần đầu sẽ hỏi:

```
The authenticity of host 'github.com (140.82.121.4)' can't be established.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Gõ `yes` rồi Enter.

**Thành công** khi thấy dòng này:

```
Hi tuongna247! You've successfully authenticated, but GitHub does not provide shell access.
```

> Câu `does not provide shell access` là **bình thường**, không phải lỗi. Miễn thấy `successfully authenticated` là xong.

**Thất bại** nếu thấy:

```
git@github.com: Permission denied (publickey).
```

→ Xem cách xử lý ở [06-loi-thuong-gap.md](06-loi-thuong-gap.md).

---

## 8. Tóm tắt lệnh (bản dán nhanh cho học viên)

```bash
ssh-keygen -t ed25519 -C "email-cua-ban@example.com"   # 1. Tạo key, Enter 3 lần
eval "$(ssh-agent -s)"                                  # 2. Bật agent
ssh-add ~/.ssh/id_ed25519                               # 3. Nạp key
pbcopy < ~/.ssh/id_ed25519.pub                          # 4. Copy public key (macOS)
# 5. Dán vào github.com/settings/keys
ssh -T git@github.com                                   # 6. Kiểm tra
```
