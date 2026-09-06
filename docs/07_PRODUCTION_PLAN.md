# BƯỚC 7: KẾ HOẠCH SẢN XUẤT — Stone Knight

**Trạng thái:** ĐÃ CHỐT
**Tổng ước lượng:** ~54 ngày phát triển (dev days)
**Milestone:** 5 giai đoạn (Greybox → Alpha → Beta → RC → Release)

---

## 1. Production Milestones

### Tổng Quan Timeline

```
        M0          M1          M2           M3           M4
        │           │           │            │            │
   GREYBOX      ALPHA       BETA       RELEASE       POST-
   (2 tuần)     (3 tuần)    (3 tuần)   CANDIDATE     LAUNCH
                                        (1 tuần)      (∞)
        │           │           │            │            │
   Push feel    Gameplay    Polish       Bug fix      Content
   Core loop    complete    Art/Audio    Final test   updates
        ▼           ▼           ▼            ▼            ▼
   "Có vui      "Chơi       "Nhìn        "Không      "Thêm
    không?"      được"       đẹp"         bug"        nội dung"
```

---

## 2. M0 — GREYBOX (Tuần 1-2, ~10 ngày)

> **Mục tiêu: Trả lời câu hỏi "PUSH CÓ VUI KHÔNG?"**
> Nếu push không vui ở greybox → PIVOT trước khi đầu tư art/audio.

### Deliverables

| Task | Chi tiết | Ngày | Priority |
|---|---|---|---|
| Project setup | Godot project, folder structure, git | 0.5 | 🔴 |
| Player movement | WASD, 8 hướng, boundary, responsive | 1 | 🔴 |
| **Push mechanic** | Radius, force, cooldown, radial push | **3** | 🔴 |
| **Push physics** | Wall slam, entity collision, force transfer | **3** | 🔴 |
| Chain detection | Chain window, depth counting, combo | 1.5 | 🔴 |
| Basic enemies | 1 type (Slime), move toward player | 1 | 🔴 |
| Placeholder arena | Rectangle with walls, 1 altar zone | 0.5 | 🔴 |
| Shard drop/collect | Drop on kill, magnet pickup | 0.5 | 🟡 |

**Total: ~11 ngày (buffer = 10 days target)**

### Greybox Visual Style
```
Player:     Hình vuông xanh cyan 16×16 px
Enemy:      Hình tròn đỏ 12×12 px
Wall:       Hình chữ nhật xám
Altar:      Hình tròn tím (zone)
Pulse:      Vòng tròn trắng expanding
Shard:      Chấm vàng nhỏ
```

### M0 Gate — Câu Hỏi Phải Trả Lời

| # | Câu hỏi | Pass criteria |
|---|---|---|
| 1 | Push có thỏa mãn? | Tự mình muốn push thêm |
| 2 | Chain có WOW? | Chain x5+ tạo cảm giác "cool!" |
| 3 | Wall slam có đã? | Nghe/thấy quái đập tường = thỏa mãn |
| 4 | Altar seal có rõ? | Biết rõ khi nào quái bị seal |
| 5 | Muốn chơi lại? | Sau 5 phút, tự bấm restart |

**Nếu 3/5 = NO → dừng lại, điều chỉnh push feel trước khi tiếp.**

---

## 3. M1 — ALPHA (Tuần 3-5, ~15 ngày)

> **Mục tiêu: Gameplay hoàn chỉnh, chơi được từ đầu đến cuối.**
> Vẫn greybox art. Chưa polish.

### Deliverables

