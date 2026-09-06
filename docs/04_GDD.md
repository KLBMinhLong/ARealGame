# STONE KNIGHT — Game Design Document (GDD) v1.0

**Tên game:** Stone Knight
**Phụ đề (dự kiến):** Stone Knight: The Cursed Dungeon
**Thể loại:** Fantasy Arena Action Roguelite
**Platform:** PC (Steam) — tiềm năng mobile
**Engine:** Godot 4.x / GDScript
**Ngày tạo:** 06/09/2026
**Trạng thái:** Pre-production Draft

> *"Bạn từng là hiệp sĩ. Giờ bạn là khối đá. Push. Shatter. Remember."*

---

# PHẦN I — TỔNG QUAN

## 1. Vision Statement

Stone Knight là game **Fantasy Arena Action Roguelite** với cơ chế chiến đấu duy nhất: **ĐẨY**. Người chơi điều khiển một hiệp sĩ bị nguyền hóa đá, dùng lực đẩy cổ đại (Arcane Pulse) để hất quái vật vào bàn thờ phong ấn, tường gai, và vào nhau — tạo combo nổ dây chuyền. Mỗi run 5-10 phút. Mỗi run mạnh hơn. Mỗi run hé lộ thêm ký ức.

## 2. Pillars (Trụ Cột Thiết Kế)

| # | Pillar | Nghĩa | Ví dụ cụ thể |
|---|---|---|---|
| 1 | **Push is King** | Mọi hệ thống xoay quanh Push | Combat, upgrade, arena design |
| 2 | **Chain Satisfaction** | Combo chain = cảm giác thỏa mãn cốt lõi | Physics, VFX, SFX cascade |
| 3 | **Short & Sweet** | Mỗi run 5-10 phút, không filler | 5 waves, tight pacing |
| 4 | **Always Growing** | Luôn có thứ mới để mở khóa/khám phá | Meta-upgrades, story, skins |
| 5 | **Story Through Play** | Narrative không interrupt, tích hợp gameplay | Altar memories, NPC hub |

**Quy tắc kiểm tra feature mới:** *"Feature này phục vụ pillar nào? Nếu không phục vụ pillar nào → CẮT."*

## 3. Target Audience

| Mục | Chi tiết |
|---|---|
| Primary | Casual-mid PC gamer, 18-30 tuổi, thích roguelite ngắn |
| Session | 5-10 phút/run, 2-5 run/ngày (15-30 phút/session) |
| Comparable | Vampire Survivors, Brotato, Hades |
| Price point | $5-8 USD (Steam Early Access → Full Release) |

---

# PHẦN II — GAMEPLAY

## 4. Controls & Input

### 4.1. PC Controls

| Input | Action | Ghi chú |
|---|---|---|
| WASD / Arrow Keys | Di chuyển 8 hướng | Normalized diagonal |
| Space | Arcane Pulse (đẩy) | Cooldown 3-4s |
| ESC | Pause | Toggle |
| R | Quick Restart | Chỉ ở màn kết quả |
| 1, 2, 3 | Chọn upgrade | Khi upgrade panel mở |
| Mouse (tùy chọn) | Click upgrade card | Thay thế cho phím số |

### 4.2. Movement Specs

| Param | Value | Ghi chú |
|---|---|---|
| Base Speed | 240 px/s | Upgradeable +8%/tier (max 3) |
| Diagonal | Normalized (×0.707) | Không nhanh hơn khi đi chéo |
| Boundary | Clamp inside arena | Không đi ra ngoài playfield |
| Feel | Responsive, 0 acceleration | Nhả phím = dừng ngay |

## 5. Core Mechanic — Arcane Pulse

### 5.1. Thông Số Cơ Bản

| Param | Base Value | Upgrade Range | Ghi chú |
|---|---|---|---|
| Radius | 50 px | Upgrade → 100 px max (trong hệ 480×270) | Bán kính ảnh hưởng |
| Push Velocity | 400 px/s | Upgrade → 600 px/s max | Tốc độ khởi tạo khi bị đẩy |
| Push Deceleration | 800 px/s² | Cố định | Giảm tốc tuyến tính |
| Push Travel (lý thuyết) | ~100 px | Thay đổi theo velocity | Khoảng cách quái bị đẩy |
| Cooldown | 3.5 s | → 1.8 s min | Thời gian chờ giữa 2 push |
| Hit-stop | 50 ms | Tăng theo chain | Freeze frame khi push |
| Stun on target | 0.3 s | — | Quái bị choáng sau bị đẩy |

