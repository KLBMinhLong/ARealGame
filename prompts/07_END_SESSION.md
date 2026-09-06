# Bàn giao phiên làm việc

Copy phần trong khối dưới vào agent. Đây là prompt thông thường, không tự đăng ký slash command.

```text
Đọc git status/diff và task vừa làm. Cập nhật docs/SESSION_HANDOFF.md, TASKS và CHANGELOG chỉ bằng sự kiện thực tế.

Ghi: task và trạng thái; commit gần nhất; thay đổi chưa commit; file/wiring; lệnh/test đã chạy và log; test chưa chạy; bug còn; quyết định đang chờ tôi; đúng một việc tiếp theo. Không đưa secret vào docs.

Nếu task chỉ viết code mà chưa test, giữ IMPLEMENTED_AWAITING_TEST. Nếu bị chặn thì ghi BLOCKED và nguyên nhân. Không tự đánh dấu DONE để làm báo cáo đẹp.

Đề xuất commit nếu phù hợp nhưng không reset/clean/push/publish. Sau cập nhật, trả một tóm tắt ngắn để tôi có thể tiếp tục bằng phiên mới.
```
