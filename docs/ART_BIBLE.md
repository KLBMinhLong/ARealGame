# Art Bible v1 — Vòng Vây: Lõi Từ (Circuit Siege: Magnetic Core)

**Phiên bản:** 1.0.0 (Gate G1 & G2 Baseline)  
**Tác giả:** Đội ngũ Phát triển Dự án & Thiết kế Mỹ thuật  
**Công thức Định danh Thẩm mỹ:** `Dark Metal + Neon Accents + Cute Droid + Explosive VFX`

---

## 1. Triết Lý & Quy Chuẩn Thẩm Mỹ Chung (The Visual Formula)

### 1.1. Cốt Lõi Tương Phản (The Contrast Rule)
> [!IMPORTANT]
> **Quy tắc Bất Biến:** Thế giới và môi trường xung quanh luôn được giữ ở tông màu tối kim loại công nghiệp. **Neon KHÔNG BAO GIỜ được chiếm toàn bộ màn hình** mà chỉ được dùng làm ngôn ngữ chức năng báo hiệu: Năng lượng, Hiểm họa, Phần thưởng và Nâng cấp. Giữ màn hình tối giúp các vụ nổ và hiệu ứng xung lực khi thăng tiến sức mạnh tỏa sáng rực rỡ và không gây mỏi mắt người chơi.

### 1.2. Bảng Màu Tiêu Chuẩn (Master Color Palette)

```
[MÔI TRƯỜNG & KIM LOẠI CÔNG NGHIỆP - TỐI DỊU]
#10141a : Void Black (Nền ngoài sân chơi / Letterbox)
#161c24 : Dark Steel Base (Sàn đấu kim loại ghép tấm)
#252e3b : Steel Plate Border (Đường viền nẹp thép, vạch ngăn cách)
#374151 : Rivet & Seam Gray (Đinh tán cơ khí, rãnh thông khí)

[HỆ THỐNG NEON CHỨC NĂNG - RỰC RỠ & ĐỘNG]
#00f0ff : Pulse Cyan (Người chơi, Vòng nạp xung, Luồng phản lực ion, Hàng rào điện từ)
#38bdf8 : Electric Sky Blue (Tia chớp từ trường, Tia phóng điện phụ)
#ef4444 : Danger Crimson (Mắt đỏ quái Chaser, Laser cảnh báo Sprinter)
#f97316 : Threat Amber (Rãnh tản nhiệt, Lửa động cơ phản lực Sprinter)
#facc15 : Scrap Gold (Bánh răng phế liệu rơi, Khiên bảo vệ Aegis)
#a3e635 : Magnet Lime (Vệt sáng khi Scrap bị nam châm hút)
#c084fc : Plasma Violet (Phản ứng nổ dây chuyền Domino va chạm quái)
```

### 1.3. Ngôn Ngữ Hình Học (Shape Language)
- **Người chơi (Player):** Hình tròn thân thiện, mũm mĩm, các đường nét bo tròn đáng yêu (Chibi Droid), tạo cảm giác dễ gần, nhanh nhẹn, là "nhân vật chính yếu ớt cần được bảo vệ".
- **Kẻ địch Bọ máy (Chaser):** Hình thoi / bát giác gồ ghề, bánh xích vuông vức, càng sắt nhọn hoắt, mắt đơn Cyclops hung hãn.
- **Kẻ địch Tiêm kích (Sprinter):** Hình tam giác nhọn khí động học (Delta wing), góc cạnh sắc bén, tạo cảm giác tốc độ xé gió và chết chóc.
- **Phế liệu (Scrap):** Bánh răng cơ khí 4 chấu nhỏ nhắn, lấp lánh như đồng tiền vàng, kích thích ham muốn nhặt đồ.

---

## 2. Camera & Độ Phân Giải Pixel (Camera & Resolution Specs)

### 2.1. Độ Phân Giải Chuẩn
- **Native Resolution:** `960 × 540` pixels (Chuẩn tỉ lệ 16:9).
- **Scale Factor:**
  - Lên màn hình Full HD `1920 × 1080`: Tỉ lệ nhân nguyên bản `2×` (Pixel-perfect).
  - Lên màn hình 2K `2560 × 1440`: Tỉ lệ nhân `2.66×`.
  - Lên màn hình 4K `3840 × 2160`: Tỉ lệ nhân nguyên bản `4×`.
- **Thiết lập Engine Godot:**
  - `stretch/mode = "canvas_items"`
  - `stretch/aspect = "keep"`
  - `rendering/textures/canvas_textures/default_texture_filter = 0` (Nearest Neighbor - giữ độ sắc nét nguyên bản của pixel, không bị mờ nhòe).

