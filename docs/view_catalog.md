# View Catalog

| view_name | layer | purpose | grain | refresh_strategy | notes |
|---|---|---|---|---|---|
| clean.v_clean_tickets | 10_clean | Chuẩn hoá và làm sạch dữ liệu ticket từ raw | 1 row / ticket_id | Rebuild theo batch ingest | Có cột TODO cho mapping business fields |
| checks.v_check_null_required_fields | 20_checks | Log ticket thiếu field bắt buộc | 1 row / lỗi / ticket_id | Rebuild theo batch | Rule bắt buộc cần xác nhận từ business |
| checks.v_check_duplicate_ticket_id | 20_checks | Phát hiện ticket_id bị duplicate | 1 row / ticket_id duplicate | Rebuild theo batch | Dựa trên raw trước khi clean |
| checks.v_check_null_required_deal_fields | 20_checks | Log deal thiếu field bắt buộc | 1 row / lỗi / deal_id | Rebuild theo batch | Rule bắt buộc cần xác nhận từ business |
| checks.v_check_duplicate_deal_id | 20_checks | Phát hiện deal_id bị duplicate | 1 row / deal_id duplicate | Rebuild theo batch | Dựa trên raw |
| checks.v_check_amount_mismatch | 20_checks | So sánh amount giữa ticket và deal liên quan | 1 row / cặp ticket-deal | Rebuild theo batch | **Tách scope**: chưa đưa vào dashboard MVP |
| marts.v_error_log | 30_marts | Gom lỗi chất lượng ticket + deal về 1 view | 1 row / lỗi | Rebuild theo batch | Dùng để export sang Sheets/dashboard |
| marts.v_ticket_error_summary | 30_marts | Tổng hợp lỗi theo ticket (1 ticket_id 1 row) | 1 row / ticket_id có lỗi | Rebuild theo batch | Có cờ lỗi theo loại |
| marts.v_deal_error_summary | 30_marts | Tổng hợp lỗi theo deal (1 deal_id 1 row) | 1 row / deal_id có lỗi | Rebuild theo batch | Có cờ lỗi theo loại |
| marts.v_monthly_error_summary | 30_marts | Tổng hợp số lỗi theo tháng cho ticket/deal | 1 row / tháng / entity / rule | Rebuild theo batch | Phục vụ dashboard tháng |

## Vì sao dùng view thay vì table/materialized view ở giai đoạn đầu?
- **View**: đơn giản, dễ sửa rule nhanh khi business còn thay đổi.
- **Table**: dùng khi cần snapshot cố định hoặc audit theo thời điểm.
- **Materialized view**: dùng khi query nặng và cần tốc độ đọc ổn định.

> Giai đoạn khởi đầu: ưu tiên `view` để giảm chi phí bảo trì.
