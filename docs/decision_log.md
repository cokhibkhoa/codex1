# Decision Log

| date | decision_id | decision | reason | impact | owner | status |
|---|---|---|---|---|---|---|
| 2026-03-12 | DQ-001 | Chia pipeline thành 4 lớp `raw/clean/checks/marts` | Đơn giản hoá luồng xử lý và debug | Dễ onboarding, dễ mở rộng rule | team | active |
| 2026-03-12 | DQ-002 | Dùng PostgreSQL view cho phase đầu | Tránh over-engineering, đổi rule nhanh | Tốc độ triển khai nhanh | team | active |
| 2026-03-12 | DQ-003 | Chưa khóa cứng business rules, đánh dấu TODO | Tránh giả định sai nghiệp vụ | Cần bước xác nhận manual | analyst + business | active |

## Cách dùng
- Mỗi lần thay đổi rule quan trọng, thêm một dòng quyết định mới.
- Nếu decision bị thay thế, chuyển status sang `deprecated`.
