# F021 — Permanent Upgrades & Rune Forge (Meta-Progression)

**Status:** DONE  
**Owner approval:** APPROVED (2026-09-10)  
**Balance approval:** APPROVED_INITIAL  
**Evidence:** PASS (15/15 test_f021, 10/10 test_f018, manual playtest approved)  

---

## 1. Kết quả người chơi nhận được

Sau mỗi run (thắng hoặc thua), người chơi nhận được **Rune Stones** (tiền tệ meta vĩnh viễn) thông qua biên lai thanh toán duy nhất (Idempotent Settlement). 

Tại **Rune Forge**, người chơi có thể duyệt danh sách các Permanent Upgrades, xem chỉ số Trước/Sau khi nâng cấp, và xác nhận mua. Các nâng cấp này thay đổi vĩnh viễn chỉ số của người chơi trên một baseline duy nhất cộng dồn với nâng cấp trong run. Toàn bộ tiến trình được lưu trữ an toàn qua cơ chế Atomic Write & Backup tại `user://save_data.json`.

> [!CAUTION]
> **Nguyên tắc cốt lõi:** Meta-progression chỉ để tạo cảm giác tiến triển và đa dạng trải nghiệm, tuyệt đối không được dùng làm "thuốc chữa" hay lớp grind để che đi vấn đề cân bằng của Core Loop và Boss fight. Không bí mật scale HP/speed của quái theo cấp nâng cấp của người chơi.

---

## 2. Scope / Non-goals

### Có (Phạm vi được duyệt cho giai đoạn Discovery & Save Prototype):
- **Idempotent Run Settlement:**
  - Định danh `run_id` cho từng lượt chơi.
  - Cờ `settlement_committed`: Mỗi run chỉ được thanh toán đúng 1 lần duy nhất, trả về một biên lai (`RunReceipt`).
  - Phân tách rõ ràng các nguồn tiền: `collected_shards`, `boss_reward` (15), `victory_bonus`, `total_earned`.
- **Hệ thống Lưu trữ Bền vững An toàn (Atomic Save & Migration):**
  - Cơ chế ghi file nguyên tử (Atomic write): Ghi file tạm (`.tmp`) → flush & verify → backup bản gần nhất (`.bak`) → ghi đè file chính.
  - Khi file lỗi: Không tự ý ghi đè file hỏng bằng default; thử tải file backup; nếu cả 2 lỗi thì nạp default vào bộ nhớ và đổi tên file lỗi (`.corrupt`) để kiểm tra.
  - Schema versioning với hàm migration từng bước (`v1 -> v2`).
  - Validation chặt chẽ: Kiểu dữ liệu, chặn số âm, giới hạn tier $[0, \text{max\_tier}]$, từ chối ghi đè nếu gặp save có version tương lai.
  - Injectable Storage Path: Phục vụ Unit Test chạy trên thư mục tạm thời, tuyệt đối không đụng vào `user://save_data.json` của người chơi.
- **Công thức True-Additive (Một Baseline Duy Nhất):**
  - Mọi chỉ số phần trăm đều cộng dồn trên hằng số gốc trong `Config`:
    $$\text{effective} = \text{Config} \times (1.0 + \text{perm\_bonus} + \text{in\_run\_bonus})$$
  - Không nhân chéo 2 lớp.
- **Rune Forge Giao dịch An toàn & UI chống bấm nhầm:**
  - Candidate-state transaction: Chỉ commit trong bộ nhớ và cập nhật UI sau khi atomic save đĩa thành công.
  - Phím `1-6` chỉ để chọn/focus thẻ; cần thao tác xác nhận (`Space`/`Enter` hoặc click nút Mua) để thanh toán.
  - Hiển thị đầy đủ Before/After: Chỉ số, giá, số dư trước và sau mua.
