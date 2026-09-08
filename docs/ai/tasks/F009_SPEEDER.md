# F009 — Enemy Type: Speeder

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Quái mới "Speeder" — nhỏ, nhanh, nhẹ (dễ đẩy bay). Tạo sự đa dạng: phải chú ý hơn vì Speeder tiếp cận nhanh nhưng dễ bị pulse bắn xa.

## 2. Scope / Non-goals

- **Có:** Script speeder.gd (kế thừa EnemyBase), scene, config, spawn random (50% slime / 50% speeder), visual khác biệt (màu cam, nhỏ hơn).
- **Không:** AI đặc biệt (vẫn đi thẳng), boss, wave system, difficulty scaling.

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| EnemyBase | class_name, quản lý state/HP/push | [enemy_base.gd](file:///d:/HandMakeGame/ARealGame/scripts/actors/enemies/enemy_base.gd) | VERIFIED_IN_REPO |
| Slime config | HP=1, speed=30, size=10, weight=1.0 | [game_config.gd:82-86](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L82) | VERIFIED_IN_REPO |
| Slime _draw | Override _draw trong slime.gd, circle | [slime.gd:16-31](file:///d:/HandMakeGame/ARealGame/scripts/actors/enemies/slime.gd#L16) | VERIFIED_IN_REPO |
| Spawn | _spawn_slime() hardcoded, 1 type | [main.gd:199-205](file:///d:/HandMakeGame/ARealGame/scripts/main.gd#L199) | VERIFIED_IN_REPO |
| Signal wiring | Per enemy: died + wall_slammed | [main.gd:203-204](file:///d:/HandMakeGame/ARealGame/scripts/main.gd#L203) | VERIFIED_IN_REPO |
| Death VFX | Dùng COLOR_SLIME hardcoded | [main.gd:242](file:///d:/HandMakeGame/ARealGame/scripts/main.gd#L242) | VERIFIED_IN_REPO |

### Cần thay đổi
- Death VFX color: hiện hardcoded `COLOR_SLIME` → cần lấy từ enemy hoặc truyền color khi died.
- Spawn: cần generic `_spawn_enemy` thay vì `_spawn_slime`.

## 4. Contract

### R01 — Speeder stats
- HP: 1, Speed: 60 (2× slime), Size: 7 (nhỏ hơn), Weight: 0.6 (nhẹ hơn → bay xa), Shard: 1.

### R02 — Visual
- Màu cam/đỏ cam. Hình triangle (khác circle slime). DYING flash trắng giống slime.

### R03 — Spawn
- Random 50/50 slime/speeder mỗi spawn tick.
- Dùng generic _spawn_enemy thay _spawn_slime.

### R04 — Death VFX color
- Lấy color từ enemy thay vì hardcode.

### R05 — Không thay đổi
- Slime behavior/stats, chain/push logic, player.

## 5. Plan nhỏ nhất

| File | Thay đổi |
|---|---|
| [NEW] `scripts/actors/enemies/speeder.gd` | Script |
| [NEW] `scenes/enemies/speeder.tscn` | Scene |
| [MODIFY] `game_config.gd` | +SPEEDER constants, +COLOR_SPEEDER |
| [MODIFY] `main.gd` | Generic spawn, random type, fix death VFX color |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Speeder spawns | Runtime | Quái cam nhỏ xuất hiện | NOT_RUN |
| AC02 | Speed nhanh hơn | Runtime | Speeder tiếp cận nhanh hơn slime | NOT_RUN |
| AC03 | Nhẹ hơn | Runtime | Pulse đẩy speeder xa hơn slime | NOT_RUN |
| AC04 | Visual khác | Runtime | Triangle cam vs circle xanh | NOT_RUN |
| AC05 | Death VFX đúng màu | Runtime | Speeder chết → particles cam | NOT_RUN |
| AC06 | Slime không đổi | Runtime | Slime vẫn như cũ | NOT_RUN |

## 7. Approval

- Chờ duyệt.
