# F020 — Mini-Boss "The Warden" (Wave 5 Boss Fight)

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (Via selection 2026-09-09)
**Evidence:** Static/logic tests PASS — Runtime/Visual/Balance: AWAITING_PLAYTEST

## 1. Kết quả người chơi nhận được

Ở Wave 5, người chơi đối mặt với **Dungeon Warden** — một Mini-Boss đá khổng lồ với đòn dậm đất chấn động AoE (bán kính 80 px) có báo trước (telegraph 1.0s).

- Người chơi phải Dash né đòn dậm đất, tận dụng thời điểm Boss bị khựng (Recovery) để đổi vị trí và căn góc Pulse, hoặc Pulse ngắt chiêu gồng của Boss, đẩy Warden vào Tường Gai (2 damage) hoặc va vào tường/đệ (1 damage).
- Thanh máu hiển thị trực quan ngay trên đầu Boss.
- **Hết thời gian không tự động cho Victory; Warden phải bị tiêu diệt.** Enrage là cơ chế tạo áp lực chống kéo dài trận đấu, tắt mặc định ở V0, cần playtest để xác nhận hiệu quả trước khi bật.

---

## 2. Scope / Non-goals

- **Có:**
  - Lớp quái mới `Warden` kế thừa `EnemyBase`.
  - Cơ chế đòn AoE Ground Slam với Telegraph (1.0s), Hitbox (80px), Damage (1 HP) và Recovery (0.6s).
  - Khả năng ngắt chiêu (Interrupt) khi người chơi Pulse đẩy Boss trong lúc Telegraph.
  - Xử lý Altar: Miễn nhiễm Altar Seal tức tử, nhận 1 sát thương và bật lùi ra ngoài.
  - Thanh máu Boss nổi trực quan.
  - Spawning đệ hỗ trợ: tối đa 3 Slime (V0), không Speeder/Brute.
  - Điều kiện thắng: Tiêu diệt Warden để kích hoạt Victory; hết giờ không tự cho thắng.
  - Boss Sandbox (`boss_sandbox.tscn`) để playtest cô lập.
- **Không:**
  - Không thêm nhiều giai đoạn biến hình (Phase 2/Phase 3 phức tạp).
  - Không thêm đạn đạo (Projectiles) cho Boss.
  - Không thay đổi hành vi quái ở Wave 1–4.
  - Không thêm Enrage ở V0 (bật khi sandbox cơ bản đã vui).

---

## 3. Discovery

| Fact                              | Giá trị                                            | Nguồn                                   | Phân loại          |
| --------------------------------- | ---------------------------------------------------- | ---------------------------------------- | -------------------- |
| Thiết kế Warden GDD             | HP: 10, Speed: 50 px/s, Push: Very Heavy, AoE: 80px  | `docs/04_GDD.md` §7.5                 | FROM_DESIGN_DOC      |
| Vấn đề chạy vòng tròn (D03) | Wave hết timer không được tự động cho thắng | `docs/ai/PROJECT_TRUTH.md`             | VERIFIED_IN_REPO     |
| Cơ chế va chạm & Tường Gai   | Spike Wall: 2 dmg; Normal Wall: 1 dmg                | `scripts/actors/enemies/enemy_base.gd` | VERIFIED_IN_REPO     |
| Spawning Wave 5 hiện tại        | Name: "The Warden", max_active 3                     | `scripts/core/game_config.gd`          | VERIFIED_IN_REPO     |
| HP prototype V0                   | 6 (giảm từ GDD 10 để sandbox test nhanh)         | Owner feedback 2026-09-09                | PROPOSED → APPROVED |

---

## 4. Contract Chi tiết

### R01 — Chỉ số & Khối lượng Đẩy (`Config.gd`) — Prototype V0

- `WARDEN_HP := 6` (V0 prototype; GDD ghi 10, sẽ tuning sau playtest)
- `WARDEN_SPEED := 45.0`
- `WARDEN_PUSH_WEIGHT := 1.6` (Đẩy cơ bản bay ~39 px; Heavy Push Tier 3 bay ~119 px — cần đo thực tế trong engine)
- `WARDEN_SIZE := 24`
- `WARDEN_SHARD_DROP := 15`

### R02 — Chu kỳ Đòn AoE Ground Slam & Cơ chế Ngắt chiêu

