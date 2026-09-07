# F002 — Hit-stop (Game Freeze on Impact)

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-07)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Khi Arcane Pulse trúng quái, game đóng băng ngắn (~40ms), tạo cảm giác "nặng đòn". Chain domino tăng thời gian freeze, tối đa 80ms. Người chơi cảm nhận mỗi va chạm rõ ràng hơn mà không bị giật.

## 2. Scope / Non-goals

- **Có:** freeze/unfreeze game qua `Engine.time_scale`, timer real-time, lifecycle clear, config enable/disable.
- **Không:** camera shake mới, damage/force/cooldown thay đổi, VFX/audio, slow-motion kéo dài, Settings UI, thay đổi logic chain/spawn/collision.
- **Prerequisite:** Push system có event khi pulse trúng quái (hiện **CHƯA CÓ** signal `pulse_hit` — cần thêm).

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| Engine version | Godot v4.6.3 | project.godot `config/features` | VERIFIED_IN_REPO |
| Config HITSTOP_PULSE | 0.04 (s) | [game_config.gd:61](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L61) | VERIFIED_IN_REPO |
| Config HITSTOP_CHAIN_ADD | 0.01 (s) | [game_config.gd:62](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L62) | VERIFIED_IN_REPO |
| Config HITSTOP_MAX | 0.08 (s) | [game_config.gd:63](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L63) | VERIFIED_IN_REPO |
| pulse_fired signal | `(position: Vector2, radius: float)` | [player.gd:6](file:///d:/HandMakeGame/ARealGame/scripts/actors/player.gd#L6) | VERIFIED_IN_REPO |
| pulse_fired → push_system | push_system._on_pulse_fired biết số quái trúng | [push_system.gd:44-62](file:///d:/HandMakeGame/ARealGame/scripts/systems/push_system.gd#L44-L62) | VERIFIED_IN_REPO |
| Signal `pulse_hit(count)` | **KHÔNG TỒN TẠI** — push_system không emit event khi pulse trúng | grep toàn scripts/ | VERIFIED_IN_REPO |
| chain_updated signal | `(chain_count: int)`, emit mỗi domino collision | [push_system.gd:7](file:///d:/HandMakeGame/ARealGame/scripts/systems/push_system.gd#L7) | VERIFIED_IN_REPO |
| Engine.time_scale usage | Chưa ai dùng trong project | grep toàn scripts/ | VERIFIED_IN_REPO |
| camera_shake.gd process_mode | ALWAYS + dùng unscaled delta → **tương thích** với time_scale=0 | [camera_shake.gd:38,55](file:///d:/HandMakeGame/ARealGame/scripts/systems/camera_shake.gd#L38) | VERIFIED_IN_REPO |
| Main process_mode | ALWAYS; World/PushSystem/SpawnTimer = PAUSABLE | [main.gd:28-32](file:///d:/HandMakeGame/ARealGame/scripts/main.gd#L28-L32) | VERIFIED_IN_REPO |
| Pause mechanism | `get_tree().paused = true` | [main.gd:91](file:///d:/HandMakeGame/ARealGame/scripts/main.gd#L91) | VERIFIED_IN_REPO |
| Hit-stop implementation | Chưa có code nào trong repo | grep toàn scripts/ | VERIFIED_IN_REPO |

### Phát hiện cần giải quyết

1. **Thiếu `pulse_hit` signal:** push_system biết bao nhiêu quái bị pulse trúng (biến `enemies` ở line 45) nhưng không emit ra ngoài. Cần thêm signal + 1 dòng emit. Đây là thay đổi nhỏ nhất trong push_system, không đụng logic push/chain.

2. **time_scale vs pause:** Hit-stop dùng `Engine.time_scale = 0`, khác với pause (`get_tree().paused`). Node PAUSABLE vẫn chạy khi time_scale=0 nhưng delta=0 → gameplay đứng yên. Cần hitstop controller có `PROCESS_MODE_ALWAYS` để tự unfreeze.

3. **Xung đột hit-stop + pause:** Nếu player pause (ESC) trong lúc hit-stop → time_scale phải được restore. Giải quyết: `hitstop.clear()` khi enter PAUSED/DEAD/MENU.

4. **Camera shake tương thích:** camera_shake.gd đã dùng ALWAYS + comment "unscaled delta" nhưng thực tế `get_process_delta_time()` khi `time_scale=0` trả về 0. Cần kiểm tra decay có hoạt động đúng không → nếu không, dùng real time thay thế.

## 4. Contract

### R01 — Trigger và điều kiện
- Pulse trúng ≥1 quái → freeze `HITSTOP_PULSE` (0.04s).
- Chain x2+ → freeze `min(HITSTOP_PULSE + HITSTOP_CHAIN_ADD × (chain-1), HITSTOP_MAX)`.
- Nếu đang freeze, request mới chỉ kéo dài nếu duration > thời gian còn lại.
- Pulse không trúng quái nào → KHÔNG freeze.

### R02 — Mechanism
- Freeze = `Engine.time_scale = 0.0`. Unfreeze = `Engine.time_scale = 1.0`.
- Timer countdown dùng real time (PROCESS_MODE_ALWAYS), không phụ thuộc time_scale.
- Không thay đổi `Engine.time_scale` thành giá trị khác 0 hoặc 1 (không slow-motion).

### R03 — Repeated events / caps
- Nhiều chain_updated cùng frame → lấy duration dài nhất, không cộng dồn.
- Cap tại `HITSTOP_MAX` (0.08s).
- chain_count < 2 → không trigger thêm (pulse hit đã xử lý rồi).

### R04 — Lifecycle
- Pause (ESC), Death, Restart, Menu → `hitstop.clear()` = restore `time_scale = 1.0`, clear pending.
- Không để time_scale stuck ≠ 1.0 ở bất kỳ state transition nào.

### R05 — Không được thay đổi
- Damage, force, velocity, cooldown, collision, chain logic, spawn logic.
- Camera shake behavior (chỉ cần tương thích, không sửa).
- Pause mechanism (`get_tree().paused`).
- Gameplay RNG.

## 5. Plan nhỏ nhất

### Touched files

| File | Thay đổi | Lý do |
|---|---|---|
| [NEW] `scripts/systems/hitstop_system.gd` | Freeze/unfreeze controller | Core feature |
| [MODIFY] `push_system.gd` | +signal `pulse_hit(count)` + 1 emit | Event source |
| [MODIFY] `main.tscn` | +HitstopSystem node | Scene wiring |
| [MODIFY] `main.gd` | +ref, +signal connects, +clear() calls | Lifecycle |

### Lát cắt
1. **F002.1:** `hitstop_system.gd` + `pulse_hit` signal + scene node. Test: gọi `freeze(0.04)` trực tiếp.
2. **F002.2:** Kết nối signals + lifecycle clear. Test: Pulse trúng quái → freeze. Pause/restart → time_scale = 1.

### Rủi ro
- `get_process_delta_time()` khi `time_scale=0` có thể trả về 0 → timer không countdown. Giải pháp: dùng OS real time hoặc chia delta cho time_scale.
- Rollback: `git revert` commit, tất cả thay đổi đều additive.

## 6. Acceptance

| ID | Observable behavior | Check | Expected result | Evidence | Status |
|---|---|---|---|---|---|
| AC01 | Scope | Diff review | Không đụng damage/force/cooldown/collision/chain/spawn | — | NOT_RUN |
| AC02 | Pulse hit → freeze | Runtime | Pulse trúng quái → game đứng ~40ms → tiếp | — | NOT_RUN |
| AC03 | Pulse miss → no freeze | Runtime | Space khi không có quái gần → không freeze | — | NOT_RUN |
| AC04 | Chain scaling | Runtime | Chain x3 → freeze lâu hơn x1. Cap ≤ 80ms | — | NOT_RUN |
| AC05 | No stacking | Runtime | 5 quái cùng chain = 1 freeze, không 5 freeze | — | NOT_RUN |
| AC06 | Pause during freeze | Runtime | ESC trong lúc freeze → time_scale = 1, pause hoạt động | — | NOT_RUN |
| AC07 | Restart/death | Runtime | Chết hoặc R → time_scale = 1.0 | — | NOT_RUN |
| AC08 | Camera shake compat | Runtime | Shake decay tiếp tục đúng trong/sau hit-stop | — | NOT_RUN |
| AC09 | time_scale restore | Runtime | Sau mọi transition, time_scale luôn = 1.0 | — | NOT_RUN |
| AC10 | Owner feel gate | Manual | Owner nhận biết freeze, không thấy giật | — | NOT_RUN |

## 7. Approval và completion

- Owner cho phép scope ngày: **chưa có — chờ duyệt**.
- Chưa kiểm tra: tất cả AC.
- Manual playtest cần owner: AC10.
- Findings chưa xử lý: delta behavior khi time_scale=0 (kiểm tra trong F002.1).
- Kết luận: DRAFT, chờ owner approval trước khi implement.
