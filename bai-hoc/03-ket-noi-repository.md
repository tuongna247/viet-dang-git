# Bài 3 — Kết nối repository (Clone)

Repository của team:

```
git@github.com:tuongna247/viet-dang-git.git
```

> **Điều kiện tiên quyết**: đã hoàn thành [Bài 2 — Tạo SSH key](02-tao-ssh-key.md) và lệnh
> `ssh -T git@github.com` đã trả về `successfully authenticated`.

---

## Cách A — Dùng dòng lệnh (nhanh nhất)

### A1. Clone thẳng vào thư mục hiện tại (khuyên dùng)

Thêm dấu **`.`** ở cuối lệnh — Git sẽ đổ code ngay vào thư mục bạn đang đứng, **không tạo thêm thư mục con**, nên **không phải `cd` vào project nữa**.

```bash
# 1. Tạo và vào thư mục làm việc của bạn
mkdir -p ~/Desktop/Projects/viet-dang-git
cd ~/Desktop/Projects/viet-dang-git

# 2. Clone vào CHÍNH thư mục hiện tại (chú ý dấu chấm ở cuối)
git clone git@github.com:tuongna247/viet-dang-git.git .

# 3. Kiểm tra — làm được ngay, không cần cd thêm lần nào
git status
git remote -v
ls -a
```

> ⚠️ Thư mục hiện tại phải **rỗng**, nếu không Git báo:
> `fatal: destination path '.' already exists and is not an empty directory.`
> Kiểm tra bằng `ls -a` (chỉ thấy `.` và `..` là rỗng). Nếu đã có sẵn file,
> hãy dùng cách A2 hoặc chọn một thư mục trống khác.

### A2. Clone rồi cd vào thư mục con

```bash
# 1. Di chuyển tới thư mục muốn chứa code
cd ~/Desktop/Projects

# 2. Clone repo về — Git tự tạo thư mục viet-dang-git
git clone git@github.com:tuongna247/viet-dang-git.git

# 3. Vào thư mục vừa tải về
cd viet-dang-git

# 4. Kiểm tra
git status
git remote -v
```

### So sánh

| Lệnh | Kết quả |
|------|---------|
| `git clone <url>` | Tạo thư mục `viet-dang-git/`, phải `cd viet-dang-git` |
| `git clone <url> .` | Đổ thẳng vào thư mục hiện tại, **không cần `cd`** |
| `git clone <url> ten-khac` | Tạo thư mục tên `ten-khac` |

`git remote -v` phải in ra:

```
origin  git@github.com:tuongna247/viet-dang-git.git (fetch)
origin  git@github.com:tuongna247/viet-dang-git.git (push)
```

---

## Cách B — GitKraken

1. Mở GitKraken → **File** → **Clone Repo**
2. Chọn tab **Clone with URL**
3. Điền:
   - **Where to clone to**: thư mục chứa code, ví dụ `~/Desktop/Projects`
   - **URL**: `git@github.com:tuongna247/viet-dang-git.git`
4. Bấm **Clone the repo!**
5. Bấm **Open Now** khi có thông báo clone xong

> GitKraken cần biết SSH key: **Preferences** → **SSH** → chọn *Use local SSH agent*
> (hoặc trỏ tới `~/.ssh/id_ed25519` và `~/.ssh/id_ed25519.pub`).

---

## Cách C — Fork (macOS / Windows)

1. Mở Fork → **File** → **Clone…** (hoặc `Cmd + Shift + N`)
2. **Repository URL**: `git@github.com:tuongna247/viet-dang-git.git`
3. **Parent Directory**: chọn thư mục chứa
4. **Name**: `viet-dang-git`
5. Bấm **Clone**

---

## Cách D — SourceTree

1. Mở SourceTree → nút **Clone** (hoặc **File** → **New/Clone**)
2. **Source Path / URL**: `git@github.com:tuongna247/viet-dang-git.git`
3. **Destination Path**: thư mục chứa code trên máy
4. **Name**: `viet-dang-git`
5. Bấm **Clone**

> SourceTree có thể hỏi dùng key dạng PuTTY (`.ppk`). Vào
> **Tools** → **Options** → **General** → **SSH Client** đổi sang **OpenSSH**
> để dùng chung key đã tạo ở Bài 2.

---

## So sánh nhanh

| | Dòng lệnh | GUI (GitKraken / Fork / SourceTree) |
|---|-----------|--------------------------------------|
| Tốc độ | Nhanh nhất | Chậm hơn vài click |
| Nhìn thấy lịch sử | Cần `git log` | Trực quan, dạng cây |
| Xử lý conflict | Khó với người mới | Dễ hơn, có giao diện so sánh |
| Khi có sự cố | Thông báo lỗi rõ ràng | Đôi khi bị che bớt lỗi |

**Khuyến nghị**: học viên nên biết cả hai. GUI để nhìn tổng thể, dòng lệnh để hiểu bản chất và xử lý khi kẹt.
