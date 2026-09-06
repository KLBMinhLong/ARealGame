# Chuyển phản hồi thành một thay đổi

Copy phần trong khối dưới vào agent. Đây là prompt thông thường, không tự đăng ký slash command.

```text
Đọc GAME_BRIEF, TASKS, TEST_PLAN và các ghi nhận playtest tôi cung cấp. Không tự tạo dữ liệu người chơi, FPS hoặc tỷ lệ giữ chân.

Tóm tắt vấn đề có bằng chứng, phân biệt bug/khó hiểu/không vui/thẩm mỹ. Chọn một thay đổi nhỏ có tác động rõ để test lại; không thêm hàng loạt tính năng.

Đề xuất acceptance test và cách quan sát xem thay đổi có giúp không. Nếu là UI/art: kiểm tra viewport, spacing, contrast, silhouette, hitbox và reduced effects. Nếu là performance: đo trước, không viết kiến trúc tối ưu lớn khi chưa biết bottleneck.

Chỉ đề xuất kế hoạch trước; chờ tôi duyệt. Nếu bằng chứng chưa đủ, nói thiếu gì.
```
