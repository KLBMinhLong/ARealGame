# BƯỚC 3: CORE LOOP DESIGN — Stone Knight

**Trạng thái:** ĐÃ CHỐT
**Mục tiêu:** Thiết kế chi tiết 4 vòng lặp gameplay lồng nhau — nền tảng cho mọi hệ thống sau này

---

## 0. Nguyên Tắc Thiết Kế Core Loop

> **Quy tắc vàng:** Mọi vòng lặp đều phải tạo ra **hành động → phản hồi → phần thưởng → quyết định**. Nếu thiếu 1 trong 4, vòng lặp sẽ nhàm chán.

```
Action → Feedback → Reward → Decision → Action (lặp lại)
  │          │          │          │
  Đẩy      Nổ chain    Shards    Upgrade nào?
```

---

## 1. MICRO LOOP — "The Push Cycle" (3-8 giây)

> Đây là vòng lặp **cốt lõi nhất**. Người chơi lặp lại hành động này hàng trăm lần mỗi run. Nếu vòng này không thỏa mãn, game thất bại.

### 1.1. Flowchart

```
┌─────────────┐
│  1. OBSERVE  │   Nhìn arena: quái ở đâu? Altar ở đâu? Tường gai ở đâu?
│  (0.5-1s)    │   → Quyết định: dồn quái về hướng nào?
└──────┬──────┘
       ▼
┌─────────────┐
│  2. MOVE     │   Di chuyển đến vị trí tối ưu
│  (1-3s)      │   → Lùa quái tụ lại (quái đuổi theo mình)
│              │   → Chạy gần Altar/Tường để tận dụng terrain
└──────┬──────┘
       ▼
┌─────────────┐
│  3. PULSE!   │   Nhấn Space khi:
│  (instant)   │   → Đủ quái trong radius
│              │   → Hướng đẩy tốt (về phía altar/tường/cụm quái khác)
└──────┬──────┘
       ▼
┌─────────────────────────────────────────────┐
│  4. CHAIN REACTION (0.3-1.5s)               │
│                                              │
│  4a. Direct Push → Quái bay ra theo vector   │
│  4b. Wall Slam  → Quái đập tường = damage    │
│  4c. Altar Seal → Quái vào Altar = instant ☠ │
│  4d. Domino     → Quái va quái = truyền lực  │
│  4e. Cascade    → 4b/4c/4d lặp lại nếu đủ   │
│      lực → COMBO x2, x3, x5, x10...          │
└──────┬──────────────────────────────────────┘
       ▼
┌─────────────┐
│  5. COLLECT  │   Soul Shards bay về (magnet)
│  (0.5-1s)    │   Combo counter hiện lên
│              │   Thanh Shard progress bar cập nhật
└──────┬──────┘
       ▼
┌─────────────┐
│  6. COOLDOWN │   Pulse cooldown 3-4s
│  (3-4s)      │   → Trong lúc chờ: OBSERVE + MOVE cho push tiếp
│              │   → Né quái (không có cách giết ngoài Push)
└──────┬──────┘
       ▼
   Quay lại 1. OBSERVE
```

### 1.2. Phân Tích "Feel" Từng Phase

| Phase | Cảm xúc mục tiêu | Game Feel cần | Audio |
|---|---|---|---|
| OBSERVE | Tập trung, tính toán | Arena rõ ràng, đọc được | Ambient dungeon |
| MOVE | Căng thẳng, né quái | Responsive movement, quái đuổi sát | Footsteps, quái growl |
| PULSE | BÙM! Giải tỏa! | Hit-stop 50ms, visual burst, screen shake | WHOOOM bass hit |
| CHAIN | WOW! Thỏa mãn! | Cascade particles, pitch escalation | ting-TING-TIING-BOOM |
| COLLECT | Cha-ching! Phần thưởng | Shards fly in, numbers pop up | Coin-like pickup sounds |
| COOLDOWN | Hồi hộp, planning | Cooldown ring filling up | Heartbeat-like tick |

