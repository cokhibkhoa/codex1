# Project Context - CRM Data Quality (SME)

## 1) Mục tiêu
Dựng bộ khung tối giản để phát hiện và theo dõi lỗi chất lượng dữ liệu CRM (HubSpot), tập trung vào **tickets** và **deals**, dùng PostgreSQL làm lớp xử lý chính và xuất output cho Google Sheets/dashboard.

## 2) Hiện trạng repo (audit nhanh)
- Repo đang rất tối giản, chưa có cấu trúc data project.
- Chưa có SQL pipeline, rule catalog, hay view catalog.
- Chưa có quy ước input/output cho các bước clean/check/mart.

## 3) Nguồn dữ liệu
- data/Data Quality - Deals.csv
- data/Data Quality - Tickets.csv

## 4) Phạm vi lỗi chất lượng cần xử lý
- Thiếu dữ liệu bắt buộc (null/blank).
- Ticket ID, Deal ID ở file csv đang ở dạng số mũ (những vẫn là số unique) chuyển qua sql bảng raw type text khiến những ID này bị trùng (ví dụ: ERROR: duplicate key value violates unique constraint "hubspot_deals_pkey"
DETAIL: Key (deal_id)=(1.35199E+11) already exists.). Bản chất ID được xuất từ hubspot crm nên là unique. Nếu tạo bảng type text trước khi import gây ra việc id bị trùng.
- Sai logic nghiệp vụ (status, amount, timeline). 
- Mapping sai giữa tickets ↔ deals.
- Duplicate record id (tickets id, deals id).
- Multi-value bất thường.
- Amount lệch (tickets amount lệch so với deals sale value, giá trị lệch >1000)

## 5) Nguyên tắc thiết kế
- Implementation-first: chạy được sớm với mẫu nhỏ.
- Practical/minimal: SQL rõ ràng, không over-engineering.
- Maintainable: tách lớp `raw -> clean -> checks -> marts`.
- Business-safe: rule chưa rõ phải gắn `TODO` và chờ xác nhận.


## 6) Dữ liệu mẫu trong repo
- `data/Data Quality - Deals.csv`
- `data/Data Quality - Tickets.csv`
