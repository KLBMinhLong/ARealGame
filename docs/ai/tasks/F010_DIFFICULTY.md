# F010 — Difficulty Scaling

**Status:** DONE
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** HUMAN_PLAYTEST_PASSED (2026-09-08)

## 1. Kết quả người chơi nhận được

Game càng lâu càng khó: spawn nhanh hơn, nhiều quái hơn, tỷ lệ speeder tăng. Tạo áp lực thời gian tự nhiên.

## 2. Scope / Non-goals

- **Có:** Track run_time, giảm spawn interval, tăng max concurrent, tăng speeder ratio theo thời gian. Công thức đơn giản (lerp).
- **Không:** Wave system, boss, enemy buff, thay đổi HP/damage.

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| SPAWN_INTERVAL | 2.0s (cố định) | [game_config.gd:95](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L95) | VERIFIED_IN_REPO |
| SPAWN_MAX_CONCURRENT | 15 (cố định) | [game_config.gd:96](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L96) | VERIFIED_IN_REPO |
| SpawnTimer | Timer node, wait_time set 1 lần | [main.gd:183-184](file:///d:/HandMakeGame/ARealGame/scripts/main.gd#L183) | VERIFIED_IN_REPO |
| Speeder ratio | 50% hardcoded randf() | [main.gd:201](file:///d:/HandMakeGame/ARealGame/scripts/main.gd#L201) | VERIFIED_IN_REPO |
| run_time | Chưa có — cần thêm | — | PROPOSED |

## 4. Contract

### R01 — Scaling over 3 minutes
- `run_time` tăng mỗi frame khi RUNNING.
- Spawn interval: 2.0s → 0.8s (lerp over 180s).
- Max concurrent: 15 → 25 (lerp over 180s).
- Speeder ratio: 50% → 75% (lerp over 180s).
- Update spawn_timer.wait_time mỗi spawn tick.

### R02 — Config
- Thêm constants: SCALE_DURATION, MIN_SPAWN_INTERVAL, MAX_SPAWN_CAP, MAX_SPEEDER_RATIO.

### R03 — Reset
- run_time reset trong _reset_run_stats.

### R04 — Không thay đổi
- Enemy stats, player stats, push/chain logic.

## 5. Plan nhỏ nhất

| File | Thay đổi |
|---|---|
| [MODIFY] `game_config.gd` | +scaling constants |
| [MODIFY] `main.gd` | +run_time, scaling logic in spawn |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Game khó dần | Runtime | Quái spawn nhanh hơn theo thời gian | PASS |
| AC02 | Nhiều speeder hơn | Runtime | Tỷ lệ cam tăng | PASS |
| AC03 | Restart reset | Runtime | Run mới bắt đầu dễ lại | PASS |
| AC04 | Scope | Diff | Không đụng enemy/player stats | PASS |

## 7. Approval

- Đã duyệt và playtest đạt bởi chủ dự án (2026-09-08).
