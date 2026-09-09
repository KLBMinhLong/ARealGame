# F018 — In-Run Upgrades (Soul Evolution & 3-Card Selection)

**Status:** DONE
**Owner approval:** GRANTED (2026-09-09)
**Evidence:** VERIFIED_IN_REPO — Unit tests 8/8 PASS + Owner playtest approval recorded

## 1. Kết quả người chơi nhận được

Người chơi trải nghiệm hệ thống phát triển sức mạnh roguelite giữa các đợt sóng:
- **Thời điểm kích hoạt:**
  - Sau khi dọn sạch quái ở cuối **Wave 1, Wave 2, Wave 3, và Wave 4**, game tạm dừng toàn bộ gameplay và mở màn hình chọn **SOUL EVOLUTION**.
  - Cuối Wave 5 không mở bảng nâng cấp mà chuyển thẳng sang màn hình **VICTORY**.
- **Giao diện chọn thẻ chuyên biệt (`upgrade_selection.tscn`):**
  - Hiển thị 3 thẻ bài tách biệt với HUD, có viền nét, tên thẻ, cấp độ hiện tại / kế tiếp (`Tier X/3`), chỉ số cụ thể.
  - Hỗ trợ cả phím số bàn phím (`1`, `2`, `3`) và nhấp chuột (Click) vào thẻ.
  - Cơ chế khóa lựa chọn (`selection_committed` guard): một khi đã chọn, khóa lập tức toàn bộ input để không thể chọn đúp hoặc dính click thừa.
  - Miễn nhiễm hoàn toàn sát thương và vô hiệu hóa điều khiển nhân vật trong lúc đang mở bảng chọn thẻ.
- **Danh mục nâng cấp cốt lõi (Tính toán Additive từ Baseline):**
  1. **Heavy Push (`UPG_FORCE`):** Lực đẩy Pulse +25% mỗi Tier (400 → 500 → 600 → 700 px/s).
  2. **Wider Reach (`UPG_RADIUS`):** Bán kính Pulse +20% mỗi Tier (50 → 60 → 70 → 80 px). Đồng bộ tuyệt đối giữa vùng hit detection và hình ảnh vòng sóng xung kích.
  3. **Quick Charge (`UPG_CD`):** Hồi chiêu Pulse -0.4s mỗi Tier (3.5s → 3.1s → 2.7s → 2.3s). Áp dụng từ lần Pulse tiếp theo, không reset tức thì cooldown đang chạy.
  4. **Swift Stone (`UPG_SPEED`):** Tốc độ chạy +15% mỗi Tier (120 → 138 → 156 → 174 px/s). Không làm biến dạng quãng đường Dash.
  5. **Stone Heart (`UPG_HP`):** Mỗi Tier tăng +1 Max HP cho run hiện tại VÀ hồi ngay 1 HP (nhất quán, không phạt người chơi khi đang bị thương).
  6. **Soul Magnet (`UPG_MAGNET`):** Bán kính hút Soul Shards +50% mỗi Tier (40 → 60 → 80 → 100 px).

## 2. Scope / Non-goals

- **Có:**
  - `UpgradeManager` chỉ quản lý `tiers: Dictionary`, tính toán giá trị hiệu lực (effective values) trực tiếp từ baseline `Config` (công thức additive, không compound).
  - Tách biệt kiến trúc: Player phát signal `pulse_fired(position, radius, force)` chứa sẵn thông số hiệu lực; `PushSystem` nhận trực tiếp từ signal, không truy vấn ngược vào nội bộ Player.
  - UI riêng biệt `scenes/ui/upgrade_selection.tscn` + `scripts/ui/upgrade_selection.gd`.
  - Bộ sinh ngẫu nhiên riêng `upgrade_rng` (RandomNumberGenerator) độc lập với spawn RNG và audio RNG.
  - Quy tắc an toàn: Không rút thẻ trùng nhau, không rút thẻ đã đạt Tier 3.
  - Triển khai theo 4 pha nhỏ: F018.1 (Foundation & 2 thẻ đầu) → F018.2 (UI độc lập & Selection Flow) → F018.3 (Các thẻ còn lại) → F018.4 (Balance & Playtest).
