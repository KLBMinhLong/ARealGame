# F004 — Wall Dust Particles

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Khi quái bị đẩy đập vào tường arena, vài hạt bụi nhỏ bắn ra từ điểm va chạm, tạo phản hồi trực quan cho wall slam. Nhẹ nhàng, không che tình huống.

## 2. Scope / Non-goals

- **Có:** CPUParticles2D one-shot tại vị trí wall slam, hướng bắn ngược tường, tự cleanup.
- **Không:** GPU particles (overkill cho pixel art nhỏ), thay đổi damage/collision, sound, screen shake mới.
- **Prerequisite:** `wall_slammed(at_position)` signal hoạt động (VERIFIED).

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| wall_slammed signal | `(at_position: Vector2)`, emit khi enemy hit wall | [enemy_base.gd:8,174](file:///d:/HandMakeGame/ARealGame/scripts/actors/enemies/enemy_base.gd#L8) | VERIFIED_IN_REPO |
| wall_slammed wiring | Per enemy trong _spawn_slime → _on_wall_slam_for_shake | [main.gd:202](file:///d:/HandMakeGame/ARealGame/scripts/main.gd#L202) | VERIFIED_IN_REPO |
| Arena bounds | ORIGIN=(30,30), END=(450,240) | [game_config.gd:16-19](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L16) | VERIFIED_IN_REPO |
| VFX container | $VFX (Node2D), trống, world space | [main.tscn:27](file:///d:/HandMakeGame/ARealGame/scenes/main.tscn#L27) | VERIFIED_IN_REPO |
| wall_slammed chỉ có position | Không có hướng tường. Cần suy từ position vs ARENA bounds | enemy_base.gd:154-170 | VERIFIED_IN_REPO |
| CPUParticles2D | Built-in Godot 4, one_shot=true tự dừng, cần queue_free thủ công | Godot 4.6 docs | VERIFIED_IN_REPO |

### Phát hiện

1. **Thiếu hướng tường**: wall_slammed chỉ emit position, không biết enemy đập tường nào (top/bottom/left/right). Giải pháp: suy hướng từ position so với arena bounds — gần bound nào nhất = tường đó.

## 4. Contract

### R01 — Trigger
- wall_slammed signal → spawn dust particles tại at_position.
- Hướng bắn: ngược ra khỏi tường (đập left wall → bắn phải).

### R02 — Particles
- CPUParticles2D, one_shot=true, 4-8 hạt.
- Màu: trắng/xám nhạt, alpha thấp.
- Lifetime: 0.3-0.5s.
- Spread nhỏ (±30°), velocity nhỏ (20-40 px/s).
- Gravity nhẹ xuống.
- Tự queue_free sau lifetime.

### R03 — Lifecycle
- Restart/menu → queue_free tất cả particles trong $VFX.
- Pause → particles pause theo tree (Node2D = PAUSABLE).

### R04 — Không thay đổi
- Damage, collision, camera, chain, spawn, scoring.

## 5. Plan nhỏ nhất

| File | Thay đổi | Lý do |
|---|---|---|
| [NEW] `scripts/vfx/wall_dust.gd` | Spawn CPUParticles2D one-shot | Core feature |
| [MODIFY] `main.gd` | Kết nối wall_slammed → dust, cleanup | Wiring |

### Rollback
- `git revert` commit.

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Scope | Diff | Không đụng damage/collision/camera/chain | NOT_RUN |
| AC02 | Wall slam → dust | Runtime | Quái đập tường → hạt bụi bắn ra | NOT_RUN |
| AC03 | Hướng đúng | Runtime | Đập left wall → bụi bắn phải | NOT_RUN |
| AC04 | Auto cleanup | Runtime | Particles biến mất sau 0.3-0.5s | NOT_RUN |
| AC05 | Restart/menu | Runtime | Particles clear | NOT_RUN |
| AC06 | Owner feel | Manual | Nhẹ nhàng, không che tình huống | NOT_RUN |

## 7. Approval và completion

- Owner cho phép scope ngày: **chưa có — chờ duyệt**.