### 1.3. Skill Expression — "Easy to Learn, Hard to Master"

| Level | Cách chơi | Hiệu quả |
|---|---|---|
| **Newbie** | Đẩy bừa khi quái gần | Chain x1-2, chậm clear |
| **Trung bình** | Lùa quái vào gần tường rồi đẩy | Chain x3-5, wall slam |
| **Giỏi** | Lùa quái vào giữa Altar + cụm quái khác | Chain x5-10, altar + domino |
| **Master** | Tính toán góc đẩy để 1 push clear cả wave | Chain x10+, screen clear |

---

## 2. MESO LOOP — "The Wave" (45-90 giây)

> Mỗi wave là một "bài toán" positioning khác nhau. Arena layout + enemy composition = người chơi phải adapt.

### 2.1. Cấu Trúc 1 Wave

```
┌─────────────────────────────────────────────┐
│ WAVE START                                   │
│ ┌─────────────────────────────────────────┐  │
│ │ Arena Setup:                             │  │
│ │ • Altar(s) vị trí mới                   │  │
│ │ • Tường Gai thêm/bớt                    │  │
│ │ • Hazard mới? (vực, cột rune)           │  │
│ │ • Brief flash hiện layout 1s            │  │
│ └─────────────────────────────────────────┘  │
│                                              │
│ SPAWN PHASE (liên tục trong wave):           │
│ • Quái spawn từ rìa arena                   │
│ • Số lượng + loại tăng dần trong wave        │
│ • Cap: không quá 30 quái cùng lúc            │
│                                              │
│ COMBAT PHASE (player thực hiện micro loop):  │
│ • Lặp Push Cycle nhiều lần                   │
│ • Thu Soul Shards                            │
│                                              │
│ WAVE CLEAR CONDITION:                        │
│ • Timer hết (45-90s tùy wave)                │
│ • HOẶC giết đủ quota quái                    │
│                                              │
│ WAVE END:                                    │
│ • Clear bonus shards                         │
│ • Nếu đủ Shard threshold → UPGRADE PICK      │
│ • Brief pause 2-3s → Next wave               │
└─────────────────────────────────────────────┘
```

### 2.2. Wave Clear Condition — Timer vs Kill Quota

| Option | Ưu | Nhược | Quyết định |
|---|---|---|---|
| **Timer only** (sống sót X giây) | Đơn giản, dễ hiểu | Thụ động, khuyến khích né tránh | ❌ |
| **Kill quota** (giết X quái) | Chủ động, khuyến khích push | Có thể stuck nếu khó | ❌ |
| **Hybrid: Timer + Kill bonus** | Timer là baseline, kill thêm = bonus shard | Best of both | ✅ |

**Quyết định:** Wave kết thúc khi **timer hết**. Nhưng mỗi quái giết TRƯỚC khi timer hết = **bonus Soul Shards**. Tạo incentive chủ động mà không punish người chơi yếu.

### 2.3. Upgrade Pick (Giữa Wave)

```
┌──────────────────────────────────────────────┐
│  ★ SOUL EVOLUTION ★                          │
│                                               │
│  Soul Shards: 15/15 — Chọn 1 nâng cấp:      │
│                                               │
│  ┌─────────────────────────────────────────┐  │
│  │ [1] 🔥 FLAME PULSE                      │  │
│  │     Đẩy + để lại vệt lửa 2s            │  │
│  │     Quái đi qua lửa chịu thêm damage   │  │
│  │     Tier 1 / Max 3                      │  │
│  └─────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────┐  │
│  │ [2] 💨 WIDER REACH                      │  │
│  │     Push radius +40%                    │  │
│  │     Đẩy được nhiều quái hơn 1 lần       │  │
│  │     Tier 1 / Max 3                      │  │
│  └─────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────┐  │
│  │ [3] 🧲 SOUL MAGNET                      │  │
│  │     Thu Soul Shards từ xa hơn 60%       │  │
│  │     + Shards bay nhanh hơn              │  │
│  │     Tier 1 / Max 3                      │  │
│  └─────────────────────────────────────────┘  │
│                                               │
│  Thời gian còn: PAUSED (không giới hạn)       │
└──────────────────────────────────────────────┘
```

