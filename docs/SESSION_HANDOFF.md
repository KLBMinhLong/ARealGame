# Bàn giao phiên

## Trạng thái ban đầu

- Source starter 0.1 và bộ tài liệu đã được kiểm chứng hoạt động.
- Engine và game đã chạy thực tế trên máy người dùng, người dùng đã chơi và xác nhận thành công (T001, T002, T003 hoàn thành).
- Cache `.godot/` đã sinh hợp lệ, static checks đạt 66/66 PASS.
- M0 hoàn thành với commit baseline Git local.
- Chủ project đã duyệt thực hiện tiếp (T100 đạt).

## Việc tiếp theo

Chủ project mở Godot bấm F5 kiểm thử tay Tutorial và Màn hình kết quả (T240):
1. Tại Menu chính: bấm nút **HOW TO PLAY** xem bảng hướng dẫn chi tiết (phím điều khiển, Pulse Space, Chaser cam, Sprinter đỏ). Bấm **BACK** quay lại Menu.
2. Trong lúc Pause (Esc): bấm **HOW TO PLAY** xem có mở hướng dẫn và bấm **BACK** quay lại màn hình Pause không.
3. Khi thua (Lost): kiểm tra màn hình **RUN TERMINATED** có hiển thị thống kê thời gian sống sót, tỷ lệ %, số lượng Drone trên sân và lời khuyên chiến thuật (Tip).
4. Thử bấm phím `R` hoặc nút **TRY AGAIN**: trận đấu reset sạch và bắt đầu lại ngay lập tức.
5. Khi sống sót 03:00 (Won): kiểm tra màn hình **VICTORY** hiển thị trọn vẹn 100%.

## Cập nhật phiên

```text
Ngày: 06/09/2026
Task: T240 — Tutorial và kết quả dễ hiểu
Commit gần nhất: f52c6f4 docs: mark T230 Sprinter enemy as verified and DONE
Thay đổi chưa commit: scripts/ui/hud.gd, scripts/main.gd, tests/smoke_test.gd, docs/TASKS.md, docs/SESSION_HANDOFF.md
Files/wiring vừa đổi: hud.gd (HOW TO PLAY button, tutorial panel, detailed lost/won stats and tips), main.gd (pass drone count to show_panel), smoke_test.gd (test tutorial navigation and result titles)
Test đã chạy và log: tools/verify_structure.py (68/68 PASS)
Test chưa chạy: Kiểm thử tay trên Godot bởi chủ project
Bug còn: Không
Quyết định đang chờ chủ project: Kiểm thử trải nghiệm Tutorial và màn hình Kết quả
Task tiếp theo (chỉ một): Hoàn thành Milestone M2 & Chuẩn bị Milestone M3 (Save & Settings)
```