- **Thay thế / Cắt giảm nâng cấp gây bẫy kinh tế:**
  - Loại bỏ `Dungeon Insight` (+20% RS) để tránh biến thành thuế kinh tế bắt buộc hoặc bẫy người chơi.
  - Thay bằng nâng cấp Utility (ví dụ: `Rune Foresight` — 1 lần reroll thẻ in-run mỗi run) hoặc tạm thời chỉ giữ 5 nâng cấp cốt lõi.

### Không (Non-goals & Gates phong tỏa):
- **CHƯA triển khai Combat Modifiers đầy đủ vào Main Game** khi Core Wave và Warden Boss chưa được playtest xác nhận là công bằng và đủ vui.
- **CHƯA chốt bảng giá 350 RS** khi chưa có dữ liệu đo Shard thực tế thu được qua 10–20 run.
- Không xây Hub 2D đi lại phức tạp.
- Không dùng Autoload toàn cục bừa bãi; ưu tiên Service Component gắn vào scene gốc có lifecycle rõ ràng và truyền dependency có kiểm soát.

---

## 3. Discovery & Baseline Facts

| Fact | Giá trị hiện hành trong Repo | Nguồn xác minh | Phân loại |
|---|---|---|---|
| Engine & Renderer | Godot 4.x, Compatibility | `project.godot` | VERIFIED_IN_REPO |
| Baseline Player HP | `Config.PLAYER_MAX_HP = 3` | `scripts/core/game_config.gd:27` | VERIFIED_IN_REPO |
| Baseline Pulse Cooldown | `Config.PULSE_COOLDOWN = 3.5` (s) | `scripts/core/game_config.gd:42` | VERIFIED_IN_REPO |
| Baseline Move Speed | `Config.PLAYER_SPEED = 120.0` (px/s) | `scripts/core/game_config.gd:26` | VERIFIED_IN_REPO |
| Baseline Pulse Force | `Config.PULSE_VELOCITY = 400.0` (px/s) | `scripts/core/game_config.gd:40` | VERIFIED_IN_REPO |
| Baseline Shard Magnet | `Config.SHARD_MAGNET_RADIUS = 40.0` (px) | `scripts/core/game_config.gd:101` | VERIFIED_IN_REPO |
| Điểm kết thúc Run | `_enter_state(GameState.DEAD)` và `VICTORY` | `scripts/main.gd:145-167` | VERIFIED_IN_REPO |
| Nguy cơ Race Condition | Callbacks chết/thắng có thể bị gọi lặp hoặc chồng chéo | `scripts/main.gd` | VERIFIED_IN_REPO |
| Hiện trạng Save File | Chưa có file save nào trong repo (`FileAccess` = 0) | Toàn bộ repo | VERIFIED_IN_REPO |

---

## 4. Contract Chi tiết

### R01 — True-Additive Formula (Một Baseline Duy Nhất)

Mọi hiệu ứng nâng cấp chỉ cộng trực tiếp từ giá trị `Config` gốc:

1. **Lực đẩy (Pulse Force):**
   $$\text{effective\_force} = \text{Config.PULSE\_VELOCITY} \times (1.0 + \text{perm\_force} + \text{in\_run\_force})$$
2. **Tốc độ di chuyển (Move Speed):**
   $$\text{effective\_speed} = \text{Config.PLAYER\_SPEED} \times (1.0 + \text{perm\_speed} + \text{in\_run\_speed})$$
3. **Bán kính hút Shard (Magnet Radius):**
   $$\text{effective\_magnet} = \text{Config.SHARD\_MAGNET\_RADIUS} \times (1.0 + \text{perm\_magnet} + \text{in\_run\_magnet})$$
4. **Thời gian hồi chiêu Pulse (Cooldown):**
   $$\text{effective\_cd} = \max(1.5, \text{Config.PULSE\_COOLDOWN} - \text{perm\_cd\_reduc} - \text{in\_run\_cd\_reduc})$$
5. **Máu tối đa (Max HP):**
   $$\text{effective\_max\_hp} = \text{Config.PLAYER\_MAX\_HP} + \text{perm\_hp} + \text{in\_run\_hp}$$