| Task | Chi tiết | Ngày | Priority |
|---|---|---|---|
| Wave system | 5 waves, timer, spawn, transitions | 3 | 🔴 |
| 3 enemy types | Slime + Skeleton (flock) + Wraith (fast) | 2 | 🔴 |
| Mini-Boss | Warden: HP, AoE slam, heavy push weight | 2 | 🔴 |
| 5 arena layouts | Cố định per wave (xem Bước 6) | 1.5 | 🔴 |
| Arena elements | Spike wall, pit, rune pillar | 1 | 🔴 |
| Upgrade system | 6 upgrades, pick 1/3 UI, apply effects | 2 | 🔴 |
| HP & death | Player HP, grace period, game over state | 0.5 | 🔴 |
| HUD | HP, wave, CD, shards, timer, chain counter | 1.5 | 🟡 |
| Menus | Main menu, pause, result screen (basic) | 1.5 | 🟡 |

**Total: ~15 ngày**

### M1 Gate

| # | Câu hỏi | Pass criteria |
|---|---|---|
| 1 | Có thể chơi full run 5 wave? | Không crash, không soft-lock |
| 2 | Difficulty curve cảm giác đúng? | Wave 1 dễ, Wave 5 khó |
| 3 | Upgrades có impact? | Thấy rõ khác biệt sau upgrade |
| 4 | Boss fight có tension? | Đánh boss khác vs quái thường |
| 5 | "One more run" feeling? | Tự muốn chơi lại sau thua |

---

## 4. M2 — BETA (~23.5 ngày dev)

> **Mục tiêu: Art, audio, meta-progression, polish. Game trông đẹp & nghe hay.**

### Deliverables

| Task | Chi tiết | Ngày | Priority |
|---|---|---|---|
| **Art: Player sprites** | Stone Knight 6 states (idle/move/pulse/hit/up/die) | 3 | 🔴 |
| **Art: Enemy sprites** | 3 enemies + Boss, 3 states mỗi loại (idle/move/die) | 3 | 🔴 |
| **Art: Arena tileset** | Floor, walls, spike, altar, pit, pillar | 2 | 🔴 |
| **Art: UI elements** | Hearts, shard icon, upgrade cards, buttons | 1 | 🔴 |
| **Art: VFX** | Pulse ring, wall dust, seal flash, chain spark, shard sparkle | 2 | 🟡 |
| **Audio: SFX** | 8 core sounds | 2 | 🔴 |
| **Audio: Music** | 2 tracks (menu + gameplay) | 1.5 | 🔴 |
| **Game Feel** | Screen shake, hitstop, combo counter, particles | 2 | 🔴 |
| **Meta: Hub** | The Hollow basic (background + Forge + NPC) | 1.5 | 🟡 |
| **Meta: Rune Forge** | 6 permanent upgrades, buy UI | 1.5 | 🟡 |
| **Meta: Save/Load** | JSON save, auto-save, load on start | 1.5 | 🟡 |
| **Meta: NPC dialogue** | Blacksmith 8-10 lines, trigger system | 1 | 🟡 |
| **Narrative** | 3-4 memory fragments, trigger on clear | 0.5 | 🟡 |
| **Settings** | Volume sliders, fullscreen, reduced effects | 1 | 🟡 |

**Total: 23.5 ngày** (con số thật, không nén)

### M2 Gate

| # | Câu hỏi | Pass criteria |
|---|---|---|
| 1 | Art style nhất quán? | Tất cả sprites cùng palette/style |
| 2 | Audio thêm feel? | Push "nghe" mạnh, chain "nghe" thỏa mãn |
| 3 | Meta-progression hoạt động? | Earn RS → buy upgrade → effect in next run |
| 4 | Save/Load stable? | Quit + relaunch = data còn |
| 5 | Sẵn sàng cho người ngoài test? | Không crash, không confusing, không ugly |

---

## 5. M3 — RELEASE CANDIDATE (Tuần 9, ~5 ngày)

> **Mục tiêu: Bug fix, balance, final polish. Sẵn sàng ship.**

### Deliverables

