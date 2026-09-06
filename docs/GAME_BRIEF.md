# Game brief — Vòng Vây: Lõi Từ (Circuit Siege: Magnetic Core)

**Trạng thái:** ĐÃ DUYỆT CỔNG G1 (06/09/2026). Định hướng phát triển thương mại dài hạn.

## Mục tiêu

Phát triển một tựa game PC 2D Survivors-like / Action Roguelite thương mại hoàn chỉnh bằng Godot 4 và quy trình AI, đạt tiêu chuẩn phát hành trên Steam / Itch.io với lối chơi cuốn hút, hình ảnh Modern Pixel Art độc đáo, âm thanh giàu năng lượng và hệ thống tiến trình giữ chân người chơi lâu dài.

## Một câu mô tả

Điều khiển một chú robot dọn dẹp tí hon đáng yêu bị mắc kẹt giữa bãi phế liệu công nghiệp, sử dụng bộ tạo xung từ trường nén (Magnetic Pulse) để hất văng đàn quái robot biến chất đập vào tường và va chạm nhau nổ dây chuyền, thu nhặt linh kiện từ tính (Scraps) để tiến hóa sức mạnh tức thì và mở khóa nâng cấp vĩnh viễn.

## Người chơi giả định

Game thủ PC yêu thích thể loại Action Roguelite / Survivors-like (tương tự phong cách *Brotato*, *Vampire Survivors*, *SNKRX*) với nhịp độ dồn dập, cơ chế phản đòn vật lý đã tay, đồ họa pixel art hiện đại và cảm giác tiến hóa sức mạnh rõ rệt sau mỗi trận.

## Vòng lặp Cốt lõi (Core Loop)

```text
Menu / Workshop → Bắt đầu Run → Nhử quái tụ đàn (Flocking) → Kích hoạt Pulse hất văng
  → Quái đập tường / đập nhau nổ dây chuyền (Domino Explosion)
  → Hút Scraps rơi ra → Đạt ngưỡng: Chọn 1 trong 3 Nâng cấp sức mạnh (Bullet-Time)
  → Sống sót vượt qua các đợt cao trào (180s) hoặc hết HP
  → Thu thập Chip Lõi (Core Chips) → Mở khóa nâng cấp vĩnh viễn & Skin → Chơi lại
```

## Bốn Trụ Cột Thiết Kế

1. **Lối chơi Chủ động & Nổ dây chuyền:** Chuyển dịch từ né tránh thụ động sang cơ chế phản công công phá cao. Tận dụng tương tác vật lý đẩy va chạm (tường và quái với quái), kết hợp AI bầy đàn (Flocking) để tạo chuỗi nổ liên hoàn.
2. **Tiến trình 2 Tầng (In-run & Meta-progression):**
   * *Trong trận:* Thu thập Scrap theo ngưỡng lũy tiến để chọn 1 trong 3 nâng cấp ngẫu nhiên (Xung công phá, Tụ điện cao tần, Bão điện từ, Nam châm tận thu, Khiên phản lực).
   * *Vĩnh viễn:* Tích lũy Core Chips sau mỗi trận để nâng cấp thông số cơ bản (Hull HP, Tốc độ, Lực đẩy) và mở khóa Skin tại Xưởng Chế Tạo (Workshop).
3. **Mỹ thuật Modern Pixel Art & Dark-Metal Neon:**
   * Công thức thẩm mỹ: `Dark Metal + Neon Accents + Cute Droid + Explosive VFX`.
   * Thế giới tối kim loại làm nền cho ánh sáng neon chức năng (Cyan = Người chơi/Từ trường, Đỏ = Cảnh báo nguy hiểm, Vàng = Scraps).
   * Nhân vật robot chibi có đầy đủ spritesheet hoạt ảnh (Idle, Move, Pulse, Hit, Defeat).
4. **Âm thanh & Nhạc nền Chuyên nghiệp:**
   * Bản nhạc nền Synthwave Cyber-Industrial 126–128 BPM tràn đầy năng lượng, lặp liền mạch (seamless loop).
   * Bộ SFX cơ khí - va chạm giòn giã có lực nén sub-bass, tách biệt các kênh âm lượng Master/Music/SFX độc lập.

## Phạm vi Vertical Slice G2 (Lát cắt 60–90 giây)

1. Một phòng đấu hoàn thiện mỹ thuật sàn kim loại tối viền neon.
2. Nhân vật Robot Pulse Droid có sprite pixel art và hoạt ảnh chuyển động/xung/bị thương.
3. Hai loại quái hoàn thiện sprite pixel: Chaser (Crawler Bot) và Sprinter (Dart Droid).
4. Cơ chế Đẩy va đập tường & Va đập quái với quái gây nổ dây chuyền rơi Scrap.
5. Hệ thống nhặt Scrap và bảng chọn 1 trong 3 nâng cấp khi đủ ngưỡng.
6. Một bản nhạc nền gameplay loop hoàn chỉnh và hệ thống âm thanh SFX đồng bộ.