### R02 — Bảng Nâng cấp Thử nghiệm An toàn (Tạm thời cho Playtest)

| Upgrade ID | Tên | Tiers | Giá tạm | Mức tăng thử nghiệm | Ghi chú an toàn |
|---|---|---|---|---|---|
| `PERM_HP` | Stone Body | 2 | [15, 45] | +1 HP per tier (Tối đa 5 HP) | Không tăng lên 6 để tránh mất áp lực boss |
| `PERM_FORCE` | Heavy Core | 2 | [15, 40] | +7.5% per tier (Tối đa +15%) | Tránh đẩy quái bay xuyên sàn |
| `PERM_SPEED` | Quick Feet | 2 | [15, 40] | +4% per tier (Tối đa +8%) | Giữ nguyên độ nhạy điều khiển |
| `PERM_CD` | Charged Core | 2 | [20, 50] | -0.2s per tier (Tối đa -0.4s) | Không để cooldown dưới 2.5s trước in-run |
| `PERM_MAGNET` | Soul Attunement | 1 | [30] | +30% Magnet radius | Nâng cấp tiện ích an toàn |
| `PERM_FORESIGHT` | Rune Foresight | 1 | [40] | Cho phép 1 lần Reroll thẻ in-run/run | Thay thế Dungeon Insight (+20% RS) |

### R03 — Idempotent Run Settlement & Receipt Contract

1. Mỗi run khi bắt đầu tại `_start_run()` được cấp:
   - `run_id: String` (UUID hoặc timestamp độc nhất).
   - `settlement_committed: bool = false`.
   - `receipt: RunReceipt = null`.
2. Hàm `settle_run(reason: String) -> RunReceipt`:
   - Nếu `settlement_committed == true`: Trả về ngay `receipt` cũ, **không tính toán hay cộng tiền lần nữa**.
   - Tính toán biên lai:
     - `collected_shards`: Số Shard người chơi nhặt trong trận.
     - `boss_reward`: 15 nếu hoàn thành Wave 5 (Warden chết), ngược lại 0.
     - `victory_bonus`: Thưởng cố định nếu Victory (ví dụ: +5 RS).
     - `total_earned = collected_shards + boss_reward + victory_bonus`.
   - Cập nhật số dư `MetaProgression.add_rune_stones(total_earned)`.
   - Cập nhật thống kê `total_runs += 1`, `best_wave = max(best_wave, current_wave)`.
   - Thực hiện **Atomic Save**.
   - Đánh dấu `settlement_committed = true`.
   - Lưu và trả về `receipt`.
3. Màn hình kết thúc (Death / Victory) chỉ hiển thị dữ liệu từ `receipt`:
   - `Collected: X RS`
   - `Boss Defeated: +Y RS`
   - `Victory Bonus: +Z RS`
   - `Total Earned: +T RS`
   - `Balance: B RS`

### R04 — Lưu Trữ Bền Vững (Atomic Write & Validation)

1. **Quy trình Atomic Write:**
   - Serialize dictionary sang JSON string.
   - Ghi vào file tạm: `path + ".tmp"`.
   - `flush()` và kiểm tra file đọc lại được.
   - Sao lưu file chính hiện tại sang `path + ".bak"` (nếu có).
   - Đổi tên file tạm thành file chính.
2. **Quy trình Load an toàn:**
   - Đọc file chính. Nếu file không tồn tại: tạo state mặc định (không báo lỗi).
   - Nếu file chính lỗi cú pháp: Thử đọc file backup (`.bak`).
   - Nếu cả 2 file lỗi: Khởi tạo state mặc định trong RAM, đổi tên file hỏng thành `path + ".corrupt"` để dev kiểm tra, **tuyệt đối không tự động ghi đè file hỏng ngay lập tức**.