- **Không:**
  - Không sửa đổi hằng số trong `Config` khi nâng cấp.
  - Không nhét toàn bộ UI thẻ vào `hud.gd`.
  - Chưa làm hệ thống Rune Forge / Meta-upgrade ngoài sảnh The Hollow.

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| Baseline Pulse Velocity | 400.0 px/s | `game_config.gd:40` | VERIFIED_IN_REPO |
| Baseline Pulse Radius | 50.0 px | `game_config.gd:39` | VERIFIED_IN_REPO |
| Baseline Pulse Cooldown | 3.5s | `game_config.gd:42` | VERIFIED_IN_REPO |
| Baseline Player Speed | 120.0 px/s | `game_config.gd:26` | VERIFIED_IN_REPO |
| Baseline Player HP | 3 HP | `game_config.gd:27` | VERIFIED_IN_REPO |
| Baseline Magnet Radius | 40.0 px | `game_config.gd:200` | VERIFIED_IN_REPO |
| Signal Pulse hiện tại | `pulse_fired(position: Vector2, radius: float)` | `player.gd:6` | VERIFIED_IN_REPO |
| Vòng đời Wave | `PRE_WAVE → SPAWNING → CLEAR_REMAINING → INTERMISSION → COMPLETE` | `main.gd:18` | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Công thức Tính Giá trị Hiệu lực (Additive from Baseline)

Mọi chỉ số đều tính trực tiếp từ baseline `Config` dựa trên số Tier hiện tại, không cộng dồn lũy kế lên biến:
- **Lực đẩy:** `effective_force = Config.PULSE_VELOCITY * (1.0 + 0.25 * tier)`
- **Bán kính Pulse:** `effective_radius = Config.PULSE_RADIUS * (1.0 + 0.20 * tier)`
- **Hồi chiêu Pulse:** `effective_cooldown = maxf(1.5, Config.PULSE_COOLDOWN - 0.4 * tier)`
- **Tốc độ chạy:** `effective_speed = Config.PLAYER_SPEED * (1.0 + 0.15 * tier)`
- **Bán kính hút Shard:** `effective_magnet = Config.SHARD_MAGNET_RADIUS * (1.0 + 0.50 * tier)`
- **Stone Heart:** `max_hp = Config.PLAYER_MAX_HP + tier`, hồi 1 HP khi chọn.

### R02 — Quy tắc Rút Thẻ & Cách ly RNG
- Sử dụng `upgrade_rng = RandomNumberGenerator.new()` riêng biệt.
- Chỉ rút từ danh sách thẻ có `tier < 3`.
- Rút ngẫu nhiên 3 thẻ không trùng lặp.
- Seed của `upgrade_rng` có thể thiết lập được để phục vụ automated testing.

### R03 — Quy tắc An toàn khi Bảng Nâng Cấp Mở
1. `selection_committed = false` khi mở bảng; chuyển thành `true` ngay tick nhận input hợp lệ đầu tiên.
2. Vô hiệu hóa toàn bộ Button/phím tắt ngay khi commit để chống double-selection.
3. Không nhận input từ phím đang giữ (dùng `is_action_just_pressed` hoặc tiêu thụ input frame mở).
4. Đóng băng gameplay: Player không nhận sát thương, không thể Dash/Pulse; quái không spawn.
5. Bấm `R` trong lúc mở bảng: dọn dẹp an toàn và restart về Wave 1 tinh khôi.

### R04 — Tách biệt Signal & Gameplay Pipeline
- `player.pulse_fired` đổi thành `signal pulse_fired(position: Vector2, radius: float, force: float)`.
- Player phát cả `effective_radius` và `effective_force`.
- `PushSystem` nhận trực tiếp `force` từ signal để tính vận tốc đẩy quái, không truy xuất nội bộ `player`.
- `Player._draw()` dùng đúng `effective_radius` để vẽ vòng sóng xung kích, đảm bảo 100% đồng bộ với vùng hit detection.

## 5. Lộ trình Triển khai Chi tiết

