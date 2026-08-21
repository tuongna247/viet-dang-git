# Bài 12 — Theo dõi thay đổi và Discard từng dòng

> **Buổi 3 — Thứ Tư 26/08/2026**
> Đây là bài giải quyết câu hỏi hằng ngày: *"Tôi vừa sửa những gì, và làm sao bỏ đúng phần tôi không muốn giữ?"*

---

## 1. Git nhìn thấy thay đổi như thế nào?

Git **không lưu file**, mà lưu **thay đổi theo dòng**. Hiểu điều này là hiểu mọi thứ còn lại.

```
File CŨ (đã commit)           File MỚI (đang sửa)
─────────────────────         ─────────────────────
1  def tinh_tong(a, b):       1  def tinh_tong(a, b):     ← giống nhau
2      return a + b           2      """Tinh tong."""     ← THÊM
3                             3      return a + b
4  print("xong")              4
                              5  print("hoan tat")        ← SỬA (= xoá + thêm)
```

Git diễn đạt việc đó thành:

```diff
 def tinh_tong(a, b):
+    """Tinh tong."""
     return a + b
 
-print("xong")
+print("hoan tat")
```

| Ký hiệu | Nghĩa |
|---------|-------|
| dòng bắt đầu bằng ` ` (dấu cách) | **Không đổi** — chỉ hiển thị để lấy ngữ cảnh |
| `+` | Dòng **được thêm** |
| `-` | Dòng **bị xoá** |

> Git **không có khái niệm "sửa dòng"**. Sửa một dòng = xoá dòng cũ + thêm dòng mới.

---

## 2. Đọc kết quả `git diff`

```bash
git diff                    # thay đổi CHƯA git add
git diff --staged           # thay đổi ĐÃ git add, chờ commit
git diff HEAD               # cả hai gộp lại
git diff ten-file.py        # chỉ 1 file
git diff main..feature/abc  # so sánh 2 nhánh
git diff HEAD~3 HEAD        # so 3 commit trước với hiện tại
```

Kết quả đầy đủ trông như sau:

```diff
diff --git a/tinh_toan.py b/tinh_toan.py
index 83db48f..bf269f4 100644
--- a/tinh_toan.py          ← bản CŨ
+++ b/tinh_toan.py          ← bản MỚI
@@ -1,4 +1,5 @@            ← thông tin HUNK
 def tinh_tong(a, b):
+    """Tinh tong."""
     return a + b
```

### Đọc dòng `@@ -1,4 +1,5 @@`

```
@@ -1,4 +1,5 @@
    │ │  │ │
    │ │  │ └── bản mới có 5 dòng ở đoạn này
    │ │  └──── bản mới bắt đầu từ dòng 1
    │ └─────── bản cũ có 4 dòng
    └───────── bản cũ bắt đầu từ dòng 1
```

### HUNK — khái niệm quan trọng nhất bài này

**Hunk** là một *cụm thay đổi liền nhau*. Một file sửa ở 3 chỗ cách xa nhau → Git chia thành **3 hunk**.

Vì sao cần biết? Vì Git cho phép bạn **chọn từng hunk, thậm chí từng dòng** để `add` hoặc `discard` — thay vì buộc phải lấy hoặc bỏ cả file.

Các tuỳ chọn xem diff dễ đọc hơn:

```bash
git diff --stat                  # tóm tắt: file nào, thêm/bớt bao nhiêu dòng
git diff --word-diff             # so sánh theo TỪ, không theo dòng — rất hợp file văn bản
git diff --color-words           # như trên, có màu
git diff -U10                    # hiện 10 dòng ngữ cảnh thay vì 3
git diff --ignore-all-space      # bỏ qua khác biệt về khoảng trắng
```

> `--word-diff` cực hữu ích khi sửa file `.md`, `.txt` — thay vì báo "cả dòng đổi",
> nó chỉ ra đúng chữ nào đổi.

---

## 3. Add từng phần — `git add -p`

Tình huống rất thật: bạn sửa 3 việc trong cùng một file — sửa lỗi, thêm log để debug, và đổi tên biến. Bạn muốn commit **chỉ phần sửa lỗi**, giữ lại phần còn lại.

```bash
git add -p ten-file.py
```

Git hiện **từng hunk một** và hỏi:

```diff
@@ -1,4 +1,5 @@
 def tinh_tong(a, b):
+    """Tinh tong."""
     return a + b

(1/3) Stage this hunk [y,n,q,a,d,s,e,?]?
```

