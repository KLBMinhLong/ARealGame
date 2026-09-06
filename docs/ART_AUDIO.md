# Định hướng Mỹ thuật & Âm thanh — Vòng Vây: Lõi Từ (Cổng G1 Approved)

**Trạng thái:** ĐÃ DUYỆT CỔNG G1 (06/09/2026). Đặc tả sản xuất cho Cổng G2 (Vertical Slice).  
**Công thức Thẩm mỹ Cốt lõi:** `Dark Metal + Neon Accents + Cute Droid + Explosive VFX`.

---

## 1. Định hướng Mỹ thuật & Hoạt ảnh (Art & Animation Direction)

Chuyển đổi từ đồ họa vector hình học thô sơ sang **Modern Pixel Art 2D**:
* **Quy tắc Phối màu & Tương phản:**
  * **Nền & Sàn đấu (World Base):** Tối và đậm chất kim loại công nghiệp (`#101216` ~ `#1b2028`), sàn tôn gân, rãnh thông khí và vết trầy xước cơ khí. Giữ nền dịu và chìm để không gây mỏi mắt hay phân tán sự chú ý.
  * **Hệ thống Neon Chức năng (Functional Neon):** Ánh sáng neon chỉ dùng để báo hiệu trạng thái:
    * **Cyan (`#00f0ff` / `#38bdf8`):** Người chơi (Pulse Droid), vòng nạp xung, sóng từ trường.
    * **Crimson / Amber (`#ff0055` / `#ff5e00`):** Kẻ địch, tia laser nhắm mục tiêu, vùng nguy hiểm.
    * **Neon Lime / Gold (`#a3e635` / `#facc15`):** Phế liệu từ tính (Scraps), hạt năng lượng nhặt được.
    * **Plasma Violet (`#c084fc`):** Nổ dây chuyền (Chain reaction), phóng điện từ trường.

### 1.1. Thiết kế Nhân vật & Kẻ địch (Sprite Specifications)
* **Người chơi — Pulse Droid (Scrappy):**
  * Kích thước canvas: 24×24 pixel (tỉ lệ upscale 2x hiển thị sắc nét trong game).
  * Thiết kế: Dáng robot hình cầu tí hon dễ thương (Chibi Droid), vỏ kim loại chắp vá, ống xả phản lực phía sau, mắt LED xanh Cyan biểu cảm sống động.
  * Hoạt ảnh (Spritesheet):
    * `idle`: Lơ lửng bồng bềnh tại chỗ (4 frames).
    * `move`: Nghiêng thân theo vector di chuyển + phụt tia lửa phản lực từ ống xả (6 frames).
    * `pulse`: Co người nạp xung rồi bung cánh tản nhiệt phóng vòng điện (4 frames).
    * `hit`: Chớp đỏ kim loại, văng ốc vít nhỏ (3 frames).
    * `defeat`: Vỡ bung các mảnh vỏ kèm khói đen (6 frames).
* **Kẻ địch 1 — Chaser (Crawler Bot):**
  * Kích thước: 20×20 pixel.
  * Thiết kế: Bọ máy bánh xích mini màu cam gỉ sét, mắt LED đỏ quét trái phải liên tục.
* **Kẻ địch 2 — Sprinter (Dart Droid):**
  * Kích thước: 28×28 pixel.
  * Thiết kế: Dáng phi thuyền mũi nhọn khí động học.
  * Trạng thái hành vi: `STALK` $\rightarrow$ `TELEGRAPH` (Xòe cánh tản nhiệt màu cam, tia laser đỏ rực khóa hướng) $\rightarrow$ `DASH` (Phụt lửa đuôi lao xuyên màn hình) $\rightarrow$ `REST` (Khói bốc lên xả nhiệt).
* **Linh kiện rơi — Scraps:**
  * Kích thước: 8×8 pixel.
  * Thiết kế: Bánh răng vi mạch phát sáng vàng chanh xoay nhẹ, có hiệu ứng hút mượt về phía người chơi.

### 1.2. Hiệu ứng Hình ảnh (Juice & VFX)
* **Particle System:** Hạt bụi phản lực khi di chuyển, tia lửa điện khi va chạm quái và mảnh vụn kim loại khi quái phát nổ.
* **Camera Shake (Rung chấn màn hình):** Decay rung 2D khi dùng Pulse và khi quái đập tường nổ tung.
* **Hit Freeze (Micro-pause):** Khựng hình 30ms khi xảy ra nổ va chạm mạnh, tăng cảm giác lực tác động.

---

## 2. Định hướng Âm nhạc & Thiết kế Âm thanh (Audio Direction)

### 2.1. Nhạc nền (Soundtrack Gameplay Loop)
* **Thể loại:** Cyber-Industrial Synthwave.
* **Nhịp độ (BPM):** 126–128 BPM.
* **Cảm xúc:** Dồn dập, mạnh mẽ, tạo không khí sinh tồn nghẹt thở nhưng tràn đầy năng lượng phản công.
* **Quy chuẩn kỹ thuật:** File OGG Vorbis / WAV chất lượng cao, loop liền mạch không click/pop tại điểm nối loop, phát trực tiếp qua `Music` audio bus với thanh trượt âm lượng độc lập.

### 2.2. Danh mục SFX Phối Khí Chuyên Nghiệp

| Mã SFX | Mục đích | Mô tả âm thanh | Độ dài | Bus |
|---|---|---|---|---|
| `snd_pulse` | Kích hoạt Xung Space | Tiếng xả khí nén áp suất cao kèm tiếng bass nổ bùm | ~0.35s | SFX |
| `snd_wall_slam` | Quái va vào tường điện | Tiếng kim loại đập mạnh kèm tiếng nổ xé toạc linh kiện | ~0.40s | SFX |
| `snd_enemy_collide` | Quái va chạm nhau | Tiếng cọc cạch va đập kim loại giòn giã | ~0.20s | SFX |
| `snd_scrap_pickup` | Thu thập linh kiện | Tiếng "ting" nốt nhạc điện tử cao dần theo chuỗi | ~0.15s | SFX |
| `snd_level_up` | Đủ Scrap chọn nâng cấp | Tiếng nạp năng lượng đầy (Power surge chord) | ~0.60s | SFX |
| `snd_telegraph` | Sprinter khóa mục tiêu | Tiếng laser sạc tần số cao rít lên cảnh báo nguy hiểm | ~0.55s | SFX |
| `snd_dash` | Sprinter phóng qua sân | Tiếng phản lực xé gió tốc độ cao | ~0.35s | SFX |
| `snd_hit` | Player mất 1 HP | Tiếng vỏ giáp nứt vỡ kèm chuông cảnh báo pin yếu | ~0.25s | SFX |
| `snd_game_over` | Thua cuộc (hết HP) | Tiếng tụt áp ngắt nguồn hệ thống toàn phần | ~0.80s | SFX |
| `snd_victory` | Sống sót đủ thời gian | Hợp âm synth chiến thắng ngân vang | ~1.20s | SFX |

---

## 3. Kiến trúc Quản lý Âm thanh & Cài đặt

* **3 Audio Buses:** `Master` (kèm Limiter), `Music` (nhạc nền), `SFX` (hiệu ứng).
* Lưu trữ và đồng bộ hóa tức thời qua `user://settings.cfg` với 3 thanh trượt âm lượng độc lập trong menu HUD Cài đặt.
* **Quản lý Bản quyền:** 100% tài nguyên audio và pixel art sử dụng đều có chứng chỉ bản quyền thương mại rõ ràng (CC0 hoặc Commercial License được lưu tại `docs/ASSET_REGISTER.md`).