### 2.2. Hành Vi Camera
- **Đấu trường Arena:** Cố định bao quát toàn bộ khu vực chiến đấu `720 × 405` nằm cân đối giữa khung hình `960 × 540`, chừa không gian viền cho HUD và cảnh báo.
- **Camera Trauma Shake (Rung Chấn Cơ Học):**
  - Không rung ngẫu nhiên tuyến tính (linear). Dùng công thức suy giảm phi tuyến `Trauma²`:
    $$\text{Offset} = \text{Trauma}^2 \times \text{MaxOffset} \times \text{RandomDirection}$$
  - Khi phát xung Space: `Trauma = 0.4` (rung nhẹ giật lùi).
  - Khi quái đập tường / nổ dây chuyền: `Trauma = 0.65` (rung mạnh tức thời trong 0.2s).
  - Chỉ áp dụng rung chấn lên tầng `World`, giữ nguyên lớp `CanvasLayer HUD` đứng yên để không gây chóng mặt cho người chơi.

---

## 3. Thiết Kế Nhân Vật Chính (Player Design: "Scrappy Droid")

### 3.1. Hình Dáng & Giải Phẫu Thiết Kế
- **Tên hiệu:** Scrappy — The Magnetic Pulse Droid.
- **Kích thước Pixel:** `24 × 24` pixels (Bán kính va chạm vật lý $R = 12$ px).
- **Cấu trúc 5 thành phần:**
  1. *Khối cầu thân kim loại:* Thép hợp kim xám đen (`#222f3e`), viền khớp nẹp thép sáng (`#576574`).
  2. *Mắt kính Visor Chibi:* Kính cong đen bóng (`#0c141f`), mắt LED to tròn phát sáng Cyan (`#00f0ff`), kèm đốm sáng trắng lấp lánh ở góc mắt tạo nét đáng yêu (Cute Chibi Look).
  3. *Anten / Cánh vây ổn định:* Cặp anten mini gắn 2 bên hông lơ lửng, đầu anten có hạt đèn cyan định vị.
  4. *Ống xả phản lực ion:* Đặt ở phía sau đối diện hướng nhìn; khi di chuyển, phụt ra luồng lửa plasma xanh cyan (`#00f0ff` và `#38bdf8`) nhấp nháy sinh động.
  5. *Vòng đo năng lượng xung (Integrated Pulse Ring):* Vòng tròn neon Cyan mỏng ôm sát thân robot, tự động khép kín góc từ $-90^\circ$ đến $+270^\circ$ khi hồi chiêu, sáng bừng lên khi sẵn sàng phát xung.

### 3.2. Bảng Hoạt Ảnh (Animation States)
- `IDLE`: Thân robot bập bềnh lên xuống $\pm 1.5$ px theo chu kỳ sin $1.2$s, mắt LED thỉnh thoảng chớp nhẹ.
- `MOVE`: Nghiêng thân về phía trước $8^\circ$, ngọn lửa ion đuôi kéo dài từ 4px lên 8px kèm các hạt bụi điện nhỏ rơi lại phía sau.
- `PULSE`: Robot co nhẹ thân lại trong $0.05$s rồi bung ra một vòng xung kích từ trường Cyan mở rộng từ $R = 12$ px lên $R = 120$ px.
- `HURT / INVULNERABLE`: Kích hoạt trường lực bọc cầu Aegis màu vàng kim (`#facc15`) trong $0.8$s, robot chớp nháy bán trong suốt.

---

## 4. Thiết Kế Kẻ Địch (Enemy Design)

### 4.1. Chaser — Scrap Crawler Bot
- **Kích thước:** `20 × 20` pixels (Bán kính $R = 10$ px).
- **Cấu tạo:**
  - Thân vỏ thép bát giác tối màu (`#1f2937`) viền đinh tán (`#4b5563`).
  - Đôi bánh xích cơ khí hai bên hông màu đen than (`#141923`) với các nẹp xích kim loại chuyển động.
  - Cặp càng kẹp phế liệu sắt góc nhọn vươn ra phía trước góc $\pm 35^\circ$.
  - Mắt đơn Cyclops tròn đỏ rực (`#ef4444`), tỏa quầng sáng đỏ ám hiệu hung dữ.
- **Trạng thái:**
  - *Săn mồi (Flocking Chase):* Bò theo bầy, bâu quanh người chơi thành cụm.
  - *Bị Choáng (Stunned):* Thân giáp chuyển màu xám tro xỉn, mắt chuyển sang màu vàng hổ phách chập điện (`#eab308`) và bắn ra tia lửa hồ quang nhỏ.
  - *Va tường nổ tung (Wall-Slammed):* Vỡ bung thành 4-6 mảnh sắt vụn, bắn ra bánh răng Scrap.