### Bảng phím — học thuộc 5 phím đầu là đủ dùng

| Phím | Tác dụng |
|------|----------|
| `y` | **Yes** — stage hunk này |
| `n` | **No** — bỏ qua, không stage |
| `q` | **Quit** — thoát, giữ những gì đã chọn |
| `s` | **Split** — chia hunk lớn thành nhiều hunk nhỏ hơn |
| `e` | **Edit** — sửa tay, **chọn tới từng dòng** |
| `a` | Stage hunk này và **tất cả** hunk còn lại của file |
| `d` | **Không** stage hunk này và tất cả hunk còn lại của file |
| `?` | Hiện trợ giúp |

### `s` — chia nhỏ hunk

Khi hai thay đổi nằm gần nhau, Git gộp thành 1 hunk. Bấm `s` để tách ra, rồi chọn riêng từng phần.

### `e` — chọn tới từng DÒNG

Đây là câu trả lời cho *"làm sao discard từng dòng"*. Bấm `e`, Git mở trình soạn thảo với nội dung hunk:

```diff
# Manual hunk edit mode -- see bottom for a quick guide.
@@ -1,4 +1,7 @@
 def tinh_tong(a, b):
+    """Tinh tong."""
+    print("DEBUG: dang tinh")      ← dòng này KHÔNG muốn stage
     return a + b
```

Quy tắc sửa:

| Muốn gì | Làm gì với dòng đó |
|---------|--------------------|
| **Không** stage một dòng `+` | **Xoá hẳn dòng đó** khỏi trình soạn thảo |
| **Không** stage một dòng `-` | Đổi ký tự `-` đầu dòng thành **dấu cách** |
| Giữ nguyên | Không đụng vào |

Lưu và đóng. Chỉ những dòng còn lại được stage.

Kiểm tra kết quả:

```bash
git diff --staged     # phần sắp commit
git diff              # phần còn lại, chưa stage
```

---

## 4. Discard từng phần — bỏ thay đổi không muốn giữ

⚠️ **Nhóm lệnh nguy hiểm nhất bài này. Đã discard là KHÔNG khôi phục được** — Git chưa từng lưu nội dung đó ở đâu cả.

### Discard cả file

```bash
git restore ten-file.py            # bỏ mọi thay đổi chưa stage của file
git restore .                      # ⚠️ bỏ TẤT CẢ thay đổi chưa stage
```

### Discard từng hunk / từng dòng

```bash
git restore -p ten-file.py
```

Giao diện giống hệt `git add -p`, nhưng câu hỏi đổi thành:

```
Discard this hunk from worktree [y,n,q,a,d,s,e,?]?
```

Bấm `y` là **xoá vĩnh viễn** thay đổi đó. `e` để chọn tới từng dòng, theo đúng quy tắc ở mục 3.

### Bảng phân biệt — hay nhầm nhất

| Lệnh | Tác dụng | Khôi phục được? |
|------|----------|-----------------|
| `git restore file` | Bỏ thay đổi **chưa stage** | ❌ **KHÔNG** |
| `git restore -p file` | Bỏ **từng hunk/dòng** chưa stage | ❌ **KHÔNG** |
| `git restore --staged file` | Bỏ khỏi staging, **giữ nội dung sửa** | ✅ có |
| `git restore --staged --worktree file` | Bỏ cả staging **lẫn** nội dung sửa | ❌ **KHÔNG** |
| `git stash` | **Cất tạm** thay đổi | ✅ `git stash pop` |

> 💡 **Thói quen an toàn**: chưa chắc chắn thì `git stash` thay vì `git restore`.
> Stash lấy lại được, restore thì không. Vài giây cân nhắc đổi lấy việc không mất code.

### Sau khi đã stage rồi mới muốn bỏ

```bash
git restore --staged ten-file.py   # đưa về trạng thái chưa stage (nội dung còn nguyên)
git restore ten-file.py            # rồi mới bỏ nội dung nếu thực sự muốn
```

---

## 5. Làm bằng giao diện

### VS Code — tiện nhất cho việc discard từng dòng

1. Mở tab **Source Control** (`Ctrl/Cmd + Shift + G`)
2. Bấm vào file → hiện **màn hình so sánh 2 cột**: bản cũ bên trái, bản mới bên phải
3. Trong cột bên trái của trình soạn thảo có **thanh gutter** đánh dấu thay đổi:
   - Vạch **xanh** = dòng thêm
   - Vạch **đỏ (tam giác)** = dòng xoá
   - Vạch **xanh dương** = dòng sửa
