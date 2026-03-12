# Tổng quan dự án (cho người mới)

Hiện tại repository này gần như ở trạng thái khởi tạo ban đầu và **chưa có mã nguồn ứng dụng**.

## Cấu trúc chung hiện tại

- `.git/`: thư mục metadata của Git (lịch sử commit, config nhánh, object, ...).
- `.gitkeep`: file placeholder rỗng để giữ cho repository không hoàn toàn trống.

## Điều quan trọng cần biết

1. Chưa có source code để đọc kiến trúc thực tế (module, service, API, UI, ...).
2. Chưa có tệp cấu hình build/test phổ biến (ví dụ `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, ...).
3. Chưa có README hướng dẫn chạy hoặc tiêu chuẩn đóng góp.

## Nên học/thiết lập gì tiếp theo

### 1) Chọn stack và chuẩn hoá cấu trúc
- Chọn ngôn ngữ/framework chính.
- Tạo cấu trúc thư mục tối thiểu (`src/`, `tests/`, `docs/`).

### 2) Viết tài liệu nền tảng
- `README.md`: mục tiêu, cách cài đặt, cách chạy local, cách test.
- `CONTRIBUTING.md`: quy tắc commit, code style, quy trình PR.

### 3) Thiết lập chất lượng mã
- Formatter + linter.
- Unit test cơ bản và CI để chạy test tự động.

### 4) Tạo “vertical slice” đầu tiên
- Implement 1 tính năng nhỏ end-to-end.
- Có test đi kèm để làm mẫu cho team.

---

Nếu bạn muốn, bước tiếp theo mình có thể đề xuất luôn một **skeleton repo** cụ thể theo stack bạn chọn (Node.js, Python, Go, Rust, ...), kèm cấu trúc thư mục và script chạy/test tối thiểu.
