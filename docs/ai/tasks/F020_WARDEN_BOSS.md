# F020 — Mini-Boss "The Warden" (Wave 5 Boss Fight)

**Status:** AWAITING_PLAYTEST
**Owner approval:** GRANTED (Via selection 2026-09-09)
**Evidence:** VERIFIED_IN_REPO — Unit tests 40/40 PASS (test_f020_warden.py)

## 1. Kết quả người chơi nhận được

Ở Wave 5, người chơi đối mặt với **Dungeon Warden** — một Mini-Boss đá khổng lồ 10 HP với đòn dậm đất chấn động AoE (bán kính 80 px) có báo trước (telegraph 1.0s). 
- Người chơi phải Dash né đòn dậm đất, tận dụng thời điểm Boss bị khựng hoặc Pulse ngắt chiêu gồng của Boss, đẩy Warden vào Tường Gai (2 damage) hoặc va vào tường/đệ (1 damage).
- Thanh máu 10 vạch hiển thị trực quan ngay trên đầu Boss.
- **Chấm dứt hoàn toàn chiến thuật chạy vòng tròn:** Hết thời gian 60 giây không giúp người chơi thắng run mà kích hoạt trạng thái **Cuồng Nộ (Enraged)**; người chơi bắt buộc phải tiêu diệt Warden mới giành được **Chiến Thắng (Victory)**.

---

## 2. Scope / Non-goals

- **Có:**
  - Lớp quái mới `Warden` kế thừa `EnemyBase`.
  - Cơ chế đòn AoE Ground Slam với Telegraph (1.0s), Hitbox (80px), Damage (1 HP) và Recovery (0.6s).
  - Khả năng ngắt chiêu (Interrupt) khi người chơi Pulse đẩy Boss trong lúc Telegraph.
  - Xử lý Altar: Miễn nhiễm Altar Seal tức tử, nhận 1 sát thương và bật lùi ra ngoài.
  - Thanh máu Boss nổi 10 vạch trực quan.
  - Spawning đệ hỗ trợ điều độ (Slime, Speeder) để làm đạn domino.
  - Điều kiện thắng độc quyền: Tiêu diệt Warden để kích hoạt Victory; hết giờ kích hoạt Enrage.
- **Không:**
  - Không thêm nhiều giai đoạn biến hình (Phase 2/Phase 3 phức tạp).
  - Không thêm đạn đạo (Projectiles) cho Boss — giữ đúng bản chất vật lý melee/AoE.
  - Không thay đổi hành vi quái ở Wave 1–4.

---

## 3. Discovery

| Fact | Giá trị | Nguồn | Phân loại |
|---|---|---|---|
| Thiết kế Warden GDD | HP: 10, Speed: 50 px/s, Push: Very Heavy, AoE: 80px | `docs/04_GDD.md` §7.5 | FROM_DESIGN_DOC |
| Vấn đề chạy vòng tròn (D03) | Wave hết timer không được tự động cho thắng | `docs/ai/PROJECT_TRUTH.md` | VERIFIED_IN_REPO |
| Cơ chế va chạm & Tường Gai | Spike Wall: 2 dmg; Normal Wall: 1 dmg | `scripts/actors/enemies/enemy_base.gd` | VERIFIED_IN_REPO |
| Spawning Wave 5 hiện tại | Name: "Final Stand", spawn budget 36, max 18 | `scripts/core/game_config.gd` | VERIFIED_IN_REPO |

---

## 4. Contract Chi tiết

### R01 — Chỉ số & Khối lượng Đẩy (`Config.gd`)
- `WARDEN_HP := 10`
- `WARDEN_SPEED := 45.0`
- `WARDEN_PUSH_WEIGHT := 1.6` (Đẩy cơ bản bay ~39 px; Heavy Push Tier 3 bay ~119 px)
- `WARDEN_SIZE := 24`
- `WARDEN_SHARD_DROP := 15`

### R02 — Chu kỳ Đòn AoE Ground Slam & Cơ chế Ngắt chiêu
- Chu kỳ: Mỗi 5.0 giây khi ở trạng thái `NORMAL`.
- `TELEGRAPH` (1.0s): Dừng di chuyển, vẽ vòng cảnh báo đỏ bán kính 80 px.
- Nếu bị Pulse trong `TELEGRAPH`: Hủy đòn slam, chuyển sang `PUSHED`, hồi chiêu slam đặt lại 3.0s.
- `SLAM_IMPACT`: Nếu không bị ngắt, gây 1 damage lên Player nếu Player trong khoảng cách 80 px. Rung màn hình 0.30.
- `RECOVERY` (0.6s): Khựng bất động, mở cơ hội cho Player tấn công.

### R03 — Miễn nhiễm Altar Seal
- Khi Warden chạm Altar `(240, 90)` trong trạng thái `PUSHED`:
  - Không gọi `_start_altar_seal()` (không bị hút chết tức thì).
  - Nhận 1 sát thương (`take_damage(1, true)`).
  - Đẩy lùi vận tốc: `velocity = -velocity * 0.5`.

### R04 — Điều kiện Thắng & Cơ chế Enrage ở Wave 5
- Khi `current_wave == 5`:
  - Đồng hồ 60 giây đếm về 0: Chuyển sang `ENRAGED` (tăng 20% speed, giảm hồi chiêu slam còn 3.5s, không kết thúc wave).
  - Wave 5 chỉ hoàn thành khi Warden chết (`warden.hp <= 0`).
  - Khi Warden chết: Xóa sạch quái đệ, rơi 15 Shards, kích hoạt `_on_wave_cleared()` dẫn đến `GameState.VICTORY`.

---

## 5. Acceptance Matrix

| ID | Tiêu chí | Kiểm tra | Kỳ vọng chính xác | Trạng thái |
|---|---|---|---|---|
| AC01 | Warden Stats & Push Travel | Logic/Unit | HP=10, Size=24, Weight=1.6. Cú đẩy 400 px/s làm Warden bay ~39 px | PASS |
| AC02 | AoE Slam Hitbox Check | Logic/Unit | Player cách Warden <= 80px dính sát thương; > 80px an toàn | PASS |
| AC03 | Interrupt Slam by Pulse | Logic/Unit | Nhận Pulse khi đang Telegraph hủy bỏ đòn slam, reset hồi chiêu | PASS |
| AC04 | Altar Immunity Check | Logic/Unit | Đẩy vào Altar chỉ trừ 1 HP và nảy ra, không bị seal tức tử | PASS |
| AC05 | Wave 5 Victory Constraint | Logic/Unit | Hết timer không win run; chỉ win run khi Warden bị tiêu diệt | PASS |
| AC06 | Spike Wall Damage | Logic/Unit | Đẩy Warden vào Tường Gai trừ đúng 2 HP | PASS |

