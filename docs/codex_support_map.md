# Codex Support Map - CRM Data Quality Project

## A) Audit repo hiện tại + phân loại công việc

### 1) Codex làm được ngay
- Tạo cấu trúc thư mục chuẩn (`sql/`, `docs/`, `prompts/`, `exports/`, `logs/`).
- Viết SQL khung cho clean/check/mart.
- Viết docs vận hành ban đầu (context, rule catalog, view catalog, decision log).
- Tạo checklist triển khai và thứ tự chạy file.

### 2) Codex làm được nhưng cần input business rule từ bạn
- Xác định field nào là bắt buộc theo ticket/deal.
- Xác định mapping ticket ↔ deal (join key và cardinality).
- Chốt ngưỡng `amount mismatch` (ví dụ lệch > 10% hay > 20%).
- Chốt danh mục trạng thái hợp lệ (pipeline stage, closed-won/lost logic).

### 3) Codex chỉ nên hỗ trợ draft/review
- Đề xuất logic anti-duplicate khi có nhiều ngoại lệ nghiệp vụ.
- Thiết kế score/chấm điểm data quality cho dashboard điều hành.
- Chuẩn hoá taxonomy lỗi đa phòng ban.

### 4) Việc bạn phải làm thủ công ngoài Codex
- Cấp quyền DB, tạo user/secret, thiết lập kết nối hạ tầng.
- Thiết lập lịch sync HubSpot thật (API/app integration).
- Xác nhận cuối cùng với stakeholder business trước khi áp rule production.
- Kiểm duyệt ngẫu nhiên dữ liệu thật để validate false-positive/false-negative.

---

## B) Chỗ Codex hỗ trợ tốt
- Dựng skeleton nhanh, đồng nhất naming convention.
- Viết SQL dễ đọc và refactor nhanh.
- Biến rule nghiệp vụ thành truy vấn kiểm tra có thể chạy.
- Tạo tài liệu onboarding và hướng dẫn vận hành.

## C) Chỗ Codex dễ sai
- Suy đoán business rule khi dữ liệu có ngoại lệ domain-specific.
- Join sai key khi hệ thống CRM có mapping lịch sử phức tạp.
- Đặt ngưỡng cảnh báo không phù hợp với thực tế vận hành.

## D) Chỗ cần bạn xác nhận nghiệp vụ
1. Danh sách trường bắt buộc cho từng loại ticket/deal.
2. Công thức amount chuẩn và ngưỡng chấp nhận sai lệch.
3. Quy tắc mapping multi-value field (separator, chuẩn hoá giá trị rỗng).
4. Mức độ severity và hành động tương ứng khi phát hiện lỗi.

## E) Workflow đề xuất để dùng Codex an toàn
1. Bạn cung cấp context + sample data + business rule hiện có.
2. Codex viết SQL draft theo rule và gắn TODO chỗ chưa rõ.
3. Bạn review nghiệp vụ, chốt rule chính thức.
4. Codex cập nhật SQL/checks + docs.
5. Chạy thử trên sample tuần gần nhất, so false-positive.
6. Chỉ sau khi đạt đồng thuận mới bật cho production reporting.
