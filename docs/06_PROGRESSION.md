# BƯỚC 6: THIẾT KẾ TRẢI NGHIỆM & PROGRESSION — Stone Knight

**Trạng thái:** ĐÃ CHỐT
**Mục tiêu:** Vạch ra đường cong độ khó, hệ thống thưởng, cấu trúc wave, wireframe UI/UX

---

## 1. Đường Cong Độ Khó (Difficulty Curve)

### 1.1. Nguyên Tắc

> **"Luôn cho người chơi cảm giác VỪA ĐỦ KHÓ."**
> - Quá dễ → nhàm. Quá khó → bỏ cuộc.
> - Sweet spot: người chơi chết 40-60% run trong 2 tuần đầu.
> - Sau khi có meta-upgrades: tỉ lệ clear tăng lên 60-80%.

### 1.2. Difficulty Per Wave (First Run, No Meta-Upgrades)

```
                    Player Power vs Enemy Pressure
Power ▲
   10 │                                         ╱╱ Player (with upgrades)
      │                                      ╱╱╱
    8 │                                   ╱╱╱
      │                              ╱╱╱╱╱    ← Fun Zone
    6 │                          ╱╱╱╱╱     ╱╱╱╱ Enemy Pressure
      │                     ╱╱╱╱╱     ╱╱╱╱╱
    4 │                ╱╱╱╱╱     ╱╱╱╱╱
      │           ╱╱╱╱╱     ╱╱╱╱╱
    2 │      ╱╱╱╱╱     ╱╱╱╱╱
      │ ╱╱╱╱╱     ╱╱╱╱╱
    0 ├───────┬───────┬───────┬───────┬───────►
         W1       W2       W3       W4       W5
```

**Giải thích:**
- **Wave 1-2:** Player power > Enemy → Học cách chơi, feel powerful
- **Wave 3:** Lines gần nhau → Tension tăng, phải play smart
- **Wave 4:** Enemy pressure vượt nhẹ → Thử thách thật sự
- **Wave 5 (Boss):** Spike mạnh → Climax, có thể chết nếu không giỏi

### 1.3. Bảng Difficulty Chi Tiết

| Wave | Quái (loại × số max) | Spawn Rate | Enemy Speed | Player Upgrades | Kill Win-Rate Target |
|---|---|---|---|---|---|
| 1 | Slime ×12 | 1 con/2s | 60 px/s | 0 | 95% (gần auto-win) |
| 2 | Slime ×8 + Skeleton ×10 | 1 con/1.5s | 60-80 px/s | 0-1 | 85% |
| 3 | Skeleton ×12 + Wraith ×8 | 1 con/1.2s | 80-120 px/s | 1-2 | 60% |
| 4 | Slime ×8 + Skeleton ×10 + Wraith ×10 | 1 con/0.8s | 60-120 px/s | 2-3 | 40% |
| 5 | Boss + Skeleton ×15 + Wraith ×10 | 1 con/1s + Boss | 50-120 px/s | 3-4 | 25% (first time) |

### 1.4. Difficulty Modifiers Từ Meta-Progression

| Meta-Upgrade | Effective Difficulty Change |
|---|---|
| Stone Body I (+1 HP) | Giảm ~15% (chịu thêm 1 hit) |
| Heavy Core I (+10% force) | Giảm ~10% (push xa hơn) |
| Quick Feet I (+8% speed) | Giảm ~8% (né dễ hơn) |
| Full meta (6 upgrades max) | Giảm ~40% tổng → Wave 5 win-rate: ~65% |

---

## 2. Reward System — "Dopamine Schedule"

### 2.1. Reward Frequency Map

```
Timeline 1 Run (5-10 min):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
│  ↓↓↓ ↓↓↓ ↓↓↓   ↓↓  ↓↓↓ ↓↓↓   ↓  ↓↓  ↓↓↓↓ ↓↓ │
│  Shard pickups (mỗi 3-5 giây)                    │ ← Micro-reward
│  ▲         ▲              ▲         ▲            │
│  Chain x3  Chain x5       Chain x3  Chain x8     │ ← Combo satisfaction
│       ★              ★              ★       ★    │
│     Upgrade        Upgrade        Upgrade  Upgr. │ ← Meaningful choice
│                                              ⚑   │
│                                         Wave 5   │ ← Achievement
│                                         Clear!   │
│                                              💎  │
│                                         Rune     │ ← Meta-progress
│                                         Stones   │
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Reward density: ~1 reward mỗi 3-8 giây (KHÔNG BAO GIỜ để trống > 10s)
```