### 5.2. Push Physics Rules

```
1. DIRECTION: Quái bị đẩy THEO HƯỚNG từ Player → Enemy (radial outward)
2. VELOCITY DECAY: Quái gần player hơn → nhận 100% velocity. Tại rìa radius → 50%. Linear decay.
3. PUSHED STATE: Quái nhận velocity > 0 → chuyển sang state PUSHED. 
   PUSHED tắt khi velocity < 30 px/s HOẶC sau 0.8s (safety timeout).
   CHỈ enemy ở state PUSHED mới gây/nhận collision damage.
4. WALL COLLISION: Enemy PUSHED + chạm tường → dừng + nhận Wall Damage
5. ENTITY COLLISION: Enemy PUSHED + chạm enemy khác → truyền 60% velocity + CẢ HAI nhận Domino Damage.
   Enemy bị va cũng chuyển sang PUSHED (propagation).
6. DYING STATE: Enemy chết (HP≤0) → DYING 0.15s. Trong DYING vẫn có collision body,
   vẫn truyền lực nếu va chạm tiếp. Sau 0.15s → xóa khỏi scene.
   Mục đích: giữ chain sống (A→B chết→B xác bay tiếp→va C).
7. ALTAR COLLISION: Enemy PUSHED + chạm Altar → Phong ấn tức thì (instant kill) + bonus loot
8. PIT COLLISION: Enemy PUSHED + chạm Vực → Rơi xuống (instant kill) + KHÔNG rơi loot
9. CHAIN WINDOW: 0.6s sau va chạm cuối, nếu tiếp tục va → chain tiếp
10. CHAIN LIMIT: Max chain depth = 8 (safety limit, tránh infinite loop)
```

### 5.3. Damage System

| Nguồn sát thương | Damage | Ghi chú |
|---|---|---|
| Wall Slam | 1 HP | Per hit |
| Domino (quái va quái) | 1 HP | Cả 2 nhận damage |
| Altar Seal | ∞ (instant kill) | Bất kể HP |
| Pit Fall | ∞ (instant kill) | Không rơi loot |
| Chain Lightning (upgrade) | 1 HP | Chỉ khi có upgrade |
| Flame trail (upgrade) | 0.5 HP/s | DoT zone |

### 5.4. Player Damage

| Nguồn | Damage | Grace Period |
|---|---|---|
| Enemy contact | 1 HP | 1.2s bất tử sau hit |
| Boss AoE attack | 1 HP | 1.2s bất tử sau hit |
| Player base HP | 3 | Upgradeable +1/tier (max 5) |

## 6. Wave System

### 6.1. Wave Structure

| Wave | Timer | Arena Changes | Enemies | Target Shard Threshold |
|---|---|---|---|---|
| 1 | 45s | 1 Altar (giữa), tường kín | Slime ×8-12 | 12 shards |
| 2 | 60s | Altar di chuyển, +Tường Gai | Slime + Skeleton ×15-20 | 15 shards |
| 3 | 60s | 2 Altar, +Vực, +Cột Rune | Skeleton + Wraith ×18-25 | 18 shards |
| 4 | 75s | Hazard nhiều, Altar xa hơn | All types ×25-35 | 22 shards |
| 5 | 90s | Boss arena (rộng, ít obstacle) | Boss + horde ×20-30 | — |

### 6.2. Spawn Rules

| Rule | Value |
|---|---|
| Spawn location | Rìa arena, cách player ≥ 150px |
| Max concurrent enemies | 30 |
| Spawn interval | Start: 1.5s → End: 0.5s (mỗi wave tuyến tính) |
| Wave 1-4 end | Timer hết → quái còn lại biến mất (fade out 1s) → wave clear |
| Wave 5 end | **Boss HP = 0 → WIN.** Timer hết + boss sống → **LOST** (thất bại, không đủ mạnh). Quái thường vẫn fade khi timer hết, chỉ boss ở lại. |

### 6.3. Wave Transition