3. **Data Validation:**
   - `version` phải là số nguyên dương $\le \text{CURRENT\_VERSION}$.
   - Nếu `version < CURRENT\_VERSION`: Kích hoạt bộ chuyển đổi migration từng bước.
   - Nếu `version > CURRENT\_VERSION`: Không đọc, không ghi đè, báo lỗi không tương thích.
   - `rune_stones >= 0`, `total_runs >= 0`, `best_wave >= 0`.
   - Cấp bậc nâng cấp: $0 \le \text{tier} \le \text{max\_tier}$. Bỏ qua các key lạ hoặc ép về default nếu sai kiểu dữ liệu.
4. **Test Isolation:**
   - Lớp `MetaProgression` cho phép cấu hình `save_path`.
   - Tất cả các bài test tự động phải truyền thư mục tạm (VD: `user://test_save_xyz.json`), không bao giờ chạm vào save thực.

### R05 — Giao dịch Mua tại Rune Forge (Two-Step & Rollback)

1. **Quy trình mua (Transaction):**
   - Kiểm tra điều kiện: Đủ Rune Stones, chưa max tier, upgrade ID hợp lệ.
   - Tạo bản sao `candidate_data`.
   - Áp dụng thay đổi trên `candidate_data`.
   - Gọi hàm Atomic Save với `candidate_data`.
   - **Chỉ khi lưu file thành công:** Cập nhật state chính trong RAM, phát tín hiệu `purchase_succeeded(upgrade_id, new_tier)`.
   - **Nếu lưu file thất bại:** Hủy giao dịch, giữ nguyên state cũ, phát tín hiệu `purchase_failed(reason)`.
2. **Thao tác UI an toàn:**
   - Phím `1-6` hoặc click thẻ: Chỉ để **Select / Focus** thẻ.
   - Bảng thông tin hiển thị chi tiết Trước → Sau:
     - `Stone Body: Tier 1 -> 2`
     - `Max HP: 4 -> 5`
     - `Cost: 45 RS`
     - `Balance: 60 -> 15 RS`
   - Nút Mua (hoặc phím `Space`/`Enter`) mới thực hiện thanh toán. Nút Mua bị mờ/disabled nếu không đủ tiền hoặc đã MAX tier.

---

## 5. Lộ trình Triển khai (Phased Roadmap)

```
[Phase 0: GATES TRƯỚC HẾT]
- Hoàn thành kiểm thử & tuning Warden Boss (F020).
- Thu thập dữ liệu Shards thực tế từ 10-20 runs.
       │
       ▼
[F021.0: Economy Discovery]
- Đo lường trung vị Shard/run (Wave 1, 2, 3, 4, 5, Clear).
- Chốt Boss Reward & Victory Bonus.
       │
       ▼
[F021.1: Save Foundation Prototype]
- Viết MetaProgression với Atomic Write, Backup, Validation, Migration.
- Bộ Unit Test cô lập (dùng mock path).
       │
       ▼
[F021.2: Run Settlement]
- Gắn run_id & idempotent settlement vào main.gd.
- Kiểm tra chặn race condition (Double death / Victory overlap).
       │
       ▼
[F021.3: Rune Forge UI Prototype]
- Giao diện lưới thẻ, Two-Step selection, nút Mua an toàn.
       │
       ▼
[F021.4: Thử nghiệm 1 Upgrade (Utility)]
- Thử nghiệm với Soul Attunement (Magnet) hoặc Rune Foresight.
       │
       ▼
[F021.5: Combat Modifiers]
- Lần lượt thêm HP, Force, Speed, Cooldown theo công thức True-Additive.
- Chạy regression toàn diện sau mỗi chỉ số.
```

---

## 6. Tiêu chí Chấp nhận (Acceptance Matrix Mở Rộng)

