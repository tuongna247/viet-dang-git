#!/usr/bin/env bash
#
# tao-repo-luyen-tap-16.sh — Dựng repo luyện tập cho Bài 16
#                            (rebase, gộp commit, cherry-pick, conflict)
#
# Cách chạy (macOS, Linux, Git Bash trên Windows):
#   bash tao-repo-luyen-tap-16.sh                  # tạo thư mục ./luyen-tap-16
#   bash tao-repo-luyen-tap-16.sh ~/Desktop/lt16   # hoặc chỉ định chỗ khác
#
# Script chỉ làm việc trong thư mục mới tạo, KHÔNG đụng tới repo nào khác
# và không cần mạng. "Máy chủ" là một repo rỗng nằm ngay bên cạnh, nên
# push hay force-push thoải mái mà không ảnh hưởng tới ai.
#
# Làm hỏng thì xoá thư mục đi rồi chạy lại script.

set -euo pipefail

DICH="${1:-luyen-tap-16}"
if [ -e "$DICH" ]; then
  echo "Thư mục '$DICH' đã tồn tại. Xoá nó đi, hoặc chọn tên khác:"
  echo "  bash $0 <ten-thu-muc-khac>"
  exit 1
fi

mkdir -p "$DICH"
cd "$DICH"
GOC="$(pwd)"

# ── "Máy chủ" giả lập: một repo rỗng ngay bên cạnh ─────────────
git init -q --bare may-chu.git
git --git-dir=may-chu.git symbolic-ref HEAD refs/heads/main

git init -q repo
cd repo
git checkout -q -b main        # tương thích cả Git cũ chưa có `git init -b`
git remote add origin "$GOC/may-chu.git"

# Commit mẫu ghi tên "đồng nghiệp", không đổi cấu hình danh tính của bạn
lam () {  # lam "<tên>" "<message>"
  git add -A
  git -c user.name="$1" -c user.email="dong.nghiep@congty.vn" \
      -c commit.gpgsign=false commit -q -m "$2"
  echo "    ✓ [$(git rev-parse --abbrev-ref HEAD)] $2"
}

# ─────────────────────────────────────────────────────────────
echo "==> Dựng lịch sử nhánh main"

cat > README.md <<'EOF'
# Dự án mẫu — Luyện tập Bài 16

Repo do script dựng ra để tập rebase, gộp commit và cherry-pick.
Hỏng thì xoá thư mục `luyen-tap-16` rồi chạy lại script.
EOF

mkdir -p config
cat > config/app.yml <<'EOF'
ten_ung_dung: Ung Dung Mau
phien_ban: 1.0.0
moi_truong: development

tinh_nang:
  dang_nhap: true
  thong_bao: false
  bao_cao: false
EOF

cat > bang-gia.md <<'EOF'
# Bảng giá

| Gói | Giá chưa thuế |
|---|---|
| Cơ bản | 100.000 |
| Nâng cao | 250.000 |

Thuế VAT: 8%
EOF
lam "Anh Minh" "docs: khởi tạo dự án"

cat > huong-dan.md <<'EOF'
# Hướng dẫn sử dụng

1. Đăng nhập bằng email công ty.
2. Chọn mục cần xem ở thanh bên trái.
EOF
lam "Anh Minh" "docs: thêm hướng dẫn sử dụng"

# Ba nhánh cùng tách ra từ đây
git branch release/1.0
git branch feature/bao-cao
git branch feature/thong-bao

cat > config/app.yml <<'EOF'
ten_ung_dung: Ung Dung Mau
phien_ban: 1.1.0
moi_truong: development

tinh_nang:
  dang_nhap: true
  thong_bao: false
  bao_cao: false
EOF
lam "Chị Hà" "chore: nâng phiên bản lên 1.1.0"

cat > config/app.yml <<'EOF'
ten_ung_dung: Ung Dung Mau
phien_ban: 1.1.0
moi_truong: development

tinh_nang:
  dang_nhap: true
  thong_bao: email
  bao_cao: false