```
Wave Clear
    ↓
Quái fade out (1s)
    ↓
"Wave X Complete!" text (1s)
    ↓
Upgrade Pick (nếu đủ shards) — PAUSED
    ↓
Arena morphs (tường/altar di chuyển — animation 2s)
    ↓
"Wave X+1" text (1s)
    ↓
First spawn
```

## 7. Enemy Catalog

### 7.1. Cursed Ooze (Slime)

| Attribute | Value |
|---|---|
| HP | 1 |
| Speed | 60 px/s |
| Behavior | Đi thẳng về player, không flocking |
| Push weight | Light (bị đẩy xa nhất) |
| Shard drop | 1 |
| Visual | Blob dẻo, xanh lá tối, mắt 1 bên |
| Purpose | Tutorial enemy, chain starter, cannon fodder |

### 7.2. Bone Walker (Skeleton)

| Attribute | Value |
|---|---|
| HP | 1 |
| Speed | 80 px/s |
| Behavior | Flocking — đi theo bầy, tụ cụm quanh player |
| Push weight | Medium |
| Shard drop | 2 |
| Visual | Xương trắng xám, đi lắc lư, mắt đỏ |
| Purpose | Bầy đàn = chain opportunity, positioning test |

### 7.3. Soul Wraith

| Attribute | Value |
|---|---|
| HP | 1 |
| Speed | 120 px/s |
| Behavior | Nhanh, xuyên Cột Rune (không xuyên tường), zig-zag |
| Push weight | Light (bay xa nhưng nhẹ) |
| Shard drop | 2 |
| Visual | Bóng ma tím, trail mờ, mắt trắng |
| Purpose | Pressure — buộc push nhanh, timing test |

### 7.4. Broken Golem

| Attribute | Value |
|---|---|
| HP | 3 |
| Speed | 40 px/s |
| Behavior | Chậm, đi thẳng, phá Cột Rune khi va |
| Push weight | Heavy (bị đẩy gần, cần nhiều push) |
| Shard drop | 5 |
| Visual | Đá vỡ, to hơn, mắt cam, giống player bị hỏng |
| Purpose | Tank — cần wall slam nhiều lần, blocking path |

### 7.5. Dungeon Warden (Mini-Boss)

| Attribute | Value |
|---|---|
| HP | 10 |
| Speed | 50 px/s |
| Behavior | Đuổi player + AoE slam mỗi 5s (bán kính 80px) |
| Push weight | Very Heavy (chỉ đẩy được 40px/push) |
| Altar immunity | KHÔNG thể bị Altar seal |
| Shard drop | 15 + 1 Rune Stone |
| Visual | Giáp đá khổng lồ, rune đỏ, 2 tay búa |
| Purpose | Skill check — phải wall slam 5 lần trong khi dodge AoE |

---

# PHẦN III — PROGRESSION

## 8. In-Run Upgrades

### 8.1. Upgrade Pool

| ID | Category | Name | Effect per Tier | Max Tier |
|---|---|---|---|---|
| UPG_FORCE | Offensive | Heavy Push | Push force +30% | 3 |
| UPG_RADIUS | Offensive | Wider Reach | Push radius +40% | 3 |
| UPG_FLAME | Offensive | Flame Pulse | Lửa tồn tại 2s (+0.5s/tier) gây 0.5 DPS | 3 |
| UPG_ICE | Offensive | Frost Pulse | Slow 50% (+10%/tier) trong 3s | 3 |
| UPG_CHAIN | Offensive | Chain Lightning | Sét nhảy sang 2 (+1/tier) quái gần | 3 |
| UPG_HP | Defensive | Stone Heart | Max HP +1 | 2 |
| UPG_SPEED | Defensive | Swift Stone | Move speed +15% | 3 |
| UPG_SHIELD | Defensive | Rune Shield | 0.5s bất tử sau mỗi Push | 2 |
| UPG_MAGNET | Utility | Soul Magnet | Shard pickup radius +60% | 3 |
| UPG_CD | Utility | Quick Charge | Push cooldown -20% | 3 |
| UPG_ALTAR | Utility | Altar Resonance | Altar seal = x2 shards | 2 |

### 8.2. Upgrade Pick Rules