### 2.4. Danh Sách Upgrade Trong Run (Draft v1)

| Category | ID | Tên | Hiệu ứng | Max Tier |
|---|---|---|---|---|
| **Offensive** | UPG_FORCE | Heavy Push | Push force +30% | 3 |
| | UPG_RADIUS | Wider Reach | Push radius +40% | 3 |
| | UPG_FLAME | Flame Pulse | Để lại lửa 2s sau push | 3 |
| | UPG_ICE | Frost Pulse | Slow quái bị đẩy 50% trong 3s | 3 |
| | UPG_CHAIN | Chain Lightning | Quái bị đẩy phóng sét sang quái gần | 3 |
| **Defensive** | UPG_HP | Stone Heart | Max HP +1 | 2 |
| | UPG_SPEED | Swift Stone | Move speed +15% | 3 |
| | UPG_SHIELD | Rune Shield | Miễn damage 0.5s sau mỗi Push | 2 |
| **Utility** | UPG_MAGNET | Soul Magnet | Shard pickup radius +60% | 3 |
| | UPG_COOLDOWN | Quick Charge | Push cooldown -20% | 3 |
| | UPG_ALTAR | Altar Resonance | Altar phong ấn = x2 shards | 2 |

**Mỗi upgrade pick:** Random 3 từ pool, người chơi chọn 1. Tier tăng nếu đã có.

---

## 3. MACRO LOOP — "The Run" (5-10 phút)

> Một run hoàn chỉnh từ bắt đầu đến kết thúc. Đây là đơn vị "session" chính.

### 3.1. Cấu Trúc Run

```
┌─ RUN START ─────────────────────────────────────────────┐
│                                                          │
│  WAVE 1: "Awakening" (45s)                               │
│  • Arena: Simple — 1 Altar ở giữa, tường kín            │
│  • Quái: Chỉ có Slime (chậm, yếu)                       │
│  • Mục tiêu ngầm: Học cơ chế Push + Altar               │
│  • Upgrade: 0-1 lần                                      │
│  • Difficulty: ★☆☆☆☆                                    │
│                                                          │
│  WAVE 2: "The Hunt" (60s)                                │
│  • Arena: Altar di chuyển sang góc, thêm Tường Gai       │
│  • Quái: Slime + Skeleton (trung bình, bầy đàn)          │
│  • Mục tiêu ngầm: Học Wall Slam + Lùa quái              │
│  • Upgrade: 1 lần                                        │
│  • Difficulty: ★★☆☆☆                                    │
│                                                          │
│  WAVE 3: "Shifting Ground" (60s)                         │
│  • Arena: 2 Altar, vực xuất hiện, cột Rune chắn          │
│  • Quái: Skeleton + Wraith (nhanh, xuyên cột)            │
│  • Mục tiêu ngầm: Adapt terrain mới, multi-altar play    │
│  • Upgrade: 1 lần                                        │
│  • Difficulty: ★★★☆☆                                    │
│                                                          │
│  WAVE 4: "The Swarm" (75s)                               │
│  • Arena: Phức tạp — hazard nhiều, Altar xa hơn          │
│  • Quái: Tất cả loại, spawn dày đặc                      │
│  • Mục tiêu ngầm: Test build đã chọn, chain lớn          │
│  • Upgrade: 1 lần                                        │
│  • Difficulty: ★★★★☆                                    │
│                                                          │
│  WAVE 5: "The Warden" (90s)                              │
│  • Arena: Boss arena — rộng, ít obstacle                  │
│  • Quái: MINI-BOSS + horde quái thường                    │
│  • Mini-boss: Không thể Altar-seal, phải wall-slam 5 lần  │
│  • Mục tiêu ngầm: Peak power fantasy, boss kill           │
│  • Difficulty: ★★★★★                                    │
│                                                          │
├─ RUN END ───────────────────────────────────────────────┤
│                                                          │
│  KẾT QUẢ:                                               │
│  ┌─ THẮNG (clear wave 5) ────────────────────────────┐  │
│  │ "The seal cracks further..."                       │  │
│  │ Rune Stones earned: 15 (base) + bonuses            │  │
│  │ Mảnh ký ức mới mở khóa                             │  │
│  │ [PLAY AGAIN] [THE HOLLOW] [MENU]                   │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  ┌─ THUA (HP = 0) ───────────────────────────────────┐  │
│  │ "The stone claims you... for now."                 │  │
│  │ Wave reached: X/5                                  │  │
│  │ Rune Stones earned: (ít hơn, tỉ lệ theo wave)     │  │
│  │ [TRY AGAIN] [THE HOLLOW] [MENU]                    │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### 3.2. Đường Cong Khó (Difficulty Curve)

```
Difficulty
    ▲
    │                                    ╱ Wave 5
    │                                 ╱╱  (Boss)
    │                              ╱╱
    │                          ╱╱╱   Wave 4
    │                       ╱╱╱
    │                   ╱╱╱      Wave 3
    │               ╱╱╱
    │           ╱╱╱          Wave 2
    │       ╱╱╱
    │   ╱╱╱              Wave 1
    │╱╱╱
    └────────────────────────────────► Time
    0s   45s  105s  165s  240s  330s

    Người chơi power:
    ──────▶ ngày càng mạnh (upgrades)
    
    Enemies:
    ──────▶ ngày càng nhiều + đa dạng + nhanh

    Gap (Power - Difficulty) = Fun Zone:
    • Nếu gap > 0 quá nhiều → quá dễ, nhàm
    • Nếu gap < 0 quá nhiều → quá khó, frustrating
    • Sweet spot: gap dao động quanh 0, đôi khi + đôi khi -
