# Bàn giao phiên

## Trạng thái ban đầu

- Source starter 0.1 và bộ tài liệu đã được kiểm chứng hoạt động.
- Engine và game đã chạy thực tế trên máy người dùng, người dùng đã chơi và xác nhận thành công (T001, T002, T003 hoàn thành).
- Cache `.godot/` đã sinh hợp lệ, static checks đạt 66/66 PASS.
- M0 hoàn thành với commit baseline Git local.
- Chủ project đã duyệt thực hiện tiếp (T100 đạt).

## Việc tiếp theo

Milestone M3 (v1 Feature Set) đã hoàn tất 100%.
Chuyển sang **Milestone M4 — Release Candidate**:
Nhiệm vụ tiếp theo: **T400 — Regression đầy đủ**:
1. **Rà soát toàn diện danh mục TEST_PLAN:**
   - Kiểm tra toàn bộ các khâu cốt lõi: Khởi động không lỗi, cấu hình Viewport 1152x648, renderer GL Compatibility.
   - Di chuyển chuẩn 8 hướng không vượt biên sân đấu 1072x480.
   - Cơ chế xung Space Pulse (bán kính 120px, đẩy 80px, stun 0.25s, hồi chiêu 4s, vòng sạc quanh Drone).
   - Va chạm & thời gian hồi 1.2s bất tử; Hull giảm chính xác từ 3 về 0.
   - Hành vi quái: Chaser bám đuôi, Sprinter báo laser đỏ 0.6s và lao theo hướng đã khóa.
   - Hệ thống UI: Main Menu, How to Play, Settings (Master/SFX volume, Fullscreen, Reduced flash), Credits & Licenses (MIT/CC0).
   - Tạm dừng/tiếp tục (Esc), chơi lại nhanh (phím R), lưu/tải kỷ lục `user://save_data.json`.
   - Hệ thống âm thanh procedural synth trên bus SFX có Master Limiter bảo vệ chống rè.
2. **Cập nhật báo cáo kiểm thử:**
   - Ghi nhận nhật ký kiểm thử chính thức vào [docs/QA_REPORT.md](file:///d:/HandMakeGame/ARealGame/docs/QA_REPORT.md).

## Cập nhật phiên

```text
Ngày: 06/09/2026
Task: T350 — Cân bằng đủ lượt 180 giây (DONE)
Commit gần nhất: a324f88 feat(ui): add in-game credits, licenses modal, and project attribution (T340)
Thay đổi chưa commit: tests/smoke_test.gd, docs/qa/static-check.txt, docs/TASKS.md, docs/SESSION_HANDOFF.md
Files/wiring vừa đổi: smoke_test.gd (test toán học độ khó tăng tiến, kiểm tra các ngưỡng an toàn chống unfair spawn, và giả lập kích hoạt chiến thắng 180s)
Test đã chạy và log: tools/verify_structure.py (77/77 PASS), docs/qa/static-check.txt
Test chưa chạy: Không
Bug còn: Không
Quyết định đang chờ chủ project: Duyệt chuyển sang Milestone M4 (Task T400 — Regression đầy đủ)
Task tiếp theo (chỉ một): T400 — Regression đầy đủ
```