- Trigger: Khi Soul Shards ≥ threshold (xem Wave System)
- Display: 3 random từ pool (không trùng, ưu tiên chưa max)
- Input: Phím 1/2/3 hoặc click
- Game state: **PAUSED** — không giới hạn thời gian chọn
- Frequency: 3-4 lần/run (wave 1 hiếm khi đủ, wave 2-4 mỗi wave 1 lần)

## 9. Meta-Progression — Rune Forge

### 9.1. Rune Stones Economy

| Source | Amount |
|---|---|
| Clear Wave 1 | 2 RS |
| Clear Wave 2 | 3 RS |
| Clear Wave 3 | 4 RS |
| Clear Wave 4 | 5 RS |
| Clear Wave 5 (Boss) | 8 RS |
| Boss kill bonus | +3 RS |
| Full clear bonus | +5 RS |
| **Max possible per run** | **30 RS** |
| **Typical run (die wave 3)** | **9 RS** |

### 9.2. Permanent Upgrade Catalog

| Category | ID | Name | Cost (RS) | Effect |
|---|---|---|---|---|
| **Stats** | PERM_HP1-5 | Stone Body I-V | 10/20/40/80/150 | Base HP +1 per tier |
| | PERM_FORCE1-3 | Heavy Core I-III | 15/30/60 | Base push force +10% |
| | PERM_SPEED1-3 | Quick Feet I-III | 15/30/60 | Base move speed +8% |
| | PERM_CD1-3 | Charged Core I-III | 20/40/80 | Base cooldown -0.3s |
| **Pulse** | PERM_FLAME | Flame Pulse | 50 | Unlock Flame upgrades in-run |
| | PERM_FROST | Frost Pulse | 50 | Unlock Frost upgrades in-run |
| | PERM_STORM | Storm Pulse | 80 | Unlock Chain Lightning in-run |
| | PERM_VOID | Void Pull | 120 | Unlock reverse-push (hút) in-run |
| **Arena** | PERM_ALTAR2 | Ancient Altar | 60 | Unlock Life Altar (heal on seal) |
| | PERM_SPIKE | Spike Walls | 40 | Tường Gai gây x2 damage |
| | PERM_RICOCHET | Rune Pillars | 60 | Cột Rune ricochet quái |
| **Cosmetic** | PERM_SKIN1-5 | Knight's Memory I-V | 30/50/80/120/200 | Visual: dần lấy lại giáp trụ |

### 9.3. Unlock Pacing

```
Runs needed to unlock (estimated):

Run 1-5:    Stone Body I, Quick Feet I (safety net)
Run 6-10:   Heavy Core I, Flame Pulse (first new content)
Run 11-20:  Frost Pulse, Spike Walls, Skin I-II
Run 21-35:  Storm Pulse, Ancient Altar, Skin III
Run 36-50:  Void Pull, Rune Pillars, Skin IV
Run 50+:    Max stats, Skin V (full knight restoration)

Total RS needed for 100%: ~1,565 RS
Average RS/run: ~12 RS
Estimated runs for 100%: ~130 runs = ~15-20 hours
```

---

# PHẦN IV — NARRATIVE

## 10. Story Outline

### 10.1. Premise

Một hiệp sĩ bảo vệ vương quốc bị phản bội và nguyền hóa đá bởi pháp sư tối Malachar. Bị ném xuống ngục tối cổ đại — nơi Malachar giam giữ linh hồn để nuôi sức mạnh. Lõi rune trong ngực tự kích hoạt (di sản của thầy cũ) — cho phép Stone Knight dùng Pulse duy nhất.

### 10.2. Story Beats — Mảnh Ký Ức (10 chapters)

| Chapter | Trigger | Memory Fragment (1-2 dòng) |
|---|---|---|
| 1 | Clear Wave 5 lần đầu | *"Ánh sáng... tôi nhớ ánh sáng mặt trời trên đồng cỏ. Ai đó gọi tên tôi."* |
| 2 | Clear Wave 5 lần 3 | *"Lưỡi kiếm. Tôi từng cầm kiếm. Tay này... từng bảo vệ ai đó."* |
| 3 | Clear Wave 5 lần 5 | *"Malachar. Hắn ta là bạn. Rồi hắn ta không còn là bạn nữa."* |
| 4 | Clear Wave 5 lần 8 | *"Nghi lễ. Ánh sáng đỏ. Đá lan từ chân lên. Tôi hét nhưng không ai nghe."* |
| 5 | Clear Wave 5 lần 12 | *"Ngục này... là nơi hắn giam giữ mọi thứ hắn sợ. Kể cả tôi."* |
| 6-10 | Tiếp tục... | Dần hé lộ: quá khứ, phản bội, mục đích ngục tối, cách phá nguyền |

