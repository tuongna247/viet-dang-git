# Bài 14 — Compare tool: so sánh code bằng công cụ ngoài

> [Bài 12](12-theo-doi-va-discard-thay-doi.md) dùng `git diff` trong terminal. Bài này gắn **công cụ so sánh đồ hoạ**
> vào Git — dễ đọc hơn nhiều, và là thứ bắt buộc khi xử lý conflict phức tạp.

---

## 1. Vì sao cần compare tool riêng?

`git diff` trong terminal đủ dùng cho thay đổi nhỏ. Nhưng khi:

- File dài hàng trăm dòng, thay đổi rải rác
- Một khối code bị **di chuyển** chỗ khác — `git diff` báo "xoá hết rồi thêm lại hết"
- Đang **giải quyết conflict** giữa 2 nhánh
- Cần so sánh **2 thư mục** với nhau

...thì diff dạng văn bản rất khó theo dõi. Compare tool hiển thị **2 (hoặc 3) cột song song**, nối các dòng tương ứng bằng đường kẻ, tô màu từng ký tự đổi.

---

## 2. Git có sẵn cơ chế cắm tool ngoài

Đây là phần cốt lõi cần hiểu — nắm được thì cắm **tool nào cũng được**, kể cả tool tự viết.

| Lệnh | Dùng khi |
|------|----------|
| `git difftool` | **Xem** thay đổi — thay cho `git diff` |
| `git mergetool` | **Giải quyết conflict** — mở tool 3 cột |

```bash
git difftool                    # xem thay đổi chưa stage
git difftool --staged           # xem thay đổi đã stage
git difftool HEAD~1             # so với commit trước
git difftool main..feature/abc  # so 2 nhánh
git difftool -d main            # so TOÀN BỘ thư mục, không từng file
git mergetool                   # khi đang có conflict
```

> `git difftool -d` (viết tắt của `--dir-diff`) mở **toàn bộ thay đổi trong một lần** thay vì
> hỏi từng file một. Với PR lớn, đây là cách xem nhanh nhất.

### Bốn biến Git truyền cho tool

⚠️ **`$LOCAL` và `$REMOTE` mang nghĩa KHÁC NHAU** giữa `difftool` và `mergetool` — chỗ này rất hay bị nhầm khi cấu hình.

**Với `git difftool`** — chỉ có 2 biến:

| Biến | Nội dung |
|------|----------|
| `$LOCAL` | Bản **CŨ** — hiện ở cột **trái** |
| `$REMOTE` | Bản **MỚI** — hiện ở cột **phải** |

Kiểm chứng thật (sửa `gia = 100` thành `gia = 120`):

```
LOCAL  = /tmp/git-blob-g0y0Uj/gia.py  -> gia = 100          ← bản cũ, Git trích ra file tạm
REMOTE = gia.py                        -> gia = 120; thue = 10   ← file đang sửa trên máy
```

**Với `git mergetool`** — có đủ 4 biến:

| Biến | Nội dung |
|------|----------|
| `$LOCAL` | Bản **của bạn** (ours — nhánh hiện tại) |
| `$REMOTE` | Bản **của người kia** (theirs — nhánh đang merge vào) |
| `$BASE` | **Tổ tiên chung** — bản gốc trước khi hai bên tách ra |
| `$MERGED` | File **kết quả** — nơi ghi nội dung sau khi giải quyết |

### Vì sao merge cần 3 cột, không phải 2?

```
        BASE (tổ tiên chung)
        "gia = 100"
           ╱        ╲
    LOCAL            REMOTE
  "gia = 120"      "gia = 100
                    thue = 10"
```

Nhìn 2 cột (LOCAL vs REMOTE), bạn **không biết** ai đã đổi cái gì. Có `BASE` mới thấy rõ:
bạn đổi giá, người kia thêm thuế → **giữ cả hai**. Đó là lý do merge tool luôn hiện 3 cột.

---

## 3. VS Code — có sẵn, miễn phí, cài trong 1 phút

Ai cũng đã có VS Code. Đây là phương án nền, dùng được ngay trong buổi học.

**Git 2.44 trở lên đã hỗ trợ sẵn tên `vscode`** — chỉ cần 2 dòng, không phải khai báo `cmd`:

```bash
git config --global diff.tool vscode
git config --global merge.tool vscode

# Không hỏi xác nhận trước mỗi file
git config --global difftool.prompt false

# Không để lại file .orig rác sau khi merge
git config --global mergetool.keepBackup false
```

Git cũ hơn thì khai báo tay:

```bash
git config --global difftool.vscode.cmd 'code --wait --diff "$LOCAL" "$REMOTE"'
git config --global mergetool.vscode.cmd 'code --wait "$MERGED"'
```

**Xem Git hỗ trợ sẵn những tool nào:**

```bash
git difftool --tool-help
```