- Chu kỳ: Mỗi 5.0 giây khi ở trạng thái `NORMAL`.
- `TELEGRAPH` (1.0s): Dừng di chuyển, vẽ vòng cảnh báo đỏ bán kính 80 px.
- Nếu bị Pulse trong `TELEGRAPH`: Hủy đòn slam, chuyển sang `PUSHED`, hồi chiêu slam đặt lại 3.0s.
- `SLAM_IMPACT`: Nếu không bị ngắt, gây 1 damage lên Player nếu Player trong khoảng cách 80 px. Rung màn hình 0.30.
- `RECOVERY` (0.6s): Warden đứng yên — cơ hội cho Player đổi vị trí, căn góc và chuẩn bị cú Pulse tiếp theo. **Không phải cơ hội tấn công** (Stone Knight không có đòn đánh trực tiếp).

### R03 — Miễn nhiễm Altar Seal

- Khi Warden chạm Altar `(240, 90)` trong trạng thái `PUSHED`:
  - Không gọi `_start_altar_seal()` (không bị hút chết tức thi).
  - Ghi impact, áp dụng damage trước.
  - `take_damage(1, true)` — nếu chết, đi death path duy nhất.
  - Nếu còn sống mới áp bounce: `velocity = bounce_dir * 100.0`.
  - Chống multi-trigger: `impact_processed = true`.

### R04 — Điều kiện Thắng & Enrage (V0: Enrage TẮT)

- Khi `current_wave == 5`:
  - Wave 5 chỉ hoàn thành khi Warden chết (`warden.hp <= 0`).
  - **V0**: Timer 60s hết → KHÔNG trigger Enrage. Boss giữ nguyên thông số.
  - **V1** (sau playtest): Bật Enrage (tăng 20% speed, giảm hồi chiêu slam còn 3.5s) qua `Config.WARDEN_ENRAGE_ENABLED`.
  - Khi Warden chết: Xóa quái đệ, cộng 15 Shards trực tiếp vào `shard_count` (không drop ra đất), kích hoạt Victory.

### R05 — Shard Reward khi Boss chết

- Cộng `WARDEN_SHARD_DROP` trực tiếp vào run result.
- Không spawn shard entities ra đất (tránh cleanup race với Victory).
- Victory screen hiển thị tổng shard bao gồm boss reward.

---

## 5. Acceptance Matrix

| ID   | Tiêu chí                      | Kiểm tra               | Kỳ vọng                                                                                           | Trạng thái                           |
| ---- | ------------------------------- | ----------------------- | --------------------------------------------------------------------------------------------------- | -------------------------------------- |
| AC01 | Warden Stats & Push Travel      | Logic/Unit + Engine đo | HP=6, Size=24, Weight=1.6. Cần đo quãng đường thực tế trong engine, không chỉ công thức | Static: PASS / Runtime: NOT_RUN        |
| AC02 | AoE Slam Hitbox Check           | Logic/Unit              | Player cách Warden <= 80px dính damage; > 80px an toàn                                           | Static: PASS                           |
| AC03 | Interrupt Slam by Pulse         | Logic/Unit + Sandbox    | Nhận Pulse khi đang Telegraph hủy bỏ đòn slam, reset hồi chiêu                              | Static: PASS / Feel: AWAITING_PLAYTEST |
| AC04 | Altar Immunity Check            | Logic/Unit              | Đẩy vào Altar chỉ trừ 1 HP và nảy ra; death order đúng                                     | Static: PASS                           |
| AC05 | Wave 5 Victory Constraint       | Logic/Unit              | Hết timer không win run; chỉ win run khi Warden bị tiêu diệt                                  | Static: PASS                           |
| AC06 | Spike Wall Damage               | Logic/Unit              | Đẩy Warden vào Tường Gai trừ đúng 2 HP                                                      | Static: PASS                           |
| AC07 | Shard Reward trực tiếp        | Manual/Sandbox          | Boss chết → 15 shard cộng vào shard_count, Victory hiển thị đúng                            | NOT_RUN                                |
| AC08 | Telegraph đọc được         | Visual/Playtest         | Người chơi nhìn thấy và hiểu Slam trước khi bị đánh                                     | AWAITING_PLAYTEST                      |
| AC09 | Dash/Interrupt lựa chọn thực | Playtest                | Có lựa chọn thật giữa Dash né và Pulse interrupt                                             | AWAITING_PLAYTEST                      |
| AC10 | Căn góc đẩy boss            | Playtest                | Thú vị sau lần thứ 3, không lặp máy móc                                                     | AWAITING_PLAYTEST                      |
| AC11 | Minion hỗ trợ hay gây rối   | Playtest                | Domino tạo thêm chiến thuật, không che telegraph                                               | AWAITING_PLAYTEST                      |
