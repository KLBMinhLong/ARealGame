# Chuẩn bị bản build, không phát hành

Copy phần trong khối dưới vào agent. Đây là prompt thông thường, không tự đăng ký slash command.

```text
Đọc AGENT_RULES, TASKS, TEST_PLAN, RELEASE_CHECKLIST, ASSET_REGISTER và QA/handoff mới nhất.

Chỉ chuẩn bị release candidate Windows trong builds/windows, không upload, publish, push public, trả phí hay tạo tài khoản. Kiểm tra cổng M0–M4; thiếu kiểm thử/licensing thì báo blocker, không che bằng store copy.

Xác minh Godot executable/version và export templates phù hợp. Nếu thiếu templates, hỏi tôi trước khi tải, không tự dùng bản khác. Kiểm tra preset, tạo thư mục build, chạy --export-release nếu được phép, xem cả log và exit code.

Liệt kê chính xác các file output cần phân phối. Với preset PCK không nhúng, đừng chỉ lấy exe. Kiểm tra không đóng gói secret/log/docs/test không cần. Hướng dẫn tôi test từ thư mục sạch khi editor đã đóng; không bịa rằng bạn đã chơi trên Windows nếu chưa làm được.

Kết thúc với build version/commit, log export, file list, checksum nếu tạo, checklist test thật còn lại, giới hạn và quyết định cần tôi duyệt.
```
