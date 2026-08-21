# Bài 13 — Quy trình Pull Request hiệu quả

> [Bài 9](09-branch-va-pull-request.md) dạy **cách** mở PR. Bài này dạy **cách làm cho nó hiệu quả** —
> để PR được duyệt nhanh, ít qua lại, và không ai sợ review.

---

## 1. Vì sao PR của team thường chậm?

| Triệu chứng | Nguyên nhân thật |
|---|---|
| PR nằm 3 ngày không ai duyệt | PR quá lớn, reviewer thấy 40 file là ngại mở |
| Review qua lại 5–6 vòng | Tác giả không tự đọc lại trước khi gửi |
| "Chỗ này để làm gì?" | Mô tả PR trống, reviewer phải đoán |
| Merge xong thì hỏng | Không ai chạy thử, chỉ đọc code |
| Reviewer và tác giả căng thẳng | Góp ý viết như phán xét con người |

Cả 5 vấn đề đều **giải quyết được bằng quy trình**, không phải bằng việc cố gắng hơn.

---

## 2. Nguyên tắc số 1: PR NHỎ

Đây là điều quan trọng nhất bài học. Mọi thứ khác chỉ là phụ.

| Kích thước PR | Thời gian chờ duyệt | Chất lượng review |
|---|---|---|
| < 100 dòng | Vài chục phút | Đọc kỹ từng dòng |
| 100–400 dòng | Nửa ngày | Còn đọc được |
| 400–1000 dòng | 1–2 ngày | Đọc lướt |
| > 1000 dòng | Vài ngày | **"LGTM"** — duyệt mà không thực sự đọc |

> PR quá lớn không được review kỹ hơn — nó được review **tệ hơn**. Reviewer mệt, bỏ qua chi tiết,
> và bug lọt vào `main` chính vì PR to.

### Làm sao để PR nhỏ?

**Một PR = một mục đích.** Nếu phần mô tả của bạn phải dùng chữ "và", nhiều khả năng nên tách:

| ❌ Một PR | ✅ Tách thành |
|---|---|
| "Thêm trang đăng nhập **và** sửa lỗi hiển thị ngày **và** đổi tên biến" | 3 PR riêng |

Đang làm dở mà phát hiện thứ cần sửa không liên quan? Ghi lại, làm PR sau. Đừng nhét vào PR đang mở.

**Tách theo tầng** khi tính năng lớn:

```
PR 1: Thêm bảng dữ liệu + migration        (nhỏ, dễ duyệt)
PR 2: Thêm API đọc/ghi                     (dựa trên PR 1)
PR 3: Thêm giao diện                       (dựa trên PR 2)
```

---

## 3. Trước khi bấm "Create pull request"

### Bước bắt buộc: TỰ REVIEW

**Luôn tự đọc diff của mình trước khi gửi.** Bước này tốn 5 phút và cắt được phần lớn vòng qua lại.

```bash
git diff main...HEAD              # xem toàn bộ thay đổi của nhánh
git diff main...HEAD --stat       # tóm tắt file nào đổi bao nhiêu
```

Hoặc mở PR ở chế độ **Draft** rồi tự đọc tab **Files changed** — đọc trên giao diện GitHub dễ phát hiện lỗi hơn đọc trong IDE, vì bạn nhìn bằng con mắt của người khác.

Checklist tự review:

- [ ] Còn `print()` / `console.log()` debug nào không?
- [ ] Còn code đã comment lại mà quên xoá không?
- [ ] Còn mật khẩu, API key, đường dẫn máy cá nhân không?
- [ ] File nào lọt vào ngoài ý muốn không? (`.env`, `.DS_Store`, file build)
- [ ] Tên biến, tên hàm có dễ hiểu không?
- [ ] Đã tự chạy thử chưa?

> Dùng [`git add -p`](12-theo-doi-va-discard-thay-doi.md) ngay từ lúc commit thì PR sẽ sạch sẵn —
> không lẫn dòng debug vào.

### Dọn commit trước khi gửi

```bash
git log --oneline main..HEAD
```

Thấy lịch sử kiểu này thì nên dọn:

```
a1b2c3d fix
d4e5f6a fix again
b7c8d9e sua typo
f1a2b3c them tinh nang dang nhap
```

```bash
git rebase -i main       # gộp các commit "fix", "sua typo" vào commit chính
```

Hoặc đơn giản hơn: cứ để nguyên rồi chọn **Squash and merge** lúc merge — GitHub gộp hết thành 1 commit sạch trên `main`.

---

## 4. Viết mô tả PR

Mô tả tốt tiết kiệm cho reviewer 15 phút đọc code mò mẫm.

### Mẫu mô tả

