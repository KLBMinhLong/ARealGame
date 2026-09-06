# Bàn giao phiên

## Trạng thái ban đầu

- Source starter 0.1 và bộ tài liệu đã được kiểm chứng hoạt động.
- Engine và game đã chạy thực tế trên máy người dùng, người dùng đã chơi và xác nhận thành công (T001, T002, T003 hoàn thành).
- Cache `.godot/` đã sinh hợp lệ, static checks đạt 66/66 PASS.
- M0 hoàn thành với commit baseline Git local.
- Chủ project đã duyệt thực hiện tiếp (T100 đạt).

## Việc tiếp theo

Chuyển sang nhiệm vụ tiếp theo: **T340 — Credits + license trong game**:
1. **Thiết kế UI Credits & Licenses:**
   - Bổ sung nút `CREDITS & LICENSES` trên Main Menu (song song với START RUN, HOW TO PLAY, SETTINGS).
   - Modal hiển thị bảng cuộn (ScrollContainer/VBoxContainer) hoặc bảng tab tối giản, trang trọng:
     - Tên game: **VÒNG VÂY** (AI Starter Arena Survival).
     - Đội ngũ phát triển & Công nghệ: Phát triển bởi Chủ project cùng Antigravity AI Pair Programmer.
     - Giấy phép Động cơ: **Godot Engine** (MIT License, Copyright (c) 2014-present Godot Engine contributors).
     - Giấy phép Đồ họa & Âm thanh: 100% Procedural Vector Geometry & 16-bit PCM Synthesizer (Bản quyền tự do MIT / CC0).
     - Third-party Notice: Trích dẫn liên kết và ghi nhận các thành phần mã nguồn mở theo đúng thông lệ của Godot (FreeType, MbedTLS, Libpng, v.v.).
2. **Tương tác & Khả năng truy cập:**
   - Nút `BACK` hoặc bấm `Esc` để đóng bảng Credits và quay lại Main Menu.
   - Hỗ trợ phím điều hướng hoặc cuộn mượt mà.
3. **Đồng bộ tài liệu:**
   - Đối chiếu chéo 100% khớp với `docs/ASSET_REGISTER.md` và `docs/ART_AUDIO.md`.

## Cập nhật phiên

```text
Ngày: 06/09/2026
Task: T330 — Âm thanh và audio buses (DONE)
Commit gần nhất: 2511deb docs(art-audio): specify visual geometry standards and audio asset inventory (T300)
Thay đổi chưa commit: default_bus_layout.tres, scripts/core/audio_manager.gd, scripts/actors/enemy.gd, scripts/main.gd, tests/smoke_test.gd, docs/TASKS.md, docs/SESSION_HANDOFF.md
Files/wiring vừa đổi: default_bus_layout.tres (Master with Limiter, Music, SFX buses), audio_manager.gd (procedural 16-bit PCM synth: pulse, hit, telegraph, dash, win, game_over), enemy.gd (telegraph_started, dash_started signals), main.gd (wire audio to pulse, hit, sprinter, won, lost), smoke_test.gd (test audio buses and streams)
Test đã chạy và log: tools/verify_structure.py (77/77 PASS)
Test chưa chạy: Không
Bug còn: Không
Quyết định đang chờ chủ project: Duyệt phương án kiến trúc T340 (Credits + license trong game)
Task tiếp theo (chỉ một): T340 — Credits + license trong game
```









