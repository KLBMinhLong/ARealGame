# Chọn đúng một task tiếp theo

Copy phần trong khối dưới vào agent. Đây là prompt thông thường, không tự đăng ký slash command.

```text
Đọc AGENT_RULES.md, docs/TASKS.md, docs/SESSION_HANDOFF.md, docs/DECISIONS.md và git status/diff. Không coi test chưa chạy là đã đạt.

Chọn đúng MỘT task nhỏ nhất chưa xong, dependency đã được chứng minh đạt. Nếu M0 chưa qua thì không thêm feature. Nếu brief chưa được tôi duyệt, yêu cầu duyệt trước.

Trả lời: ID + mục tiêu; trạng thái thật hiện nay; scene/node/input/signal liên quan; file cần đổi; kế hoạch nhỏ; acceptance test tự động và test tay; rủi ro và điều cần tôi quyết định.

Chỉ lập kế hoạch, chờ tôi duyệt trước khi sửa. Không triển khai toàn bộ roadmap và không tự đổi phạm vi.
```