### 10.3. NPC Dialogues (Simplified Bucket System)

**Priority Order:**
1. **Story Beat** (nếu vừa unlock chapter mới) — BẮT BUỘC hiện
2. **Achievement React** (lần đầu clear wave X, lần đầu chain x10...) — Ưu tiên cao
3. **Contextual** (dùng Fire Pulse lần đầu, chết bởi Boss...) — Ưu tiên trung bình
4. **Flavor** (random wisdom, hint, humor) — Fallback

**Ví dụ dialogue per NPC:**

| NPC | Trigger | Line |
|---|---|---|
| Blacksmith | First visit | *"Một khối đá... biết đi? Hmm. Để ta xem lõi rune của ngươi."* |
| Blacksmith | Unlock Flame Pulse | *"Lửa! Ngươi tìm lại được lửa! Có lẽ... ngươi mạnh hơn đá."* |
| Scholar | After Chapter 2 | *"Kiếm? Ngươi nhớ kiếm? Thú vị. Lời nguyền thường xóa ký ức trước."* |
| Commander | Die to Boss | *"Thằng canh ngục đó mạnh. Nhưng ngươi nhớ không — tường là vũ khí."* |
| Commander | Clear Boss first time | *"Ha! Ngươi vẫn còn bản năng chiến binh. Đá không che giấu được."* |

---

# PHẦN V — ART DIRECTION

## 11. Visual Style

### 11.1. Art Style: "Dark Fantasy Stylized Pixel"

**Công thức:** `Dark Stone Environment + Bright Rune Glow + Semi-Chibi Characters`

**Mục tiêu:**
- Pixel art hoặc clean low-res vector (phù hợp solo dev)
- Resolution target: 320×180 native, scale 6x → 1920×1080
- Hoặc 480×270 native, scale 4x → 1920×1080
- Nearest-neighbor filtering (giữ pixel crisp)

### 11.2. Color Palette

```
[ENVIRONMENT — Tối, lạnh, đá]
#0a0e14 : Void Black (background ngoài arena)
#161c24 : Dungeon Stone (sàn arena)
#252e3b : Stone Border (tường, cột)
#374151 : Rivet Gray (chi tiết cơ khí, nứt)

[PLAYER — Xám ấm + Cyan rune]
#4a5568 : Stone Body (thân golem chính)
#718096 : Light Stone (highlight)
#00e5ff : Rune Glow (lõi ngực, vết nứt, pulse)
#b8860b : Armor Remnant (mảnh giáp còn sót — vàng cũ)

[ENEMIES]
#2d5a27 : Slime Green (Ooze)
#d4d4d8 : Bone White (Skeleton)
#7c3aed : Wraith Purple (Soul Wraith)
#92400e : Golem Orange (Broken Golem)
#dc2626 : Boss Red (Warden — danger)

[INTERACTIVE — Sáng, chức năng]
#facc15 : Soul Shard Gold (loot)
#a78bfa : Altar Purple (phong ấn glow)
#ef4444 : Danger Red (cảnh báo, boss attack zone)
#22c55e : Heal Green (Life Altar)
#f97316 : Fire Orange (Flame Pulse trail)
#38bdf8 : Ice Blue (Frost Pulse)
#fbbf24 : Lightning Yellow (Chain Lightning)
```

### 11.3. Character Design — Stone Knight

**Kích thước sprite:** 24×24 px (hoặc 32×32 nếu cần chi tiết hơn)

**Cấu trúc visual:**
```
      ┌──┐
      │🪖│  ← Mảnh mũ giáp/vương miện (vàng cũ, méo)
    ┌─┤  ├─┐
    │ │👁│ │  ← Mắt le lói qua khe nứt (cyan glow)
    │ └──┘ │
    │╔════╗│  ← Vết nứt hình giáp trụ (cyan glow lines)
    │║ 💎 ║│  ← Lõi Rune phát sáng ở ngực (cyan core)
    │╚════╝│
    │ ╔══╗ │  ← Thân đá xám (block body)
    │ ║  ║ │
    └─╚══╝─┘
      ║  ║    ← Chân đá (stumpy legs)
```

