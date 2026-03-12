# Rule Catalog

> Mục đích: danh mục rule data quality để quản lý version, owner, mức độ nghiêm trọng và trạng thái xác nhận nghiệp vụ.

## Quy ước severity
- `HIGH`: ảnh hưởng trực tiếp dashboard/KPI hoặc gây sai quyết định.
- `MEDIUM`: ảnh hưởng một phần báo cáo hoặc vận hành.
- `LOW`: nên sửa để tăng độ sạch dữ liệu, chưa ảnh hưởng lớn.

| rule_id | domain | rule_name | description | severity | status | owner | business_confirmation |
|---|---|---|---|---|---|---|---|
| RQ_TICKET_001 | tickets | required_fields_not_null | Ticket phải có các field bắt buộc | HIGH | draft | data-team | TODO |
| RQ_TICKET_002 | tickets | duplicate_ticket_id | Không được trùng ticket_id | HIGH | draft | data-team | TODO |
| RQ_DEAL_001 | deals | amount_mismatch_with_ticket | Amount deal lệch bất thường so với ticket liên quan | MEDIUM | draft | data-team | TODO |

## Checklist xác nhận rule trước khi production
1. Định nghĩa field bắt buộc theo từng pipeline.
2. Ngưỡng so sánh amount (% lệch cho phép).
3. Quy tắc mapping ticket ↔ deal (1-1, 1-n, theo key nào).
4. Hành động khi vi phạm rule (chặn, cảnh báo, hay chỉ log).
