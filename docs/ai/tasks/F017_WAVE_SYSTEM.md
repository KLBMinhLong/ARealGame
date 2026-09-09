# F017 — Wave System (Spawn Phase, Clear Remaining & 5 Waves Progression)

**Status:** DONE
**Owner approval:** GRANTED (2026-09-09)
**Evidence:** VERIFIED_IN_REPO — Playtest & owner approval recorded

## 1. Kết quả người chơi nhận được

Người chơi trải nghiệm một vòng lặp chơi có cấu trúc gồm **5 đợt sóng (Waves)** với mục tiêu chiến đấu rõ ràng, không thể "chạy vòng tròn chờ hết giờ":
- **Cơ chế 2 giai đoạn (Spawn Phase → Cleanup Phase):**
  - **Giai đoạn sinh quái (SPAWNING):** Đồng hồ đếm ngược (`00:35` → `00:00`), quái sinh liên tục cho tới khi hết ngân sách (`spawn_budget`) hoặc hết giờ.
  - **Giai đoạn dọn sạch (CLEAR_REMAINING):** Khi hết giờ hoặc hết ngân sách, game **ngừng sinh quái**. Toàn bộ quái còn sống trên sân **KHÔNG tự động biến mất** — người chơi bắt buộc phải dùng cơ chế đẩy/đập tường/Altar để tiêu diệt hết.
  - HUD chuyển từ `Wave 1/5 [00:00]` thành `Wave 1/5 [CLEAR: 6]` hiển thị số quái còn lại cần tiêu diệt.
  - Chỉ khi số quái trên sân về `0`, đợt sóng mới chính thức được tính là **Wave Cleared!**
- **Cấu trúc 5 Waves thận trọng (Conservative Budget & Max Active):**
  - **Wave 1 ("Awakening", 35s):** 100% Slime. Ngân sách 14 quái, tối đa 8 quái sống cùng lúc.
  - **Wave 2 ("The Hunt", 40s):** Xuất hiện Speeder (30%), quái đầu tiên chắc chắn là Speeder. Ngân sách 18 quái, tối đa 10 quái sống cùng lúc.
  - **Wave 3 ("Heavy Impact", 45s):** Xuất hiện Brute 2 HP (15%), quái đầu tiên chắc chắn là Brute. Ngân sách 22 quái, tối đa 12 quái sống cùng lúc.
  - **Wave 4 ("The Swarm", 50s):** Phối hợp dày đặc (Slime 40%, Speeder 40%, Brute 20%). Ngân sách 28 quái, tối đa 15 quái sống cùng lúc.
  - **Wave 5 ("Final Stand", 60s):** Đợt sóng đỉnh cao (Slime 35%, Speeder 40%, Brute 25%). Ngân sách 36 quái, tối đa 18 quái sống cùng lúc.
- **Chuẩn bị trước Wave (PRE_WAVE) & Khoảng nghỉ (INTERMISSION):**
  - **PRE_WAVE (1.2s):** Bắt đầu Wave có 1.2s chuẩn bị vị trí, hiện banner `WAVE X: <NAME>`, chưa sinh quái để người chơi định vị không bị che khuất tầm nhìn.
  - **INTERMISSION (3.0s):** Khi dọn sạch quái cuối cùng, hiện `WAVE X CLEARED!`, người chơi có 3s định thần và chuẩn bị vị trí cho wave kế tiếp (không hồi máu).
- **Màn hình Chiến thắng (VICTORY) & Hy sinh (DEAD):**
  - Vượt qua Wave 5: Chuyển sang `GameState.VICTORY` ("THE SEAL HOLDS! RUN COMPLETE!") hiển thị thời gian, số quái đã diệt, combo cao nhất, Shards.
  - Hy sinh: Màn hình `DEAD` ghi nhận chính xác `Wave Reached: Wave X/5`.

## 2. Scope / Non-goals

