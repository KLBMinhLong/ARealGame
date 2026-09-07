# BƯỚC 2: NGHIÊN CỨU & THAM KHẢO — Stone Knight

**Trạng thái:** Đang thực hiện
**Mục tiêu:** Phân tích sâu các game tham khảo, rút bài học áp dụng cho Stone Knight

---

## 1. Bản Đồ Tham Khảo

Stone Knight nằm ở giao điểm 3 dòng game. Mỗi dòng đóng góp một yếu tố cốt lõi:

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ SURVIVORS-LIKE   │     │ PHYSICS COMBAT   │     │ NARRATIVE        │
│ (Session Model)  │     │ (Core Mechanic)  │     │ ROGUELITE        │
│                  │     │                  │     │ (Retention)      │
│ • Vampire Surv.  │     │ • Peglin         │     │ • Hades          │
│ • Brotato        │     │ • SNKRX          │     │ • Death Must Die │
│ • Halls of Torm. │     │ • Rack and Slay  │     │                  │
└────────┬─────────┘     └────────┬─────────┘     └────────┬─────────┘
         │                        │                         │
         ▼                        ▼                         ▼
    Run ngắn 5-10m         Push + Chain Reaction     Narrative giữa run
    Power fantasy           Arena positioning       Mảnh ký ức / NPC
    Meta-progression        Emergent gameplay       "Failure = Progress"
         │                        │                         │
         └────────────────────────┼─────────────────────────┘
                                  ▼
                           ╔══════════════╗
                           ║ STONE KNIGHT ║
                           ╚══════════════╝
```

---

## 2. Phân Tích Chi Tiết Từng Game Tham Khảo

### 2.1. Vampire Survivors — Bài Học Về Session & Power Fantasy

**Lấy gì:**
| Yếu tố | Cách VS làm | Stone Knight áp dụng |
|---|---|---|
| Power Fantasy Curve | Bắt đầu yếu → cuối run = thần hủy diệt | Wave 1 đẩy 1 con → Wave 5 chain 20 con nổ tung |
| Low Input Complexity | Auto-attack, chỉ cần di chuyển | Chỉ có Move + 1 nút Pulse. Không combo phức tạp |
| "One More Run" | Run ngắn, restart gần tức thì | Run 5-10 phút, restart < 3 giây loading |
| Visual Spectacle | Cuối run = cả màn hình đạn/nổ | Cuối run = chain explosion khắp arena |
| Meta-progression | Mở khóa nhân vật/vũ khí mới giữa run | Mở khóa Pulse type/Altar type/Skin giữa run |

**Không lấy:**
| Yếu tố | Tại sao bỏ |
|---|---|
| Auto-attack | Stone Knight cần timing/positioning chủ động |
| Infinite run (30 phút) | Quá dài cho target casual 5-10 phút |
| Flat arena (không thay đổi) | Stone Knight cần arena dynamics |

---

### 2.2. Brotato — Bài Học Về Decisions & Build Diversity

**Lấy gì:**
| Yếu tố | Cách Brotato làm | Stone Knight áp dụng |
|---|---|---|
| Meaningful Choices | Shop giữa wave = quyết định táctical | Upgrade pick 1/3 giữa wave = quyết định build |
| Wave Structure | Wave ngắn → shop → wave → shop | Wave → (upgrade nếu đủ shard) → wave |
| Character Diversity | 40+ nhân vật khác stats/playstyle | Các loại Pulse khác nhau = playstyle khác |
| Risk/Reward | Items có trade-off (damage+ nhưng HP-) | Altar xa hơn = khó đẩy tới nhưng bonus lớn hơn |

**Không lấy:**
| Yếu tố | Tại sao bỏ |
|---|---|
| Manual aim/shooting | Stone Knight chỉ có push |
| Shop economy (mua/bán) | Quá phức tạp cho v1, có thể thêm sau |

---

### 2.3. Hades — Bài Học Về Narrative & Emotional Investment

**Lấy gì:**
| Yếu tố | Cách Hades làm | Stone Knight áp dụng |
|---|---|---|
| "Failure = Progress" | Chết = về hub, NPC nhớ bạn chết ra sao | Chết = thức dậy trong hub, NPC comment |
| Prioritized Dialogue | Hệ thống bucket: story beat > trigger > flavor | Mảnh ký ức (story) > NPC reaction > flavor text |
| Hub Between Runs | House of Hades = social/story space | "The Hollow" (nơi linh hồn tụ tập) = hub |
| Narrative Reward | Giải mã câu chuyện = reward ngoài gameplay | Phá lời nguyền = mở mảnh ký ức + visual change |
| Meta as Narrative | Upgrade = NPC comment, feels story-driven | Mở khóa Pulse mới = lấy lại 1 mảnh sức mạnh cũ |

**Không lấy:**
| Yếu tố | Tại sao bỏ |
|---|---|
| Hades-level art quality | Tốn quá nhiều chi phí cho solo dev |
| Complex NPC relationship trees | Quá scope cho v1, giữ đơn giản |
| Boon system (chọn god) | Thay bằng hệ thống upgrade pick 1/3 đơn giản hơn |

**Cách đơn giản hóa cho solo dev:**
- Thay vì voice acting → text box ngắn 1-2 dòng
- Thay vì 30+ NPC → 3-5 linh hồn NPC trong hub
- Thay vì dialogue tree → linear story unlock qua mảnh ký ức
- Thay vì hand-painted art → stylized pixel art hoặc clean vector

---

### 2.4. Peglin / SNKRX — Bài Học Về Physics & Chain Reaction

**Lấy gì:**
| Yếu tố | Cách họ làm | Stone Knight áp dụng |
|---|---|---|
| Emergent Gameplay | Physics = mỗi lần kết quả khác nhau | Push + arena layout = mỗi chain khác nhau |
| Visual Chain Feedback | Bouncing ball = trail + particles | Quái va nhau = trail + explosion + screenshake |
| Proportional Juice | Hit lớn = shake lớn, hit nhỏ = shake nhỏ | Chain 1 = nhẹ. Chain 10 = cả màn hình rung |
| Satisfying Audio | Layered sounds (thud + ting + boom) | Wall slam = thud. Chain = cascade ting-ting-BOOM |

---

## 3. Phân Tích "Game Feel" — Anatomy of The Push

### 3.1. Tại Sao "Push" Phải Cảm Giác Đúng

> Push là HÀNH ĐỘNG DUY NHẤT của người chơi. Nếu Push không thỏa mãn, game thất bại. Mọi thứ khác đều phụ thuộc vào Push cảm giác tốt.

### 3.2. Công Thức "Juicy Push" — 6 Lớp Feedback

```
Người chơi nhấn SPACE
        │
        ▼
