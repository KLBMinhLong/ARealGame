# F006 — Enemy Death VFX

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Khi quái chết, burst particles nhỏ bắn ra từ vị trí chết + flash trắng ngắn. Tạo cảm giác "phá hủy" rõ ràng.

## 2. Scope / Non-goals

- **Có:** Flash trắng trong DYING state (slime.gd _draw), CPUParticles2D burst tại vị trí chết (spawned bởi VFX), dùng màu quái.
- **Không:** Sound, thay đổi HP/damage/dying duration, enemy type mới.
- **Prerequisite:** `died(position, shards, is_altar)` signal hoạt động (VERIFIED).

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| died signal | `(position, shard_amount, is_altar_seal)` | [enemy_base.gd:7](file:///d:/HandMakeGame/ARealGame/scripts/actors/enemies/enemy_base.gd#L7) | VERIFIED_IN_REPO |
| _die() | Set DYING, emit died, dying_timer=0 | [enemy_base.gd:140-143](file:///d:/HandMakeGame/ARealGame/scripts/actors/enemies/enemy_base.gd#L140) | VERIFIED_IN_REPO |
| DYING_DURATION | 0.15s, queue_free ở cuối | [game_config.gd:48](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L48) | VERIFIED_IN_REPO |
| Slime DYING draw | Fade alpha, không flash | [slime.gd:25-28](file:///d:/HandMakeGame/ARealGame/scripts/actors/enemies/slime.gd#L25) | VERIFIED_IN_REPO |
| VFX container | $VFX (wall_dust.gd), có spawn_dust + clear | [wall_dust.gd](file:///d:/HandMakeGame/ARealGame/scripts/vfx/wall_dust.gd) | VERIFIED_IN_REPO |
| died wiring | main.gd _on_enemy_died, per enemy | [main.gd:201](file:///d:/HandMakeGame/ARealGame/scripts/main.gd#L201) | VERIFIED_IN_REPO |
| COLOR_SLIME | (0.176, 0.353, 0.153) green | [game_config.gd:112](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L112) | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Flash (trong enemy)
- Khi DYING bắt đầu: color = trắng → lerp về color gốc → fade alpha. Nhanh (0.15s total).

### R02 — Burst particles (trong VFX)
- CPUParticles2D one-shot tại died position, 8-12 hạt.
- Màu = color quái (slime green). Spread 360°, velocity nhỏ.
- Lifetime 0.3s, tự cleanup.

### R03 — Không thay đổi
- HP, damage, dying duration, chain, scoring, collision.

## 5. Plan nhỏ nhất

| File | Thay đổi | Lý do |
|---|---|---|
| [MODIFY] `slime.gd` | DYING draw: flash trắng → lerp | Flash effect |
| [MODIFY] `wall_dust.gd` | +spawn_death_burst(pos, color) | Burst particles |
| [MODIFY] `main.gd` | _on_enemy_died gọi vfx.spawn_death_burst | Wiring |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Scope | Diff | Không đụng HP/damage/dying duration | NOT_RUN |
| AC02 | Flash trắng | Runtime | Quái chết → flash trắng rồi fade | NOT_RUN |
| AC03 | Burst particles | Runtime | Hạt xanh bắn ra từ vị trí chết | NOT_RUN |
| AC04 | Auto cleanup | Runtime | Particles biến mất sau 0.3s | NOT_RUN |
| AC05 | Owner feel | Manual | "Phá hủy" rõ ràng, không quá chói | NOT_RUN |

## 7. Approval và completion

- Owner cho phép scope ngày: **chưa có — chờ duyệt**.
