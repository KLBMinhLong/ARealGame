# BƯỚC 5: SCOPE & NỀN TẢNG — Stone Knight

**Trạng thái:** ĐÃ CHỐT
**Mục tiêu:** Xác định chính xác PHẠM VI v1.0, cắt mọi thứ không cần thiết, đảm bảo game có thể hoàn thành

> **Nguyên tắc an toàn:** *Cắt giảm scope đến khi bạn thấy "hơi ít" thì mới vừa đủ.*

---

## 1. Platform & Technical Specs

### 1.1. Platform Mục Tiêu

| Mục | Quyết định |
|---|---|
| **Primary** | PC — Windows (Steam) |
| **Secondary** | Linux, macOS (Godot export sẵn) |
| **Future** | Mobile (Android/iOS) — SAU khi PC hoàn chỉnh |
| **Engine** | Godot 4.x (stable mới nhất khi bắt đầu code) |
| **Language** | GDScript |
| **Renderer** | GL Compatibility (rộng nhất, phù hợp 2D pixel) |

### 1.2. Performance Target

| Metric | Target | Ghi chú |
|---|---|---|
| Resolution | 1920×1080 (native render 480×270, scale 4x) | Pixel-perfect |
| FPS | 60 FPS stable | 2D pixel art, không nặng |
| RAM | < 200 MB | Nhẹ |
| VRAM | < 50 MB | Pixel art nhỏ |
| Min Spec | Intel HD 4000 / 4GB RAM / Win 7+ | Rất phổ thông |
| Load Time | < 3s total (launch → menu) | Instant restart |
| File Size | < 100 MB | Pixel art + synth audio |

### 1.3. Viewport & Rendering

| Param | Value |
|---|---|
| Internal Resolution | 480×270 px |
| Scale Factor | 4x (→ 1920×1080) |
| Stretch Mode | canvas_items |
| Stretch Aspect | keep |
| Filter | Nearest-neighbor |
| Tile Size | 30×30 px (16×9 grid = 480/30 × 270/30) |
| Arena Playable | 420×240 px (14×8 tiles, border 1 tile) |

---

## 2. Scope Definition — CÁI GÌ CÓ, CÁI GÌ KHÔNG

### 2.1. ✅ V1.0 — Minimum Viable Game (MVG)

> Bản nhỏ nhất có thể release Early Access trên Steam.

**CORE (Bắt buộc — game không chơi được nếu thiếu):**

| Feature | Chi tiết | Ước lượng |
|---|---|---|
| Player movement | WASD, 8-hướng, boundary clamp | 1 ngày |
| Arcane Pulse | Push mechanic đầy đủ (radius, force, cooldown) | 3 ngày |
| Push Physics | Wall slam, domino, altar seal, pit fall | 5 ngày |
| Chain Reaction | Chain detection, window, depth limit | 3 ngày |
| 3 Enemy types | Slime, Skeleton, Wraith (Golem CẮT v1) | 4 ngày |
| Wave System | 5 waves, timer, spawn rules | 3 ngày |
| Arena (1 layout set) | 5 wave layouts cố định (không random v1) | 2 ngày |
| Soul Shards | Drop, magnet, collection | 1 ngày |
| Upgrade Pick | 1/3 cards, 6 upgrades (CẮT 5 cái) | 3 ngày |
| Mini-Boss | Wave 5 boss cơ bản | 3 ngày |
| HP & Death | Player HP, grace period, death state | 1 ngày |
| **Subtotal Core** | | **29 ngày** |

**UI (Bắt buộc — không thể phát hành nếu thiếu):**

| Feature | Chi tiết | Ước lượng |
|---|---|---|
| Main Menu | Start, Settings, Quit | 1 ngày |
| HUD | HP, Wave, Pulse CD, Shards, Timer | 2 ngày |
| Pause Menu | Resume, Restart, Quit | 0.5 ngày |
| Upgrade Pick UI | 3 card display, selection | 1.5 ngày |
| Wave Transition | Clear text, arena morph animation | 1 ngày |
| Victory/Defeat Screen | Stats, rewards, buttons | 1 ngày |
| Settings Screen | Volume (Master/Music/SFX), Fullscreen | 1 ngày |
| **Subtotal UI** | | **8 ngày** |

**FEEL (Bắt buộc — game "sống" hay "chết" tùy phần này):**