- **Có:**
  - Vòng đời Wave rõ ràng với `WavePhase`: `PRE_WAVE`, `SPAWNING`, `CLEAR_REMAINING`, `INTERMISSION`, `COMPLETE`.
  - Cấu hình `WAVES_DATA`: `duration`, `spawn_budget`, `max_active`, `interval_start/end`, `enemy_weights`, `guaranteed_spawns`.
  - Giới hạn số lượng quái sống cùng lúc (`max_active` từ 8 đến 18, không đẩy lên 28 để tránh quá tải thị giác, âm thanh và hiệu năng).
  - Ngắt spawn khi hết giờ/hết budget, bắt buộc diệt hết quái mới Clear.
  - Phân tách rạch ròi giữa "quái bị người chơi giết" và "quái bị hệ thống dọn dẹp" (`despawn` không tính kill, không rơi shard, không tăng combo).
  - Quy tắc ưu tiên sự kiện (Event Precedence): Chết trước Victory thì ghi nhận DEAD; đã vào Victory thì vô hiệu hóa sát thương.
  - Bổ sung hiển thị `CLEAR: X` trên HUD khi bước vào Cleanup phase.
- **Không:**
  - Tự động xóa quái khi hết giờ wave (chống chiến thuật chạy vòng tròn).
  - Tự động hồi máu trong giai đoạn Intermission.
  - Thêm quái Boss phức tạp (dành cho milestone Boss riêng).
  - Hệ thống chọn thẻ nâng cấp (In-Run Upgrade Cards) — sẽ cắm vào Intermission ở task sau.

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| Chiến thuật chạy vòng tròn | Nếu hết giờ tự xóa quái, player chỉ cần né quái là thắng | Phân tích gameplay | VERIFIED_IN_REPO |
| Số lượng quái hiện tại | Slime (1 HP), Speeder (1 HP, nhanh), Brute (2 HP, nặng) | `scenes/enemies/` | VERIFIED_IN_REPO |
| Brute feedback | 2 HP: hit 1 đổi màu `COLOR_BRUTE_DAMAGED`, hit 2 chết; Altar seal 1-hit | `brute.gd`, `F011` | VERIFIED_IN_REPO |
| Thời lượng thiết kế | Prototype đề xuất: 230s combat + 12s nghỉ (~4 phút), khác số 330s trong GDD cũ | GDD vs Prototype | PROPOSED |
| State machine cấp cao | `GameState { MENU, RUNNING, PAUSED, DEAD, VICTORY }` | `main.gd:6` | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Bảng Thông số 5 Waves (Prototype Đề xuất)

| Wave | Tên | Thời lượng | Spawn Budget | Max Active | Tần suất spawn | Thành phần quái | Spawns chỉ định đầu |
|:---:|---|:---:|:---:|:---:|:---:|---|---|
| **1** | Awakening | 35s | 14 | 8 | 2.2s → 1.5s | 100% Slime | Slime |
| **2** | The Hunt | 40s | 18 | 10 | 1.8s → 1.2s | 70% Slime, 30% Speeder | 1 Speeder đầu wave |
| **3** | Heavy Impact | 45s | 22 | 12 | 1.6s → 1.0s | 55% Slime, 30% Speeder, 15% Brute | 1 Brute đầu wave |
| **4** | The Swarm | 50s | 28 | 15 | 1.3s → 0.8s | 40% Slime, 40% Speeder, 20% Brute | 1 Speeder, 1 Brute |
| **5** | Final Stand | 60s | 36 | 18 | 1.1s → 0.6s | 35% Slime, 40% Speeder, 25% Brute | 1 Speeder, 1 Brute |

### R02 — Trạng thái Vòng đời Wave (WavePhase)
Trong `GameState.RUNNING`, trạng thái đợt sóng gồm:
1. `PRE_WAVE` (1.2s):
   - Banner `WAVE X: <NAME>` xuất hiện.
   - Chưa sinh quái, đồng hồ wave chưa chạy, player có thể di chuyển định vị.
2. `SPAWNING`:
   - Đồng hồ wave đếm lùi `wave_time_left -= delta`.
   - Sinh quái theo nhịp tăng tốc dần cho tới khi: hết thời gian (`wave_time_left <= 0`) HOẶC hết ngân sách (`wave_spawned_count >= spawn_budget`).
   - Luôn tôn trọng giới hạn `max_active`.
3. `CLEAR_REMAINING`:
   - Ngừng sinh quái (`spawn_timer.stop()`).
   - Quái còn sống **KHÔNG** tự biến mất.
   - HUD hiển thị: `Wave X/5 [CLEAR: %d]`.
   - Khi toàn bộ quái bị tiêu diệt (`enemies_count == 0`): kích hoạt Wave Cleared.
