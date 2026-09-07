# STONE KNIGHT — Concept Pitch v1.0

**Trạng thái:** ĐÃ CHỐT (Bước 1 hoàn thành)
**Ngày chốt:** 06/09/2026
**Thể loại:** Fantasy Arena Action Roguelite (Survivors-like variant)
**Platform mục tiêu:** PC (Steam) — tiềm năng mobile sau
**Engine:** Godot 4.x, GDScript

---

## Elevator Pitch

> *Bạn từng là một hiệp sĩ. Giờ bạn là một khối đá.*
>
> *Bị nguyền hóa đá, mất khả năng cầm kiếm — thứ duy nhất còn lại là một lực đẩy cổ đại ẩn trong lõi đá. Dùng nó để hất bầy quái vật vào bàn thờ phong ấn, vào tường gai, và vào chính nhau. Mỗi Altar bị phá hé lộ một mảnh ký ức về con người bạn từng là. Mỗi run đưa bạn gần hơn đến việc phá lời nguyền.*

**Một câu marketing:**
> *"Push. Shatter. Remember."*

---

## 1. Ý Tưởng Cốt Lõi

### 1.1. The Hook — Tại Sao Phải Chơi Game Này?

**"Game survivors duy nhất mà vũ khí chính là ĐẨY."**

Không bắn, không chém. Đẩy quái vào bàn thờ phong ấn, vào tường gai, vào nhau — combo chain explosion. Mỗi run 5-10 phút, mỗi run mạnh hơn, mỗi run hé lộ thêm câu chuyện.

### 1.2. USP (Unique Selling Points)

| # | USP | Tại sao unique |
|---|---|---|
| 1 | **"Push, Don't Shoot"** | Không game survivors nào dùng "đẩy" làm combat chính |
| 2 | **Arena thay đổi layout mỗi wave** | Positioning strategy liên tục phải adapt |
| 3 | **Chain Reaction Physics** | Combo nổ dây chuyền = emergent gameplay + GIF viral |
| 4 | **Cursed Knight narrative** | Cơ chế đẩy = hệ quả tự nhiên của lời nguyền, không phải gimmick |

### 1.3. Cảm Giác Chơi Mục Tiêu (Target Feel)

- **Power Fantasy:** Wave 1 = đẩy 1 con, chật vật. Wave 5 = một phát Pulse nổ tung cả phòng.
- **Satisfaction:** Combo chain 10 con nổ liên hoàn = cảm giác pinball/billiards.
- **Narrative Drive:** "Thêm 1 run nữa" không chỉ vì gameplay, mà vì muốn biết tiếp câu chuyện.
- **"Just one more run":** Run ngắn 5-10 phút → dễ nói "chơi thêm 1 lần" → retention.

---

## 2. Nhân Vật Chính — The Stone Knight

### 2.1. Backstory

Một hiệp sĩ (hoặc chiến binh) bị lời nguyền biến toàn thân thành đá. Mắc kẹt trong thân xác Golem, mất khả năng cầm nắm vũ khí — tay đã hóa đá cục mịch. Thứ duy nhất còn hoạt động là lõi rune cổ đại ẩn trong ngực, tạo ra lực đẩy (Arcane Pulse).

**Tại sao thiết kế này hay:**
- Giải thích TỰ NHIÊN tại sao chỉ có "đẩy" (tay đá không cầm được gì)
- Tạo động lực nhập vai mạnh (người chơi muốn cứu con người bên trong)
- Khớp hoàn hảo với "ngày càng OP" (mạnh hơn = gần phá lời nguyền hơn)
- Meta-progression = dần lấy lại nhân dạng (skin/ability = mảnh ký ức)

### 2.2. Tạo Hình — Semi-Chibi Với Chiều Sâu

**KHÔNG** thuần chibi dễ thương → giữ tính bi kịch "con người mắc kẹt".

**Phong cách:**
- Tỉ lệ hơi chibi (đầu hơi to hơn thân) — phù hợp top-down, dễ animate, thân thiện
- Vết nứt phát sáng hình giáp trụ trên bề mặt đá → gợi nhân dạng hiệp sĩ cũ
- Mảnh mũ giáp/vương miện còn sót trên đầu đá → dấu vết quá khứ
- Ánh mắt le lói qua khe nứt → có linh hồn bên trong, không phải đá vô tri
- Lõi rune phát sáng ở ngực → nguồn sức mạnh Pulse

