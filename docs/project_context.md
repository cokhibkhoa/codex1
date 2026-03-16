# Project Context — CRM Data Quality

| Mục | Nội dung |
|---|---|
| **Mục tiêu** | Xây dựng pipeline kiểm tra **chất lượng dữ liệu HubSpot CRM** cho **Deals** và **Tickets**. Stack: **CSV export → PostgreSQL → Google Sheets / dashboard**. |
| **Pipeline** | `CSV → raw → clean → checks → marts` |
| **raw layer** | Import trực tiếp CSV, **không transform**, giữ dữ liệu gốc để debug. |
| **clean layer** | Chuẩn hoá dữ liệu: format ID, number, date, trim blank, normalize field. |
| **checks layer** | Chạy **data quality rules**. Output bảng issue: `rule_name, object_type, record_id, issue_detail`. |
| **marts layer** | Bảng tổng hợp để xuất **Google Sheets / dashboard**. |
| **Nguồn dữ liệu** | `data/Data Quality - Deals.csv` ; `data/Data Quality - Tickets.csv` |
| **Đặc điểm dữ liệu** | ID có thể ở dạng **scientific notation** (`1.35199E+11`), dữ liệu trống nhiều. |
| **Missing data** | Đo số lượng null ở tất cả các cột(attributes) |
| **ID issues** | Scientific notation có thể gây **duplicate key violation** khi import PostgreSQL. ID cần **normalize trước khi enforce uniqueness**. |
| **Business logic errors** | Ví dụ: `ABS(ticket_amount - deal_amount) > 1000`, deal_amount là sale confirmation values. |
| **Multi-value issues** | Field dạng `12345;56789;34567`. Kiểm tra số lượng value và format. |
| **Nguyên tắc thiết kế** | Implementation-first, SQL đơn giản, tách lớp `raw → clean → checks → marts`. |
| **Rule chưa rõ** | Gắn `TODO: confirm business rule`. |
| **Dữ liệu mẫu** | CSV trong thư mục `data/` dùng để thiết kế schema và test rule. |