| ID | Nhóm | Observable behavior | Kiểm tra | Kỳ vọng | Trạng thái |
|---|---|---|---|---|---|
| AC01 | Save/Load | File trống hoặc không tồn tại | Logic Test | Nạp default state, không crash | PASS |
| AC02 | Save/Load | Round-trip hợp lệ | Logic Test | Dữ liệu lưu và đọc lại hoàn toàn khớp | PASS |
| AC03 | Save/Load | File JSON bị cắt ngang | Logic Test | Tự động đọc file `.bak`, không ghi đè file lỗi | PASS |
| AC04 | Save/Load | Dữ liệu bẩn (âm tiền, quá tier) | Logic Test | Validator ép về cận an toàn, không crash | PASS |
| AC05 | Save/Load | Save từ phiên bản cao hơn | Logic Test | Từ chối nạp, không ghi đè đè mất tiến trình | PASS |
| AC06 | Economy | Thanh toán Idempotent | Logic Test | Gọi `settle_run` nhiều lần trong 1 run chỉ cộng tiền 1 lần | PASS |
| AC07 | Economy | Race condition Death/Victory | Logic Test | Xảy ra chết và thắng cùng frame không tạo duplicate reward | PASS |
| AC08 | Economy | Phân tách nguồn tiền trên Receipt | Logic Test | Biên lai tách bạch rõ Shard nhặt, Boss kill và Victory | PASS |
| AC09 | Purchase | Giao dịch thất bại khi lưu đĩa lỗi | Logic Test | File save lỗi thì memory và UI rollback, không trừ tiền | PASS |
| AC10 | Purchase | Chặn spam click / phím cùng lúc | UI/Unit Test | Không thể tạo giao dịch kép cho 1 lần mua | PASS |
| AC11 | Modifiers | True-Additive Formula | Logic Test | Force với tier 2 perm (+15%) và tier 3 in-run (+75%) = đúng 1.9x base | PASS |
| AC12 | Modifiers | Cooldown Cap Protection | Logic Test | Cooldown không thể bị hạ xuống dưới 1.5s dù cộng dồn tối đa | PASS |
| AC13 | Modifiers | Reset Run Isolation | Logic Test | Vào run mới reset in-run tiers nhưng giữ nguyên permanent tiers | PASS |
| AC14 | UI | Two-step Purchase Safety | UI Test | Nhấn phím 1 chỉ highlight thẻ, không tiêu tiền; ấn xác nhận mới mua | PASS |
| AC15 | UI | Hiển thị Before/After rõ ràng | UI Test | Label hiển thị chính xác giá trị trước và sau khi nâng cấp | PASS |
| AC16 | UI | Modal chặn input xuyên | UI Test | Space/Enter/Click trong Forge không kích hoạt Pulse/start/restart | PASS |
| AC17 | UI | Mở/đóng không chồng | UI Test | Nhấn F liên tục không mở chồng nhiều Forge | PASS |
| AC18 | UI | Return context đúng | UI Test | Menu→F→Esc=Menu, Death→F→Esc=Death, Victory→F→Esc=Victory | PASS |
| AC19 | Settlement | Forge sau settlement | Logic Test | Mở Forge từ Death/Victory không gọi lại settle_run() | PASS |
| AC20 | Settlement | Đóng/mở nhiều lần | Logic Test | Đóng và mở Forge 10 lần không cộng lại reward | PASS |
| AC21 | Purchase | Upgrade chưa implemented | Logic Test | can_buy trả false, UI hiển COMING SOON | PASS |
| AC22 | Purchase | Transaction lock UI | UI Test | Enter/Space bị block khi save đang chạy | PASS |
| AC23 | Purchase | Refresh toàn bộ sau mua | UI Test | Mọi thẻ cập nhật tier, giá, trạng thái can_afford sau 1 giao dịch | PASS |
| AC24 | UI | Không double-click mua | UI Test | Click chỉ select, không mua; Enter/Space mới xác nhận | PASS |
| AC25 | UI | Layout vừa viewport 480×270 | UI Test | 6 thẻ và panel chi tiết không tràn ở native viewport | PASS |