Trên máy giảng viên (Git 2.50.1) lệnh này in ra: `opendiff`, `vimdiff`, `vscode` đang dùng được;
và `bc`, `bc3`, `bc4`, `meld`, `kdiff3`, `winmerge`, `smerge`, `p4merge`... hợp lệ nhưng chưa cài.

> Điều kiện: lệnh `code` phải chạy được trong terminal. Nếu chưa:
> mở VS Code → `Cmd/Ctrl + Shift + P` → gõ **Shell Command: Install 'code' command in PATH**.

Kiểm tra:

```bash
git difftool HEAD~1
```

### Giao diện merge của VS Code

Khi có conflict, mở file trong VS Code sẽ thấy các nút ngay trên khối conflict:

- **Accept Current Change** — giữ bản của bạn
- **Accept Incoming Change** — giữ bản người kia
- **Accept Both Changes** — giữ cả hai
- **Compare Changes** — mở so sánh cạnh nhau

Hoặc bấm **Resolve in Merge Editor** để có giao diện 3 cột đầy đủ (LOCAL | KẾT QUẢ | REMOTE).

---

## 4. Beyond Compare

### 4.1 Bản chính thức (Scooter Software — có phí)

```bash
# macOS — cần cài Command Line Tools từ menu Beyond Compare
git config --global diff.tool bc
git config --global difftool.bc.path "/usr/local/bin/bcomp"
git config --global merge.tool bc
git config --global mergetool.bc.path "/usr/local/bin/bcomp"
git config --global mergetool.bc.trustExitCode true
```

```bash
# Windows (Git Bash)
git config --global difftool.bc.path "C:/Program Files/Beyond Compare 5/BComp.exe"
git config --global mergetool.bc.path "C:/Program Files/Beyond Compare 5/BComp.exe"
```

Git **hiểu sẵn** tên `bc` — không cần khai báo `cmd`, chỉ cần chỉ đúng đường dẫn.

> Trên macOS, mở Beyond Compare → menu **Beyond Compare** → **Install Command Line Tools**
> để tạo `/usr/local/bin/bcomp`.

### 4.2 Bản nội bộ của công ty

Team Việt Đăng có công cụ compare tự phát triển, **không mất phí bản quyền**. Cách cắm vào Git giống hệt — chỉ đổi đường dẫn:

```bash
# Đặt tên tuỳ ý, ở đây dùng "vdcompare"
DUONG_DAN="/Applications/VDCompare.app/Contents/MacOS/vdcompare"   # macOS
# DUONG_DAN="C:/Program Files/VDCompare/VDCompare.exe"             # Windows

# Diff — 2 cột
git config --global diff.tool vdcompare
git config --global difftool.vdcompare.cmd "\"$DUONG_DAN\" \"\$LOCAL\" \"\$REMOTE\""

# Merge — 3 cột + file kết quả
git config --global merge.tool vdcompare
git config --global mergetool.vdcompare.cmd "\"$DUONG_DAN\" \"\$LOCAL\" \"\$REMOTE\" \"\$BASE\" \"\$MERGED\""
git config --global mergetool.vdcompare.trustExitCode true

git config --global difftool.prompt false
git config --global mergetool.keepBackup false
```

> ⚠️ **Thứ tự tham số phải khớp với cách tool đọc đối số.** Beyond Compare nhận theo thứ tự
> `LOCAL REMOTE BASE MERGED`. Tool khác có thể khác — kiểm tra tài liệu của tool, hoặc chạy thử
> một lần với 2 file bất kỳ để xác nhận cột nào hiện nội dung nào.

`trustExitCode true` nghĩa là: tool thoát với mã 0 thì Git coi như conflict **đã giải quyết xong**.
Nếu tool của bạn chưa trả mã thoát chuẩn, đặt `false` để Git hỏi lại bằng tay.

**Kiểm tra cấu hình đã đúng chưa:**

```bash
git config --global --get-regexp 'difftool|mergetool|diff.tool|merge.tool'
git difftool HEAD~1        # phải mở đúng tool
```

---

## 5. Các lựa chọn miễn phí khác

| Tool | Nền tảng | Ghi chú |
|------|----------|---------|
| **VS Code** | Tất cả | Đã có sẵn, đủ dùng cho hầu hết trường hợp |
| **Meld** | Linux/Win/Mac | Miễn phí, chuyên diff/merge, 3 cột rõ ràng |
| **KDiff3** | Tất cả | Miễn phí, mạnh về merge tự động |
| **opendiff / FileMerge** | macOS | **Có sẵn trong Xcode Tools**, không cần cài gì thêm |
| **delta** | Terminal | Không phải GUI — làm `git diff` trong terminal đẹp và dễ đọc hơn nhiều |

```bash
# opendiff — có sẵn trên macOS
git config --global diff.tool opendiff
git config --global merge.tool opendiff

# Meld
git config --global diff.tool meld
git config --global merge.tool meld

# delta — cải thiện git diff ngay trong terminal
brew install git-delta
git config --global core.pager delta
git config --global delta.side-by-side true
git config --global delta.line-numbers true
```