| Feature | Chi tiết | Ước lượng |
|---|---|---|
| Screen Shake | Trauma-based, proportional | 1 ngày |
| Hit-stop | Freeze frame on push/chain | 0.5 ngày |
| Particle VFX | Push ring, wall dust, altar seal flash, shard sparkle | 3 ngày |
| Combo Counter | Pop-up x2, x3, x5... | 0.5 ngày |
| Audio SFX | 8 core SFX (push, slam, seal, chain, pickup, hit, death, wave) | 3 ngày |
| Music | 2 tracks minimum (menu, gameplay) | 2 ngày |
| **Subtotal Feel** | | **10 ngày** |

**META (Quan trọng — giữ chân người chơi):**

| Feature | Chi tiết | Ước lượng |
|---|---|---|
| The Hollow (Hub) | Simple hub, 1 NPC placeholder | 2 ngày |
| Rune Stones currency | Earn + spend | 1 ngày |
| Rune Forge | 6 permanent upgrades (CẮT 9 cái) | 2 ngày |
| Save/Load | JSON, best run, total stats, unlocks | 2 ngày |
| **Subtotal Meta** | | **7 ngày** |

**TỔNG V1.0 MVG: ~54 ngày phát triển**

---

### 2.2. ❌ CẮT BỎ khỏi V1.0 (Thêm sau)

> [!WARNING]
> Mọi feature dưới đây đều HAY nhưng KHÔNG CẦN cho bản đầu tiên. Thêm sau khi core đã vững.

| Feature | Lý do cắt | Thêm khi nào |
|---|---|---|
| ~~Broken Golem (enemy type 4)~~ | 3 loại quái đủ cho 5 wave v1 | v1.1 |
| ~~5 in-run upgrades (Flame, Ice, Chain, Shield, Altar Res.)~~ | 6 upgrade đủ variety cho v1 | v1.1-v1.2 |
| ~~9 permanent upgrades~~ | 6 đủ motivation, thêm = thêm balancing | v1.1+ |
| ~~Randomized arena layouts~~ | Layout cố định đủ cho v1, random = bugs | v1.2 |
| ~~Memory Wall (story collection)~~ | Text giữ ở NPC dialogue, không cần gallery | v1.2 |
| ~~Soul Mirror (skins)~~ | Cosmetics = nice to have, không core | v1.3 |
| ~~10 story chapters~~ | 3-4 chapters đủ cho EA | v1.1-v2.0 |
| ~~3 NPCs full dialogue~~ | 1 NPC đủ cho v1 | v1.1 |
| ~~Life Altar~~ | 1 loại Altar đủ | v1.1 |
| ~~Rune Pillar ricochet~~ | Nice mechanic nhưng complex | v1.2 |
| ~~Void Pull (reverse push)~~ | Phức tạp, cần balance riêng | v1.3 |
| ~~Mobile port~~ | PC trước, mobile sau | v2.0 |
| ~~Leaderboard/Online~~ | Offline first | v2.0 |
| ~~Multiple dungeon themes~~ | 1 theme đủ cho EA | v1.2+ |
| ~~Tutorial system~~ | Wave 1 tự là tutorial | v1.1 |
| ~~Achievements~~ | Steam achievements sau | v1.2 |

### 2.3. V1.0 MVG — Tóm Tắt Scope

```
V1.0 BÁN ĐƯỢC GỒM:
─────────────────────
• 1 nhân vật (Stone Knight)
• 1 loại Pulse (base Arcane)
• 3 loại quái + 1 Boss
• 5 waves cố định / run
• 6 in-run upgrades
• 6 permanent upgrades
• 1 Hub đơn giản + 1 NPC
• 3-4 mảnh ký ức
• 2 nhạc nền + 8 SFX
• Main Menu, HUD, Settings, Pause, Results
• Save/Load
• Full game feel (shake, hitstop, VFX, particles)

TUYỆT ĐỐI KHÔNG CÓ:
─────────────────────
• Multiple characters
• Multiple Pulse types
• Multiple dungeon themes
• Online features
• Mobile port
• Crafting/inventory
• Shop/economy phức tạp
```

---

## 3. Tool Pipeline

### 3.1. Development Tools

| Mục đích | Tool | Ghi chú |
|---|---|---|
| **Engine** | Godot 4.x | Free, open-source |
| **Code** | GDScript + Antigravity IDE | Built-in editor |
| **Version Control** | Git + GitHub/GitLab | Private repo |
| **Pixel Art** | Aseprite ($20) HOẶC LibreSprite (free) | Animation support |
| **Tilemap** | Godot TileMap (built-in) HOẶC LDtk (free) | Level design |
| **Audio SFX** | sfxr/jsfxr (free) + Audacity (free) | Procedural → polish |
| **Music** | Chọn 1: License track / AI gen / Commission | Tùy budget |
| **Task Management** | Markdown TODO trong repo HOẶC Trello | KISS |
| **Playtesting** | Record video + note | Không cần tool fancy |

