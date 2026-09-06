# M0 CURRENT SPEC — Nguồn Sự Thật Duy Nhất Cho Greybox

**Tài liệu này có quyền ưu tiên CAO NHẤT.**
**Khi mâu thuẫn với 01-08, tài liệu này thắng.**
**Phiên bản:** 1.0 — Ngày: 07/09/2026

> Mục đích: AI đọc file này TRƯỚC, chỉ tham khảo 01-08 khi cần bối cảnh.
> Đang làm: **M0 Greybox** — kiểm chứng push feel.
> Chưa làm: M1-M3, art thật, audio thật, meta-progression, narrative.

---

## ENGINE & VIEWPORT — Chốt

| Param | Value | Ghi chú |
|---|---|---|
| Engine | Godot v4.6.3.stable.official [7d41c59c4] | KHÔNG upgrade giữa chừng |
| Language | GDScript | |
| Renderer | GL Compatibility | |
| Internal resolution | 480 × 270 px | Đây là hệ tọa độ duy nhất |
| Scale | 4× nearest-neighbor → 1920×1080 | |
| Stretch mode | canvas_items | |
| Stretch aspect | keep | |

## ARENA — Chốt

| Param | Value | Tính toán |
|---|---|---|
| Tile size | 30 × 30 px | |
| Grid | 16 × 9 tiles | 480÷30 = 16, 270÷30 = 9 |
| Border | 1 tile mỗi phía | Tường solid |
| Playable area | **420 × 210 px** (14 × 7 tiles) | (16−2)×30 = 420, (9−2)×30 = 210 |
| Origin | Top-left của playable = (30, 30) | |

> ⚠️ **Sửa lỗi A:** Trước đó ghi 420×240 — sai. Đúng là **420×210**.
> Mọi tọa độ, tốc độ, bán kính trong file này dùng hệ 480×270.

## PLAYER — Chốt

| Param | Value | Ghi chú |
|---|---|---|
| Size | 12 × 12 px | Placeholder: cyan square |
| Start position | (240, 135) | Giữa playable area |
| Speed | **120 px/s** | ~57% chiều ngang sân/giây. Đủ nhanh để dodge, không quá nhanh |
| Diagonal | Normalized (×0.707) | |
| Boundary | Clamp within (30, 30) → (450, 240) | Trừ player size |
| HP | 3 | |
| Grace period | 1.2s sau khi nhận damage | Flash effect |
| Contact damage | 1 HP per hit | Từ enemy contact |

## ARCANE PULSE — Chốt

| Param | Value | Ghi chú |
|---|---|---|
| Input | Space | |
| Cooldown | 3.5 s | |
| Radius | **50 px** | ~24% chiều ngang sân. Vừa phải, cần positioning |
| Push type | **Impulse velocity** | KHÔNG phải "force = distance" |
| Initial velocity | **400 px/s** | Tốc độ quái bị bắn ra ngay khi pulse |
| Deceleration | **800 px/s²** | Ma sát/giảm tốc tuyến tính |
| Travel distance (lý thuyết) | **~100 px** | v²/(2×a) = 400²/(2×800) = 100px |
| Travel time | **~0.5s** | v/a = 400/800 |
| Direction | Radial outward (player → enemy) | |
| Distance scaling | Gần hơn = 100% velocity. Tại rìa radius = 50% velocity | Linear decay |

> ⚠️ **Sửa lỗi A:** Trước đó ghi "Force = 200 px distance" — không đủ rõ.
> Giờ định nghĩa bằng **velocity + deceleration**, có thể triển khai vật lý trực tiếp.

### Pulse Visual (Placeholder)

- Frame 0: Player flash trắng
- Frame 1-3: `draw_arc` expanding circle, trắng, alpha fade 1.0 → 0.0
- Radius animation: 0 → pulse_radius (50px) trong 0.15s

## COLLISION & DAMAGE — Chốt (Sửa lỗi B)

### Trạng thái "Pushed"

> ⚠️ **Sửa lỗi B:** Va chạm chỉ gây damage khi entity đang trong trạng thái PUSHED.

