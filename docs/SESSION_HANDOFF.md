# Bàn giao phiên

## Trạng thái ban đầu

- Source starter 0.1 và bộ tài liệu đã được kiểm chứng hoạt động.
- Engine và game đã chạy thực tế trên máy người dùng, người dùng đã chơi và xác nhận thành công (T001, T002, T003 hoàn thành).
- Cache `.godot/` đã sinh hợp lệ, static checks đạt 66/66 PASS.
- M0 hoàn thành với commit baseline Git local.
- Chủ project đã duyệt thực hiện tiếp (T100 đạt).

## Việc tiếp theo

Chuyển sang nhiệm vụ tiếp theo: **T330 — Âm thanh và audio buses**:
1. Thiết lập Audio Buses trong Godot (`default_bus_layout.tres`): Master, Music, SFX với Compressor/Limiter bảo vệ chống clipping.
2. Xây dựng module phát âm thanh `scripts/core/audio_manager.gd` quản lý phát các hiệu ứng âm thanh cốt lõi (Pulse, Hit, Telegraph, Dash, Win, Game Over).
3. Đấu nối các sự kiện game sang `audio_manager`:
   - Space pulse -> phát âm `sfx_pulse`.
   - Player trúng đòn -> phát âm `sfx_hit`.
   - Sprinter báo trước -> phát âm `sfx_telegraph`.
   - Sprinter lao -> phát âm `sfx_dash`.
   - Chiến thắng 03:00 -> phát âm `sfx_win`.
   - Thua trận -> phát âm `sfx_game_over`.
4. Đảm bảo âm lượng tuân thủ cài đặt trong Settings (Master / SFX volume) và tạm dừng/tiếp tục đúng khi Pause game.

## Cập nhật phiên

```text
Ngày: 06/09/2026
Task: T300 — Art/audio direction + inventory (DONE)
Commit gần nhất: dade734 feat(settings): add persistent volume, display, and accessibility options (T320)
Thay đổi chưa commit: docs/ART_AUDIO.md, docs/ASSET_REGISTER.md, docs/TASKS.md, docs/SESSION_HANDOFF.md
Files/wiring vừa đổi: ART_AUDIO.md (hoàn thiện quy chuẩn hình học vector và thông số 6 SFX cốt lõi), ASSET_REGISTER.md (đăng ký 100% tài nguyên visual, UI và audio kế hoạch)
Test đã chạy và log: tools/verify_structure.py (75/75 PASS)
Test chưa chạy: Kiểm thử hệ thống âm thanh (T330)
Bug còn: Không
Quyết định đang chờ chủ project: Duyệt phương án triển khai Hệ thống Âm thanh và Audio Buses T330
Task tiếp theo (chỉ một): T330 — Âm thanh và audio buses (Master/Music/SFX)
```