EOF
lam "Chị Hà" "feat: gửi thông báo qua email"

cat > bang-gia.md <<'EOF'
# Bảng giá

| Gói | Giá chưa thuế |
|---|---|
| Cơ bản | 100.000 |
| Nâng cao | 250.000 |

Thuế VAT: 10%
EOF
lam "Anh Minh" "fix: sửa thuế VAT từ 8% thành 10%"

# ─────────────────────────────────────────────────────────────
echo "==> Nhánh release/1.0 — bản đang chạy cho khách, cần nhận bản sửa VAT"
git checkout -q release/1.0
cat > CHANGELOG.md <<'EOF'
# Ghi chú phát hành

## 1.0
- Bản phát hành đầu tiên
EOF
lam "Anh Minh" "docs: ghi chú phát hành bản 1.0"

# ─────────────────────────────────────────────────────────────
echo "==> Nhánh feature/bao-cao — bị main bỏ lại phía sau, rebase KHÔNG conflict"
git checkout -q feature/bao-cao
cat > bao-cao.md <<'EOF'
# Báo cáo doanh số

- Báo cáo theo ngày
EOF
lam "Bạn" "feat: thêm trang báo cáo doanh số"
echo "- Báo cáo theo tháng" >> bao-cao.md
lam "Bạn" "feat: thêm báo cáo theo tháng"

# ─────────────────────────────────────────────────────────────
echo "==> Nhánh feature/thong-bao — sửa đúng dòng main cũng sửa, rebase CÓ conflict"
git checkout -q feature/thong-bao
cat > config/app.yml <<'EOF'
ten_ung_dung: Ung Dung Mau
phien_ban: 1.0.0
moi_truong: development

tinh_nang:
  dang_nhap: true
  thong_bao: zalo
  bao_cao: false
EOF
lam "Bạn" "feat: gửi thông báo qua Zalo"

# ─────────────────────────────────────────────────────────────
echo "==> Nhánh feature/dang-nhap — 4 commit lặt vặt, cần gộp làm 1"
git checkout -q main
git checkout -q -b feature/dang-nhap
cat > dang-nhap.md <<'EOF'
# Trang đăng nhập

- Ô nhập email
- Ô nhập mật khẫu
EOF
lam "Bạn" "feat: thêm trang đăng nhập"
echo "- Nút Đăng nhập" >> dang-nhap.md
lam "Bạn" "fix"
cat > dang-nhap.md <<'EOF'
# Trang đăng nhập

- Ô nhập email
- Ô nhập mật khẫu
- Nút Đăng nhập
- Liên kết "Quên mật khẩu"
EOF
lam "Bạn" "fix lại"
cat > dang-nhap.md <<'EOF'
# Trang đăng nhập

- Ô nhập email
- Ô nhập mật khẩu
- Nút Đăng nhập
- Liên kết "Quên mật khẩu"
EOF
lam "Bạn" "sửa typo"

# ─────────────────────────────────────────────────────────────
echo "==> Đẩy tất cả lên máy chủ giả lập"
git checkout -q main
git push -q -u origin main release/1.0 feature/bao-cao feature/thong-bao feature/dang-nhap 2>/dev/null

echo ""
echo "════════════════════════════════════════════════════════════"
echo " Xong. Repo luyện tập nằm ở:"
echo "   $GOC/repo"
echo ""
git log --oneline --graph --all | sed 's/^/   /'
echo ""
echo " Bài tập (xem chi tiết trong Bài 16):"
echo "   16.1  rebase feature/bao-cao lên main          — không conflict"
echo "   16.2  rebase feature/thong-bao lên main        — có conflict"
echo "   16.3  gộp 4 commit của feature/dang-nhap làm 1"
echo "   16.4  cherry-pick bản sửa VAT sang release/1.0"
echo ""
echo " Bắt đầu:   cd \"$GOC/repo\""
echo " GitKraken: File → Open Repo → chọn thư mục repo ở trên"
echo "════════════════════════════════════════════════════════════"