4. `INTERMISSION` (3.0s):
   - Hiện banner `WAVE X CLEARED!`, âm thanh chuông chúc mừng.
   - Đếm ngược 3s chuẩn bị vị trí ("Next Wave in 3s...").
   - Hết 3s: chuyển sang Wave tiếp theo (`_start_wave(current_wave + 1)`).
5. `COMPLETE`:
   - Hoàn thành sau Wave 5. Chuyển sang `GameState.VICTORY`.

### R03 — Quy tắc Ưu tiên Sự kiện (Precedence & Race Conditions)
- Nếu Player nhận sát thương chết trước khi Victory được xác nhận: Chuyển `GameState.DEAD`.
- Khi `GameState.VICTORY` đã được xác nhận: Player miễn nhiễm hoàn toàn sát thương contact damage, dừng mọi cập nhật đợt sóng.
- Bấm `R` restart: Dừng toàn bộ timer, gọi `_despawn_all_entities()` đồng bộ, ngắt toàn bộ callback cũ, khởi động lại từ Wave 1 sạch sẽ.

### R04 — Phân biệt Despawn Hệ thống và Kills
- Hàm `_despawn_all_entities(reason)`:
  - Ngắt kết nối các signal `died` và `wall_slammed` trước khi `queue_free()`.
  - Tuyệt đối KHÔNG cộng `enemies_killed`, KHÔNG rơi Shard, KHÔNG tăng Chain/Combo, KHÔNG phát âm thanh thưởng.
  - Chỉ dùng khi Restart run, thoát ra Menu hoặc sau khi màn hình Victory hiển thị.

## 5. Plan nhỏ nhất

| File | Thay đổi |
|---|---|
| [MODIFY] `scripts/core/game_config.gd` | Cập nhật `WAVES_DATA` với `spawn_budget`, `max_active` hạ xuống 8-18, `WAVE_PRE_DURATION = 1.2` |
| [MODIFY] `scripts/ui/hud.gd` | Bổ sung hiển thị `CLEAR: X` khi trong phase CLEAR_REMAINING; banner PRE_WAVE; màn hình Victory & Death |
| [MODIFY] `scripts/actors/player.gd` | Bổ sung cờ `is_invulnerable` kiểm soát miễn nhiễm sát thương khi Victory / Dead |
| [MODIFY] `scripts/main.gd` | Triển khai `WavePhase` enum, `wave_budget`, `wave_spawned_count`, logic SPAWNING → CLEAR_REMAINING → INTERMISSION, bảo vệ despawn an toàn |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | PRE_WAVE 1.2s trước khi sinh quái | Runtime | Hiện banner, quái chưa sinh, player chuẩn bị vị trí an toàn | PASS |
| AC02 | Quái chỉ định xuất hiện đầu wave | Runtime | Wave 2 quái đầu là Speeder; Wave 3 quái đầu là Brute | PASS |
| AC03 | Tôn trọng max_active và spawn_budget | Runtime | Số quái sống cùng lúc không vượt max_active; tổng quái không vượt budget | PASS |
| AC04 | Hết giờ chuyển CLEAR_REMAINING | Runtime | Đồng hồ về 0, quái KHÔNG tự biến mất, HUD hiện `CLEAR: X` | PASS |
| AC05 | Bắt buộc diệt sạch mới Clear Wave | Runtime | Chạy vòng tròn không thể clear wave; chỉ clear khi quái trên sân về 0 | PASS |
| AC06 | Intermission 3s chuẩn bị vị trí | Runtime | Đếm ngược 3s không hồi máu; sau 3s tự chuyển wave tiếp theo | PASS |
| AC07 | Hoàn thành Wave 5 đạt Victory | Runtime | Diệt sạch quái Wave 5 hiện VICTORY, miễn nhiễm sát thương | PASS |
| AC08 | Hy sinh ghi nhận đúng Wave | Runtime | Chết ở wave nào hiện đúng `Wave Reached: Wave X/5` | PASS |
| AC09 | Despawn hệ thống không cộng thưởng | Code Logic | Restart/Menu dọn quái ngắt kết nối signal, không tăng kill/shard/combo | PASS |
| AC10 | Pause / Resume không double-trigger | Runtime | Pause đóng băng timer chính xác; resume tiếp tục đúng nhịp | PASS |

## 7. Approval

- Chủ dự án duyệt nghiệm thu toàn bộ tính năng Wave System (F017) và các bản sửa lỗi (2026-09-09).
