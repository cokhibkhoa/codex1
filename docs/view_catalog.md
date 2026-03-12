# View Catalog

| view_name | layer | purpose | grain | refresh_strategy | notes |
|---|---|---|---|---|---|
| clean.v_clean_tickets | 10_clean | Chuẩn hoá và làm sạch dữ liệu ticket từ raw | 1 row / ticket_id | Rebuild theo batch ingest | Có cột TODO cho mapping business fields |
| checks.v_check_null_required_fields | 20_checks | Log ticket thiếu field bắt buộc | 1 row / lỗi / ticket_id | Rebuild theo batch | Rule bắt buộc cần xác nhận từ business |
| checks.v_check_duplicate_ticket_id | 20_checks | Phát hiện ticket_id bị duplicate | 1 row / ticket_id duplicate | Rebuild theo batch | Dựa trên raw trước khi clean |
| checks.v_check_amount_mismatch | 20_checks | So sánh amount giữa ticket và deal liên quan | 1 row / cặp ticket-deal | Rebuild theo batch | Cần xác nhận ngưỡng lệch |
| marts.v_error_log | 30_marts | Gom toàn bộ lỗi chất lượng về 1 view | 1 row / lỗi | Rebuild theo batch | Dùng để export sang Sheets/dashboard |
| marts.v_weekly_error_summary | 30_marts | Tổng hợp lỗi theo tuần và rule | 1 row / tuần / rule | Rebuild theo batch | Theo dõi xu hướng chất lượng dữ liệu |

## Vì sao dùng view thay vì table/materialized view ở giai đoạn đầu?
- **View**: đơn giản, dễ sửa rule nhanh khi business còn thay đổi.
- **Table**: dùng khi cần snapshot cố định hoặc audit theo thời điểm.
- **Materialized view**: dùng khi query nặng và cần tốc độ đọc ổn định.

> Giai đoạn khởi đầu: ưu tiên `view` để giảm chi phí bảo trì.
