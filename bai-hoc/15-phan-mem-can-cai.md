# Bài 15 — Phần mềm cần cài

> Danh sách gửi học viên **trước buổi học**. Cài xong hết thì buổi học không mất thời gian vào việc cài đặt.

---

## 1. Bắt buộc

| # | Phần mềm | Dùng để làm gì | Tải ở đâu |
|---|----------|----------------|-----------|
| 1 | **Git** | Bắt buộc, mọi thứ khác chạy trên nó | https://git-scm.com/downloads |
| 2 | **VS Code** | Soạn code + **compare tool có sẵn** + xem/discard từng dòng | https://code.visualstudio.com |
| 3 | **Một GUI Git** | Nhìn lịch sử trực quan, stage/discard từng dòng dễ hơn | xem mục 2 |

### Git

| Hệ điều hành | Cách cài |
|---|---|
| **Windows** | Tải từ git-scm.com — cài kèm **Git Bash**, chọn *"Git from the command line and also from 3rd-party software"* |
| **macOS** | `xcode-select --install` hoặc `brew install git` |
| **Ubuntu/Debian** | `sudo apt update && sudo apt install git` |

Kiểm tra: `git --version`

### VS Code

Sau khi cài, **bật lệnh `code` trong terminal** (bắt buộc, để dùng làm compare tool):

`Cmd/Ctrl + Shift + P` → gõ **Shell Command: Install 'code' command in PATH**

Kiểm tra: `code --version`

---

## 2. Chọn một GUI Git

Chỉ cần **một** trong số này. Team đã dùng Fork và GitKraken.

| Tool | Giá | Nền tảng | Ưu điểm | Nhược điểm |
|------|-----|----------|---------|------------|
| **SourceGit** (bản team) | **Miễn phí** | Win/macOS/Linux | Nhẹ, nhanh, mã nguồn mở; bản team có panel Terminal và Pull Requests | Bản build phát nội bộ |
| **Fork** | 60 USD, dùng thử không giới hạn | Win/macOS | Nhanh, stage/discard từng dòng rất tốt | Không có Linux |
| **GitKraken** | Miễn phí cho repo public | Tất cả | Đồ thị đẹp, dễ cho người mới | Repo private phải trả phí, khá nặng |
| **GitHub Desktop** | Miễn phí | Win/macOS | Đơn giản nhất cho người mới | Ít tính năng nâng cao |
| **Sublime Merge** | 99 USD, dùng thử vô hạn | Tất cả | Rất nhanh | Giao diện hơi khô |

### SourceGit — bản nội bộ của team

Fork của [sourcegit-scm/sourcegit](https://github.com/sourcegit-scm/sourcegit), được team bổ sung:

- Giao diện chỉnh theo phong cách GitKraken, kèm theme `gitkraken-dark`
- `Ctrl+Z` hoàn tác commit vừa tạo (soft reset)
- Panel **Terminal** tích hợp
- Panel **Pull Requests** và quản lý token của dịch vụ Git

Miễn phí, mã nguồn mở, không giới hạn repo private — thay thế được GitKraken mà không tốn phí bản quyền.

> 📦 **Lấy bản cài**: bản build do team phát hành **nội bộ**, chưa tải từ GitHub được.
> Liên hệ giảng viên để nhận file cài trước buổi học.

---

## 3. Compare tool

| Tool | Giá | Ghi chú |
|------|-----|---------|
| **VS Code** | Miễn phí | **Đã có sẵn** — đủ dùng cho hầu hết trường hợp, ưu tiên dùng cái này |
| **Compare tool nội bộ** | **Miễn phí** | Bản do team phát triển, thay thế Beyond Compare mà không tốn phí bản quyền |
| Beyond Compare | 35–70 USD | Bản chính thức của Scooter Software |
| **Meld** | Miễn phí | https://meldmerge.org — chuyên diff/merge, 3 cột rõ ràng |
| **KDiff3** | Miễn phí | Mạnh về merge tự động |
| **opendiff** | Miễn phí | **Có sẵn trên macOS** trong Xcode Tools, không cần cài |

Cách cắm bất kỳ tool nào vào Git: xem [Bài 14](14-compare-tool.md).

> **Compare tool nội bộ**: mã nguồn hiện đang private, team sẽ có hướng dẫn triển khai riêng.
> Trong lúc chờ, dùng VS Code — cùng cơ chế, cấu hình y hệt, chỉ khác đường dẫn.

---

## 4. Nên cài thêm (không bắt buộc)

| Tool | Dùng để | Cài thế nào |
|------|---------|-------------|
| **delta** | `git diff` trong terminal đẹp và dễ đọc hơn hẳn | `brew install git-delta` |
| **gh** (GitHub CLI) | Tạo/xem/merge PR ngay trong terminal | `brew install gh` |
| **GitLens** (VS Code) | Xem ai sửa dòng nào, ngay trong editor | Cài từ Extensions |
| **Git Graph** (VS Code) | Đồ thị lịch sử trong VS Code | Cài từ Extensions |

```bash
# delta
brew install git-delta
git config --global core.pager delta
git config --global delta.side-by-side true
git config --global delta.line-numbers true

# gh
brew install gh
gh auth login          # đăng nhập GitHub
gh pr create           # tạo PR không cần mở trình duyệt
gh pr list
gh pr checkout 42      # lấy PR số 42 về máy để chạy thử
```

> `gh pr checkout` rất đáng dùng khi review: kéo nhánh của PR về máy, **chạy thử thật**
> thay vì chỉ đọc code trên trình duyệt.

---

## 5. Cấu hình sau khi cài xong

Chạy một lần trên mỗi máy:

```bash
# Danh tính — hiện trong mọi commit
git config --global user.name "Nguyen Van A"
git config --global user.email "nguyenvana@example.com"

# Nhánh mặc định
git config --global init.defaultBranch main

# Pull dùng merge, không rebase
git config --global pull.rebase false

# Màu cho dễ đọc
git config --global color.ui auto

# Compare tool
git config --global diff.tool vscode
git config --global merge.tool vscode
git config --global difftool.prompt false
git config --global mergetool.keepBackup false

# Windows: xử lý ký tự xuống dòng
# git config --global core.autocrlf true
```

Kiểm tra:

```bash
git config --global --list
```

---

## 6. Checklist trước buổi học Thứ Tư 26/08

Chạy script kiểm tra tự động:

```bash
cd ~/Desktop/Projects/viet-dang-git
bash tai-nguyen/kiem-tra-cai-dat.sh
```

Rồi tự đối chiếu:

- [ ] `git --version` chạy được
- [ ] `code --version` chạy được *(bắt buộc — cần cho compare tool)*
- [ ] `git config user.name` và `user.email` đã có
- [ ] SSH key đã thêm vào GitHub, `ssh -T git@github.com` báo `successfully authenticated`
- [ ] Đã clone repo `viet-dang-git` về máy
- [ ] Đã cài **một** GUI Git (SourceGit / Fork / GitKraken)
- [ ] `git difftool --tool-help` chạy được và thấy `vscode` trong danh sách khả dụng
- [ ] Đã đọc trước [Bài 12](12-theo-doi-va-discard-thay-doi.md)

> ⚠️ Mục nào chưa xong thì **làm trước ở nhà**. Buổi học sẽ đi thẳng vào thực hành,
> không dành thời gian cho cài đặt.