```

### 3.3. Power Curve Trong 1 Run

| Thời điểm | Player Power | Lý do |
|---|---|---|
| Wave 1 start | ★☆☆☆☆ | Base stats, 0 upgrade |
| Wave 2 start | ★★☆☆☆ | +1 upgrade |
| Wave 3 start | ★★★☆☆ | +2 upgrades, đã hiểu arena |
| Wave 4 start | ★★★★☆ | +3 upgrades, combo chains |
| Wave 5 mid | ★★★★★ | +3-4 upgrades, peak power fantasy |

---

## 4. META LOOP — "The Journey" (Nhiều run, nhiều ngày)

> Vòng lặp giữ người chơi quay lại ngày này qua ngày khác.

### 4.1. Hub — "The Hollow" (Hốc Đá)

```
┌─ THE HOLLOW ────────────────────────────────────────────┐
│                                                          │
│  Một hang động dưới lòng ngục tối, nơi các linh hồn     │
│  bị mắc kẹt tụ tập. Stone Knight tỉnh dậy ở đây        │
│  sau mỗi run.                                            │
│                                                          │
│  ┌──────────────┐   ┌──────────────┐                    │
│  │ RUNE FORGE   │   │ MEMORY WALL  │                    │
│  │ (Upgrades    │   │ (Story/Lore  │                    │
│  │  vĩnh viễn)  │   │  collection) │                    │
│  └──────┬───────┘   └──────┬───────┘                    │
│         │                   │                            │
│  ┌──────┴───────┐   ┌──────┴───────┐                    │
│  │ SOUL MIRROR  │   │ NPC SPIRITS  │                    │
│  │ (Skins/      │   │ (Dialogue,   │                    │
│  │  Cosmetics)  │   │  hints, lore)│                    │
│  └──────────────┘   └──────────────┘                    │
│                                                          │
│  ┌──────────────────────────────────────────────┐       │
│  │ [ENTER THE DUNGEON]  — Bắt đầu run mới       │       │
│  └──────────────────────────────────────────────┘       │
│                                                          │
│  Rune Stones: 247     Best Wave: 5     Total Runs: 34   │
└──────────────────────────────────────────────────────────┘
```

### 4.2. Hệ Thống Unlock Vĩnh Viễn

**Rune Forge — Permanent Upgrades (Rune Stones currency)**

| Category | Unlock | Cost (RS) | Hiệu ứng |
|---|---|---|---|
| **Core Stats** | Stone Body I-V | 10/20/40/80/150 | Max HP +1 mỗi tier |
| | Heavy Core I-III | 15/30/60 | Base push force +10% |
| | Quick Feet I-III | 15/30/60 | Base move speed +8% |
| | Charged Core I-III | 20/40/80 | Base push cooldown -0.3s |
| **Pulse Types** | Flame Pulse | 50 | Unlock Fire upgrades trong run |
| | Frost Pulse | 50 | Unlock Ice upgrades trong run |
| | Storm Pulse | 80 | Unlock Chain Lightning trong run |
| | Void Pulse | 120 | Unlock Gravity Pull (hút quái lại) |
| **Arena** | Ancient Altar | 60 | Unlock Altar mới (Life Altar = heal) |
| | Spike Walls | 40 | Tường Gai gây x2 damage |
| | Rune Pillars | 60 | Cột Rune phản xạ quái (ricochet) |
| **Story** | Memory Shard I-X | Quest-based | Mở chapter ký ức |

### 4.3. NPC Spirits — Narrative Between Runs

| NPC | Vai trò | Dialogue trigger |
|---|---|---|
| **The Blacksmith** (Linh hồn thợ rèn) | Forge upgrades, hints about weapons | Khi unlock new tier |
| **The Scholar** (Linh hồn học giả) | Lore, memory interpretation | Khi mở memory shard mới |
| **The Knight Commander** (Linh hồn tướng quân) | Chiến thuật, hints boss | Khi thua boss / clear wave mới |

### 4.4. Meta Loop Flowchart Hoàn Chỉnh

```
┌───────────────────────────────────────────────────────┐
│                    THE HOLLOW (Hub)                     │
│                                                        │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────────┐  │
│  │  Forge  │  │ Mirror │  │ Memory │  │ NPC Talk   │  │
│  │ Upgrade │  │  Skins │  │  Wall  │  │ (if new    │  │
│  │(Rune St)│  │(Rune St)│  │(Story) │  │  dialogue) │  │
│  └────┬───┘  └────┬───┘  └────┬───┘  └─────┬──────┘  │
│       └──────┬────┘──────┬────┘─────────────┘          │
│              ▼                                          │
│     [ENTER THE DUNGEON]                                │
└──────────────┬──────────────────────────────────────────┘
               ▼
