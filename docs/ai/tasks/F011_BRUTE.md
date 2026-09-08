# F011 — Enemy Type: Brute

**Status:** DONE
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** HUMAN_PLAYTEST_PASSED (2026-09-08)

## 1. Kết quả người chơi nhận được

Thêm loại quái thứ 3: "Brute" — to, chậm, 2 HP, nặng (khó bị đẩy xa).
Tạo thử thách chiến thuật mới: không thể 1-hit kill bằng 1 lần đập tường đơn giản (trừ khi đẩy vào Altar hoặc combo đập tường + domino). Khi bị thương (còn 1 HP), Brute có biểu hiện nứt/đổi màu rõ rệt. Khi chết rơi 2 Shards.

## 2. Scope / Non-goals

- **Có:**
  - Script `brute.gd` (kế thừa `EnemyBase`)
  - Scene `scenes/enemies/brute.tscn`
  - Constants trong `game_config.gd` (HP=2, speed=20, size=14, push_weight=1.8, shard_drop=2, colors)
  - Visual riêng: hình vuông đỏ (Square), khi còn 1 HP có vết nứt (crack line), chết nổ particles đỏ
  - Tỉ lệ spawn: bổ sung vào pool spawn cùng Slime và Speeder (Slime 50%→20%, Speeder 35%→50%, Brute 15%→30% theo thời gian)
  - Fix edge-case trong `EnemyBase`: kiểm tra hướng vận tốc khi va tường để quái 2 HP không bị trừ máu nhiều frame liên tiếp trong 1 lần va
- **Không:**
  - AI đặc biệt (vẫn di chuyển hướng về player)
  - Boss / Mini-boss
  - Kỹ năng tấn công tầm xa hay nhảy đập

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| `EnemyBase` hỗ trợ `max_hp`, `push_weight`, `shard_drop` | Có sẵn, subclass override được | `scripts/actors/enemies/enemy_base.gd:13-18` | VERIFIED_IN_REPO |
| `main._on_enemy_died` hỗ trợ nhiều shards | `for i in shard_amount: _spawn_shard(...)` | `scripts/main.gd:253-254` | VERIFIED_IN_REPO |
| `_check_wall_collision` va chạm theo frame | Dùng `<=` không check hướng vận tốc, có thể trừ máu liên tục nếu quái trượt dọc tường | `scripts/actors/enemies/enemy_base.gd:155-172` | VERIFIED_IN_REPO |
| Spawning hiện tại | Slime + Speeder với tỉ lệ scaling qua `run_time` | `scripts/main.gd:207-220` | VERIFIED_IN_REPO |
| Visual quái hiện có | Slime: hình tròn xanh (10px); Speeder: hình tam giác cam (7px) | `slime.gd`, `speeder.gd` | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Stats của Brute
- `max_hp`: 2
- `speed`: 20.0 px/s (chậm hơn Slime 30, Speeder 60)
- `enemy_size`: 14 px (to hơn Slime 10, Speeder 7)
- `push_weight`: 1.8 (nặng hơn, chỉ bay ~55% khoảng cách so với Slime)
- `shard_drop`: 2 (rơi 2 shards khi chết)

### R02 — Visual & States
- Hình vuông (Square) màu đỏ thẫm `COLOR_BRUTE`.
- Khi đầy máu (2 HP): khối vuông đặc vững chắc.
- Khi bị thương (1 HP): đổi sắc độ `COLOR_BRUTE_DAMAGED` kèm đường nứt (crack line).
- Khi PUSHED: sáng màu hơn.
- Khi DYING: flash trắng → đỏ → tan biến (giống Slime/Speeder).
- Death particles: burst màu đỏ.

### R03 — Cơ chế nhận sát thương & va tường
- Altar seal: sát thương 999 → tiêu diệt ngay lập tức.
- Wall slam: sát thương 1 → còn 1 HP, dừng lực đẩy của lần va đó. Thêm điều kiện vận tốc hướng vào tường (`velocity.x < 0` cho tường trái,...) để tránh trừ máu 2 lần trong 1 lần va.
- Domino: sát thương 1 (nếu bị va hoặc va quái khác) → còn 1 HP.

### R04 — Tỉ lệ Spawn (tích hợp Scaling F010)
- Bắt đầu run (t = 0s): Slime 50%, Speeder 35%, Brute 15%.
- Ramp tối đa (t >= 180s): Slime 20%, Speeder 50%, Brute 30%.

## 5. Plan nhỏ nhất

| File | Thay đổi |
|---|---|
| [NEW] `scripts/actors/enemies/brute.gd` | Script cho Brute (draw hình vuông đỏ, crack khi 1 HP) |
| [NEW] `scenes/enemies/brute.tscn` | Scene cho Brute |
| [MODIFY] `scripts/core/game_config.gd` | Thêm hằng số `BRUTE_*`, `COLOR_BRUTE*`, chỉnh tỉ lệ spawn |
| [MODIFY] `scripts/actors/enemies/enemy_base.gd` | Bổ sung check hướng vận tốc khi va tường để tránh multi-damage |
| [MODIFY] `scripts/main.gd` | Cập nhật `_spawn_enemy()` hỗ trợ 3 loại quái |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Brute xuất hiện | Runtime | Quái hình vuông to màu đỏ xuất hiện | PASS |
| AC02 | Chuyển động chậm & nặng | Runtime | Đi chậm hơn Slime, khi bị Pulse đẩy bay ngắn hơn | PASS |
| AC03 | Cần 2 đòn để chết | Runtime | Đập tường lần 1 không chết ngay; đập tường lần 2 hoặc domino mới chết | PASS |
| AC04 | Phản hồi thị giác khi mất máu | Runtime | Còn 1 HP thấy vết nứt/đổi màu rõ rệt | PASS |
| AC05 | Rơi 2 Shards | Runtime | Khi chết nhả ra 2 cục Shard vàng | PASS |
| AC06 | Altar seal 1-hit | Runtime | Đẩy Brute vào Altar trung tâm tiêu diệt ngay lập tức | PASS |
| AC07 | Không phá vỡ Slime/Speeder | Runtime | Slime và Speeder vẫn hoạt động đúng như cũ | PASS |

## 7. Approval

- Đã duyệt và playtest đạt bởi chủ dự án (2026-09-08).