**Kết quả:** Vừa giữ sự dễ marketing của tạo hình compact, vừa không mất chiều sâu cảm xúc.

### 2.3. Trạng Thái Diễn Hoạt (Animation States)

| State | Mô tả |
|---|---|
| IDLE | Đá rung nhẹ, vết nứt nhấp nháy ánh sáng, mảnh mũ giáp lung lay |
| MOVE | Bước nặng nề kiểu đá (ground impact nhẹ), vệt rune sáng kéo theo |
| PULSE | Co lại → BÙM sóng xung từ lõi ngực, vết nứt bừng sáng |
| HIT | Đá vỡ vụn rồi tái tạo, ánh mắt chớp đỏ |
| POWER UP | Vết nứt giáp trụ sáng rực hơn, mảnh giáp hiện rõ hơn |
| DEFEAT | Đá vỡ, thoáng thấy bóng hình hiệp sĩ bên trong trước khi tan |

---

## 3. Thế Giới & Setting

### 3.1. Bối Cảnh

**Ngục Tối Cổ Đại (The Cursed Dungeon)** — nơi lời nguyền bắt nguồn. Nhiều tầng, mỗi tầng có theme riêng.

### 3.2. Tone & Atmosphere

**Dark Fantasy + Semi-Cute + Tương Phản Màu Mạnh (Hades-inspired)**

```
Nền tối: Đá xám, ngục tối mục nát, bóng đổ dày
Điểm sáng: Rune phát quang (xanh/tím/vàng) — chức năng
Quái vật: Stylized, rõ silhouette, đọc được hành vi qua hình
Cảm giác: Mysterious, bi tráng nhưng không u ám, có khoảnh khắc ấm
```

**Không phải:**
- ❌ Dark Souls (quá grim, quá khó)
- ❌ Candy Crush (quá trẻ con)
- ❌ Hades-level art detail (quá tốn chi phí cho solo dev)

**Mà là:**
- ✅ Tinh thần tương phản màu của Hades
- ✅ Đối thoại ngắn giữa các run (hé lộ lời nguyền)
- ✅ Đơn giản hóa art cho phù hợp solo/nhóm nhỏ

### 3.3. Kể Chuyện Qua Gameplay

- Mỗi Altar phong ấn bị phá → giải phóng **một mảnh ký ức** (1-2 dòng thoại ngắn về quá khứ hiệp sĩ)
- Giữa các run → **NPC linh hồn** bị mắc kẹt trong ngục cũng dần hé lộ thông tin về lời nguyền
- Meta-progression = dần phá lời nguyền = dần lấy lại nhân dạng (visual + narrative)

---

## 4. Cơ Chế Gameplay Cốt Lõi

### 4.1. The Push — Arcane Pulse

| Yếu tố | Chi tiết |
|---|---|
| Input | Space / Tap (mobile tương lai) |
| Hiệu ứng | Đẩy TẤT CẢ entities trong radius ra xa |
| Cooldown | ~3-4 giây (upgradeable) |
| Skill expression | Positioning + Timing = hiệu quả chain |

### 4.2. Tiêu Diệt Quái — 3 Cách

| Cách | Mô tả | Phần thưởng |
|---|---|---|
| **Altar Seal** | Đẩy quái vào Bàn Thờ Phong Ấn | Instant kill + bonus Soul Shards + mảnh ký ức |
| **Wall Slam** | Đẩy quái vào tường/gai đá | Gây sát thương, có thể giết |
| **Domino Chain** | Quái va vào quái khác | Truyền lực → nổ lan → combo |

### 4.3. Arena Dynamics (Thay Đổi Mỗi Wave)

| Yếu tố | Cách thay đổi |
|---|---|
| Altar vị trí | Di chuyển/xuất hiện chỗ mới mỗi wave |
| Tường Gai | Xuất hiện/biến mất → cơ hội wall-slam thay đổi |
| Hố/Vực | Đẩy quái xuống = instant kill nhưng không rơi loot |
| Cột Rune | Chắn đường tạo pocket, ảnh hưởng positioning |
| Boss | Phá hủy terrain → buộc adapt chiến thuật |