┌──────────────────────────────┐
│         RUN (5-10 min)        │
│                               │
│  Wave 1 → Wave 2 → Wave 3    │
│  → Wave 4 → Wave 5 (Boss)    │
│                               │
│  Upgrades in-run: 3-4x        │
│  Micro loops: 30-50x          │
└──────────────┬────────────────┘
               ▼
┌──────────────────────────────┐
│         RUN RESULT            │
│                               │
│  + Rune Stones (tùy wave)    │
│  + Memory Shard (nếu clear)  │
│  + NPC dialogue trigger       │
│  + Stats tracking             │
└──────────────┬────────────────┘
               ▼
          Quay lại THE HOLLOW
```

---

## 5. STATE MACHINE — Toàn Bộ Game

```
                    ┌──────────┐
                    │  LAUNCH  │
                    └────┬─────┘
                         ▼
                    ┌──────────┐
            ┌──────│   MENU   │──────┐
            │      └────┬─────┘      │
            ▼           ▼            ▼
       ┌────────┐  ┌─────────┐  ┌────────┐
       │SETTINGS│  │THE HOLLOW│  │  QUIT  │
       └────┬───┘  │  (Hub)   │  └────────┘
            │      └────┬─────┘
            │           ▼
            │      ┌─────────┐     ┌──────────┐
            │      │  FORGE  │────▶│   MIRROR  │
            │      │  MEMORY │◀────│   NPCs    │
            │      └────┬─────┘     └──────────┘
            │           ▼
            │      ┌──────────┐
            └─────▶│   RUN    │
                   │ RUNNING  │◀──────────────┐
                   └────┬─────┘               │
                        │                     │
              ┌─────────┼─────────┐           │
              ▼         ▼         ▼           │
         ┌────────┐ ┌───────┐ ┌────────┐      │
         │ PAUSED │ │UPGRADE│ │  WAVE  │      │
         │        │ │ PICK  │ │TRANSIT │      │
         └────┬───┘ └───┬───┘ └────┬───┘      │
              │         │          │           │
              ▼         ▼          ▼           │
         ┌────────┐ ┌───────────────────┐      │
         │ RESUME │ │ Next Wave / Boss  │──────┘
         └────────┘ └─────────┬─────────┘
                              │
                    ┌─────────┼─────────┐
                    ▼                   ▼
              ┌──────────┐       ┌──────────┐
              │   WON    │       │   LOST   │
              │(Clear W5)│       │ (HP = 0) │
              └────┬─────┘       └────┬─────┘
                   │                   │
                   └─────────┬─────────┘
                             ▼
                      ┌────────────┐
                      │ RUN RESULT │
                      │ + Rewards  │
                      └──────┬─────┘
                             ▼
                      Quay lại THE HOLLOW
