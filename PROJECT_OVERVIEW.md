# Giới thiệu nhanh về Codex (cho người mới)

## Codex là gì?
Codex là một trợ lý AI tập trung vào công việc kỹ thuật, đặc biệt mạnh ở đọc hiểu codebase, viết/chỉnh sửa mã, chạy lệnh terminal, và đề xuất quy trình triển khai thay đổi an toàn.

Nói ngắn gọn: Codex giúp bạn đi nhanh hơn trong vòng lặp **hiểu yêu cầu → sửa code → kiểm tra → commit/PR**.

---

## Codex làm được gì?

### 1) Hiểu và giải thích code
- Tóm tắt kiến trúc dự án theo thư mục/module.
- Giải thích luồng xử lý theo mức độ cho người mới.
- Chỉ ra điểm rủi ro: bug tiềm ẩn, xử lý lỗi thiếu, nợ kỹ thuật.

### 2) Viết và refactor mã
- Tạo tính năng mới theo yêu cầu.
- Refactor để code rõ hơn, dễ test hơn.
- Chuẩn hoá style theo convention sẵn có trong repo.

### 3) Tự động hóa thao tác kỹ thuật
- Chạy lệnh build/test/lint.
- Sửa lỗi theo log và retry có kiểm chứng.
- Chuẩn bị commit message/PR message rõ ràng.

### 4) Hỗ trợ tài liệu kỹ thuật
- Viết README, onboarding guide, migration notes.
- Tạo checklist release hoặc checklist review.

---

## Giao diện làm việc của Codex

Tuỳ môi trường, Codex thường làm việc theo dạng:
- **Chat + công cụ terminal**: nhận yêu cầu bằng ngôn ngữ tự nhiên, rồi thực thi bằng lệnh.
- **Workflow kiểu agent**: tự lên kế hoạch ngắn, sửa file, chạy check, báo cáo kết quả.
- **Tích hợp quy trình Git**: hỗ trợ commit và tạo nội dung PR.

Bạn có thể xem Codex như một “pair programmer” biết dùng terminal và đọc cả codebase.

---

## Codex mạnh nhất ở những task nào?

### Rất mạnh
- Onboarding nhanh vào codebase mới.
- CRUD/API/service logic tiêu chuẩn.
- Viết test unit/integration cơ bản.
- Refactor có phạm vi rõ ràng.
- Tự động hóa tác vụ lặp lại (script, formatting, lint fixes).

### Mạnh nhưng cần bạn định hướng thêm
- Thiết kế kiến trúc lớn nhiều ràng buộc nghiệp vụ.
- Tối ưu hiệu năng ở hệ thống production phức tạp.
- Bài toán bảo mật/tuân thủ yêu cầu domain-specific.

### Nên có người kiểm duyệt kỹ
- Logic nghiệp vụ “high-stakes” (tài chính/y tế/pháp lý).
- Migration dữ liệu lớn, thay đổi ảnh hưởng diện rộng.
- Quyết định kiến trúc dài hạn khó đảo ngược.

---

## Cách dùng hiệu quả cho người mới
1. Viết yêu cầu cụ thể: bối cảnh, mục tiêu, ràng buộc.
2. Yêu cầu Codex nêu kế hoạch ngắn trước khi sửa.
3. Bắt buộc chạy test/check sau mỗi thay đổi.
4. Review diff theo từng phần nhỏ, không gộp quá lớn.
5. Luôn giữ người chịu trách nhiệm cuối cùng là con người.

---

## Lộ trình học tiếp theo
- Học Git workflow cơ bản: branch, commit nhỏ, PR rõ ràng.
- Học test nền tảng (unit/integration) để kiểm chứng output của AI.
- Học đọc log và debug để phối hợp tốt với Codex.
- Học kiến trúc phần mềm căn bản để đặt yêu cầu đúng.

Nếu bạn muốn, mình có thể làm tiếp một bản **playbook sử dụng Codex theo vai trò** (Junior Dev, Reviewer, Tech Lead) để áp dụng ngay cho team.