> `delta` đáng cài nhất trong nhóm này: không cần rời terminal, `git diff` và `git log -p`
> lập tức dễ đọc hơn hẳn, có đánh số dòng và hiển thị 2 cột.

---

## 6. Compare có sẵn trong GUI Git

Nếu team đã dùng GUI thì thường **không cần cài tool riêng**.

### Fork
Chọn commit hoặc file → khung diff bên phải. Nút ở đầu khung để đổi giữa **Unified** (1 cột) và **Split** (2 cột). Chuột phải file → **External Diff** để mở tool ngoài đã cấu hình.

### GitKraken
Bấm vào file trong commit → diff hiện ra. Nút **Split/Unified** ở góc trên. Có chế độ so sánh 2 commit bất kỳ bằng cách giữ `Cmd/Ctrl` và chọn 2 commit trên đồ thị.

### SourceGit (bản nội bộ của team)
Bản team đang dùng là fork của [sourcegit-scm/sourcegit](https://github.com/sourcegit-scm/sourcegit), được bổ sung:

- Giao diện chỉnh theo phong cách GitKraken, kèm theme `gitkraken-dark`
- `Ctrl+Z` để hoàn tác commit vừa tạo (soft reset)
- Panel **Terminal** tích hợp
- Panel **Pull Requests** và quản lý token của dịch vụ Git

Miễn phí, mã nguồn mở, chạy được Windows/macOS/Linux. Bản build do team phát hành nội bộ — **hỏi giảng viên để lấy file cài**, chưa tải từ GitHub được.

---

## 7. Dùng compare tool để xử lý conflict

Đây là lúc compare tool phát huy tác dụng nhất.

```bash
git pull
# CONFLICT (content): Merge conflict in DANH-SACH-TEAM.txt

git status              # xem file nào conflict
git mergetool           # mở tool 3 cột cho từng file
```

Trong tool, bạn thấy 3 (hoặc 4) khung:

```
┌─────────────┬─────────────┬─────────────┐
│   LOCAL     │    BASE     │   REMOTE    │
│  (của bạn)  │  (gốc chung)│ (người kia) │
├─────────────┴─────────────┴─────────────┤
│              MERGED (kết quả)            │
│      ← nơi bạn ghi nội dung cuối cùng    │
└──────────────────────────────────────────┘
```

Cách làm:
1. Xem `BASE` để hiểu **ban đầu là gì**
2. So `LOCAL` và `REMOTE` để biết **mỗi bên đổi gì**
3. Chọn từng khối: lấy bên trái, lấy bên phải, lấy cả hai, hoặc tự gõ
4. Lưu và đóng tool

```bash
git status              # file đã hết "unmerged"
git commit -m "Giai quyet conflict"
git push
```

Muốn huỷ giữa chừng: đóng tool không lưu, rồi `git merge --abort`.

---

## 8. Bài tập

```bash
cd ~/Desktop/Projects/viet-dang-git
git pull

# 1. Cấu hình VS Code làm compare tool
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff "$LOCAL" "$REMOTE"'
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait "$MERGED"'
git config --global difftool.prompt false
git config --global mergetool.keepBackup false

# 2. Kiểm tra cấu hình
git config --global --get-regexp 'diff.tool|merge.tool|difftool|mergetool'

# 3. Thử xem thay đổi bằng tool
echo "dong moi de thu nghiem" >> "Nguyen Van A.txt"
git difftool

# 4. So sánh với commit trước
git difftool HEAD~1

# 5. So sánh TOÀN BỘ thư mục giữa 2 commit
git difftool -d HEAD~3 HEAD

# 6. Dọn dẹp
git restore "Nguyen Van A.txt"
```

**Bài tập theo cặp — giải quyết conflict bằng tool**

Làm lại kịch bản ở [Bài 10](10-thuc-hanh-2-conflict.md), nhưng lần này **không sửa tay**:

1. A và B cùng sửa dòng 1 của `DANH-SACH-TEAM.txt`
2. A push trước, B bị `rejected`
3. B chạy `git pull` → conflict
4. B chạy **`git mergetool`** thay vì mở file sửa tay
5. Trong giao diện 3 cột: đọc BASE, so LOCAL và REMOTE, giữ cả hai tên
6. Lưu, đóng, `git commit`, `git push`

So sánh: sửa tay và dùng tool, cách nào nhanh hơn? Cách nào ít sai sót hơn?

---

## 9. Câu hỏi

1. `git difftool` khác `git diff` chỗ nào?
2. Bốn biến `$LOCAL`, `$REMOTE`, `$BASE`, `$MERGED` là gì?
3. Vì sao merge tool cần **3 cột** thay vì 2?
4. `git difftool -d` khác `git difftool` thường ra sao? Khi nào nên dùng?
5. `mergetool.keepBackup false` để làm gì?
6. `trustExitCode true` nghĩa là gì? Khi nào nên để `false`?
