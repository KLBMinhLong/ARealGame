# Bàn giao phiên

## Trạng thái ban đầu

- Source starter 0.1 và bộ tài liệu đã được kiểm chứng hoạt động.
- Engine và game đã chạy thực tế trên máy người dùng, người dùng đã chơi và xác nhận thành công (T001, T002, T003 hoàn thành).
- Cache `.godot/` đã sinh hợp lệ, static checks đạt 66/66 PASS.
- M0 hoàn thành với commit baseline Git local.
- Chủ project đã duyệt thực hiện tiếp (T100 đạt).


## Việc tiếp theo

Chuyển đổi theo định hướng phát triển thương mại dài hạn (**GEMINI_REVIEW_AND_IMPROVEMENT_PLAN.md**):
1. **Hoàn thành Cổng G0 (Nền an toàn):**
   - Đã xử lý triệt để R01: Cô lập đường dẫn save/settings trong smoke test, loại bỏ nguy cơ ghi đè dữ liệu chơi thật (`save_data.json` & `settings.cfg`).
   - Đã sửa crash format string unescaped `%` trong `hud.gd`.
   - Đã nâng cấp `SaveManager.load_data()` sang `JSON.new().parse()` để tránh engine error log khi kiểm thử file hỏng.
   - Toàn bộ 133/133 checks trong `smoke_test.gd` và 77/77 static checks đều PASS tuyệt đối.
2. **Khởi động Cổng G1 (Chốt sản phẩm):**
   - Nhiệm vụ tiếp theo: **G1-SPEC — Chốt đặc tả sản phẩm (Core Loop, Art Direction, Audio Direction)**.
   - Thảo luận và thống nhất với chủ project về:
     - Cơ chế "Vòng Vây: Lõi Từ" (biến quái thành linh kiện, bẫy từ trường/trạm tái chế giải quyết bài toán dồn quái và tạo phần thưởng).
     - Phong cách đồ họa nhân vật (chuyển từ hình học tạm sang sprite robot có animation đi/chạy/dash/pulse).
     - Hướng thiết kế âm thanh và nhạc nền (soundtrack loop bản quyền minh bạch).

## Cập nhật phiên

```text
Ngày: 06/09/2026
Task: G0-R01 — Cô lập save/settings test tự động (DONE - TECHNICALLY_VERIFIED)
Commit gần nhất: a324f88 feat(ui): add in-game credits, licenses modal, and project attribution (T340)
Thay đổi chưa commit: scripts/core/save_manager.gd, scripts/main.gd, scripts/ui/hud.gd, tests/smoke_test.gd, docs/TASKS.md, docs/SESSION_HANDOFF.md
Files/wiring vừa đổi:
- scripts/main.gd (custom_save_path, custom_settings_path injection)
- scripts/ui/hud.gd (unescaped % -> %%)
- scripts/core/save_manager.gd (JSON.new().parse() thay vì JSON.parse_string())
- tests/smoke_test.gd (inject test paths, assert path isolation, cleanup test files)
- docs/TASKS.md, docs/SESSION_HANDOFF.md (bổ sung lộ trình G0-G6 và cập nhật nhật ký)
Test đã chạy và log:
- tools/verify.ps1 (133/133 PASS, exit code 0)
- tools/verify_structure.py (77/77 PASS, exit code 0)
- SHA256 checksum kiểm chứng không đổi save thật
Test chưa chạy: Playtest tay đồ họa mới (chưa sản xuất asset)
Bug còn: Không có bug blocker. Đã ghi nhận các điểm R02-R06 để giải quyết trong các cổng G1, G2 tiếp theo.
Quyết định đang chờ chủ project: Duyệt tài liệu đề xuất Cổng G1-SPEC về Lối chơi (Lõi Từ), Phong cách Đồ họa và Nhạc nền.
Task tiếp theo (chỉ một): G1-SPEC — Chốt đặc tả sản phẩm (Core Loop, Art Direction, Audio Direction)
```