```markdown
## Làm gì
Thêm trang đăng nhập bằng email và mật khẩu.

## Vì sao
Ticket #42 — người dùng hiện phải nhập mã OTP mỗi lần vào, quá phiền.

## Cách làm
- Thêm form đăng nhập tại `/dang-nhap`
- Dùng bcrypt để băm mật khẩu
- Lưu phiên bằng JWT, hạn 7 ngày

## Cách kiểm tra
1. `docker compose up -d`
2. Mở http://localhost:8000/dang-nhap
3. Đăng nhập bằng `test@example.com` / `matkhau123`
4. Kiểm tra cookie `session` đã được tạo

## Lưu ý cho reviewer
- Chưa làm phần "quên mật khẩu", sẽ ở PR sau
- File `auth.py` dòng 45: mình phân vân giữa 2 cách, mong được góp ý
```

Mục **"Lưu ý cho reviewer"** là phần giá trị nhất — nó chỉ thẳng chỗ bạn muốn được nhìn kỹ.

### Tạo template dùng chung cho cả team

Tạo file `.github/pull_request_template.md` trong repo:

```markdown
## Làm gì


## Vì sao


## Cách kiểm tra


## Checklist
- [ ] Đã tự review diff
- [ ] Đã chạy thử
- [ ] Không còn code debug
- [ ] Không có secret trong code
```

Từ đó mọi PR mới tự động có sẵn khung này.

---

## 5. Draft Pull Request

```
Create pull request ▾  →  Create draft pull request
```

Dùng khi:
- Muốn xin góp ý về hướng làm khi **chưa xong**
- Muốn CI chạy thử sớm
- Muốn đồng nghiệp thấy bạn đang làm gì, tránh trùng việc

Draft **không merge được** cho tới khi bấm **Ready for review** — an toàn.

---

## 6. Vai người review

### Thứ tự đọc

1. **Đọc mô tả trước** — hiểu mục đích rồi mới xem code
2. **Nhìn tổng thể** tab Files changed — cấu trúc có hợp lý không
3. **Đọc chi tiết** từng file
4. **Chạy thử** nếu là thay đổi quan trọng

### Nên soi cái gì

| Ưu tiên | Nội dung |
|---|---|
| 🔴 Cao | Lỗi logic, lỗ hổng bảo mật, secret bị lộ, mất dữ liệu |
| 🟡 Vừa | Trường hợp biên chưa xử lý, thiếu kiểm tra lỗi, hiệu năng |
| 🟢 Thấp | Tên biến, định dạng code, phong cách |

> Nhóm 🟢 nên để **công cụ tự động** làm (linter, formatter), đừng để tốn thời gian con người.
> Team nên cài `prettier`/`black` + pre-commit hook thay vì tranh luận dấu cách trong PR.

### Cách viết góp ý

Nguyên tắc: **góp ý cho CODE, không nhắm vào NGƯỜI.**

| ❌ Đừng viết | ✅ Nên viết |
|---|---|
| "Sai rồi." | "Chỗ này nếu `danh_sach` rỗng thì sẽ lỗi IndexError. Thêm kiểm tra được không?" |
| "Sao lại viết thế này?" | "Mình chưa hiểu đoạn này giải quyết trường hợp nào, bạn giải thích giúp?" |
| "Code xấu quá." | "Hàm này đang làm 3 việc, tách ra 3 hàm nhỏ sẽ dễ test hơn. Bạn thấy sao?" |

**Phân loại rõ mức độ** để tác giả biết cái nào bắt buộc sửa:

```
[bắt buộc] Chỗ này lộ mật khẩu ra log, phải sửa trước khi merge.
[đề xuất]  Dùng dict thay vì if-else dài sẽ gọn hơn.
[hỏi]      Vì sao chọn cách này thay vì dùng thư viện có sẵn?
[khen]     Phần xử lý lỗi ở đây viết rất gọn, mình học được.
```

Đừng quên `[khen]` — review chỉ toàn chê khiến người ta sợ gửi PR.

### Dùng "Suggested changes"

Trên GitHub, khi góp ý bạn có thể bấm biểu tượng **±** để đề xuất code cụ thể:

````
```suggestion
    if not danh_sach:
        return None
```
````

Tác giả bấm **Commit suggestion** là xong — không phải sửa tay. Rất hợp cho lỗi nhỏ.

### Kết thúc review

| Nút | Dùng khi |
|---|---|
| **Approve** | Ổn, merge được |
| **Comment** | Có ý kiến nhưng không chặn |
| **Request changes** | **Có vấn đề bắt buộc sửa** trước khi merge |

> Đừng dùng **Request changes** cho góp ý nhỏ về phong cách — nó **chặn** PR và tạo áp lực không cần thiết.
> Góp ý nhỏ thì dùng **Comment** kèm **Approve**: "Duyệt rồi, sửa được thì tốt, không sửa cũng merge được."

---

## 7. Vai tác giả — khi nhận góp ý

```bash
# Vẫn đứng trên nhánh cũ, commit tiếp — PR tự cập nhật
git add .
git commit -m "Sua theo gop y review"
git push
```

**Trả lời từng comment**, đừng im lặng sửa:

