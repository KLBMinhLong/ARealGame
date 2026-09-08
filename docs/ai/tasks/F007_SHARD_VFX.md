# F007 — Shard Pickup VFX

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Khi nhặt shard, vài hạt vàng bắn ra từ vị trí nhặt + shard flash sáng trước khi biến mất. Feedback nhặt loot rõ ràng.

## 2. Scope / Non-goals

- **Có:** CPUParticles2D burst vàng tại vị trí pickup, shard flash trước queue_free.
- **Không:** Sound, thay đổi magnet/shard value/lifetime, UI animation.
- **Prerequisite:** collected signal (VERIFIED, nhưng không có position — cần sửa).

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| collected signal | Không có parameter (voidd) | [shard.gd:6](file:///d:/HandMakeGame/ARealGame/scripts/world/shard.gd#L6) | VERIFIED_IN_REPO |
| Pickup logic | dist < 6.0 → emit → queue_free | [shard.gd:33-35](file:///d:/HandMakeGame/ARealGame/scripts/world/shard.gd#L33) | VERIFIED_IN_REPO |
| COLOR_SHARD | Yellow (0.980, 0.800, 0.082) | [game_config.gd:118](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L118) | VERIFIED_IN_REPO |
| _on_shard_collected | shard_count += 1, không có position | [main.gd:253](file:///d:/HandMakeGame/ARealGame/scripts/main.gd#L253) | VERIFIED_IN_REPO |

### Cần thay đổi
- collected signal cần thêm position: `collected(at_position: Vector2)`.

## 4. Contract

### R01 — Trigger
- Shard pickup → burst particles vàng tại position.

### R02 — Particles
- 6 hạt, 360°, vàng→fade, 0.25s, one-shot.

### R03 — Không thay đổi
- Shard value, magnet, lifetime, scoring logic.

## 5. Plan nhỏ nhất

| File | Thay đổi | Lý do |
|---|---|---|
| [MODIFY] `shard.gd` | collected signal +position, emit position | Signal fix |
| [MODIFY] `wall_dust.gd` | +spawn_pickup_burst(pos) | Particles |
| [MODIFY] `main.gd` | _on_shard_collected(pos) → vfx | Wiring |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Scope | Diff | Không đụng shard value/magnet/lifetime | NOT_RUN |
| AC02 | Pickup → burst | Runtime | Nhặt shard → hạt vàng bắn ra | NOT_RUN |
| AC03 | Auto cleanup | Runtime | Particles biến mất nhanh | NOT_RUN |
| AC04 | Owner feel | Manual | Nhặt loot thấy "satisfying" | NOT_RUN |

## 7. Approval và completion

- Owner cho phép scope ngày: **chưa có — chờ duyệt**.