### Pha F018.1 — Modifier Foundation & Push/Radius Proof
- Tạo `scripts/systems/upgrade_manager.gd`: lưu trữ `tiers: Dictionary`, hàm tính toán additive, hàm reset, `upgrade_rng`.
- Nâng cấp signal `pulse_fired` của Player và tích hợp `effective_force` vào `push_system.gd`.
- Kiểm thử logic tự động: công thức additive, giới hạn Tier 3, reset sạch.
- Kiểm tra gameplay: Heavy Push (500 px/s) và Wider Reach (60 px) không làm lỗi Wall Slam hay bỏ sót Altar.

### Pha F018.2 — Dedicated UI & Selection Flow
- Tạo scene `scenes/ui/upgrade_selection.tscn` và script `scripts/ui/upgrade_selection.gd`.
- Thiết kế 3 thẻ bài với phím `[1]`, `[2]`, `[3]`, text rõ ràng, viền nổi bật khi hover/focus.
- Triển khai guards: `selection_open`, `selection_committed`.
- Tích hợp phase `WavePhase.UPGRADE_SELECTION` vào `scripts/main.gd`.

### Pha F018.3 — Triển khai Các Thẻ Còn Lại
- Tích hợp `Quick Charge` (chính sách áp dụng từ lần Pulse tiếp theo, 3.5 → 3.1 → 2.7 → 2.3s).
- Tích hợp `Swift Stone` (tốc độ chạy tăng 15%/tier, không đổi dash distance).
- Tích hợp `Stone Heart` (+1 Max HP & hồi 1 HP mỗi tier).
- Tích hợp `Soul Magnet` (+50% bán kính hút).

### Pha F018.4 — Balance & Playtest Verification
- Chạy 1 run đầy đủ qua 5 Waves.
- Kiểm tra tính ổn định vật lý ở Tier 3 của Heavy Push (700 px/s).
- Bàn giao playtest cho chủ dự án.

## 6. Acceptance Matrix (Số đo Chính xác)

| ID | Tiêu chí | Kiểm tra | Kỳ vọng chính xác | Trạng thái |
|---|---|---|---|---|
| AC01 | Additive math chính xác | Logic | Heavy Push: Tier 1 = 500, Tier 2 = 600, Tier 3 = 700 px/s | PASS |
| AC02 | Quick Charge mốc an toàn | Logic | Cooldown: Tier 1 = 3.1s, Tier 2 = 2.7s, Tier 3 = 2.3s | PASS |
| AC03 | Cooldown áp dụng lần kế tiếp | Runtime | Pulse đang hồi không bị reset ngay khi chọn thẻ Quick Charge | PASS |
| AC04 | Stone Heart nhất quán | Runtime | Ở 1/3 HP chọn Stone Heart → thành 2/4 HP; đầy 3/3 HP → thành 4/4 HP | PASS |
| AC05 | 3 thẻ không trùng lặp | Logic | Rút 100 lần không bao giờ có thẻ trùng trong cùng lượt | PASS |
| AC06 | Không xuất hiện thẻ Max Tier | Logic | Thẻ đạt Tier 3 không xuất hiện trong các lượt rút tiếp theo | PASS |
| AC07 | RNG cách ly | Logic | Rút thẻ không làm thay đổi chuỗi random sinh quái của Wave | PASS |
| AC08 | Guard chống chọn đúp | Runtime | Nhấn phím 1 và click chuột đồng thời chỉ ghi nhận đúng 1 lần nâng cấp | PASS |
| AC09 | Wider Reach đồng bộ 100% | Runtime | Bán kính hình ảnh vòng Pulse khớp chính xác bán kính quét quái | PASS |
| AC10 | Heavy Push Tier 3 an toàn | Runtime | Quái 700 px/s không xuyên tường, Wall Slam và Altar ghi nhận 100% | PASS |
| AC11 | Kích hoạt đúng thời điểm | Runtime | Hiện sau Wave 1, 2, 3, 4; Wave 5 vào thẳng Victory | PASS |
| AC12 | Reset sạch sẽ | Runtime | Nhấn R chơi lại: toàn bộ tiers về 0, player stats về đúng 100% Config | PASS |

## 7. Approval

- Chủ dự án đã nghiệm thu và phê duyệt (2026-09-09). Toàn bộ tiêu chí đạt yêu cầu.
