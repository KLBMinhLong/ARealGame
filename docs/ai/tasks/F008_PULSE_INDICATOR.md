# F008 — Pulse Charge Indicator

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Khi pulse sẵn sàng (cooldown=0), vòng sáng cyan nhấp nháy nhẹ quanh player. Người chơi biết được lúc nào có thể nhấn Space mà không cần nhìn HUD cooldown.

## 2. Scope / Non-goals

- **Có:** Glow ring pulse quanh player khi `pulse_cooldown_left <= 0`, draw trong player.gd.
- **Không:** Sound, UI thay đổi, cooldown/damage thay đổi, file mới.
- **Prerequisite:** pulse_cooldown_left đã có.

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| pulse_cooldown_left | float, 0 = sẵn sàng | [player.gd:13](file:///d:/HandMakeGame/ARealGame/scripts/actors/player.gd#L13) | VERIFIED_IN_REPO |
| CD indicator hiện tại | Arc nhỏ ở dưới player (khi CD > 0) | [player.gd:145-150](file:///d:/HandMakeGame/ARealGame/scripts/actors/player.gd#L145) | VERIFIED_IN_REPO |
| _draw đã queue_redraw mỗi frame | Có | [player.gd:41](file:///d:/HandMakeGame/ARealGame/scripts/actors/player.gd#L41) | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Visual
- CD=0: vòng sáng cyan mờ (alpha pulse sin wave 0.15↔0.4) quanh player, radius = PLAYER_HALF + 3.
- CD>0: không hiện (CD arc đã xử lý).

### R02 — Không thay đổi
- Cooldown, damage, movement.

## 5. Plan nhỏ nhất

| File | Thay đổi |
|---|---|
| [MODIFY] `player.gd` | Thêm draw glow khi CD=0 |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | CD=0 → glow | Runtime | Vòng sáng nhấp nháy nhẹ | NOT_RUN |
| AC02 | CD>0 → no glow | Runtime | Không hiện glow | NOT_RUN |
| AC03 | Owner feel | Manual | Biết được pulse sẵn sàng | NOT_RUN |

## 7. Approval

- Chờ duyệt.