### 4.4. Thu Thập & Nâng Cấp Trong Run

- Quái chết → rơi **Soul Shards**
- Đủ ngưỡng Shards → chọn **1 trong 3 upgrade** (mỗi run 3-4 lần upgrade)
- Ví dụ upgrade: Pulse radius +, Cooldown giảm, Fire Pulse, Ice Pulse (slow), Double Push...

---

## 5. Cấu Trúc Session & Progression

### 5.1. Một Run (5-10 phút)

```
Wave 1 (~45s): Giới thiệu — ít quái, 1 Altar, tường cố định
Wave 2 (~60s): Thêm loại quái, Altar di chuyển
Wave 3 (~60s): Thêm hazard (gai đá, vực), quái mạnh hơn
Wave 4 (~75s): Arena phức tạp, nhiều combo opportunity, đang OP
Wave 5 (~90s): MINI-BOSS + đám quái — Peak power fantasy
─────────────────────────────────────────────
Tổng: ~330s ≈ 5.5 phút (nhanh) → 7-8 phút (chậm)
```

### 5.2. Progression 2 Tầng

**Trong run (In-run):**
- Thu Soul Shards → chọn upgrade → Pulse mạnh hơn → chain lớn hơn → nhiều Shards hơn → snowball

**Giữa các run (Meta-progression):**
- Thu **Rune Stones** (currency vĩnh viễn, dựa trên wave đạt được)
- Mở khóa: loại Pulse mới, stats cơ bản, Altar mới, skin/visual cho Stone Knight
- Skin = "lấy lại nhân dạng" → mảnh giáp rõ hơn, ánh mắt sáng hơn → narrative reward

### 5.3. Mô Hình Giữ Chân

| Yếu tố | Cách hoạt động |
|---|---|
| Run ngắn 5-10 phút | Chơi lúc nghỉ, trên xe bus, trước khi ngủ |
| "Thêm 1 run nữa" | Gần đủ Rune Stone mở khóa → chơi thêm |
| Narrative pull | Muốn biết mảnh ký ức tiếp theo → chơi thêm |
| Meta-progression | Hôm nay unlock Fire Pulse → muốn thử → chơi thêm |
| Arena thay đổi | Không run nào giống run nào |

---

## 6. Đối Tượng Người Chơi

| Mục | Chi tiết |
|---|---|
| **Primary** | Game thủ casual-mid PC thích roguelite ngắn (VS, Brotato audience) |
| **Secondary** | Mobile gamer (nếu port sau) — run ngắn phù hợp mobile |
| **Age** | 16-35 |
| **Session** | 5-10 phút/run, 2-5 run/ngày |
| **Retention** | Meta-progression + narrative unlock giữ chân hàng tuần |

---

## 7. Tên & Branding

**Tên chính:** **STONE KNIGHT**
**Phụ đề (tùy chọn):** Stone Knight: The Cursed Dungeon / Stone Knight: Shattered Seal
**Tagline:** *"Push. Shatter. Remember."*

**Tại sao tên này:**
- Ngắn, dễ nhớ, dễ tìm trên Steam
- Gợi hình fantasy rõ ràng
- "Stone" = đá = lời nguyền. "Knight" = hiệp sĩ = quá khứ
- Để lại khoảng trống cho phụ đề (DLC, sequel, subtitle)
- Không trùng tên game lớn nào hiện tại

---

## 8. Tóm Tắt — "Tại Sao Game Này Sẽ Hay?"

1. **Cơ chế ĐẨY** là thứ chưa ai làm trong survivors → **sự khác biệt**
2. **Chain Reaction** tạo emergent gameplay → **mỗi run khác nhau**
3. **Cursed Knight** tạo narrative drive tự nhiên → **lý do chơi tiếp**
4. **5-10 phút/run** phù hợp mọi lúc → **retention cao**
5. **Meta-progression** = luôn có thứ mới để mở → **"thêm 1 run nữa"**
6. **Arena thay đổi** = không nhàm chán → **replayability**
7. **GIF combo chain** = viral potential → **marketing tự bán**

---

*Tài liệu này là nền tảng cho toàn bộ quá trình phát triển. Mọi quyết định thiết kế sau này phải quay lại đây để kiểm tra: "Có phục vụ vision Stone Knight không?"*
