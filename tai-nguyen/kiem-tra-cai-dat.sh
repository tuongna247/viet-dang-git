#!/usr/bin/env bash
#
# kiem-tra-cai-dat.sh — Kiểm tra máy học viên đã sẵn sàng thực hành Git chưa
#
# Cách chạy:
#   bash kiem-tra-cai-dat.sh
#
# Script này CHỈ ĐỌC thông tin, không thay đổi gì trên máy bạn.

set -u

XANH='\033[0;32m'; DO='\033[0;31m'; VANG='\033[0;33m'; DAM='\033[1m'; HET='\033[0m'
DAT=0; HONG=0; CANHBAO=0

dat()     { printf "${XANH}  [ĐẠT]${HET}     %s\n" "$1"; DAT=$((DAT+1)); }
hong()    { printf "${DO}  [HỎNG]${HET}    %s\n" "$1"; HONG=$((HONG+1)); }
canhbao() { printf "${VANG}  [LƯU Ý]${HET}   %s\n" "$1"; CANHBAO=$((CANHBAO+1)); }
sua()     { printf "             ${VANG}→ Sửa:${HET} %s\n" "$1"; }
muc()     { printf "\n${DAM}%s${HET}\n" "$1"; }

printf "${DAM}"
echo "=================================================="
echo "  KIỂM TRA MÔI TRƯỜNG THỰC HÀNH GIT"
echo "=================================================="
printf "${HET}"

# ---------- 1. Git ----------
muc "1. Cài đặt Git"
if command -v git >/dev/null 2>&1; then
  dat "Git đã cài — $(git --version)"
else
  hong "Chưa cài Git"
  sua "macOS: brew install git | Windows: https://git-scm.com/download/win | Ubuntu: sudo apt install git"
  echo ""; echo "Chưa có Git thì không kiểm tra tiếp được. Cài Git rồi chạy lại script này."
  exit 1
fi

# ---------- 2. Danh tính ----------
muc "2. Cấu hình danh tính"
TEN=$(git config --global user.name || true)
MAIL=$(git config --global user.email || true)

if [ -n "$TEN" ]; then
  dat "user.name  = $TEN"
else
  hong "Chưa cấu hình user.name"
  sua "git config --global user.name \"Nguyen Van A\""
fi

if [ -n "$MAIL" ]; then
  case "$MAIL" in
    *@*.*) dat "user.email = $MAIL" ;;
    *)     canhbao "user.email = $MAIL — trông không giống địa chỉ email"
           sua "git config --global user.email \"ban@example.com\"" ;;
  esac
else
  hong "Chưa cấu hình user.email"
  sua "git config --global user.email \"ban@example.com\""
fi

# ---------- 3. SSH key ----------
muc "3. SSH key"
KEY=""
for k in ~/.ssh/id_ed25519 ~/.ssh/id_rsa ~/.ssh/id_ecdsa; do
  if [ -f "$k" ]; then KEY="$k"; break; fi
done

if [ -n "$KEY" ]; then
  dat "Tìm thấy private key: $KEY"
  if [ -f "${KEY}.pub" ]; then
    dat "Tìm thấy public key:  ${KEY}.pub"
    printf "             Vân tay: %s\n" "$(ssh-keygen -lf "${KEY}.pub" 2>/dev/null | awk '{print $2}')"
  else
    hong "Thiếu public key ${KEY}.pub"
    sua "ssh-keygen -y -f $KEY > ${KEY}.pub"
  fi

  QUYEN=$(ls -l "$KEY" | cut -c1-10)
  case "$QUYEN" in
    -rw-------) dat "Quyền private key đúng (600)" ;;
    *)          canhbao "Quyền private key là $QUYEN — quá mở, SSH có thể từ chối dùng"
                sua "chmod 600 $KEY" ;;
  esac
else
  hong "Chưa có SSH key nào trong ~/.ssh"
  sua "ssh-keygen -t ed25519 -C \"${MAIL:-ban@example.com}\"  (rồi nhấn Enter 3 lần)"
fi

# ---------- 4. ssh-agent ----------
muc "4. ssh-agent"
if ssh-add -l >/dev/null 2>&1; then
  dat "ssh-agent đang chạy và đã nạp $(ssh-add -l | wc -l | tr -d ' ') key"
else
  canhbao "ssh-agent chưa chạy hoặc chưa nạp key nào"
  sua "eval \"\$(ssh-agent -s)\" && ssh-add ${KEY:-~/.ssh/id_ed25519}"
fi

# ---------- 5. Kết nối GitHub ----------
muc "5. Kết nối tới GitHub"
KQ=$(ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -T git@github.com 2>&1 || true)

case "$KQ" in
  *"successfully authenticated"*)
    USER=$(echo "$KQ" | sed -n 's/^Hi \([^!]*\)!.*/\1/p')
    dat "Xác thực SSH thành công — tài khoản GitHub: ${USER:-?}"
    ;;
  *"Permission denied"*)
    hong "GitHub từ chối: Permission denied (publickey)"
    sua "Dán nội dung ${KEY:-~/.ssh/id_ed25519}.pub vào https://github.com/settings/keys"
    ;;
  *"Connection timed out"*|*"Operation timed out"*|*"Network is unreachable"*)
    hong "Không kết nối được port 22 — nhiều khả năng mạng đang chặn SSH"
    sua "Thử SSH qua port 443:  ssh -T -p 443 git@ssh.github.com"
    sua "Xem bai-hoc/11-kich-ban-giang-day.md mục 5 để cấu hình vĩnh viễn"
    ;;
  *)
    canhbao "Kết quả không rõ ràng:"
    echo "$KQ" | sed 's/^/             /'
    ;;
esac

# ---------- 6. Thư mục hiện tại ----------
muc "6. Thư mục hiện tại"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  dat "Đang đứng trong một repo Git: $(git rev-parse --show-toplevel)"
  NHANH=$(git branch --show-current 2>/dev/null || echo "?")
  printf "             Nhánh: %s\n" "$NHANH"
  REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
  if [ -n "$REMOTE" ]; then
    printf "             Remote origin: %s\n" "$REMOTE"
    case "$REMOTE" in
      https://*) canhbao "Remote đang dùng HTTPS — sẽ phải nhập token mỗi lần push"
                 sua "git remote set-url origin git@github.com:tuongna247/viet-dang-git.git" ;;
    esac
  else
    canhbao "Repo này chưa có remote origin"
    sua "git remote add origin git@github.com:tuongna247/viet-dang-git.git"
  fi
else
  canhbao "Thư mục hiện tại không phải repo Git — bình thường nếu bạn chưa clone"
  sua "git clone git@github.com:tuongna247/viet-dang-git.git ."
fi

# ---------- Tổng kết ----------
printf "\n${DAM}"
echo "=================================================="
printf "  KẾT QUẢ: ${XANH}%d đạt${HET}${DAM}  ·  ${VANG}%d lưu ý${HET}${DAM}  ·  ${DO}%d hỏng${HET}\n" "$DAT" "$CANHBAO" "$HONG"
echo "=================================================="
printf "${HET}"

if [ "$HONG" -eq 0 ]; then
  printf "${XANH}Máy bạn đã sẵn sàng thực hành. Chúc học vui!${HET}\n"
  exit 0
else
  printf "${DO}Còn %d mục cần sửa. Làm theo dòng \"→ Sửa:\" ở trên rồi chạy lại script.${HET}\n" "$HONG"
  printf "Cần trợ giúp: xem ${DAM}bai-hoc/06-loi-thuong-gap.md${HET}\n"
  exit 1
fi