### 2.2. Reward Types & Schedule

| Reward Type | Frequency | Satisfaction Level | Purpose |
|---|---|---|---|
| **Shard Pickup** | Mỗi 3-5s | ★☆☆☆☆ (low) | Constant drip, feel productive |
| **Chain Combo** | Mỗi 10-20s | ★★★☆☆ (mid) | Skill expression, spectacle |
| **Wave Clear** | Mỗi 45-90s | ★★★★☆ (high) | Milestone, sense of progress |
| **Upgrade Pick** | 3-4x/run | ★★★★★ (peak) | Power spike, meaningful choice |
| **Run Complete** | 1x/run | ★★★★★ (peak) | Achievement, closure |
| **Meta Unlock** | Mỗi 3-5 runs | ★★★★★★ (epic) | Long-term goal reached |
| **Story Fragment** | Mỗi 3-8 runs | ★★★★★★ (epic) | Narrative reward, curiosity |

### 2.3. "Just One More Run" Triggers

| Trigger | Cơ chế | Hiệu quả |
|---|---|---|
| **Near-miss** | "Wave 4/5 — gần clear!" | Muốn thử lại ngay |
| **New upgrade** | "Vừa unlock Quick Charge ở Forge" | Muốn test ngay |
| **Rune Stones gần đủ** | "Còn thiếu 5 RS mở Heavy Core" | Chơi thêm 1 run |
| **Story tease** | "Chapter 3: Malachar... bạn?" | Muốn biết tiếp |
| **Personal best** | "Chain x12 — có thể x15?" | Cải thiện kỹ năng |

---

## 3. Cấu Trúc Wave Chi Tiết (V1.0)

### Wave 1: "Awakening" (45s)

```
Goal: Dạy player cách push & altar
Arena:
  ████████████████
  █              █
  █  ×        ×  █
  █              █
  █      ◎       █
  █     (P)      █
  █              █
  █  ×        ×  █
  █              █
  ████████████████

Enemies: Slime only (1 type)
Spawn: 1 con/2s, max 12
Shard threshold: 12 (có thể đạt upgrade cuối wave)
Hidden tutorial:
  - Slime chậm → player có thời gian observe
  - Altar ở giữa → tự nhiên push về đó
  - Tường kín → wall slam sẽ xảy ra tự nhiên
```

### Wave 2: "The Hunt" (60s)

```
Goal: Dạy wall slam & bầy đàn
Arena:
  ████████████████
  █         ╬╬╬╬█
  █  ×           █
  █      ◎       █    ◎ Altar di chuyển sang phải
  █              █    ╬ Tường Gai (x2 damage)
  █     (P)      █
  █              █
  █  ×      ×    █
  █              █
  ████████████████

Enemies: Slime + Skeleton (bầy)
Spawn: 1 con/1.5s, max 18
Shard threshold: 15
Learning: Skeleton flock → cơ hội push cả bầy vào Spike Wall
```

### Wave 3: "Shifting Ground" (60s)

```
Goal: Arena phức tạp, fast enemies, multi-altar
Arena:
  ████████████████
  █    ¤    ╬╬╬╬█
  █  ×           █    2 Altar
  █    ◎    ▼    █    1 Vực (instant kill no loot)
  █         ¤    █    2 Cột Rune (chặn quái)
  █     (P)      █
  █       ¤      █
  █  ×      ◎    █
  █         ×    █
  ████████████████

Enemies: Skeleton + Wraith (fast!)
Spawn: 1 con/1.2s, max 20
Shard threshold: 18
Learning: Wraith xuyên cột → phải push nhanh. Pit = risk/reward.
```

### Wave 4: "The Swarm" (75s)