### 11.4. Animation Principles

| State | Frames | Key Visual |
|---|---|---|
| Idle | 4f loop @4fps | Nhịp thở nhẹ (bob 1px), rune core flicker |
| Move | 4f loop @8fps | Chân bước nặng nề, rune trail phía sau |
| Pulse | 6f once @12fps | Co lại → BÙM sóng xung từ ngực |
| Hit | 3f once @10fps | Flash trắng → đá vỡ rồi tái tạo |
| Power Up | 5f once @8fps | Vết nứt sáng rực, mảnh giáp hiện rõ hơn |
| Defeat | 8f once @6fps | Vỡ từng mảng, thoáng thấy bóng hiệp sĩ, fade |

---

# PHẦN VI — AUDIO DIRECTION

## 12. Sound Design

### 12.1. Music

| Context | Style | BPM | Mood |
|---|---|---|---|
| Main Menu | Orchestral ambient | — | Mysterious, haunting, hopeful undertone |
| The Hollow (Hub) | Soft fantasy | 70-80 | Safe haven, contemplative |
| Wave 1-2 | Dungeon synth + percussion | 100-110 | Building tension |
| Wave 3-4 | Intense orchestral + electronic | 120-130 | Action, urgency |
| Wave 5 (Boss) | Heavy drums + choir | 140+ | Epic, climactic |
| Victory | Triumphant fanfare | — | Relief, achievement |
| Defeat | Somber strings | — | Loss but not despair |

### 12.2. SFX Catalog

| ID | Sound | Priority | Ghi chú |
|---|---|---|---|
| SFX_PULSE | Arcane Pulse release | HIGH | Deep WHOOOM + magic shimmer |
| SFX_WALL_HIT | Enemy wall slam | HIGH | Stone crack + thud |
| SFX_DOMINO | Enemy-enemy collision | MED | Metal clang + smaller thud |
| SFX_ALTAR_SEAL | Enemy sealed in altar | HIGH | Magic whoosh + seal snap |
| SFX_PIT_FALL | Enemy falls in pit | MED | Falling + distant thud |
| SFX_CHAIN_1-5 | Chain reaction (pitch up) | HIGH | ting → TING → TIING (escalating) |
| SFX_SHARD_PICKUP | Collect soul shard | LOW | Coin-like chime |
| SFX_UPGRADE | Upgrade selected | MED | Level up jingle |
| SFX_PLAYER_HIT | Player takes damage | HIGH | Stone crack + pain |
| SFX_PLAYER_DEATH | Player defeat | HIGH | Crumbling stone |
| SFX_BOSS_SLAM | Boss AoE attack | HIGH | Heavy ground pound |
| SFX_WAVE_CLEAR | Wave completed | MED | Achievement chime |

### 12.3. Audio Rules

- **Chain audio escalation:** Mỗi hit trong chain = pitch +15%, volume +5%
- **Polyphony limit:** Max 8 concurrent SFX, priority-based culling
- **Music ducking:** SFX_PULSE và SFX_ALTAR_SEAL duck music 30% trong 0.3s
- **Separate buses:** Master / Music / SFX — independent volume control

---

# PHẦN VII — UI/UX

## 13. Screen Flow

```
LAUNCH → MAIN MENU
              │
    ┌─────────┼─────────┬──────────┐
    ▼         ▼         ▼          ▼
 SETTINGS  THE HOLLOW  CREDITS    QUIT
              │
    ┌─────────┼─────────┬──────────┐
    ▼         ▼         ▼          ▼
 RUNE FORGE  MEMORY   SOUL      NPC TALK
 (Upgrades)  WALL     MIRROR    (Dialogue)
 (Perma)    (Story)   (Skins)
              │
              ▼
         START RUN
              │
              ▼
    ┌── GAMEPLAY HUD ──┐
    │  HP | Wave | CD   │
    │  Shards | Timer   │
    └────────┬──────────┘
             │
    ┌────────┼────────┐
    ▼        ▼        ▼
  PAUSE   UPGRADE   WAVE
  MENU    PICK      TRANSITION
    │        │        │
    └────────┼────────┘
             │
    ┌────────┼────────┐
    ▼                  ▼
  VICTORY           DEFEAT
  SCREEN            SCREEN
    │                  │
    └────────┬─────────┘
             ▼
    [PLAY AGAIN] [THE HOLLOW] [MENU]
```

