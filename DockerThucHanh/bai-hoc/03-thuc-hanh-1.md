# Bài Thực Hành số 1 — Chạy dịch vụ thật bằng container

> **Thời lượng**: 40 phút · **Hình thức**: mỗi học viên làm trên máy mình
> **Mục tiêu**: dựng PostgreSQL và Redis **không cần cài gì lên máy**, rồi kết nối vào được.

---

## Phần A — PostgreSQL trong 1 lệnh

Bình thường cài PostgreSQL mất 15–30 phút và để lại rác trên máy. Với Docker:

```bash
docker run -d \
  --name db-thuc-hanh \
  -e POSTGRES_USER=hocvien \
  -e POSTGRES_PASSWORD=matkhau123 \
  -e POSTGRES_DB=hocdocker \
  -p 5432:5432 \
  postgres:16-alpine
```

Kiểm tra:

```bash
docker ps
docker logs db-thuc-hanh | tail -5
```

Thấy dòng `database system is ready to accept connections` là xong.

### Vào bên trong dùng psql

```bash
docker exec -it db-thuc-hanh psql -U hocvien -d hocdocker
```

Trong psql, gõ:

```sql
CREATE TABLE thanh_vien (
    id SERIAL PRIMARY KEY,
    ho_ten TEXT NOT NULL,
    nam_sinh INT
);

INSERT INTO thanh_vien (ho_ten, nam_sinh) VALUES
    ('Nguyen Van A', 1995),
    ('Tran Thi B', 1998);

SELECT * FROM thanh_vien;
\q
```

---

## Phần B — Bài học đắt giá: container KHÔNG giữ dữ liệu

Đây là phần quan trọng nhất của buổi học. Làm đúng thứ tự và quan sát kỹ.

```bash
# 1. Xoá container
docker rm -f db-thuc-hanh

# 2. Tạo lại y hệt
docker run -d --name db-thuc-hanh \
  -e POSTGRES_USER=hocvien -e POSTGRES_PASSWORD=matkhau123 -e POSTGRES_DB=hocdocker \
  -p 5432:5432 postgres:16-alpine

sleep 5

# 3. Tìm lại bảng vừa tạo
docker exec -it db-thuc-hanh psql -U hocvien -d hocdocker -c "SELECT * FROM thanh_vien;"
```

Kết quả:

```
ERROR:  relation "thanh_vien" does not exist
```

**Dữ liệu đã mất sạch.** Container bị xoá là mọi thứ ghi bên trong nó biến mất.

### Sửa bằng volume

```bash
docker rm -f db-thuc-hanh

docker run -d --name db-thuc-hanh \
  -e POSTGRES_USER=hocvien -e POSTGRES_PASSWORD=matkhau123 -e POSTGRES_DB=hocdocker \
  -p 5432:5432 \
  -v du-lieu-db:/var/lib/postgresql/data \
  postgres:16-alpine
```

Chỉ thêm **một dòng** `-v du-lieu-db:/var/lib/postgresql/data`.

Tạo lại bảng, rồi **xoá container và tạo lại lần nữa**:

```bash
docker exec -it db-thuc-hanh psql -U hocvien -d hocdocker -c \
  "CREATE TABLE thanh_vien (id SERIAL PRIMARY KEY, ho_ten TEXT); INSERT INTO thanh_vien (ho_ten) VALUES ('Nguyen Van A');"

docker rm -f db-thuc-hanh

docker run -d --name db-thuc-hanh \
  -e POSTGRES_USER=hocvien -e POSTGRES_PASSWORD=matkhau123 -e POSTGRES_DB=hocdocker \
  -p 5432:5432 -v du-lieu-db:/var/lib/postgresql/data postgres:16-alpine

sleep 5
docker exec -it db-thuc-hanh psql -U hocvien -d hocdocker -c "SELECT * FROM thanh_vien;"
```

Lần này **dữ liệu vẫn còn**. Volume nằm ngoài container nên sống sót.

```bash
docker volume ls              # thấy volume "du-lieu-db"
docker volume inspect du-lieu-db
```

---

## Phần C — Redis

```bash
docker run -d --name cache-thuc-hanh -p 6379:6379 redis:7-alpine

docker exec -it cache-thuc-hanh redis-cli
```

Trong redis-cli:

```
SET ten "Nguyen Van A"
GET ten
INCR so_luot
INCR so_luot
GET so_luot
exit
```

---

## Phần D — Nhiều container cùng lúc

```bash
docker run -d --name web1 -p 8081:80 nginx:alpine
docker run -d --name web2 -p 8082:80 nginx:alpine
docker run -d --name web3 -p 8083:80 nginx:alpine

docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Ba web server, mỗi cái một cổng, dựng trong vài giây. Thử với máy ảo thì mất hàng chục phút và vài GB RAM.

```bash
docker stats --no-stream    # xem mỗi container ăn bao nhiêu RAM
```

---

## Phần E — Lỗi cố ý: trùng cổng

Chạy lệnh này khi `web1` vẫn đang chiếm cổng 8081:

```bash
docker run -d --name web4 -p 8081:80 nginx:alpine
```

```
docker: Error response from daemon: driver failed programming external connectivity
on endpoint web4: Bind for 0.0.0.0:8081 failed: port is already allocated
```

**Cách xử lý**: đổi sang cổng khác, hoặc tìm và dừng cái đang chiếm:

```bash
docker ps --filter publish=8081
docker rm -f web1
```

---

## Dọn dẹp

```bash
docker rm -f db-thuc-hanh cache-thuc-hanh web1 web2 web3 web4 2>/dev/null
docker volume rm du-lieu-db
docker ps -a
```

---

## Tiêu chí hoàn thành

- [ ] Chạy được PostgreSQL bằng container, tạo bảng và insert dữ liệu
- [ ] **Tự tay chứng kiến** dữ liệu mất khi xoá container không có volume
- [ ] Dùng volume và chứng kiến dữ liệu sống sót
- [ ] Chạy được Redis và thao tác bằng redis-cli
- [ ] Chạy 3 nginx cùng lúc trên 3 cổng khác nhau
- [ ] Gây ra và tự xử lý lỗi trùng cổng
- [ ] Dọn sạch container và volume sau khi xong

## Câu hỏi

1. Vì sao xoá container lại mất dữ liệu database?
2. `-v du-lieu-db:/var/lib/postgresql/data` — vế trái và vế phải là gì?
3. Vì sao 3 container nginx chạy được cùng lúc mà không đụng nhau?
4. Nếu 2 container cùng muốn cổng 8081 thì sao?
