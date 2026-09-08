# F013 — Score / Run Summary

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Khi hy sinh (Game Over), người chơi nhận được bảng thống kê hoàn chỉnh của lượt chơi vừa qua:
- **Thời gian sống sót (Survival Time):** định dạng `MM:SS` (ví dụ `02:15`)
- **Quái đã tiêu diệt (Enemies Slain):** tổng số quái hạ gục trong run
- **Combo cao nhất (Best Combo):** xN (ví dụ `x12`)
- **Soul Shards thu thập:** tổng số shard đã nhặt
Kèm lớp phủ mờ tối (dim overlay) giúp bảng tổng kết nổi bật, dễ đọc trên nền đấu trường.

## 2. Scope / Non-goals

- **Có:**
  - Track biến `enemies_killed` trong `main.gd` (tăng khi quái chết, reset khi restart run).
  - Cập nhật hàm `hud.show_death(time_survived, enemies_killed, shards, best_chain)`.
  - Tạo lớp phủ mờ nhẹ (`dim_overlay`) phía sau text khi chết (và khi pause) để tăng độ tương phản.
  - Định dạng hiển thị thời gian phút:giây rõ ràng.
- **Không:**
  - Save vĩnh viễn / High score hệ thống lưu file (meta progression làm riêng).
  - Thống kê chi tiết từng loại quái (giữ giao diện gọn gàng cho màn hình 480x270).
  - Nút bấm chuột (vẫn dùng phím R để restart nhanh).

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| `run_time` | Đã có, track thời gian chạy và reset khi restart | `scripts/main.gd:23, 138` | VERIFIED_IN_REPO |
| `shard_count` | Đã có, track số shard nhặt được | `scripts/main.gd:135, 267` | VERIFIED_IN_REPO |
| `best_chain` | Đã có, track combo cao nhất trong run | `scripts/main.gd:136, 277` | VERIFIED_IN_REPO |
| `enemies_killed` | Chưa có biến đếm, cần thêm vào `_on_enemy_died` | — | PROPOSED |
| `hud.show_death` | Hiện chỉ nhận `shards` và `best_chain` | `scripts/ui/hud.gd:59` | VERIFIED_IN_REPO |
| Game Over gọi tại | `main.gd:109` trong `_enter_state(GameState.DEAD)` | `scripts/main.gd:109` | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Tracking `enemies_killed`
- Khai báo `var enemies_killed: int = 0` trong `main.gd`.
- Mỗi khi `_on_enemy_died()` được gọi: `enemies_killed += 1`.
- Khi `_reset_run_stats()` được gọi: `enemies_killed = 0`.

### R02 — Cập nhật `hud.show_death`
- Signature: `show_death(time_survived: float, enemies_killed: int, shards: int, best_chain: int) -> void`.
- Định dạng text:
  ```
  💀  RUN OVER  💀

  Survival Time: MM:SS
  Enemies Slain: N
  Best Combo: xN
  Shards Collected: N

  Press R to restart
  ```

### R03 — Dim Overlay
- Thêm `dim_overlay: ColorRect` (màu đen mờ ~65% opacity) vào `HUD` phía sau Label.
- Hiện khi ở state `DEATH` (và `PAUSE`), ẩn khi ở `HUD` (đang chơi) và `MENU`.

### R04 — Reset
- Bấm `R` restart run mới: toàn bộ stats (run_time, enemies_killed, shards, best_chain) reset về 0, ẩn dim overlay.

## 5. Plan nhỏ nhất

| File | Thay đổi |
|---|---|
| [MODIFY] `scripts/ui/hud.gd` | Thêm dim overlay, mở rộng `show_death()` hiển thị đủ 4 chỉ số |
| [MODIFY] `scripts/main.gd` | Track `enemies_killed`, truyền thêm `run_time` và `enemies_killed` vào `show_death()` |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Bảng thống kê hiện đủ 4 chỉ số | Runtime | Chết thấy Time (MM:SS), Enemies Slain, Best Combo, Shards | NOT_RUN |
| AC02 | Số liệu chính xác | Runtime | Giết quái, nhặt shard, tạo combo đều phản ánh đúng | NOT_RUN |
| AC03 | Nền tối tương phản | Runtime | Có lớp phủ mờ đen phía sau chữ giúp dễ đọc | NOT_RUN |
| AC04 | Restart reset về 0 | Runtime | Bấm R bắt đầu lại, stats reset về 0, lớp mờ biến mất | NOT_RUN |

## 7. Approval

- Chờ chủ dự án duyệt brief.