```
Goal: Stress test, chain opportunity, peak variety
Arena:
  ████████████████
  █╬           ╬█
  █  ×   ▼  ×   █
  █    ◎    ¤   █    3 loại quái
  █   ¤         █    Hazards nhiều
  █     (P)     █    Altar xa → phải lùa quái xa hơn
  █         ◎   █
  █  ×   ¤   ×  █
  █╬           ╬█
  ████████████████

Enemies: Slime + Skeleton + Wraith (tất cả)
Spawn: 1 con/0.8s, max 30
Shard threshold: 22
Peak moment: Lùa 15+ quái → 1 MEGA PUSH → chain x10+
```

### Wave 5: "The Warden" — BOSS (90s)

```
Goal: Boss fight, climax, use everything learned
Arena:
  ████████████████
  █              █
  █              █
  █  ╬        ╬  █    Boss arena: rộng, 4 spike walls
  █              █    Boss: Dungeon Warden
  █    (BOSS)    █    + Skeleton horde
  █     (P)      █
  █  ╬        ╬  █
  █              █
  █              █
  ████████████████

Boss: Dungeon Warden (HP: 10, push weight: Very Heavy)
  - Behavior: Đuổi player + AoE slam mỗi 5s
  - Immune: Altar seal, Pit fall
  - Kill: Wall/Spike slam 5 lần (mỗi slam = 2 dmg from spike)
  - Adds: Skeleton spawn mỗi 8s
Learning: Phải position boss gần spike wall → push → wall damage
```

---

## 4. UI/UX Wireframes

### 4.1. Main Menu

```
┌─────────────────────────────────────────────────────────┐
│                                                          │
│                   ⚔️ STONE KNIGHT ⚔️                    │
│                  The Cursed Dungeon                      │
│                                                          │
│                                                          │
│               ╔═══════════════════════╗                  │
│               ║     ENTER DUNGEON     ║ ← Primary CTA   │
│               ╚═══════════════════════╝                  │
│                                                          │
│                  [ THE HOLLOW ]        ← Hub access      │
│                  [  SETTINGS  ]                          │
│                  [   CREDITS  ]                          │
│                  [    QUIT    ]                          │
│                                                          │
│  v1.0.0                          Best: Wave 5 | Runs: 34│
└─────────────────────────────────────────────────────────┘
```

### 4.2. In-Game HUD

```
┌─────────────────────────────────────────────────────────┐
│ ♥♥♥♡♡                              ⚡ ████░░░░ 2.1s    │
│                                                          │
│                                                          │
│                                                          │
│                    [GAME ARENA]                          │
│                                                          │
│                                                          │
│                                                          │
│                                                          │
│ 💎 ████████░░ 12/18                     ⏱ 0:34  🔗 x7  │
└─────────────────────────────────────────────────────────┘

Top-left:     ♥♥♥♡♡ HP hearts (filled = current, empty = max)
Top-right:    ⚡ Pulse cooldown bar + seconds
Bottom-left:  💎 Soul Shard progress bar (current/threshold)
Bottom-right: ⏱ Wave timer | 🔗 Best chain this run
Center-top:   Wave indicator (only during transition)
```

### 4.3. Upgrade Pick

```
┌─────────────────────────────────────────────────────────┐
│                                                          │
│                  ★ SOUL EVOLUTION ★                      │
│                                                          │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │
│  │     [1]       │ │     [2]       │ │     [3]       │   │
│  │               │ │               │ │               │   │
│  │  💪 HEAVY     │ │  🏃 SWIFT     │ │  🧲 SOUL      │   │
│  │    PUSH       │ │    STONE      │ │    MAGNET     │   │
│  │               │ │               │ │               │   │
│  │ Push force    │ │ Move speed    │ │ Pickup range  │   │
│  │    +30%       │ │    +15%       │ │    +60%       │   │
│  │               │ │               │ │               │   │
│  │  Tier 1/3     │ │  Tier 2/3     │ │  Tier 1/3     │   │
│  └──────────────┘ └──────────────┘ └──────────────┘    │
│                                                          │
│             Press 1, 2, or 3 to choose                  │
└─────────────────────────────────────────────────────────┘
```

### 4.4. Result Screen (Victory)