### 4.2. Sprinter — Razor Dart Interceptor
- **Kích thước:** `28 × 28` pixels (Bán kính $R = 10$ px).
- **Cấu tạo:**
  - Dáng tiêm kích delta cánh dơi khí động học, thép titan đen bóng (`#1e293b`).
  - Viền cánh sắc lẹm màu cam rực (`#f97316`).
  - Rãnh tản nhiệt neon cam chạy dọc sống lưng và cánh.
  - Động cơ phản lực phía đuôi.
- **Hành vi 4 Pha Rõ Rệt:**
  1. `STALK`: Bay lượn từ tốn quanh mục tiêu, động cơ phản lực chỉ có đốm nhiệt nhỏ.
  2. `TELEGRAPH`: Dừng khựng lại, xoay thẳng mũi về hướng người chơi, rãnh tản nhiệt bừng sáng, bắn ra đường laser ngắm bắn màu đỏ rực kẹp chính xác mép tường (cảnh báo trước 0.6s).
  3. `DASH`: Phụt ngọn lửa phản lực ion cam vàng cực đại dài 12px, lao xuyên màn hình với tốc độ $420$ px/s.
  4. `REST`: Đâm vào tường hoặc hết đà, khựng lại xả nhiệt bốc khói mờ trong 0.5s.

---

## 5. Prototype Vòng Lặp Lõi Trong Godot (Core Loop Prototype)

Đã hoàn thành và vận hành mượt mà tại Gate G2:
1. **Lùa quái:** Thuật toán bầy đàn Boids (Flocking Separation) giúp quái Chaser bâu kín thành cụm tự nhiên quanh Scrappy.
2. **Kích hoạt Xung:** Nhấn `Space` phát ra sóng xung kích lực đẩy $80 \times \text{PushMultiplier}$ px.
3. **Va đập sát thương:** Quái bị văng va vào 4 bức tường hoặc va đập dây chuyền (domino) vào nhau sẽ nhận sát thương chí mạng nổ tung.
4. **Hút Phế liệu:** Bánh răng Scrap rơi ra và bị lực từ trường của Droid hút mượt mà về thân.
5. **Thăng cấp:** Đạt ngưỡng $\lfloor 15 \times 1.35^{L-1} \rfloor$ mở popup 3 thẻ nâng cấp ngẫu nhiên hỗ trợ phím số `[1, 2, 3]`.

---

## 6. Danh Mục Hiệu Ứng Hình Ảnh Quan Trọng (Key VFX Showcase)

| STT | Tên VFX | Nguyên lý kỹ thuật | Ý nghĩa trải nghiệm |
|---|---|---|---|
| **VFX-01** | **Pulse Shockwave** | `draw_arc` + `draw_circle` Cyan mở rộng từ $R_{min} \to R_{max}$ trong 0.25s, alpha mờ dần | Cảm giác bùng nổ năng lượng giải tỏa áp lực tức thì |
| **VFX-02** | **Wall-Slam Smash** | Tia lửa điện nổ tung + 6 hạt mảnh vụn kim loại văng theo vector phản xạ | Đã tay, chứng minh lực tác động nghiền nát của tường điện |
| **VFX-03** | **Magnetic Scrap Trail** | Bánh răng vàng phát sáng + vệt sáng xanh lime bay theo đường cong Bezier về người chơi | Kích thích cảm giác thu hoạch phần thưởng liên tục |
| **VFX-04** | **Camera Trauma Shake** | Hàm mũ $T^2$ tác động lên vị trí Node World trong $0.2$s | Thể hiện trọng lượng và uy lực của các cú va chạm cơ khí |
| **VFX-05** | **Sprinter Laser Sight** | Đường kẻ đôi (Tia ngoài đỏ bán trong suốt, tia lõi vàng trắng rực rỡ) kẹp chuẩn biên | Cảnh báo thị giác rõ ràng, công bằng, tạo cơ hội né tránh phản xạ |
| **VFX-06** | **Aegis Invulnerable Bubble** | Vòng tròn năng lượng vàng kim bập bềnh ôm quanh Droid kèm hiệu ứng chớp alpha | Báo hiệu trạng thái an toàn sau khi nhận sát thương |

---

*Tài liệu này là chuẩn mực sản xuất cho toàn bộ asset 2D, âm thanh và hiệu ứng được đưa vào game.*