- Đồng ý và đã sửa → *"Đã sửa ở commit a3f9c21, cảm ơn bạn."*
- Không đồng ý → *"Mình giữ cách này vì X, nhưng nếu bạn thấy Y quan trọng hơn thì mình đổi."*
- Chưa hiểu → *"Bạn nói rõ hơn giúp mình chỗ này được không?"*

Sửa xong thì bấm **Resolve conversation** để reviewer biết chỗ nào đã xong.

> Bất đồng kéo dài quá **2 vòng** qua lại trên PR thì **gọi điện hoặc nói trực tiếp** 5 phút.
> Tranh luận qua comment rất tốn thời gian và dễ hiểu lầm giọng điệu.

---

## 8. Bảo vệ nhánh `main`

Vào repo → **Settings** → **Branches** → **Add branch protection rule**:

| Thiết lập | Vì sao |
|---|---|
| ☑ Require a pull request before merging | Không ai push thẳng vào `main` |
| ☑ Require approvals: **1** | Ít nhất 1 người duyệt |
| ☑ Dismiss stale approvals when new commits are pushed | Sửa thêm code thì phải duyệt lại |
| ☑ Require status checks to pass | CI phải xanh mới merge được |
| ☑ Require conversation resolution | Mọi comment phải được xử lý |

Với team nhỏ mới bắt đầu: bật 2 dòng đầu là đủ. Bật hết ngay sẽ khiến mọi người thấy vướng.

---

## 9. Quy trình chuẩn của team

```
┌─ TÁC GIẢ ────────────────────────────────────────┐
│ 1. git checkout main && git pull                 │
│ 2. git checkout -b feature/ten-viec              │
│ 3. Code — commit nhỏ, dùng git add -p            │
│ 4. TỰ REVIEW: git diff main...HEAD               │
│ 5. git push -u origin feature/ten-viec           │
│ 6. Mở PR, điền mô tả theo template, gán reviewer │
└──────────────────────────────────────────────────┘
                      ↓
┌─ REVIEWER (trong vòng 1 ngày làm việc) ──────────┐
│ 7. Đọc mô tả → xem tổng thể → đọc chi tiết       │
│ 8. Góp ý có phân loại [bắt buộc]/[đề xuất]/[hỏi] │
│ 9. Approve / Request changes                     │
└──────────────────────────────────────────────────┘
                      ↓
┌─ TÁC GIẢ ────────────────────────────────────────┐
│ 10. Sửa, trả lời từng comment, Resolve           │
│ 11. Được Approve → Squash and merge → xoá nhánh  │
└──────────────────────────────────────────────────┘
                      ↓
┌─ CẢ HAI ─────────────────────────────────────────┐
│ 12. git checkout main && git pull                │
│     git branch -d feature/ten-viec               │
│     git fetch -p                                 │
└──────────────────────────────────────────────────┘
```

---

## 10. Cam kết của team — nên chốt và ghi vào README

| Hạng mục | Đề xuất |
|---|---|
| Kích thước PR tối đa | 400 dòng |
| Thời gian phản hồi review | Trong 1 ngày làm việc |
| Số reviewer tối thiểu | 1 |
| Kiểu merge | Squash and merge |
| Xoá nhánh sau merge | Có |
| Đặt tên nhánh | `feature/` · `fix/` · `hotfix/` · `docs/` |

> Điều quan trọng nhất không phải con số cụ thể, mà là **cả team thống nhất một con số**.

---

## 11. Bài tập theo cặp

**Vòng 1 — PR tốt**

1. Tạo nhánh, sửa **một việc duy nhất** dưới 50 dòng
2. Tự review bằng `git diff main...HEAD`
3. Mở PR, điền đủ mô tả theo mẫu ở mục 4
4. Người ngồi cạnh review: để lại **ít nhất 1 comment mỗi loại** `[bắt buộc]`, `[đề xuất]`, `[hỏi]`, `[khen]`
5. Tác giả sửa, trả lời từng comment, Resolve
6. Approve → Squash and merge → xoá nhánh

**Vòng 2 — PR tệ, để thấy khác biệt**

1. Tạo nhánh, sửa **3 việc không liên quan** trong 5 file
2. Commit với message `fix`, `fix again`, `sua`
3. Mở PR với mô tả trống
4. Người review thử đánh giá — **bấm giờ**, so với vòng 1

Thảo luận: mất bao lâu? Có chắc mình đã hiểu hết thay đổi không?

**Vòng 3 — Suggested changes**

Reviewer dùng nút **±** đề xuất sửa trực tiếp, tác giả bấm **Commit suggestion**.

---

## 12. Câu hỏi

1. Vì sao PR lớn lại được review **tệ hơn** PR nhỏ?
2. Bước nào tác giả phải làm trước khi bấm Create pull request?
3. `[bắt buộc]` và `[đề xuất]` khác nhau chỗ nào? Vì sao cần phân loại?
4. Khi nào **không** nên dùng Request changes?
5. Draft PR dùng để làm gì?
6. Bất đồng kéo dài trên PR thì nên làm gì?
