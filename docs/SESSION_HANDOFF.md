# Bàn giao phiên

## Trạng thái ban đầu

- Source starter 0.1 và bộ tài liệu đã được kiểm chứng hoạt động.
- Engine và game đã chạy thực tế trên máy người dùng, người dùng đã chơi và xác nhận thành công (T001, T002, T003 hoàn thành).
- Cache `.godot/` đã sinh hợp lệ, static checks đạt 66/66 PASS.
- M0 hoàn thành với commit baseline Git local.
- Chủ project đã duyệt thực hiện tiếp (T100 đạt).

## Việc tiếp theo

Chuyển sang nhiệm vụ tiếp theo trong Milestone M3: **T320 — Settings cơ bản**:
1. Tạo module quản lý cấu hình người dùng `scripts/core/settings_manager.gd` lưu trữ tại `user://settings.cfg` (sử dụng ConfigFile an toàn).
2. Lưu các thiết lập:
   - `master_volume`: 0.0 - 1.0 (mặc định 0.8).
   - `sfx_volume`: 0.0 - 1.0 (mặc định 0.8).
   - `fullscreen`: bool (mặc định false).
   - `reduced_effects`: bool (mặc định false - giảm bớt hiệu ứng lóe sáng).
3. Hỗ trợ nút `Reset to Default`.
4. Giao diện modal `SETTINGS` trong HUD có thể mở từ Menu chính và màn hình Pause.

## Cập nhật phiên

```text
Ngày: 06/09/2026
Task: T310 — Save best survival/win count (DONE)
Commit gần nhất: ee63425 docs: mark T240 tutorial and results screen as verified and DONE
Thay đổi chưa commit: scripts/core/save_manager.gd, scripts/main.gd, scripts/ui/hud.gd, tests/smoke_test.gd, docs/TASKS.md, docs/SESSION_HANDOFF.md
Files/wiring vừa đổi: save_manager.gd (JSON user://save_data.json, schema_version 1, safe parsing & fallback), main.gd (load on ready, record_run on finish_run, _input R restart), hud.gd (BEST label, runs display, run stats on menu/won/lost), smoke_test.gd (test defaults, record_run, reload, corrupt fallback, R input)
Test đã chạy và log: tools/verify_structure.py (72/72 PASS), test manual bởi chủ project: hoạt động chuẩn xác
Test chưa chạy: Kiểm thử Settings (T320)
Bug còn: Không
Quyết định đang chờ chủ project: Duyệt phương án triển khai Cài đặt cơ bản T320
Task tiếp theo (chỉ một): T320 — Settings cơ bản (Volume, Fullscreen, Reduced effects)
```









