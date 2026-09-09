# F017 — Wave System (5 Waves, Transitions & Victory)

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-09)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Người chơi trải nghiệm một vòng lặp chơi hoàn chỉnh có cấu trúc gồm **5 đợt sóng (Waves)** thay vì sinh quái vô tận:
- **Cấu trúc 5 Waves tăng tiến:**
  - **Wave 1 ("Awakening", 35s):** 100% Slime. Nhịp độ làm quen cơ chế đẩy, tối đa 10 quái.
  - **Wave 2 ("The Hunt", 40s):** Xuất hiện Speeder (35%), di chuyển nhanh hơn, tối đa 14 quái.
  - **Wave 3 ("Heavy Impact", 45s):** Xuất hiện quái trâu Brute 2 HP (20%), Speeder (30%), tối đa 18 quái.
  - **Wave 4 ("The Swarm", 50s):** Bầy đàn dày đặc (Slime 30%, Speeder 45%, Brute 25%), tối đa 22 quái.
  - **Wave 5 ("Final Stand", 60s):** Đợt sóng đỉnh cao, quái tràn ngập sân, tối đa 28 quái.
- **Wave HUD & Bộ đếm thời gian:** HUD hiển thị rõ `Wave: 1/5` cùng đồng hồ đếm ngược thời gian còn lại của wave (`00:35`).
- **Wave Banner & Transition:**
  - Khi bắt đầu Wave: Banner chữ nổi `"WAVE X: <TÊN WAVE>"` xuất hiện trang trọng rồi mờ dần.
  - Khi hết giờ Wave: Quái còn lại fade out biến mất, xuất hiện thông báo rực rỡ `"WAVE X CLEARED!"`, người chơi được nghỉ ngơi hồi sức trong 3.0s ("Next Wave in 3... 2... 1...").
- **Màn hình Thắng / Thua:**
  - Hoàn thành Wave 5: Chuyển sang màn hình chiến thắng **VICTORY** ("THE SEAL HOLDS! RUN COMPLETE!") hiển thị đầy đủ thông số thời gian sống sót, quái đã diệt, combo cao nhất và số Shard.
  - Khi hy sinh (HP = 0): Màn hình DEAD ghi nhận thêm `Wave Reached: X/5`.

## 2. Scope / Non-goals

- **Có:**
  - Cấu hình dữ liệu 5 Wave trong `game_config.gd` (`WAVES_DATA`: tên, thời lượng, khoảng cách spawn, tỉ lệ loại quái, trần quái tối đa).
  - Quản lý trạng thái Wave trong `main.gd` (`current_wave`, `wave_timer`, `is_intermission`, `intermission_timer`).
  - Cập nhật state machine trong `main.gd`: thêm trạng thái `GameState.VICTORY`.
  - Cập nhật HUD trong `hud.gd`:
    - Hiển thị Wave number và đếm ngược trên thanh trạng thái.
    - Hiển thị banner bắt đầu wave và banner kết thúc wave / đếm ngược nghỉ ngơi 3s.
    - Màn hình Victory và cập nhật màn hình Death với số Wave đạt được.
  - Dọn dẹp quái êm ái khi hết Wave (fade out / clear).
  - Tích hợp âm thanh: phát âm thanh chúc mừng khi Clear Wave (`sound_manager.play_altar_seal()` hoặc combo chime).
- **Không:**
  - Thêm quái Boss mới có thanh máu riêng (để dành cho task Boss chuyên biệt).
  - Hệ thống chọn thẻ nâng cấp (In-Run Upgrade Pick) — sẽ cắm trực tiếp vào giai đoạn nghỉ giữa wave ở task sau.
  - Thay đổi địa hình sân đấu (Arena morphing) — giữ sân hiện tại ổn định.

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| Chế độ sinh quái hiện tại | Vô tận (Endless) theo `run_time`, không có khái niệm Wave | `main.gd:163-167, 193-240` | VERIFIED_IN_REPO |
| Danh mục quái hiện có | Slime, Speeder, Brute | `scenes/enemies/` | VERIFIED_IN_REPO |
| State machine hiện tại | `GameState { MENU, RUNNING, PAUSED, DEAD }` | `main.gd:6` | VERIFIED_IN_REPO |
| HUD rendering | Dùng CanvasLayer + Label duy nhất, hiển thị HP, CD, Shards, Chain | `hud.gd:6-127` | VERIFIED_IN_REPO |
| GDD Wave spec | 5 Waves, thời lượng 35s-60s, dọn quái khi clear wave, nghỉ giữa wave | `docs/04_GDD.md:140-159`, `docs/03_CORE_LOOP.md:199-250` | FROM_DESIGN_DOC |
| Nhịp sinh quái | `SpawnTimer` điều chỉnh `wait_time` theo thời gian | `main.gd:196-216` | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Dữ liệu 5 Waves chuẩn
- Dữ liệu từng wave lưu trong `Config.WAVES_DATA`:
  - Wave 1: 35s, Slime 100%, max 10 quái, spawn interval 2.0s → 1.4s.
  - Wave 2: 40s, Slime 65%, Speeder 35%, max 14 quái, interval 1.6s → 1.1s.
  - Wave 3: 45s, Slime 50%, Speeder 30%, Brute 20%, max 18 quái, interval 1.4s → 0.9s.
  - Wave 4: 50s, Slime 30%, Speeder 45%, Brute 25%, max 22 quái, interval 1.1s → 0.7s.
  - Wave 5: 60s, Slime 30%, Speeder 40%, Brute 30%, max 28 quái, interval 0.9s → 0.5s.

