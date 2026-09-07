# F003 — Combo Counter Popup

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-07)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Khi chain domino xảy ra (x2, x3, ...), text "x2!", "x3!" hiện lên giữa màn hình, bay lên và mờ dần. Người chơi nhận phản hồi trực quan về combo mà không cần nhìn HUD.

## 2. Scope / Non-goals

- **Có:** Label tạo động (Tween animation: scale up → drift up → fade out), kết nối chain_updated signal, cleanup khi restart/menu.
- **Không:** particle effects, sound, thay đổi chain logic/damage/scoring, persistent UI, Settings.
- **Prerequisite:** chain_updated signal hoạt động (VERIFIED).

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| chain_updated signal | `(chain_count: int)`, emit mỗi domino | [push_system.gd:7](file:///d:/HandMakeGame/ARealGame/scripts/systems/push_system.gd#L7) | VERIFIED_IN_REPO |
| chain_count bắt đầu từ | 1 (pulse hit) → 2+ (domino) | [push_system.gd:139,146](file:///d:/HandMakeGame/ARealGame/scripts/systems/push_system.gd#L139) | VERIFIED_IN_REPO |
| _end_chain | Reset count=0, không emit signal | [push_system.gd:151-154](file:///d:/HandMakeGame/ARealGame/scripts/systems/push_system.gd#L151) | VERIFIED_IN_REPO |
| HUD | CanvasLayer + Label, không bị camera shake | [hud.gd](file:///d:/HandMakeGame/ARealGame/scripts/ui/hud.gd) | VERIFIED_IN_REPO |
| VFX node | Exists tại $VFX (Node2D), trống | [main.tscn:26](file:///d:/HandMakeGame/ARealGame/scenes/main.tscn#L26) | VERIFIED_IN_REPO |
| Viewport | 480×270 logical px | [game_config.gd](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd) | VERIFIED_IN_REPO |
| Tween trong Godot 4 | `create_tween()` trên bất kỳ node, auto-cleanup | Godot 4.6 docs | VERIFIED_IN_REPO |
| COLOR_COMBO_TEXT | `Color(1,1,1)` white | [game_config.gd:116](file:///d:/HandMakeGame/ARealGame/scripts/core/game_config.gd#L116) | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Trigger
- chain_count ≥ 2 → hiển thị popup "x{count}!".
- chain_count = 1 (pulse hit) → không popup (không phải combo).
- Mỗi chain_updated với count ≥ 2 tạo popup mới (popup cũ tiếp tục animation, không bị kill).

### R02 — Animation
- Label xuất hiện tại vị trí va chạm cuối (hoặc trung tâm viewport nếu vị trí không khả thi).
- Scale: 0 → 1.5 nhanh (0.1s) → 1.0 (0.05s).
- Drift up: 20px trong 0.6s.
- Fade: alpha 1.0 → 0.0 trong 0.4s cuối.
- Tổng thời gian: ~0.6s.
- Tự queue_free sau animation.

### R03 — Caps / repeated
- Tối đa 5 popup cùng lúc (cũ nhất bị kill nếu vượt).
- chain_count lớn hơn → text lớn hơn (scale bonus nhỏ).

### R04 — Lifecycle
- Restart/menu → kill tất cả popup hiện có.
- Pause → popup đứng yên (Tween bị pause theo tree).
- Popup ở CanvasLayer (HUD) → không bị camera shake.

### R05 — Không thay đổi
- Chain logic, damage, scoring, HUD layout, camera, gameplay RNG.

## 5. Plan nhỏ nhất

| File | Thay đổi | Lý do |
|---|---|---|
| [NEW] `scripts/ui/combo_popup.gd` | Popup Label + Tween animation | Core feature |
| [MODIFY] `main.gd` | Kết nối chain_updated → spawn popup, cleanup | Wiring |

### Lát cắt
1. Tạo combo_popup.gd + wiring. Test: chain x2 → popup "x2!" bay lên fade.

### Rollback
- `git revert` commit.

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Scope | Diff | Không đụng chain/damage/scoring/camera | NOT_RUN |
| AC02 | x2+ popup | Runtime | Chain x2 → "x2!" hiện và animate | NOT_RUN |
| AC03 | x1 no popup | Runtime | Pulse hit (x1) → không popup | NOT_RUN |
| AC04 | Multiple popups | Runtime | Chain nhanh → nhiều popup cùng lúc, cap 5 | NOT_RUN |
| AC05 | Animation complete | Runtime | Scale up → drift → fade → biến mất | NOT_RUN |
| AC06 | Restart/menu clear | Runtime | R hoặc menu → popup biến mất | NOT_RUN |
| AC07 | Pause | Runtime | ESC → popup đứng yên | NOT_RUN |
| AC08 | Owner feel | Manual | Popup đọc được, không che tình huống | NOT_RUN |

## 7. Approval và completion

- Owner cho phép scope ngày: **chưa có — chờ duyệt**.