```
Enemy states liên quan va chạm:
- NORMAL: di chuyển bình thường. Va chạm với enemy khác = KHÔNG damage. 
  Chỉ separation force nhẹ (tránh chồng nhau).
- PUSHED: vừa bị Pulse hoặc bị entity PUSHED khác đập vào.
  Bật khi: nhận impulse velocity > 0.
  Tắt khi: velocity giảm về < 30 px/s HOẶC sau 0.8s (safety timeout).
  Trong trạng thái này:
    - Va chạm tường → Wall Damage
    - Va chạm enemy khác → Domino Damage (CHO CẢ HAI)
    - Va chạm Altar → Altar Seal
    - Va chạm Pit → Pit Fall
```

### Damage Table

| Nguồn | Điều kiện | Damage | Target |
|---|---|---|---|
| Wall Slam | Enemy PUSHED + chạm tường | 1 HP | Enemy |
| Spike Wall Slam | Enemy PUSHED + chạm spike wall | 2 HP | Enemy (v1.1+ khi unlock) |
| Domino | Enemy PUSHED + chạm enemy khác | 1 HP | **Cả hai** |
| Altar Seal | Enemy PUSHED + chạm Altar zone | ∞ (instant kill) | Enemy |
| Pit Fall | Enemy PUSHED + chạm Pit zone | ∞ (instant kill) | Enemy, **không drop shard** |
| Enemy → Player | Enemy NORMAL + chạm Player | 1 HP | Player |

### Chain Propagation (Sửa lỗi B — Phần 2)

```
Khi enemy A (PUSHED) va chạm enemy B (NORMAL hoặc PUSHED):
1. Cả A và B nhận 1 damage
2. B nhận 60% velocity của A, theo hướng A→B
3. B chuyển sang trạng thái PUSHED
4. NẾU A chết (HP ≤ 0):
   → A chuyển sang DYING (0.15s)
   → Trong DYING: A VẪN CÓ collision body, VẪN truyền lực nếu va chạm tiếp
   → Sau 0.15s: A bị xóa khỏi scene
   → Hiệu ứng chết: flash + fade
5. NẾU B chết: tương tự — DYING 0.15s, vẫn có collision
6. Chain depth counter: +1 mỗi lần domino xảy ra
7. Max chain depth: 8 (safety limit, tránh infinite loop)
8. Chain window: mỗi va chạm reset timer 0.6s. Hết timer = chain kết thúc.
```

> **Tại sao 0.15s DYING thay vì xóa ngay?**
> Nếu xóa ngay khi chết, chain A→B→C sẽ dừng tại B (B chết = biến mất = C không bị va).
> 0.15s DYING = "xác bay tiếp" đủ lâu để va vào C, giữ chain sống.

## ENEMIES — M0 Chỉ Có 1 Loại

> ⚠️ **Sửa lỗi D:** M0 chỉ test push feel. CHỈ CẦN SLIME.
> Skeleton và Wraith thêm ở M1, KHÔNG PHẢI M0.

### Slime (Cursed Ooze) — Loại duy nhất trong M0

| Param | Value |
|---|---|
| HP | 1 |
| Speed | 30 px/s | 
| Behavior | Đi thẳng về player, không flocking |
| Size | 10 × 10 px (placeholder: green circle) |
| Push weight | 1.0 (standard — nhận đầy đủ push velocity) |
| Shard drop | 1 |
| PUSHED velocity threshold | > 30 px/s mới gây collision damage |

> Tốc độ 30 px/s (không phải 60) vì sân nhỏ hơn (420×210). 
> 30 px/s = quái đi hết chiều ngang trong ~14s — đủ thời gian cho player react.

## ARENA ELEMENTS — M0

| Element | Có trong M0? | Ghi chú |
|---|---|---|
| Wall (tường solid) | ✅ | Border 1-tile, luôn có |
| Altar (1 cái) | ✅ | Vị trí cố định, 1 altar |
| Spike Wall | ❌ | M1+ |
| Pit | ❌ | M1+ |
| Rune Pillar | ❌ | M1+ |

### Altar Spec (M0)

