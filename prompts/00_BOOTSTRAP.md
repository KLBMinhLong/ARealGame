# Khởi động và xác minh baseline

Copy phần trong khối dưới vào agent. Đây là prompt thông thường, không tự đăng ký slash command.

```text
Bạn đang làm trong workspace Vòng Vây. Tôi muốn hoàn thành M0 trước khi thêm tính năng.

Đọc lần lượt README.md, ENGINE_VERSION.txt, AGENT_RULES.md, docs/GAME_BRIEF.md, docs/TECH_SPEC.md, docs/TASKS.md, docs/QA_REPORT.md và docs/SESSION_HANDOFF.md. Đọc file thật, không suy đoán từ tên.

1. Xác nhận workspace root là thư mục chứa project.godot. Kiểm tra git status nếu repo đã có Git, không ghi đè thay đổi của tôi.
2. Tóm tắt luồng scene/script/input/signal đang nối, phân biệt source đã viết với tính năng đã kiểm chứng.
3. Xác định Godot executable tại đường dẫn tôi cung cấp hoặc cấu hình IDE/PATH. Không quét dữ liệu riêng/toàn ổ đĩa. Nếu thiếu đường dẫn, hỏi tôi. Chạy --version và đối chiếu ENGINE_VERSION.txt; mismatch thì dừng để hỏi, không tự đổi engine.
4. Trước import, nhắc tôi lưu/dừng game và đóng editor nếu đang mở. Dùng tools/verify.ps1 hoặc lệnh tương đương để chạy import, smoke và startup; không đổi execution policy hay cài phần mềm. Lưu log trong logs/.
5. Nếu lỗi, báo lỗi đầu tiên + file/dòng + giả thuyết + đề xuất sửa nhỏ. Không viết lại toàn bộ project và không thêm gameplay mới.
6. Trả bảng PASS/FAIL/BLOCKED cho T001/T002. Đưa checklist T003 để tôi kiểm thử tay. Không tự đánh dấu manual test là PASS.

Chỉ audit/xác minh baseline ở lượt này. Không mua asset, tải dependency, upload, public repo hay phát hành. Kết thúc bằng cập nhật handoff trung thực và một bước tiếp theo.
```