┌─ Lớp 1: INPUT RESPONSE (0ms)
│   → Golem co lại nhẹ (anticipation)
│
├─ Lớp 2: VISUAL BURST (1-2 frame)
│   → Sóng xung từ lõi ngực bung ra
│   → Hit-stop 2-3 frame (freeze cảm giác nặng)
│
├─ Lớp 3: PHYSICS RESULT (ngay sau)
│   → Quái bắn ra theo hướng push
│   → Tốc độ push tỉ lệ với khoảng cách (gần = mạnh)
│
├─ Lớp 4: IMPACT FEEDBACK (khi quái va chạm)
│   → Wall slam = dust particles + thud SFX + micro-shake
│   → Quái va quái = spark + ting SFX
│   → Altar seal = rune flash + whoosh SFX + bonus VFX
│
├─ Lớp 5: CHAIN REACTION (cascade)
│   → Mỗi va chạm tiếp = SFX pitch tăng dần (ting → TING → TIING)
│   → Screen shake tăng dần theo chain length
│   → Particle cascade ngày càng lớn
│
└─ Lớp 6: REWARD (sau chain)
    → Soul Shards bay ra + collection SFX
    → Combo counter hiện lên (x3! x5! x10!)
    → Upgrade notification nếu đủ shard
```

### 3.3. Tham Số Game Feel Cần Tuning

| Tham số | Ý nghĩa | Giá trị khởi điểm | Ghi chú |
|---|---|---|---|
| Push Radius | Bán kính ảnh hưởng | 100px | Upgrade → 200px max |
| Push Force | Lực đẩy | 200px distance | Upgrade → 400px max |
| Hitstop Duration | Freeze khi push | 50ms (3 frame @60) | Tăng theo chain |
| Screen Shake Intensity | Rung camera | 0.3 (push) → 0.8 (chain 5+) | Trauma² decay |
| Chain Window | Thời gian chain còn active | 0.5s sau va chạm cuối | Quá ngắn = khó chain |
| Shard Magnet Radius | Bán kính hút shard | 80px | Upgrade → 200px |

---

## 4. Phân Tích Meta-Progression — Cách Giữ Chân Lâu Dài

### 4.1. Mô Hình 2 Tầng (Rút từ VS + Brotato + Hades)

**Tầng 1: Power-Based (Sớm) — "Safety Net"**
- Mở khóa sớm, giúp người chơi mới vượt qua difficulty spike
- HP +1, Push Force +5%, Speed +3%
- Giảm frustration, tăng accessibility
- ⚠️ Giới hạn: cap sau ~20 runs, tránh trivialize game

**Tầng 2: Content-Based (Dài hạn) — "Discovery Engine"**
- Mở khóa Pulse types mới (Fire Push, Ice Push, Double Push...)
- Mở khóa Altar types mới (hiệu ứng khác nhau)
- Mở khóa Arena modifiers (biến thể terrain)
- Mở khóa mảnh ký ức / chapters câu chuyện
- Mở khóa Skin = visual lấy lại nhân dạng hiệp sĩ
- ∞ Có thể mở rộng liên tục (DLC, updates)

### 4.2. Retention Calendar Giả Định

```
Ngày 1-3:   Học cơ chế → đạt wave 3 → mở 2-3 power upgrades
Ngày 4-7:   Đạt wave 5 lần đầu → mở Fire Pulse → "WOW mới!"
Tuần 2:     Mở thêm 2 Pulse types → thử build khác nhau
Tuần 3-4:   Unlock story chapters → muốn biết kết thúc
Tháng 2+:   Hoàn thành story → chơi vì build diversity + leaderboard
```

---

## 5. Phân Tích Đối Tượng & Thị Trường

### 5.1. Target Audience Profile

```
Tên: "Lunchbreak Gamer"
Tuổi: 18-30
Platform: PC (Steam), tiềm năng mobile
Thói quen: Chơi 2-4 run/ngày (15-30 phút tổng)
Thích: VS, Brotato, Hades, casual roguelite
Muốn: Thỏa mãn nhanh, có thứ mới để khám phá, không cần commit 2 giờ
Sẵn sàng trả: $5-10 USD (hoặc F2P + cosmetics nếu mobile)
```

### 5.2. Competitive Landscape

| Game | Giống SK | Khác SK | SK có lợi thế gì |
|---|---|---|---|
| **Vampire Survivors** | Wave-based, power fantasy | Auto-attack, 30min run | Active push > passive. Run ngắn hơn |
| **Brotato** | Wave + upgrade pick | Shooting, shop | Push mechanic unique. Simpler economy |
| **Hades** | Narrative, hub, meta | Action RPG, complex combat | Simpler combat. Shorter runs |
| **Peglin** | Physics chain | Turn-based, pachinko | Real-time action. More visceral |

### 5.3. Positioning Statement

> **Stone Knight** dành cho game thủ yêu thích survivors-like nhưng muốn **cơ chế chiến đấu chủ động hơn** (push vs auto-attack), **run ngắn hơn** (5-10 vs 15-30 phút), và **lý do cảm xúc để chơi tiếp** (narrative vs pure grind).

---

## 6. Rủi Ro & Mitigation

| Rủi ro | Mức | Cách giảm thiểu |
|---|---|---|
| Push không "feel" đúng | 🔴 Cao | Dành 60% thời gian greybox cho push feel. Playtest sớm |
| Arena layout tốn thời gian thiết kế | 🟡 TB | Bắt đầu 3-5 template, randomize elements. Không cần proc-gen |
| Narrative tốn resource (viết, NPC) | 🟡 TB | V1: 3 NPC, 20 mảnh ký ức. Giữ tối giản, thêm sau |
| Scope creep (muốn thêm feature) | 🔴 Cao | LUÔN quay lại concept pitch: "Có phục vụ Push + Chain không?" |
| Market đã bão hòa survivors | 🟡 TB | USP rõ (Push unique). Marketing bằng GIF combo chain |

---

## 7. Bảng Tham Khảo Nhanh — "Cheat Sheet"

| Khi cần quyết định về... | Tham khảo game... | Cụ thể cái gì |
|---|---|---|
| Session length & pacing | Vampire Survivors, Brotato | Wave structure, run timing |
| Push feel & physics | SNKRX, Peglin | Force, hitstop, chain feedback |
| Upgrade pick UI | Vampire Survivors, Brotato | Card selection UX |
| Meta-progression structure | Hades, Vampire Survivors | Hub flow, unlock pacing |
| Narrative delivery | Hades | Dialogue bucket system, NPC reactions |
| Art style reference | Hades (tone), Brotato (simplicity) | Tương phản màu + clean sprites |
| Sound design | SNKRX, Archvale | Impact layering, chain audio cascade |
| Arena/Level variety | Enter the Gungeon, Hades rooms | Room templates + randomized elements |

---

*Nghiên cứu đã đủ sâu. Bước tiếp theo: Thiết kế Core Loop chi tiết (Bước 3).*
