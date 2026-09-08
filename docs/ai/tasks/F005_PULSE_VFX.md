# F005 — Cải thiện Pulse VFX

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Pulse ring đẹp hơn: vòng dày co lại khi mở rộng, thêm inner glow và halo mờ bên ngoài, màu cyan thay vì trắng đơn. Người chơi thấy "sóng xung kích" rõ ràng hơn.

## 2. Scope / Non-goals

- **Có:** Cải thiện `_draw()` và `_handle_pulse_vfx()` trong player.gd. Ring dày hơn, multiple layers, color gradient.
- **Không:** Particles, shader, thay đổi PULSE_RADIUS/VELOCITY/COOLDOWN/damage, thêm file mới.
- **Prerequisite:** pulse VFX đã có sẵn (VERIFIED).

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| Pulse VFX hiện tại | draw_arc 1 ring, width=1.5, white, alpha fade | [player.gd:152-157](file:///d:/HandMakeGame/ARealGame/scripts/actors/player.gd#L152) | VERIFIED_IN_REPO |
| PULSE_VFX_DURATION | 0.15s | [game_config.gd:76](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L76) | VERIFIED_IN_REPO |
| PULSE_RADIUS | 50.0 px | [game_config.gd:32](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L32) | VERIFIED_IN_REPO |
| COLOR_PULSE_RING | White (1,1,1,0.8) | [game_config.gd:119](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L119) | VERIFIED_IN_REPO |
| COLOR_PLAYER | Cyan (0,0.898,1.0) | [game_config.gd:109](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L109) | VERIFIED_IN_REPO |
| draw_arc | Godot 4 built-in, width parameter | Godot docs | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Visual
- Ring chính: width 3.0→1.0 (dày → mỏng khi mở rộng).
- Inner fill: circle mờ (alpha 0.15) co lại cùng tốc độ.
- Outer halo: ring thứ 2 mờ hơn, radius +5px, width 1.0.
- Màu: cyan (match player) thay vì trắng.

### R02 — Timing
- Tăng VFX duration lên 0.2s (cũ 0.15s) cho dễ thấy.

### R03 — Không thay đổi
- PULSE_RADIUS, VELOCITY, COOLDOWN, damage, collision.

## 5. Plan nhỏ nhất

| File | Thay đổi | Lý do |
|---|---|---|
| [MODIFY] `player.gd` | Sửa _draw pulse VFX section | Visual upgrade |
| [MODIFY] `game_config.gd` | PULSE_VFX_DURATION 0.15→0.2, COLOR_PULSE_RING→cyan | Tuning |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Scope | Diff | Không đụng radius/velocity/cooldown/damage | NOT_RUN |
| AC02 | Ring dày hơn | Runtime | Ring rõ ràng, thu nhỏ width khi expand | NOT_RUN |
| AC03 | Inner glow | Runtime | Circle mờ bên trong ring | NOT_RUN |
| AC04 | Halo ngoài | Runtime | Ring mờ thứ 2 bên ngoài | NOT_RUN |
| AC05 | Màu cyan | Runtime | Ring match player color | NOT_RUN |
| AC06 | Owner feel | Manual | "Sóng xung kích" đẹp hơn trước | NOT_RUN |

## 7. Approval và completion

- Owner cho phép scope ngày: **chưa có — chờ duyệt**.