4. **Bấm vào vạch đó** → hiện ô nhỏ với các nút:
   - **↶ Revert Change** — bỏ đúng thay đổi này
   - **+ Stage Change** — stage đúng thay đổi này
5. **Chọn tới từng dòng**: bôi đen các dòng muốn xử lý → chuột phải → **Stage Selected Ranges** / **Revert Selected Ranges**

> Đây là cách nhanh nhất cho người mới — trực quan hơn `git add -p` rất nhiều,
> nhưng làm đúng cùng một việc.

### Fork (đã cài trên máy giảng viên)

1. Tab **Changes**
2. Chọn file → khung bên phải hiện diff
3. **Bôi đen dòng** cần xử lý → chuột phải:
   - **Stage Selected Lines**
   - **Discard Selected Lines**
4. Hoặc dùng nút **Stage Hunk** / **Discard Hunk** ở đầu mỗi hunk

### GitKraken (đã cài trên máy giảng viên)

1. Bấm vào file trong khu **Unstaged Files**
2. Diff hiện ra, mỗi hunk có nút **Stage Hunk**
3. Rê chuột lên **số dòng** → hiện nút stage/discard cho riêng dòng đó
4. Nút **Discard** ở góc trên phải khung diff để bỏ cả file

---

## 6. Bài tập

Làm tuần tự, đừng bỏ bước nào.

```bash
cd ~/Desktop/Projects/viet-dang-git
git pull

# 1. Tạo file có 3 thay đổi tách biệt
cat > tinh_toan.py <<'PY'
def tinh_tong(a, b):
    return a + b

def tinh_hieu(a, b):
    return a - b

def tinh_tich(a, b):
    return a * b
PY
git add tinh_toan.py
git commit -m "Nguyen Van A 0912345678 - them file tinh toan"

# 2. Sửa 3 chỗ khác nhau
python3 - <<'PY'
s = open('tinh_toan.py').read()
s = s.replace('def tinh_tong(a, b):\n    return a + b',
              'def tinh_tong(a, b):\n    """Tinh tong hai so."""\n    return a + b')
s = s.replace('def tinh_hieu(a, b):\n    return a - b',
              'def tinh_hieu(a, b):\n    print("DEBUG: dang tru")\n    return a - b')
s = s.replace('def tinh_tich(a, b):\n    return a * b',
              'def tinh_tich(a, b):\n    """Tinh tich hai so."""\n    return a * b')
open('tinh_toan.py','w').write(s)
PY

# 3. Xem Git nhìn thấy gì
git diff
git diff --stat
```

**Yêu cầu**: chỉ commit **2 dòng docstring**, còn dòng `print("DEBUG: ...")` thì **discard hẳn**.

```bash
# 4. Stage có chọn lọc — bấm y cho 2 hunk docstring, n cho hunk DEBUG
git add -p tinh_toan.py

# 5. Kiểm tra
git diff --staged        # chỉ thấy 2 docstring
git diff                 # chỉ còn dòng DEBUG

# 6. Commit phần đã chọn
git commit -m "Nguyen Van A 0912345678 - them docstring"

# 7. Discard dòng DEBUG còn lại
git restore -p tinh_toan.py

# 8. Xác nhận sạch
git status
git diff
cat tinh_toan.py
git push
```

**Bài tập nâng cao** — thử phím `e`:

```bash
# Thêm 3 dòng liền nhau vào cùng 1 hunk
cat >> tinh_toan.py <<'PY'

def tinh_thuong(a, b):
    print("DEBUG: dang chia")
    return a / b
PY

git add -p tinh_toan.py
# Bấm "e", xoá dòng có print("DEBUG"), lưu và đóng
git diff --staged      # hàm tinh_thuong CÓ, nhưng KHÔNG có dòng DEBUG
```

---

## 7. Câu hỏi

1. Git lưu file hay lưu thay đổi theo dòng? "Sửa 1 dòng" trong diff hiện ra thế nào?
2. Dòng `@@ -1,4 +1,5 @@` nói lên điều gì?
3. Hunk là gì? Vì sao cần chia hunk?
4. Trong `git add -p`, phím `s` và `e` khác nhau ra sao?
5. `git restore file` và `git restore --staged file` — cái nào **mất** nội dung sửa?
6. Muốn bỏ thay đổi nhưng chưa chắc chắn, nên dùng lệnh gì thay cho `git restore`?
7. Trong chế độ `e`, muốn **không** stage một dòng `+` thì làm gì? Còn dòng `-`?