### 3.2. Asset Pipeline

```
ART:
  Concept sketch (giấy/digital)
  → Pixel art in Aseprite (24x24 hoặc 32x32)
  → Export PNG spritesheet
  → Import Godot (AnimatedSprite2D hoặc SpriteFrames)
  → Configure animations (idle, move, pulse, hit...)

AUDIO:
  Design sound (mô tả bằng text)
  → Generate with sfxr/jsfxr (SFX) hoặc source music
  → Polish in Audacity (EQ, normalize, trim)
  → Export .wav (SFX) hoặc .ogg (music)
  → Import Godot → AudioStreamPlayer
  → Assign to bus (SFX/Music)

LEVELS:
  Design on grid paper / markdown
  → Build in Godot scene editor (hoặc LDtk → export)
  → Place arena elements (walls, altars, pits, spawns)
  → Test play → adjust
```

### 3.3. Folder Structure (Target)

```
Stone_Knight/
├── project.godot
├── default_bus_layout.tres
│
├── assets/
│   ├── art/
│   │   ├── player/           # Stone Knight sprites
│   │   ├── enemies/          # Enemy sprites
│   │   ├── arena/            # Tiles, walls, altars
│   │   ├── ui/               # HUD icons, buttons
│   │   ├── vfx/              # Particle textures
│   │   └── hub/              # The Hollow backgrounds
│   ├── audio/
│   │   ├── sfx/              # Sound effects .wav
│   │   └── music/            # Music tracks .ogg
│   └── fonts/                # UI fonts .ttf
│
├── scenes/
│   ├── main.tscn             # Game orchestrator
│   ├── player.tscn           # Player character
│   ├── enemies/
│   │   ├── slime.tscn
│   │   ├── skeleton.tscn
│   │   ├── wraith.tscn
│   │   └── boss.tscn
│   ├── arena/
│   │   ├── arena_base.tscn   # Base arena
│   │   └── elements/         # Altar, pit, pillar, spike
│   ├── ui/
│   │   ├── hud.tscn
│   │   ├── main_menu.tscn
│   │   ├── pause_menu.tscn
│   │   ├── upgrade_pick.tscn
│   │   ├── result_screen.tscn
│   │   └── settings.tscn
│   ├── hub/
│   │   └── hollow.tscn       # The Hollow hub
│   └── vfx/
│       ├── pulse_ring.tscn
│       ├── wall_dust.tscn
│       └── shard_sparkle.tscn
│
├── scripts/
│   ├── main.gd               # Game state machine
│   ├── actors/
│   │   ├── player.gd
│   │   └── enemies/
│   │       ├── enemy_base.gd # Base enemy class
│   │       ├── slime.gd
│   │       ├── skeleton.gd
│   │       ├── wraith.gd
│   │       └── boss.gd
│   ├── world/
│   │   ├── arena.gd
│   │   ├── altar.gd
│   │   ├── pit.gd
│   │   └── spike_wall.gd
│   ├── systems/
│   │   ├── push_system.gd    # Push physics logic
│   │   ├── chain_system.gd   # Chain reaction detection
│   │   ├── wave_manager.gd   # Wave state & spawn
│   │   ├── upgrade_manager.gd
│   │   └── loot_system.gd    # Shard drop & collection
│   ├── core/
│   │   ├── game_config.gd    # All constants
│   │   ├── save_manager.gd
│   │   ├── settings_manager.gd
│   │   └── audio_manager.gd
│   └── ui/
│       ├── hud.gd
│       ├── main_menu.gd
│       ├── pause_menu.gd
│       ├── upgrade_pick.gd
│       ├── result_screen.gd
│       └── settings_screen.gd
│
├── data/
│   ├── upgrades.json         # Upgrade definitions
│   ├── enemies.json          # Enemy stats
│   ├── waves.json            # Wave configurations
│   └── story.json            # Story text & triggers
│
├── docs/                     # Design documents (hiện tại)
│   ├── 01_CONCEPT_PITCH.md
│   ├── 02_RESEARCH_REFERENCES.md
│   ├── 03_CORE_LOOP.md
│   ├── 04_GDD.md
│   ├── 05_SCOPE.md           # File này
│   ├── 06_PROGRESSION.md
│   ├── 07_PRODUCTION_PLAN.md
│   └── 08_GREYBOX.md
│
└── tests/                    # Test scripts (isolated)
```

