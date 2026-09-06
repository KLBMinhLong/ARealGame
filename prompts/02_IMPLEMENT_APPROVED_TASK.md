# Triển khai task vừa được duyệt

Copy phần trong khối dưới vào agent. Đây là prompt thông thường, không tự đăng ký slash command.

```text
Triển khai đúng task và kế hoạch tôi vừa duyệt trong cuộc hội thoại này. Nếu chưa có một task ID/kế hoạch được duyệt, dừng và hỏi, không tự chọn toàn bộ roadmap.

Đọc lại AGENT_RULES.md và file thật liên quan. Kiểm tra git status trước khi sửa. Giữ Godot theo ENGINE_VERSION.txt, GDScript và Compatibility.

Sửa tối thiểu, lắp đủ script/scene/node/input/signal/UI. Kiểm tra cả pause, retry, end-state và tài nguyên mới. Không thêm dependency hoặc đổi kiến trúc ngoài kế hoạch.

Chạy import + smoke/regression phù hợp; thêm test cho logic mới. Không bịa kết quả visual/manual. Nếu không có engine hay quyền chạy, ghi AWAITING_TEST/BLOCKED.

Kết thúc với: file/dòng và wiring thay đổi; lệnh thật/log; acceptance PASS/FAIL/BLOCKED; checklist tôi chơi thử; bug còn; TASKS/CHANGELOG/SESSION_HANDOFF cập nhật. Đề xuất commit sau khi tôi xác nhận, không push hoặc publish.
```
