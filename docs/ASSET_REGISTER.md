# Asset register

Chỉ thêm asset vào bản phát hành khi quyền sử dụng rõ. UNKNOWN là trạng thái chặn, không phải “chắc được”.

## Danh mục tài nguyên hiện có và kế hoạch v1

| File/thành phần | Nguồn | Loại/license | Dùng thương mại? | Ghi công/điều kiện | Trạng thái |
|---|---|---|---|---|---|
| Geometry trong `scripts/actors` và `world` (Player, Chaser, Sprinter, Arena) | Mã nguồn GDScript vẽ vector procedural nội bộ | MIT / Bản quyền project | Cho phép thương mại | Không cần ghi công đặc biệt | APPROVED |
| Giao diện HUD & Theme Flat Styleboxes (`scripts/ui/hud.gd`) | Mã nguồn GDScript UI nội bộ | MIT / Bản quyền project | Cho phép thương mại | Không cần ghi công đặc biệt | APPROVED |
| Hệ thống âm thanh Procedural SFX (`scripts/core/audio_manager.gd`) | Thuật toán sinh sóng âm thanh nội bộ qua AudioStreamWAV | MIT / Bản quyền project | Cho phép thương mại | Không phụ thuộc asset bên ngoài | APPROVED |
| Godot runtime khi export | Godot Engine (`v4.6.3.stable.official`) | MIT License | Theo giấy phép engine | Ghi chú trong màn hình Credits/Licenses (T340) | APPROVED |
| Font hệ thống fallback của engine | Đi kèm Godot Engine | Theo bộ third-party notices của Godot | Cho phép thương mại | Không vi phạm font ngoài | APPROVED |

## Mẫu cho asset mới phát sinh

- Đường dẫn trong project:
- URL/file nguồn và tác giả:
- Ngày lấy/tạo:
- License chính xác và bản sao/link điều khoản:
- Điều kiện thương mại, sửa đổi, phân phối:
- Text credit bắt buộc:
- Công cụ AI/điều khoản nếu có:
- Người duyệt và trạng thái APPROVED / UNKNOWN / REJECTED:

Không đính kèm token tài khoản vào nguồn. Khi dùng dịch vụ tạo asset, lưu chứng cứ điều khoản cho đúng gói/tài khoản vào nơi riêng phù hợp, không bịa quyền.
