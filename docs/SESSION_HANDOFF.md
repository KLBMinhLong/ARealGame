# Bàn giao phiên

## Trạng thái ban đầu

- Source starter 0.1 và bộ tài liệu đã được kiểm chứng hoạt động.
- Engine và game đã chạy thực tế trên máy người dùng, người dùng đã chơi và xác nhận thành công (T001, T002, T003 hoàn thành).
- Cache `.godot/` đã sinh hợp lệ, static checks đạt 66/66 PASS.
- M0 hoàn thành với commit baseline Git local.
- Chủ project đã duyệt thực hiện tiếp (T100 đạt).

## Việc tiếp theo

Chủ project mở Godot bấm F5 kiểm thử tay quái Sprinter (T230):
1. Quái Sprinter xuất hiện sau giây thứ 30: hình tam giác mũi tên màu đỏ `#e85050` (khác hẳn Chaser hình thoi màu cam).
2. Chu kỳ hành vi: Rình rập chậm (1.6s) → Dừng lại chiếu tia laser cảnh báo (0.6s) → Phóng vút theo đường đã khóa (0.35s) → Nghỉ khựng một nhịp (0.8s).
3. Thử né tránh khi Sprinter đang chiếu tia telegraph: bước sang bên xem cú lao có bị hụt không.
4. Thử bấm Space khi Sprinter chuẩn bị lao: cú lao có bị ngắt và Sprinter bị đẩy lùi + khựng không.
5. Pause game: quái Sprinter và tia telegraph dừng lại chính xác.

## Cập nhật phiên

```text
Ngày: 06/09/2026
Task: T230 — Sprinter có cảnh báo trước (Telegraph)
Commit gần nhất: a299a8d docs: mark T210 pulse UI as verified and DONE
Thay đổi chưa commit: scripts/core/game_config.gd, scripts/actors/enemy.gd, scripts/main.gd, tests/smoke_test.gd, docs/TASKS.md, docs/SESSION_HANDOFF.md
Files/wiring vừa đổi: game_config.gd (SPRINTER_* consts), enemy.gd (Type.SPRINTER, SprinterPhase state machine, telegraph ray draw), main.gd (spawn Sprinter after 30s), smoke_test.gd (unit tests for Sprinter)
Test đã chạy và log: tools/verify_structure.py (68/68 PASS)
Test chưa chạy: Kiểm thử tay trên Godot bởi chủ project
Bug còn: Không
Quyết định đang chờ chủ project: Kiểm thử trải nghiệm đối đầu quái Sprinter
Task tiếp theo (chỉ một): T240 — Cập nhật Tutorial & màn hình kết quả dễ hiểu
```





