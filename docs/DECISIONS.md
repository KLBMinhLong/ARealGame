# Decision log

| ID | Quyết định | Lý do | Trạng thái |
|---|---|---|---|
| ADR-001 | Godot 4.6.3 stable, GDScript, Compatibility | Theo engine người dùng và hướng game nhỏ cho máy 8 GB | Stack starter; version cần đối chiếu binary |
| ADR-002 | Vòng Vây: một sân, né quái, 180 giây | Mẫu cụ thể để học quy trình end-to-end | Đề xuất, chủ project duyệt T100 |
| ADR-003 | Node2D + kiểm tra khoảng cách, không physics body | Sân trống, không obstacle; dễ đọc wiring | Đã thể hiện trong starter source |
| ADR-004 | Main sở hữu state/tick; HUD phát signal | Pause/reset rõ và không giấu logic trong nhiều node | Đã thể hiện trong starter source |
| ADR-005 | Không asset/dependency/network ngoài | Dễ import, giảm license/thiết lập/chi phí | Baseline |
| ADR-006 | Windows x86_64 trước | Hướng dẫn mặc định cho môi trường được suy đoán | Cần xác minh OS tại T001 |
| ADR-007 | Xung đẩy là cơ chế v1 đề xuất | Thêm một quyết định có thời điểm, không làm combat lớn | Chờ playtest và chủ project duyệt |

Mỗi thay đổi lớn phải thêm: ngày, bối cảnh, lựa chọn, quyết định của ai, file/test cần cập nhật. Không đổi âm thầm rồi sửa tài liệu cho như đã được duyệt từ đầu.