```

---

## 6. Enemy Types — Thiết Kế Sơ Bộ

| Loại | Tên | Hành vi | Cách chết tốt nhất | Wave xuất hiện |
|---|---|---|---|---|
| **Slime** | Cursed Ooze | Chậm, đi thẳng về player | Dễ push, chain starter | Wave 1+ |
| **Skeleton** | Bone Walker | Trung bình, đi theo bầy (flocking) | Lùa cả bầy → altar | Wave 2+ |
| **Wraith** | Soul Wraith | Nhanh, xuyên cột (không xuyên tường) | Timing push khi gần | Wave 3+ |
| **Golem** | Broken Golem | Chậm, chịu 2 hit, nặng (khó push xa) | Wall slam 2 lần | Wave 4+ |
| **Mini-Boss** | Dungeon Warden | HP cao, không thể Altar-seal, tấn công AoE | Wall slam 5 lần + domino damage | Wave 5 |

---

## 7. Tổng Kết Core Loop

### Tần Suất Lặp Mỗi Vòng

| Vòng | Tần suất | Thời gian | Cảm giác chính |
|---|---|---|---|
| **Micro** (Push Cycle) | 30-50 lần/run | 3-8s/lần | Thỏa mãn, action |
| **Meso** (Wave) | 5 lần/run | 45-90s/wave | Adapt, build up |
| **Macro** (Run) | 2-5 lần/ngày | 5-10 min/run | Achievement, story |
| **Meta** (Journey) | Liên tục | Nhiều ngày/tuần | Discovery, completion |

### "Vòng Xoáy Thỏa Mãn" (Satisfaction Spiral)

```
Push → Chain Explosion → "WOW!" → Shards → Upgrade
  → Push MẠNH HƠN → Chain BIGGER → "WOW!!" → More Shards
    → Better Upgrade → Push EVEN STRONGER → MEGA CHAIN
      → "OMG!!!" → Wave Clear → Rune Stones → Permanent Upgrade
        → Next Run START STRONGER → ... (repeat with higher ceiling)
```

> **Đây chính là "ngày càng OP" — Vampire Survivors feel được dịch sang Push mechanic.**

---

*Core Loop đã hoàn chỉnh. Bước tiếp theo: Game Design Document (GDD) — Bước 4.*