### R02 — Quy trình Vòng đời Wave (Wave Lifecycle)
1. **Khởi động Wave:**
   - Đặt `wave_timer = wave_data.duration`.
   - `spawn_timer.wait_time = wave_data.interval_start`, bật timer.
   - Hiện Banner `WAVE X: <NAME>` ở giữa màn hình trong 1.5s.
2. **Trong Wave:**
   - Mỗi giây trôi qua: `wave_timer -= delta`.
   - Quái sinh theo tỉ lệ quy định của wave đó.
   - Nhịp sinh tăng tốc dần từ `interval_start` về `interval_end` theo tiến độ thời gian wave.
   - HUD hiển thị đếm ngược: `Wave 1/5 [00:24]`.
3. **Hết giờ Wave (`wave_timer <= 0`):**
   - Dừng `spawn_timer`.
   - Toàn bộ quái thường trên sân bị giải phóng (fade out mờ dần và giải phóng sau 0.6s).
   - Nếu `current_wave < 5`:
     - Phát âm thanh hoàn thành wave.
     - Hiện banner `WAVE X CLEARED!`.
     - Vào giai đoạn nghỉ 3.0s (`intermission_timer = 3.0s`), HUD đếm ngược `Next Wave in 3s...`.
     - Hết 3s: Tăng `current_wave += 1`, bắt đầu Wave tiếp theo.
   - Nếu `current_wave == 5`:
     - Hoàn thành hiệp chơi! Chuyển sang `GameState.VICTORY`.

### R03 — Trạng thái VICTORY & Cập nhật DEAD
- `GameState.VICTORY`:
  - Dừng spawn, dừng nhận sát thương.
  - Hiển thị màn hình chiến thắng với màu sắc vinh quang (Rune gold / Cyan), hiển thị tổng kết 4 chỉ số (Run time, Enemies Slain, Best Combo, Shards) cùng nút `Press R to play again`.
- `GameState.DEAD`:
  - Bổ sung thêm dòng: `Wave Reached: Wave X/5`.

### R04 — Pause, Restart & Điều khiển
- Bấm `Esc` lúc đang trong Wave hoặc Intermission đều pause chính xác thời gian và cây scene.
- Bấm `R` restart hiệp chơi: đặt lại `current_wave = 1`, làm mới toàn bộ chỉ số và quái.

## 5. Plan nhỏ nhất

| File | Thay đổi |
|---|---|
| [MODIFY] `scripts/core/game_config.gd` | Thêm cấu hình `TOTAL_WAVES`, `WAVE_INTERMISSION_DURATION`, mảng `WAVES_DATA` |
| [MODIFY] `scripts/ui/hud.gd` | Bổ sung hiển thị Wave & timer trên HUD, Banner thông báo Wave Start / Clear, hàm `show_victory()` và cập nhật `show_death()` |
| [MODIFY] `scripts/main.gd` | Thêm state `VICTORY`, các biến đếm wave (`current_wave`, `wave_timer`, `intermission_timer`), logic chuyển wave và spawn theo cấu hình từng wave |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Bắt đầu Wave 1 có Banner & thông tin | Runtime | Hiện "WAVE 1: Awakening", HUD hiển thị `Wave 1/5 [00:35]` | NOT_RUN |
| AC02 | Quái spawn đúng tỉ lệ từng wave | Runtime | Wave 1: 100% Slime; Wave 2: có Speeder; Wave 3: có Brute | NOT_RUN |
| AC03 | Đếm ngược hết giờ wave | Runtime | Đồng hồ đếm về 00:00 chính xác | NOT_RUN |
| AC04 | Quái biến mất khi hết giờ | Runtime | Toàn bộ quái còn sót lại fade out và biến mất | NOT_RUN |
| AC05 | Wave Clear & Nghỉ 3s | Runtime | Hiện "WAVE X CLEARED!", đếm ngược nghỉ 3s trước khi sang Wave mới | NOT_RUN |
| AC06 | Hoàn thành Wave 5 chuyển Victory | Runtime | Vượt qua Wave 5 hiện màn hình chiến thắng VICTORY đầy đủ chỉ số | NOT_RUN |
| AC07 | Hy sinh hiển thị Wave đạt được | Runtime | Màn hình Game Over ghi nhận chính xác Wave đạt được (ví dụ Wave 3/5) | NOT_RUN |
| AC08 | Pause / Restart hoạt động chuẩn | Runtime | Pause đóng băng đúng timer; Restart đưa về Wave 1/5 | NOT_RUN |

## 7. Approval

- Chờ chủ dự án xem xét và duyệt bản brief.
