# Bàn giao phiên

## Trạng thái ban đầu

- Source starter 0.1 và bộ tài liệu đã được kiểm chứng hoạt động.
- Engine và game đã chạy thực tế trên máy người dùng, người dùng đã chơi và xác nhận thành công (T001, T002, T003 hoàn thành).
- Cache `.godot/` đã sinh hợp lệ, static checks đạt 66/66 PASS.
- M0 hoàn thành với commit baseline Git local.
- Chủ project đã duyệt thực hiện tiếp (T100 đạt).

## Việc tiếp theo

Chủ project mở Godot bấm F5 kiểm thử tay cơ chế Xung đẩy (phím Space):
1. Bấm Space khi quái đến gần: quái trong bán kính 120px bị đẩy lùi 80px và khựng 0.25s.
2. Bấm Space liên tục: kiểm tra hồi chiêu 4 giây (không được xả liên tục).
3. Bấm Esc pause: kiểm tra hồi chiêu đóng băng.
4. Xác nhận kết quả test tay để chuyển T200 sang DONE và tiếp tục sang T210 (Thanh hiển thị hồi chiêu trên UI).

## Cập nhật phiên

```text
Ngày: 06/09/2026
Task: T200 — Xung đẩy bằng phím Space
Commit gần nhất: chore: add verified Godot starter baseline
Thay đổi chưa commit: project.godot, game_config.gd, player.gd, enemy.gd, main.gd, hud.gd, smoke_test.gd, verify_structure.py, docs/
Files/wiring vừa đổi: project.godot (action pulse), game_config.gd (PULSE_* consts), player.gd (signal pulse_triggered, cooldown, draw wave), enemy.gd (push_back, stun), main.gd (_on_player_pulse wiring), hud.gd (instruction label)
Test đã chạy và log: tools/verify_structure.py (68/68 PASS)
Test chưa chạy: Kiểm thử tay trên Godot bởi chủ project
Bug còn: Không
Quyết định đang chờ chủ project: Kiểm thử trải nghiệm xung Space trên máy
Task tiếp theo (chỉ một): T210 — UI hồi chiêu + feedback xung
```

