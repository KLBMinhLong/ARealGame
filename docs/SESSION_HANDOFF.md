# Bàn giao phiên

## Trạng thái ban đầu

- Source starter 0.1 và bộ tài liệu đã được kiểm chứng hoạt động.
- Engine và game đã chạy thực tế trên máy người dùng, người dùng đã chơi và xác nhận thành công (T001, T002, T003 hoàn thành).
- Cache `.godot/` đã sinh hợp lệ, static checks đạt 66/66 PASS.
- M0 hoàn thành với commit baseline Git local.
- Chủ project đã duyệt thực hiện tiếp (T100 đạt).

## Việc tiếp theo

Chuyển sang **Milestone M3 (Đầy đủ tính năng v1)**:
Bắt đầu với nhiệm vụ **T310 — Save best survival & win count**:
1. Tạo module quản lý lưu trữ an toàn [scripts/core/save_manager.gd](file:///d:/HandMakeGame/ARealGame/scripts/core/save_manager.gd) sử dụng đường dẫn `user://save_data.json`.
2. Lưu trữ: Kỷ lục sống sót cao nhất (`best_survival_seconds`), Số trận thắng (`win_count`), Tổng số trận đã chơi (`total_runs`).
3. Xử lý an toàn: Fallback mặc định khi file chưa tồn tại hoặc bị lỗi định dạng, kiểm tra lỗi ghi an toàn.
4. Hiển thị kỷ lục `BEST: 02:15` trên giao diện HUD và màn hình kết quả trận đấu.

## Cập nhật phiên

```text
Ngày: 06/09/2026
Task: T240 — Tutorial và kết quả dễ hiểu (DONE) -> Hoàn thành Milestone M2
Commit gần nhất: c30ff46 fix(ui): declare missing shade and panel variables in hud.gd
Thay đổi chưa commit: docs/TASKS.md, docs/SESSION_HANDOFF.md
Files/wiring vừa đổi: docs/TASKS.md, docs/SESSION_HANDOFF.md
Test đã chạy và log: tools/verify_structure.py (68/68 PASS), test manual bởi chủ project: hoạt động chuẩn xác
Test chưa chạy: Kiểm thử hệ thống Save (T310)
Bug còn: Không
Quyết định đang chờ chủ project: Duyệt triển khai tính năng Lưu điểm kỷ lục T310
Task tiếp theo (chỉ một): T310 — Save best survival/win count
```