| Task | Chi tiết | Ngày | Priority |
|---|---|---|---|
| Bug fixing | Tất cả known bugs | 2 | 🔴 |
| Balance pass | Chỉnh số (HP, force, speed, spawn rate) | 1 | 🔴 |
| Edge cases | Save corruption, fullscreen toggle, alt-tab | 0.5 | 🔴 |
| Windows export | Build .exe, test standalone | 0.5 | 🔴 |
| Final playtest | 3-5 full runs, verify flow | 0.5 | 🔴 |
| Steam prep | Store page, screenshots, description | 0.5 | 🟡 |

**Total: ~5 ngày**

### M3 Gate — Ship Checklist

| # | Check | Status |
|---|---|---|
| 1 | Chơi được 10 run liên tục không crash | ⬜ |
| 2 | Save/load hoạt động qua restart | ⬜ |
| 3 | Settings persist | ⬜ |
| 4 | Windows export chạy standalone | ⬜ |
| 5 | Không bug chặn gameplay | ⬜ |
| 6 | Người ngoài hiểu cách chơi không cần giải thích | ⬜ |
| 7 | Người ngoài muốn chơi lại | ⬜ |

---

## 6. Tổng Hợp Timeline

> ⚠️ **Sửa lỗi F:** Đây là **giả định lập kế hoạch**, không phải cam kết phát hành.
> AI có thể rút ngắn một số công việc code, nhưng thời gian sửa lỗi, tích hợp asset
> và playtest không tự động giảm theo.

```
Tuần 1-2:    M0 GREYBOX     │ Push feel + core loop         (11 ngày)
Tuần 3-5:    M1 ALPHA       │ Full gameplay, 5 waves, boss  (15 ngày)
Tuần 6-10:   M2 BETA        │ Art, audio, meta, polish      (23.5 ngày)
Tuần 11:     M3 RC          │ Bug fix, balance, ship prep   (5 ngày)
             ───────────────────────────────────────────
             SUBTOTAL TASKS: 54.5 ngày
             BUFFER (10%):   ~6 ngày
             TOTAL:          ~61 ngày → ~12 tuần (giả định lập kế hoạch)
```

### Dev Days Breakdown

| Milestone | Task Days | Buffer | Total | Cumulative |
|---|---|---|---|---|
| M0 Greybox | 11 | — | 11 | 11 |
| M1 Alpha | 15 | — | 15 | 26 |
| M2 Beta | 23.5 | — | 23.5 | 49.5 |
| M3 RC | 5 | — | 5 | 54.5 |
| Buffer | — | 6 | 6 | **60.5** |
| **Total** | **54.5** | **6** | **~61 dev days** | |


---

## 7. Post-Launch Roadmap (V1.1+)

| Version | Content | Estimated |
|---|---|---|
| **v1.1** | +Broken Golem (enemy) +Flame Pulse +3 upgrades +3 story chapters | 2 tuần |
| **v1.2** | +Frost Pulse +Randomized arena +Life Altar +Achievements | 2 tuần |
| **v1.3** | +Storm Pulse +Void Pull +Skins (3) +Full story (10 chapters) | 3 tuần |
| **v2.0** | +2 NPC thêm +Dungeon theme 2 +Difficulty modes +Mobile port | 4+ tuần |

---

## 8. Task Management

### Công Cụ

- **Primary:** Markdown checklist trong repo (`docs/TASKS.md`)
- **Backup:** Trello board (nếu cần visual)
- **Git:** Commit mỗi feature hoàn thành, tag mỗi milestone

### Quy Tắc

1. **1 task/ngày target** — không multi-task nhiều feature
2. **Feature branch** — mỗi feature 1 branch, merge khi done
3. **Playtest mỗi 3 ngày** — chơi thử 3-5 run, ghi note
4. **Không thêm feature** ngoài scope v1.0 trừ khi CẮT feature khác
5. **Nghỉ 1 ngày/tuần** — burnout prevention

---

*Kế hoạch sản xuất hoàn chỉnh. Bước cuối: Paper prototype / Greybox plan (Bước 8).*
