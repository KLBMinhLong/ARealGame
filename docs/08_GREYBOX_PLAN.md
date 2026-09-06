# BƯỚC 8: PAPER PROTOTYPE / GREYBOX PLAN — Stone Knight

**Trạng thái:** ĐÃ CHỐT
**Mục tiêu:** Kế hoạch chi tiết cho 2 tuần đầu — kiểm chứng "Push có vui không?" trước khi đầu tư thêm

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
- [ ] Entity collision:
  - [ ] Enemy hit enemy → transfer 60% force + both take 1 damage
  - [ ] Domino chain: cascading collisions
- [ ] Altar seal:
  - [ ] Enemy enter altar zone → instant kill + flash VFX + bonus shards
- [ ] Enemy death:
  - [ ] Spawn 1-2 shard objects at death position

**Verify:** Push quái vào tường = chết. Push quái vào quái = cả 2 nhận damage. Push vào altar = instant seal.

**Ngày 4: Chain Reaction + Game Feel**

**Tasks:**
- [ ] `chain_system.gd`:
  - [ ] Track chain count khi collisions cascade
  - [ ] Chain window: 0.5s
  - [ ] Max depth: 5
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
  - [ ] States: MENU → RUNNING → PAUSED → WON → LOST
  - [ ] Transitions, input handling per state
- [ ] Basic Main Menu:
  - [ ] "Press SPACE to Start" text
- [ ] Basic Pause:
  - [ ] ESC toggle, game freezes
- [ ] Basic Results:
  - [ ] "You survived X seconds" / "You died"
  - [ ] "Press R to restart"
- [ ] Timer:
  - [ ] 120s test timer (shortened for testing)
  - [ ] Display on HUD

**Verify:** Full game loop: Menu → Play → Die/Win → Results → Restart.

---

### Ngày 8-9: Multiple Enemies + Arena Tuning

**Ngày 8: Skeleton + Wraith**

**Tasks:**
- [ ] `enemy_base.gd`:
  - [ ] Base class: HP, speed, push_weight, shard_drop
  - [ ] Common: take_damage(), die(), be_pushed()
- [ ] `skeleton.gd` extends enemy_base:
  - [ ] Flocking behavior (separation + cohesion toward player)
  - [ ] Speed: 80 px/s
  - [ ] Diamond shape (draw)
- [ ] `wraith.gd` extends enemy_base:
  - [ ] Fast (120 px/s), zig-zag movement
  - [ ] Passes through pillar (not walls)
  - [ ] Triangle shape (draw)

**Verify:** 3 enemy types with distinct behavior. Push feels different per type (slime flies far, golem barely moves, wraith slides fast).

**Ngày 9: Arena Elements + Layout**

**Tasks:**
- [ ] Spike wall:
  - [ ] Like wall but deals 2x damage on slam
  - [ ] Visual: wall + red stripe
- [ ] Rune Pillar:
  - [ ] Blocks enemy movement (not wraith)
  - [ ] Player can pass through
  - [ ] Visual: small yellow square
- [ ] Test arena layout (Wave 3 style):
  - [ ] Place altar, pit, pillars, spike walls
  - [ ] Play 5-10 runs, adjust positioning

**Verify:** All arena elements work with push physics. Interesting positioning choices emerge.

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
