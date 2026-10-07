# Bài 11 — Registry và CI/CD

Đến đây bạn đã build được image trên máy mình. Bài này đưa image **lên mây** để server và đồng nghiệp dùng chung.

---

## 1. Registry là gì?

Kho chứa image, giống GitHub nhưng cho image.

| Registry | Địa chỉ | Ghi chú |
|----------|---------|---------|
| **Docker Hub** | `docker.io` | Phổ biến nhất. Miễn phí cho repo public, **giới hạn lượt pull** |
| **GitHub Container Registry** | `ghcr.io` | **Khuyến nghị** — miễn phí, gắn liền repo GitHub, xác thực bằng token sẵn có |
| GitLab Registry | `registry.gitlab.com` | Nếu team dùng GitLab |
| AWS ECR / Google GAR | | Khi hạ tầng đã ở AWS/GCP |

Team này đã dùng GitHub (khoá Git), nên dùng **`ghcr.io`** là gọn nhất.

---

## 2. Đặt tên image

```
ghcr.io / tuongna247 / app-demo : 1.0.0
└──┬──┘   └────┬────┘  └───┬──┘  └──┬─┘
registry   chủ sở hữu    tên       tag
```

### Quy ước tag

| Tag | Dùng khi |
|-----|----------|
| `1.0.0` | **Phiên bản cụ thể — dùng cho production** |
| `1.0`, `1` | Tự động nhận bản vá mới nhất trong dòng đó |
| `main`, `dev` | Bản mới nhất của một nhánh |
| `sha-a3f9c21` | Gắn với đúng một commit — truy vết tốt nhất |
| `latest` | ⚠️ **Không dùng trên production** |

> Vì sao tránh `latest`? Nó không có nghĩa "mới nhất" mà chỉ là tag mặc định.
> Server chạy `latest` thì bạn **không biết nó đang chạy code nào**, và không rollback được.

---

## 3. Đẩy image lên ghcr.io thủ công

### Bước 1 — Tạo Personal Access Token

1. https://github.com/settings/tokens → **Generate new token (classic)**
2. **Scopes**: tick `write:packages` và `read:packages`
3. Copy token (`ghp_...`) — đóng trang là không xem lại được

### Bước 2 — Đăng nhập

```bash
echo "ghp_TOKEN_CUA_BAN" | docker login ghcr.io -u tuongna247 --password-stdin
```

> Dùng `--password-stdin` thay vì gõ `-p ghp_...` trực tiếp — nếu không, token sẽ nằm trong lịch sử shell (`~/.zsh_history`).

### Bước 3 — Gắn tag và đẩy

```bash
docker build -t ghcr.io/tuongna247/app-demo:1.0.0 .

# Gắn thêm tag phụ trỏ cùng một image
docker tag ghcr.io/tuongna247/app-demo:1.0.0 ghcr.io/tuongna247/app-demo:latest

docker push ghcr.io/tuongna247/app-demo:1.0.0
docker push ghcr.io/tuongna247/app-demo:latest
```

### Bước 4 — Tải về từ máy khác

```bash
docker pull ghcr.io/tuongna247/app-demo:1.0.0
docker run -d -p 8000:8000 ghcr.io/tuongna247/app-demo:1.0.0
```

> Image trên ghcr.io mặc định **private**. Muốn công khai: vào repo GitHub → **Packages** →
> chọn package → **Package settings** → **Change visibility**.

---

## 4. Tự động hoá bằng GitHub Actions

Thay vì build tay mỗi lần, để CI làm: cứ push code lên `main` là image mới tự lên registry.

Tạo `.github/workflows/docker.yml`:

```yaml
name: Build va day Docker image

on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Lay code
        uses: actions/checkout@v4

      - name: Cai dat Buildx
        uses: docker/setup-buildx-action@v3

      - name: Dang nhap registry
        # Chi dang nhap khi day that, khong dang nhap o pull request
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Tao tag tu dong
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=sha,prefix=sha-

      - name: Build va day
        uses: docker/build-push-action@v6
        with:
          context: ./tai-nguyen/app-demo
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Vì sao workflow này viết như vậy

| Phần | Lý do |
|------|-------|
| `permissions: packages: write` | Không có dòng này, `docker push` sẽ bị từ chối |
| `secrets.GITHUB_TOKEN` | Token **tự động có sẵn**, không cần bạn tạo hay lưu gì |
| `push: ... != 'pull_request'` | Pull request thì **build để kiểm tra** nhưng không đẩy lên — tránh người ngoài đẩy image rác |
| `metadata-action` | Tự sinh tag từ nhánh, từ git tag `v1.2.3`, và từ commit SHA |
| `cache-from/to: type=gha` | Dùng cache của GitHub Actions — build lần sau nhanh hơn nhiều |

### Kiểm tra

Push code lên `main`, vào tab **Actions** của repo xem tiến trình. Xong thì image xuất hiện ở tab **Packages**.

---

## 5. Quét lỗ hổng bảo mật

```bash
docker scout cves app-demo:1.0        # có sẵn trong Docker Desktop
```

Thêm vào workflow:

```yaml
      - name: Quet lo hong
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:main
          format: table
          exit-code: "1"              # CI HỎNG nếu có lỗ hổng nghiêm trọng
          severity: CRITICAL,HIGH
```

---

## 6. Bài tập

1. Tạo Personal Access Token với scope `write:packages`.
2. Đăng nhập `ghcr.io` bằng `--password-stdin`.
3. Build, tag và push image của bạn lên ghcr.io.
4. Xoá image trên máy (`docker rmi`), rồi `docker pull` về và chạy lại.
5. Tạo workflow ở trên, push lên `main`, xem tab Actions chạy.
6. Đặt git tag `v1.0.0` và push — quan sát tag image được sinh ra khác gì.

**Câu hỏi**

1. Vì sao không nên chạy `latest` trên production?
2. Vì sao dùng `--password-stdin` thay vì `-p token`?
3. Vì sao workflow không đẩy image ở pull request?
4. `secrets.GITHUB_TOKEN` lấy ở đâu ra? Có phải tự tạo không?
