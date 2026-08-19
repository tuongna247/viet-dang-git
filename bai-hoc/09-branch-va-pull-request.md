# Bài 9 — Branch và Pull Request

> Ở Bài Thực Hành số 1, cả team commit thẳng vào `main`. Cách đó ổn cho lớp học, nhưng
> **dự án thật không làm vậy**: mỗi người làm trên nhánh riêng, xong mới gộp vào `main` qua Pull Request.

---

## 1. Vì sao cần branch?

Commit thẳng vào `main` gây ra 3 vấn đề:

1. Code chưa xong, còn lỗi cũng nằm chung với code đã chạy được.
2. Nhiều người sửa cùng lúc → conflict liên tục.
3. Không ai review trước khi code vào nhánh chính.

Branch giải quyết cả ba: bạn có một "bản sao" độc lập để làm việc, `main` luôn sạch.

```
main      A───B───────────────E───   (luôn ổn định, deploy được)
               \             /
feature         C───────D───/        (nhánh của bạn, thoải mái thử nghiệm)
```

---

## 2. Các lệnh branch cơ bản

```bash
git branch                          # liệt kê nhánh local, dấu * là nhánh đang đứng
git branch -a                       # liệt kê cả nhánh trên remote

git checkout -b feature/them-thong-tin   # TẠO nhánh mới và CHUYỂN sang luôn
git switch -c feature/them-thong-tin     # cách viết mới, cùng tác dụng

git checkout main                   # chuyển về nhánh main
git switch main                     # cách viết mới

git branch -d feature/them-thong-tin     # xoá nhánh (chỉ xoá được nếu đã merge)
git branch -D feature/them-thong-tin     # ⚠️ xoá cưỡng chế, kể cả chưa merge
```

> Luôn `git checkout main && git pull` **trước khi** tạo nhánh mới, để nhánh của bạn
> xuất phát từ code mới nhất.

### Quy ước đặt tên nhánh

| Loại việc | Mẫu tên | Ví dụ |
|---|---|---|
| Tính năng mới | `feature/<mo-ta>` | `feature/them-trang-dang-nhap` |
| Sửa lỗi | `fix/<mo-ta>` | `fix/loi-sai-so-dien-thoai` |
| Việc gấp trên production | `hotfix/<mo-ta>` | `hotfix/sap-server` |
| Tài liệu | `docs/<mo-ta>` | `docs/cap-nhat-readme` |

Dùng chữ thường, không dấu, nối bằng gạch ngang.

---

## 3. Quy trình đầy đủ: từ nhánh mới đến khi merge

### Bước 1 — Tạo nhánh từ `main` mới nhất

```bash
git checkout main
git pull
git checkout -b feature/them-thong-tin-nguyen-van-a
```

### Bước 2 — Làm việc và commit

```bash
cat > "Nguyen Van A.txt" <<'NOIDUNG'
Họ và tên: Nguyễn Văn A
Năm sinh: 1995
Số điện thoại: 0912345678
NOIDUNG

git status
git add "Nguyen Van A.txt"
git commit -m "Nguyen Van A 0912345678"
```

### Bước 3 — Push nhánh lên GitHub

```bash
git push -u origin feature/them-thong-tin-nguyen-van-a
```

Terminal sẽ in ra sẵn một đường link tạo PR:

```
remote: Create a pull request for 'feature/them-thong-tin-nguyen-van-a' on GitHub by visiting:
remote:      https://github.com/tuongna247/viet-dang-git/pull/new/feature/them-thong-tin-nguyen-van-a
```

### Bước 4 — Mở Pull Request

1. Mở link ở trên, hoặc vào repo trên GitHub → tab **Pull requests** → **New pull request**
2. Kiểm tra:
   - **base**: `main` ← nhánh sẽ nhận code
   - **compare**: `feature/them-thong-tin-nguyen-van-a` ← nhánh của bạn
3. **Title**: `Nguyen Van A 0912345678`
4. **Description**: mô tả ngắn bạn đã làm gì
5. **Reviewers**: chọn người review (trong buổi học: chọn người ngồi cạnh)
6. Bấm **Create pull request**

### Bước 5 — Review

Người được chọn vào tab **Files changed**, xem thay đổi, có thể:
- Bấm vào số dòng để để lại comment tại đúng chỗ đó
- **Review changes** → chọn **Approve** (duyệt) hoặc **Request changes** (yêu cầu sửa)

Nếu bị yêu cầu sửa, tác giả chỉ cần commit tiếp trên **cùng nhánh** và push — PR tự cập nhật:

```bash
# vẫn đứng trên nhánh feature/...
git add .
git commit -m "Sua theo gop y review"
git push
```

### Bước 6 — Merge

Sau khi được Approve, bấm **Merge pull request** → **Confirm merge** → **Delete branch**.

### Bước 7 — Dọn dẹp trên máy

```bash
git checkout main
git pull                                              # lấy code vừa merge về
git branch -d feature/them-thong-tin-nguyen-van-a     # xoá nhánh local
git fetch -p                                          # dọn các nhánh remote đã bị xoá
```

---

## 4. Ba kiểu merge trên GitHub

| Kiểu | Kết quả | Nên dùng khi |
|---|---|---|
| **Create a merge commit** | Giữ nguyên mọi commit + thêm 1 commit merge | Mặc định, giữ đủ lịch sử |
| **Squash and merge** | Gộp tất cả commit của PR thành **1 commit** trên `main` | PR có nhiều commit lặt vặt kiểu "fix typo" — lịch sử `main` sạch hơn |
| **Rebase and merge** | Xếp các commit nối tiếp, không có commit merge | Muốn lịch sử thẳng tắp |

Khuyến nghị cho team mới: **Squash and merge**.

---

## 5. Lấy code mới của `main` vào nhánh đang làm

Khi nhánh của bạn làm lâu, `main` đã chạy trước khá xa:

```bash
git checkout main
git pull
git checkout feature/cua-ban
git merge main              # gộp main vào nhánh của bạn
# có conflict thì xử lý theo Bài 10, rồi:
git push
```

---

## 6. Bài tập

**Bài 9.1** — Làm lại Bài Thực Hành số 1, nhưng bằng nhánh + Pull Request:

1. `git checkout main && git pull`
2. Tạo nhánh `feature/<ten-cua-ban>`
3. Tạo file `Họ Tên.txt`, commit với message `Họ Tên SĐT`
4. Push nhánh, mở PR, gán người ngồi cạnh làm reviewer
5. Review PR của người ngồi cạnh — để lại ít nhất **1 comment** rồi **Approve**
6. Merge PR của mình, xoá nhánh cả trên GitHub lẫn local

**Bài 9.2** — Trả lời:

1. Nếu 2 người cùng tạo nhánh từ `main` và cùng sửa 1 file, chuyện gì xảy ra khi merge PR thứ hai?
2. `git branch -d` và `git branch -D` khác nhau ở đâu?
3. Vì sao phải `git pull` trên `main` trước khi tạo nhánh mới?

---

## 7. Bảng dán nhanh

```bash
git checkout main && git pull            # 1. Đứng ở main mới nhất
git checkout -b feature/ten-viec         # 2. Tạo nhánh
# ... code ...
git add . && git commit -m "mo ta"       # 3. Commit
git push -u origin feature/ten-viec      # 4. Push nhánh
# 5. Mở PR trên GitHub, xin review, merge
git checkout main && git pull            # 6. Về main lấy code mới
git branch -d feature/ten-viec           # 7. Xoá nhánh đã xong
```
