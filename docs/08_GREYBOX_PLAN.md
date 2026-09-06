# BƯỚC 8: PAPER PROTOTYPE / GREYBOX PLAN — Stone Knight

**Trạng thái:** ĐÃ CHỐT
**Mục tiêu:** Kế hoạch chi tiết cho 2 tuần đầu — kiểm chứng "Push có vui không?" trước khi đầu tư thêm

> ⚠️ **Quyền ưu tiên:** Khi mâu thuẫn với tài liệu 01-08, file [`M0_CURRENT_SPEC.md`](file:///d:/HandMakeGame/ARealGame/docs/M0_CURRENT_SPEC.md) thắng.
> AI phải đọc M0_CURRENT_SPEC.md TRƯỚC khi code bất kỳ thứ gì.

---

## 1. Mục Đích Greybox

> **"Kiểm chứng CƠ CHẾ trước khi đầu tư HÌNH ẢNH."**

Greybox = game chơi được với:
- Hình khối đơn giản (vuông, tròn, chữ nhật)
- Không có sprite, animation đẹp
- Không có nhạc nền hoàn chỉnh
- CÓ game feel (screen shake, hitstop, particles đơn giản)
- CÓ push physics đầy đủ

**Nếu greybox KHÔNG vui → cần thay đổi cơ chế, không phải thêm art.**

---

## 2. Greybox Visual Spec

### Player — Stone Knight (Placeholder)

```
    ┌──┐
    │  │  16×16 px
    │🟦│  Màu: Cyan (#00e5ff)
    │  │  Khi pulse: flash trắng 2 frame
    └──┘  Khi hit: flash đỏ 3 frame
```

### Enemies (Placeholder)

```
Slime:     ⬤ 12px tròn, #2d5a27 (xanh lá tối)
Skeleton:  ◇ 14px diamond, #d4d4d8 (trắng xám)
Wraith:    △ 12px tam giác, #7c3aed (tím)
Boss:      ■ 24px vuông, #dc2626 (đỏ)
```

### Arena Elements (Placeholder)

```
Wall:       ████ Xám đậm (#252e3b), solid rectangle
Spike Wall: ╬╬╬╬ Xám + vạch đỏ (#ef4444)
Altar:      ◎    Vòng tròn tím (#a78bfa), filled khi quái vào
Pit:        ▒▒▒▒ Pattern chấm đen, (#0a0e14)
Pillar:     ¤    Hình vuông nhỏ vàng (#facc15)
```

### VFX (Placeholder — Quan trọng cho game feel!)

```
Pulse:      Vòng tròn trắng expanding (draw_arc), fade out
Wall slam:  3-5 particles nhỏ trắng bay ra từ điểm va
Altar seal: Flash tím sáng 0.2s tại vị trí altar
Chain spark: Đường nối trắng giữa 2 entity va chạm, 0.1s
Shard:      Chấm vàng 4px, lerp về player khi trong magnet range
Combo text: "x3!" popup trắng, tween scale up + fade out
```

---

## 3. Kế Hoạch Chi Tiết 10 Ngày

### Ngày 1: Project Setup + Player Movement

**Mục tiêu:** Di chuyển mượt mà trong arena

**Tasks:**
- [ ] Tạo Godot project mới (giữ project.godot cũ tham khảo)
- [ ] Setup folder structure theo 05_SCOPE.md
- [ ] Tạo `game_config.gd` — tất cả constants
- [ ] Tạo `main.tscn` + `main.gd` — state machine skeleton
- [ ] Tạo `player.tscn` + `player.gd`:
  - [ ] WASD/Arrow input, 8-hướng, normalized diagonal
  - [ ] Boundary clamp (arena rectangle)
  - [ ] `_draw()` placeholder (cyan square)
- [ ] Tạo `arena.tscn` + `arena.gd`:
  - [ ] Draw background + border walls

**Verify:** WASD di chuyển, không ra ngoài arena, responsive (0 input lag)

---

### Ngày 2-4: PUSH MECHANIC (3 ngày — Quan trọng nhất!)

**Ngày 2: Basic Push**

**Tasks:**
- [ ] `push_system.gd`:
  - [ ] On Space: find all enemies in radius
  - [ ] Calculate push direction (player → enemy, radial)
  - [ ] Apply force (velocity) to each enemy
  - [ ] Cooldown timer (3.5s)
- [ ] Placeholder pulse visual:
  - [ ] Expanding circle (draw_arc) — fade alpha
- [ ] Cooldown indicator:
  - [ ] Simple text "CD: 2.1s" on screen

**Verify:** Space = quái bay ra. Cooldown hoạt động.

**Ngày 3: Collision & Damage**

**Tasks:**
- [ ] Wall collision:
  - [ ] Enemy hit wall → stop + take 1 damage + dust particles
  - [ ] Enemy die (HP ≤ 0) → remove + drop shard
- [ ] Entity collision (CHỈ khi enemy ở state PUSHED, velocity > 30 px/s):
  - [ ] Enemy PUSHED + hit enemy → transfer 60% velocity + both take 1 damage
  - [ ] Enemy bị va → chuyển sang PUSHED (propagation)
  - [ ] Enemy chết (HP≤0) → DYING 0.15s (vẫn có collision body, xác bay tiếp) → xóa
  - [ ] Domino chain: cascading collisions qua DYING state
- [ ] Altar seal:
  - [ ] Enemy PUSHED vào altar zone → instant kill + flash VFX + bonus shards (+2)
- [ ] Enemy death:
  - [ ] Spawn 1 shard object at death position

**Verify:** Push quái vào tường = chết. Push quái vào quái (CHỈ khi bị push) = cả 2 nhận damage, chain tiếp qua xác. Quái đi bầy KHÔNG tự giết nhau. Altar seal rõ ràng.

**Ngày 4: Chain Reaction + Game Feel**

**Tasks:**
- [ ] `chain_system.gd`:
  - [ ] Track chain count khi collisions cascade
  - [ ] Chain window: 0.6s
  - [ ] Max depth: 8
  - [ ] Chain counter display (popup text "x3!", "x5!")
- [ ] Game feel basics:
  - [ ] Screen shake on push (intensity 0.3)
  - [ ] Screen shake scales with chain length
  - [ ] Hit-stop 50ms on push activation
  - [ ] Hit-stop tăng nhẹ per chain level
- [ ] Tuning pass:
  - [ ] Adjust push force, radius, cooldown
  - [ ] Adjust chain window timing
  - [ ] Test: "Does this FEEL good?"

**Verify:** Chain x3+ feels like "WOW!". Screen shake proportional. Hit-stop adds weight.

---

### Ngày 5: Spawn + Basic Enemy AI

**Tasks:**
- [ ] `wave_manager.gd` (basic):
  - [ ] Spawn enemies at arena edges
  - [ ] Spawn rate: 1/2s
  - [ ] Max enemies: 15
  - [ ] Continuous spawn (no wave system yet)
- [ ] Slime AI:
  - [ ] Move toward player position
  - [ ] Speed: 60 px/s
  - [ ] On contact player → player takes 1 damage
- [ ] Player HP:
  - [ ] 3 HP base
  - [ ] Grace period 1.2s after hit (flashing)
  - [ ] HP = 0 → death state

**Verify:** Quái spawn, đuổi, damage player. Player có thể chết. Push cycle hoàn chỉnh: dodge → position → push → chain → collect.

---

### Ngày 6: Shard System + Altar + Pit

**Tasks:**
- [ ] `loot_system.gd`:
  - [ ] Shard object: yellow dot, float in place
  - [ ] Magnet: khi player trong range → lerp về player
  - [ ] Collection: add to counter
  - [ ] Progress bar placeholder (text "12/15 shards")
- [ ] Altar behavior:
  - [ ] Static zone trên arena
  - [ ] Enemy enter zone = instant kill + bonus shard (3x)
  - [ ] Altar flash VFX
- [ ] Pit behavior:
  - [ ] Enemy enter pit = instant kill, NO shard drop
  - [ ] Player near pit edge = visual warning

**Verify:** Full micro loop hoạt động: push → kill (wall/altar/domino) → shards drop → collect → progress bar fills.

---

### Ngày 7: Game Loop + State Machine

**Tasks:**
- [ ] Complete state machine in `main.gd`:
  - [ ] States: MENU → RUNNING → PAUSED → DEAD
  - [ ] Transitions, input handling per state
  - [ ] KHÔNG CÓ WON state trong M0 (infinite spawn mode)
- [ ] Basic Main Menu:
  - [ ] "Stone Knight — Press SPACE" text
- [ ] Basic Pause:
  - [ ] ESC toggle, game freezes
- [ ] Basic Results (DEAD):
  - [ ] "You died" + hiện shard count + best chain
  - [ ] "Press R to restart"

**Verify:** Full game loop: Menu → Play → Die → Results → Restart. Không có win state.

---

### Ngày 8-9: Push Tuning + Altar & Shard Polish

> ⚠️ **Sửa lỗi D:** M0 CHỈ CÓ SLIME. Skeleton/Wraith/Spike/Pit/Pillar là M1.
> 2 ngày này dành cho TINH CHỈNH push feel — phần quan trọng nhất.

**Ngày 8: Push Feel Deep Tuning**

**Tasks:**
- [ ] `enemy_base.gd` (chuẩn bị cho M1 — chỉ Slime kế thừa):
  - [ ] Base class: HP, speed, push_weight, shard_drop
  - [ ] Common: take_damage(), die(), be_pushed()
  - [ ] PUSHED state machine: NORMAL → PUSHED → DYING
- [ ] Tuning session (chỉnh `game_config.gd`):
  - [ ] Push velocity: 400 px/s có đủ thỏa mãn? Thử 300, 400, 500
  - [ ] Push radius: 50 px đủ? Thử 40, 50, 60
  - [ ] Deceleration: 800 px/s² đúng feel? Thử 600, 800, 1000
  - [ ] Cooldown: 3.5s có quá lâu? Thử 2.5, 3.0, 3.5, 4.0
  - [ ] Chain window: 0.6s? Thử 0.4, 0.6, 0.8
  - [ ] DYING duration: 0.15s? Thử 0.1, 0.15, 0.2
- [ ] Ghi lại combo/setting nào FUN NHẤT

**Verify:** Tìm được sweet spot cho MỌI tham số push. Ghi vào game_config.

**Ngày 9: Altar & Shard Polish + Second Altar Position**

**Tasks:**
- [ ] Altar polish:
  - [ ] VFX rõ hơn khi seal (particle burst + flash)
  - [ ] Thử vị trí altar khác nhau (giữa, góc, rìa)
  - [ ] Chọn vị trí tạo positioning play hay nhất
- [ ] Shard feel:
  - [ ] Magnet lerp speed đúng? Không quá nhanh, không quá chậm
  - [ ] Pickup SFX placeholder (sfxr chime)
  - [ ] Shard lifetime 8s có đủ?
- [ ] Thử 2 layout altar:
  - [ ] Layout A: 1 altar giữa
  - [ ] Layout B: 1 altar góc trên-phải
  - [ ] Chọn layout nào tạo gameplay thú vị hơn

**Verify:** Altar seal thỏa mãn. Shard collection smooth. Layout tạo positioning choices.

---

### Ngày 10: Polish + Greybox Playtest

**Tasks:**
- [ ] Audio placeholder:
  - [ ] sfxr/jsfxr: push WHOOOM, wall thud, chain ting, shard pickup chime
  - [ ] 4-5 basic SFX
- [ ] Visual polish:
  - [ ] Combo counter popup (tween animation)
  - [ ] Pulse cooldown ring (draw_arc filling up)
  - [ ] Enemy death: brief flash + fade
- [ ] Playtest session:
  - [ ] Play 10 consecutive runs
  - [ ] Record: fun moments, frustration points, bugs
  - [ ] Fill out M0 Gate questionnaire

**Verify:** M0 Gate pass. If yes → proceed to M1 Alpha.

---

## 4. M0 Gate Assessment Template

```
Date: ___________
Runs played: ___________

1. Push có thỏa mãn?                    [ YES / NO / PARTLY ]
   Notes: _____________________________________________

2. Chain có WOW?                         [ YES / NO / PARTLY ]
   Best chain achieved: x___
   Notes: _____________________________________________

3. Wall slam có đã?                      [ YES / NO / PARTLY ]
   Notes: _____________________________________________

4. Altar seal có rõ?                     [ YES / NO / PARTLY ]
   Notes: _____________________________________________

5. Muốn chơi lại?                       [ YES / NO / PARTLY ]
   Số run tự muốn chơi (không ép): ___
   Notes: _____________________________________________

RESULT: ___/5 YES
  ≥ 3/5 YES → Proceed to M1 Alpha
  < 3/5 YES → Adjust push feel, replay. Do NOT proceed.

Changes needed before M1:
1. _____________________________________________
2. _____________________________________________
3. _____________________________________________
```

---

## 5. Checklist Trước Khi Bắt Đầu Code

- [ ] Đọc lại `01_CONCEPT_PITCH.md` — nhớ rõ vision
- [ ] Đọc lại `04_GDD.md` Phần II (Gameplay) — push physics rules
- [ ] Đọc lại `05_SCOPE.md` — biết feature nào CÓ, feature nào CẮT
- [ ] Setup Godot project mới (hoặc clean project cũ)
- [ ] Setup Git repo + .gitignore
- [ ] Tải Aseprite/LibreSprite (chuẩn bị cho M2)
- [ ] Tải sfxr/jsfxr (chuẩn bị cho SFX)
- [ ] Bookmark tài liệu Godot 4.x
- [ ] Tâm thế: **2 tuần tới CHỈ LÀM PUSH FEEL. Không thêm feature.**

---

*Pre-production hoàn tất. 8/8 bước đã xong. Sẵn sàng bắt tay vào code tháng tới.*
