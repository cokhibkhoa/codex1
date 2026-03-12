# Project Context - CRM Data Quality (SME)

## 1) Mục tiêu
Dựng bộ khung tối giản để phát hiện và theo dõi lỗi chất lượng dữ liệu CRM (HubSpot), tập trung vào **tickets** và **deals**, dùng PostgreSQL làm lớp xử lý chính và xuất output cho Google Sheets/dashboard.

## 2) Hiện trạng repo (audit nhanh)
- Repo đang rất tối giản, chưa có cấu trúc data project.
- Chưa có SQL pipeline, rule catalog, hay view catalog.
- Chưa có quy ước input/output cho các bước clean/check/mart.

## 3) Nguồn dữ liệu
- HubSpot export CSV hoặc API sync vào bảng raw.
- Thực thể chính:
  - `raw.hubspot_tickets`
  - `raw.hubspot_deals`

> TODO: xác nhận tên bảng raw thực tế trong môi trường của bạn.

## 4) Phạm vi lỗi chất lượng cần xử lý
- Thiếu dữ liệu bắt buộc (null/blank).
- Sai format (email, phone, date...).
- Sai logic nghiệp vụ (status, amount, timeline).
- Mapping sai giữa tickets ↔ deals.
- Duplicate record.
- Multi-value bất thường.
- Amount lệch logic.

## 5) Nguyên tắc thiết kế
- Implementation-first: chạy được sớm với mẫu nhỏ.
- Practical/minimal: SQL rõ ràng, không over-engineering.
- Maintainable: tách lớp `raw -> clean -> checks -> marts`.
- Business-safe: rule chưa rõ phải gắn `TODO` và chờ xác nhận.