| Param | Value |
|---|---|
| Size | 24 × 24 px zone |
| Position | Cố định, trên-giữa playable area: (210, 60) |
| Behavior | Enemy PUSHED vào zone → instant kill |
| Visual | Placeholder: tím (#a78bfa) circle, flash khi seal |
| Shard bonus | +2 (thay vì drop 1 bình thường) |

## SPAWN — M0

| Param | Value |
|---|---|
| Spawn location | Random trên 4 rìa playable, cách player ≥ 80px |
| Spawn interval | 1 con / 2.0s |
| Max concurrent | 15 |
| Spawn trigger | Liên tục (không có wave system trong M0) |

> M0 KHÔNG CÓ wave system. Quái spawn liên tục. Mục tiêu: test push feel, không phải progression.

## SHARD — M0

| Param | Value |
|---|---|
| Drop | Tại vị trí enemy chết |
| Size | 4 × 4 px, vàng (#facc15) |
| Magnet radius | 40 px |
| Move to player | Lerp, 200 px/s khi trong range |
| Lifetime | 8s (biến mất nếu không nhặt) |
| Counter | Hiển thị text trên HUD, chỉ đếm — chưa có threshold/upgrade |

> M0 KHÔNG CÓ upgrade system. Shard chỉ để test: "có thấy reward cycle không?"

## GAME FEEL — M0 (Quan trọng!)

| Effect | Spec | Khi nào |
|---|---|---|
| Screen shake | Trauma-based: push = 0.2, wall slam = 0.15, chain x3+ = 0.3, chain x5+ = 0.5 | On impact |
| Hit-stop | 40ms pause all physics | On Pulse activation |
| Chain hit-stop | +10ms per chain level (cap 80ms tổng) | On each chain collision |
| Pulse visual | Expanding ring 0→50px, 0.15s, alpha 1→0 | On Pulse |
| Wall dust | 3-5 particles, white, random direction, 0.3s lifetime | On wall slam |
| Altar flash | Zone flash bright purple 0.2s | On altar seal |
| Combo counter | Pop-up text "x2", "x3"... tween: scale 0→1.5→1, fade out 0.8s | On chain x2+ |
| Shard collect | Tiny yellow flash at player | On shard pickup |

## STATE MACHINE — M0

```
MENU → (Space) → RUNNING → (HP=0) → DEAD → (R) → RUNNING
                     ↕ (Esc)                        ↑
                   PAUSED ────────────────────────────┘ (R)
```

- MENU: "Stone Knight — Press SPACE" (text only)
- RUNNING: Gameplay active
- PAUSED: ESC toggle, freeze tất cả
- DEAD: "You died — Press R to restart" + hiện shard count, best chain
- KHÔNG CÓ: WON state trong M0 (infinite mode)

## HUD — M0 (Tối giản)

```
HP: ♥♥♥          CD: 2.1s
                  
[       GAME       ]
                  
Shards: 24    Chain: x5 (best: x8)
```

## CÁI GÌ KHÔNG CÓ TRONG M0

| Feature | Lý do không có |
|---|---|
| Wave system | Chưa cần, test push trước |
| Boss | M1 |
| Skeleton, Wraith | M1 |
| Upgrade pick (in-run) | M1 |
| Meta-progression (Rune Forge) | M2 |
| The Hollow (Hub) | M2 |
| NPC, narrative, memory | M2+ |
| Spike wall, Pit, Pillar | M1 |
| Save/Load | M2 |
| Settings | M2 |
| Art thật (sprites) | M2 |
| Music | M2 |
| SFX thật | M0 có sfxr placeholder |
| Memory Wall | V1.1+ (CẮT khỏi V1.0) |
| Skins | V1.3+ (CẮT khỏi V1.0) |

## M0 GATE — Pass/Fail

```
Sau 10 ngày, chơi 10 run liên tiếp. Trả lời:

1. Push có thỏa mãn?                         [ ]
2. Chain x3+ có tạo "WOW"?                   [ ]
3. Wall slam có feedback rõ?                  [ ]
4. Altar seal có thưởng rõ?                   [ ]
5. Tự muốn chơi thêm (không ép)?             [ ]

≥ 3 YES → Tiến M1. < 3 → Chỉnh push, KHÔNG thêm feature.
```

---

*File này là nguồn sự thật duy nhất cho M0. Mọi mâu thuẫn với 01-08: file này thắng.*