---

## 4. V1.0 In-Run Upgrades (Sau Khi Cắt)

Chỉ giữ **6 upgrades** cho v1.0 — đủ variety, ít balance work:

| ID | Name | Category | Effect/tier | Max |
|---|---|---|---|---|
| UPG_FORCE | Heavy Push | Offensive | Push velocity +30% | 3 |
| UPG_RADIUS | Wider Reach | Offensive | Push radius +40% | 3 |
| UPG_ECHO | Echo Pulse | **Offensive (Behavior)** | **Pulse lặp lại yếu hơn sau 0.4s delay (40% velocity, 60% radius). Tier 2: delay 0.3s. Tier 3: 60% velocity.** | 3 |
| UPG_HP | Stone Heart | Defensive | Max HP +1 | 2 |
| UPG_SPEED | Swift Stone | Defensive | Move speed +15% | 3 |
| UPG_CD | Quick Charge | Utility | Push cooldown -20% | 3 |

> ⚠️ **Sửa lỗi E:** UPG_MAGNET (Soul Magnet) bị thay bằng **UPG_ECHO (Echo Pulse)** — upgrade đổi HÀNH VI chơi, không chỉ tăng chỉ số. Echo Pulse tạo cơ hội chain mới (double push = positioning khác) thay vì chỉ hút shard xa hơn.

## 5. V1.0 Permanent Upgrades (Sau Khi Cắt)

Chỉ giữ **6 permanents** — đơn giản, rõ ràng:

| ID | Name | Cost (RS) | Effect |
|---|---|---|---|
| PERM_HP1-3 | Stone Body I-III | 10/25/60 | Base HP +1 per tier |
| PERM_FORCE1-2 | Heavy Core I-II | 15/40 | Base push force +10% |
| PERM_SPEED1-2 | Quick Feet I-II | 15/40 | Base move speed +8% |
| PERM_CD1-2 | Charged Core I-II | 20/50 | Base cooldown -0.3s |
| PERM_MAGNET | Soul Attunement | 30 | Base shard radius +30% |
| PERM_WAVE_BONUS | Dungeon Insight | 45 | +20% Rune Stones earned |

**Tổng RS cần cho 100% v1:** 350 RS (10+25+60 + 15+40 + 15+40 + 20+50 + 30 + 45)
**Runs trung bình:** ~30-35 runs (~4-6 giờ chơi, ~12 RS/run trung bình)

> ⚠️ **Sửa lỗi F:** Trước đó ghi ~410 RS — sai phép cộng. Đúng là **350 RS**.

---

## 6. Risk Assessment — V1.0

| Rủi ro | Mức | Mitigation |
|---|---|---|
| Push feel không đủ thỏa mãn | 🔴 | Greybox push TRƯỚC MỌI THỨ. 2 tuần đầu chỉ làm push. |
| Scope creep (muốn thêm feature) | 🔴 | Checklist này là pháp luật. Mọi addition → next version. |
| Art tốn quá nhiều thời gian | 🟡 | Bắt đầu greybox. Art polish SAU khi gameplay vui. |
| Cân bằng quái/upgrade khó | 🟡 | Config-driven (JSON). Playtest sớm, chỉnh nhanh. |
| Burnout (1 người làm quá lâu) | 🟡 | Milestone nhỏ. Celebrate mỗi milestone. Nghỉ ngơi. |
| Game không đủ hay để bán | 🟡 | Playtest người ngoài ở greybox stage. Pivot sớm nếu cần. |

---

## 7. Tóm Tắt Quyết Định Scope

### V1.0 = "Vertical Slice Có Thể Bán"

```
┌─────────────────────────────────────────┐
│           STONE KNIGHT v1.0              │
│                                          │
│  1 Character × 1 Pulse × 3 Enemies      │
│  + 1 Boss × 5 Fixed Waves               │
│  + 6 In-Run Upgrades                     │
│  + 6 Permanent Upgrades                  │
│  + 1 Simple Hub + 1 NPC                  │
│  + 3-4 Story Fragments                   │
│  + Full Game Feel (VFX, SFX, Shake)      │
│  + Save/Load + Settings                  │
│  + Menu, HUD, Pause, Results             │
│  ─────────────────────────────────       │
│  = 54 dev days estimated                 │
│  = $5-8 Steam Early Access              │
│  = "Short, sweet, satisfying"            │
└─────────────────────────────────────────┘
```

---

*Scope đã cắt. Bước tiếp theo: Thiết kế trải nghiệm & progression chi tiết (Bước 6).*