## 14. HUD Layout (In-Run)

```
┌─────────────────────────────────────────────────────────┐
│ ♥♥♥          WAVE 3/5           ⚡ PULSE: 2.1s         │
│                                                          │
│                                                          │
│                    [ GAME ARENA ]                        │
│                                                          │
│                                                          │
│                                                          │
│ Shards: ████████░░ 12/18        Timer: 0:34             │
│                                   Chain Best: x7         │
└─────────────────────────────────────────────────────────┘

Góc trên trái:  HP hearts
Trên giữa:      Wave indicator
Góc trên phải:  Pulse cooldown (ring hoặc text)
Dưới trái:      Soul Shard progress bar
Dưới phải:      Wave timer countdown
Dưới phải:      Best chain combo (session)
```

---

# PHẦN VIII — ARENA DESIGN

## 15. Arena Templates

### 15.1. Base Arena

| Param | Value |
|---|---|
| Size | 720×405 logical pixels (trong viewport 960×540) |
| Border | Tường đá solid (không đi qua, wall slam active) |
| Grid | 45×45 px tiles (16×9 grid) |
| Style | Dark stone floor, subtle crack pattern |

### 15.2. Arena Elements

| Element | Symbol | Behavior |
|---|---|---|
| **Wall** | `█` | Solid, wall slam damage, permanent |
| **Spike Wall** | `╬` | Wall slam = x2 damage (khi unlocked) |
| **Seal Altar** | `◎` | Push quái vào = instant kill + bonus |
| **Life Altar** | `◉` | Push quái vào = heal player 1 HP (khi unlocked) |
| **Rune Pillar** | `¤` | Chặn quái, ricochet (khi unlocked), player đi qua |
| **Pit** | `▼` | Quái rơi = instant kill, không loot. Player né |
| **Spawn Point** | `×` | Quái xuất hiện, ở rìa arena |

### 15.3. Wave Layout Examples

**Wave 1 — Simple:**
```
████████████████
█              █
█    ×    ×    █
█              █
█       ◎      █
█      (P)     █
█              █
█    ×    ×    █
█              █
████████████████
```

**Wave 3 — Complex:**
```
████████████████
█    ¤    ╬╬╬╬█
█  ×          █
█    ◎    ▼   █
█         ¤   █
█  (P)        █
█       ¤     █
█  ×     ◎    █
█         ×   █
████████████████
```

**Wave 5 — Boss Arena:**
```
████████████████
█              █
█              █
█  ╬        ╬  █
█              █
█     (BOSS)   █
█      (P)     █
█  ╬        ╬  █
█              █
█              █
████████████████
```

---

# PHẦN IX — TECHNICAL NOTES

## 16. Architecture Guidelines (Cho Khi Code)

### 16.1. Scene Tree Target

```
Main (Node2D)
├── Arena (Node2D) — background, grid, border drawing
├── World (Node2D)
│   ├── Altars (Node2D) — altar instances
│   ├── Hazards (Node2D) — pits, spikes, pillars
│   ├── Enemies (Node2D) — enemy instances
│   ├── Player (CharacterBody2D hoặc Node2D)
│   └── Loot (Node2D) — soul shards
├── VFX (Node2D) — particles, pulse ring, chain effects
├── Camera (Camera2D) — trauma shake
├── HUD (CanvasLayer) — UI elements
└── Managers (Node)
    ├── WaveManager — wave state, spawn, timing
    ├── UpgradeManager — upgrade pool, selection
    ├── AudioManager — SFX + music
    ├── SaveManager — persistent data
    └── SettingsManager — preferences
```

### 16.2. Key Principles

- **Tách trách nhiệm:** Mỗi manager 1 file, rõ ràng
- **Signal-based communication:** Không reference trực tiếp giữa systems
- **No autoloads:** Dependency injection qua scene tree
- **Config-driven:** Tất cả magic numbers → config file
- **State machine rõ ràng:** Enum-based, không boolean spaghetti

---

*GDD v1.0 hoàn thành. Tài liệu này sẽ được cập nhật khi thiết kế tiến triển qua các bước tiếp theo.*