```
┌─────────────────────────────────────────────────────────┐
│                                                          │
│              🏆 DUNGEON CLEARED! 🏆                      │
│                                                          │
│         "The seal cracks further..."                     │
│                                                          │
│   ┌───────────────────────────────────────────┐          │
│   │  Wave Reached:     5/5  ✅                 │          │
│   │  Time Survived:    6:42                   │          │
│   │  Enemies Sealed:   47                     │          │
│   │  Best Chain:       x12  🔥 NEW BEST!      │          │
│   │  Soul Shards:      89                     │          │
│   │                                           │          │
│   │  Rune Stones Earned:  +22 💎              │          │
│   │  Total Rune Stones:   247                 │          │
│   └───────────────────────────────────────────┘          │
│                                                          │
│   [ PLAY AGAIN ]  [ THE HOLLOW ]  [ MAIN MENU ]         │
└─────────────────────────────────────────────────────────┘
```

### 4.5. The Hollow (Hub)

```
┌─────────────────────────────────────────────────────────┐
│  💎 247 Rune Stones              Best: W5 | Runs: 34    │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │                                                  │    │
│  │        🔨                    👤                   │    │
│  │     RUNE FORGE           NPC DIALOGUE            │    │
│  │    (Upgrades)         (Story via Blacksmith)      │    │
│  │                                                  │    │
│  │               👤                                  │    │
│  │          THE BLACKSMITH                          │    │
│  │        "Another run, Stone?                      │    │
│  │         Your core grows                          │    │
│  │         stronger..."                             │    │
│  │                                                  │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│          ╔═══════════════════════════╗                   │
│          ║    ENTER THE DUNGEON      ║                   │
│          ╚═══════════════════════════╝                   │
└─────────────────────────────────────────────────────────┘
```

---

## 5. Player Journey Map — Tuần 1 → Tuần 4

### Tuần 1: "Learning" (Run 1-10)

```
Run 1-2:  Học push, chết wave 2-3. "Ồ, đẩy vào tường giết được!"
Run 3-4:  Đạt wave 3-4. Mua Stone Body I. "Thêm 1 HP, ngon!"
Run 5-7:  Đạt wave 4 ổn định. Mua Heavy Core I. Push mạnh hơn.
Run 8-10: Clear wave 5 lần đầu! 🎉 Mảnh ký ức #1. "Ai gọi tên tôi?"
```

### Tuần 2: "Building" (Run 11-25)

```
Run 11-15: Clear W5 30% run. Mua Quick Feet, Charged Core.
Run 16-20: Thử chain x10+. Mảnh ký ức #2. "Tôi từng cầm kiếm..."
Run 21-25: Hầu hết clear W5. Mua Soul Attunement. Farm nhanh hơn.
```

### Tuần 3: "Mastering" (Run 26-40)

```
Run 26-30: Clear W5 ổn định. Mảnh ký ức #3. "Malachar... bạn?"
Run 31-35: Tối ưu chain. Personal best chain x15+.
Run 36-40: Gần max meta-upgrades. Mảnh ký ức #4 (nếu có).
```

### Tuần 4: "Completing" (Run 41+)

```
Run 41-45: Max tất cả meta. Chơi vì chain records & story.
Run 45+:   Chờ content update (v1.1 sẽ thêm enemy, upgrades, story)
```

---

## 6. Tóm Tắt

### Design Goals Checklist

| Goal | Implementation | Đã thiết kế? |
|---|---|---|
| Run ngắn 5-10 phút | 5 waves, timer 45-90s | ✅ |
| Power fantasy | Upgrade snowball, chain escalation | ✅ |
| Easy to learn | Wave 1 = implicit tutorial, 1 button | ✅ |
| Hard to master | Positioning, timing, chain optimization | ✅ |
| "One more run" | Near-miss, meta-unlock, story tease | ✅ |
| Retain weekly | Meta-progression 5-7 hours to max | ✅ |
| Narrative drive | Memory fragments, NPC dialogue | ✅ |
| Differentiation | Push mechanic, arena dynamics | ✅ |

---

*Trải nghiệm & Progression đã thiết kế hoàn chỉnh. Bước tiếp theo: Kế hoạch sản xuất (Bước 7).*
