# Bài 8 — `git init`: Khởi tạo repository từ con số 0

> Bài 3 dạy cách **lấy repo đã có** về máy (`git clone`).
> Bài này dạy chiều ngược lại: **bạn đã có code trên máy**, muốn đưa nó thành một repo Git và đẩy lên GitHub.

---

## 1. Khi nào dùng `git init`, khi nào dùng `git clone`?

| Tình huống | Lệnh |
|-----------|------|
| Repo đã có sẵn trên GitHub, bạn muốn tải về | `git clone` |
| Bạn mở dự án mới trên máy, chưa có gì trên server | `git init` |
| Thư mục code cũ chưa từng dùng Git, muốn bắt đầu quản lý | `git init` |

---

## 2. `git init` thực sự làm gì?

Chỉ một việc: tạo ra thư mục ẩn **`.git`** trong thư mục hiện tại.

```bash
mkdir -p ~/Desktop/Projects/du-an-moi
cd ~/Desktop/Projects/du-an-moi

git init
```

Kết quả:

```
Initialized empty Git repository in /Users/ban/Desktop/Projects/du-an-moi/.git/
```

Kiểm tra:

```bash
ls -a
# .    ..    .git          <-- thư mục .git chính là "bộ não" của repo
```

> Toàn bộ lịch sử commit, cấu hình, branch... đều nằm trong `.git`.
> **Xoá `.git` = xoá sạch lịch sử**, code vẫn còn nhưng không còn là repo Git nữa.

Nếu nhánh mặc định vẫn là `master`, đổi sang `main` cho khớp GitHub:

```bash
git branch -M main
```

---

## 3. Quy trình đầy đủ: từ thư mục trống đến GitHub

### Bước 1 — Khởi tạo và tạo nội dung

```bash
mkdir -p ~/Desktop/Projects/du-an-moi
cd ~/Desktop/Projects/du-an-moi

git init
git branch -M main

# Tạo vài file để có cái mà commit
cat > README.md <<'MD'
# Dự án mới

Dự án thực hành của team.
MD
```

### Bước 2 — Commit đầu tiên

```bash
git status              # README.md nằm trong Untracked files
git add .
git status              # README.md chuyển sang Changes to be committed
git commit -m "Initial commit"
git log --oneline
```

### Bước 3 — Tạo repo rỗng trên GitHub

1. Vào https://github.com/new
2. **Repository name**: `du-an-moi`
3. Chọn **Private** hoặc **Public**
4. ⚠️ **KHÔNG tick** "Add a README file", "Add .gitignore", "Choose a license"

> Vì sao không tick? Tick nghĩa là GitHub tự tạo 1 commit trên server. Máy bạn cũng đã có 1 commit
> riêng, hai lịch sử không liên quan gì nhau → khi push sẽ bị lỗi
> `refusing to merge unrelated histories`. Cứ để repo trên GitHub hoàn toàn rỗng.

5. Bấm **Create repository**

### Bước 4 — Nối máy với GitHub

```bash
# Thêm remote tên "origin" trỏ tới repo vừa tạo
git remote add origin git@github.com:tuongna247/du-an-moi.git

# Kiểm tra
git remote -v
```

Phải in ra:

```
origin  git@github.com:tuongna247/du-an-moi.git (fetch)
origin  git@github.com:tuongna247/du-an-moi.git (push)
```

### Bước 5 — Push lần đầu

```bash
git push -u origin main
```

Giải thích cờ `-u` (viết tắt của `--set-upstream`): nó **ghi nhớ** rằng nhánh `main` trên máy
gắn với nhánh `main` trên `origin`. Nhờ vậy **từ lần sau chỉ cần gõ `git push` và `git pull`**,
không phải viết đầy đủ `git push origin main` nữa.

Kết quả:

```
Enumerating objects: 3, done.
Writing objects: 100% (3/3), 245 bytes | 245.00 KiB/s, done.
To github.com:tuongna247/du-an-moi.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

Mở GitHub xác nhận file đã lên.

---

## 4. Trường hợp: thư mục code CŨ chưa dùng Git

Áp dụng khi bạn đã có sẵn một dự án chạy được, giờ mới muốn quản lý bằng Git.

```bash
cd ~/Desktop/Projects/du-an-cu

# 1. TẠO .gitignore TRƯỚC KHI git add — cực kỳ quan trọng
cat > .gitignore <<'IGNORE'
node_modules/
.env
.DS_Store
dist/
build/
*.log
IGNORE

# 2. Khởi tạo
git init
git branch -M main

# 3. Kiểm tra kỹ những gì sắp được commit
git status
git add .
git status              # đọc lại danh sách — KHÔNG được có node_modules hay .env

# 4. Commit và push
git commit -m "Initial commit"
git remote add origin git@github.com:tuongna247/du-an-cu.git
git push -u origin main
```

> Bước 1 phải làm **trước** `git add`. Nếu lỡ commit `node_modules/` hoặc `.env` rồi mới thêm
> `.gitignore` thì file vẫn nằm trong lịch sử — với `.env` chứa mật khẩu, đó là sự cố bảo mật thật sự.
> Xem cách gỡ ở [10-thuc-hanh-2-conflict.md](10-thuc-hanh-2-conflict.md#phần-b--gitignore).

---

## 5. Các lệnh quản lý remote

```bash
git remote -v                                    # xem danh sách remote
git remote add origin <url>                      # thêm remote mới
git remote set-url origin <url-moi>              # đổi địa chỉ remote (VD: từ HTTPS sang SSH)
git remote remove origin                         # gỡ remote
git remote rename origin upstream                # đổi tên remote
```

Đổi từ HTTPS sang SSH (hay dùng khi đã cài SSH key ở Bài 2):

```bash
git remote set-url origin git@github.com:tuongna247/du-an-moi.git
```

---

## 6. Lỗi thường gặp ở bài này

| Thông báo lỗi | Nguyên nhân | Cách xử lý |
|---|---|---|
| `remote origin already exists` | Đã `git remote add origin` trước đó | `git remote set-url origin <url>` |
| `src refspec main does not match any` | Chưa có commit nào | `git add . && git commit -m "Initial commit"` |
| `refusing to merge unrelated histories` | Repo GitHub được tạo kèm README | `git pull origin main --allow-unrelated-histories` rồi push lại |
| `Updates were rejected` | Remote có commit mà máy chưa có | `git pull origin main` rồi `git push` |
| `fatal: not a git repository` | Chưa chạy `git init`, hoặc đứng sai thư mục | `pwd` kiểm tra, rồi `git init` |

---

## 7. Bảng dán nhanh — 8 lệnh cho một repo mới

```bash
mkdir du-an-moi && cd du-an-moi
git init
git branch -M main
echo "# Du an moi" > README.md
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:tuongna247/du-an-moi.git
git push -u origin main
```
