# F015 — Altar Seal (Vortex Void Absorption & Auto-Collect)

**Status:** DONE
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** OWNER_PLAYTEST_PASS

## 1. Kết quả người chơi nhận được

Khi quái bị đẩy vào Bàn thờ (Altar) ở trung tâm:
- **Hút vào hư không (Vortex & Shrink):** Quái không chết theo kiểu va đập tường hay nổ xác thông thường. Thay vào đó, quái lập tức bị hút xoáy về tâm Altar, thu nhỏ kích thước (`scale → 0`) và tan biến vào hư không trong 0.25s.
- **Không có hiệu ứng chết thông thường:** Tuyệt đối không chớp flash trắng chết, không nổ các hạt mảnh vụn quái (`spawn_death_burst`).
- **Hiệu ứng phong ấn riêng (Altar VFX):** Bàn thờ bùng sáng màu tím huyền bí (`COLOR_ALTAR_FLASH`), kèm hiệu ứng hạt hư không tím xoáy vào tâm và rung nhẹ màn hình.
- **Tiền tự động cộng trực tiếp (Auto-Collect):** Số Shards thưởng (`SHARD_ALTAR_BONUS = 2`) được cộng thẳng trực tiếp vào túi người chơi (`shard_count`), KHÔNG rơi ra sàn đấu. Xuất hiện chữ số `+2` vàng ánh kim nổi nhẹ bay lên phía trên bàn thờ để người chơi nhận biết đã nhận tiền thưởng.

## 2. Scope / Non-goals

- **Có:**
  - State mới `EnemyState.SEALING` trong `enemy_base.gd`: dừng chuyển động thường, vô hiệu hóa gây damage lên player, lerp vị trí về tâm Altar và thu nhỏ scale về 0.
  - Vẽ quái khi SEALING: chuyển dần sang sắc tím hư không và mờ dần.
  - Cập nhật `main._on_enemy_died()`: phân nhánh `is_altar_seal`:
    - Cộng thẳng `shard_count += shard_amount`.
    - Không gọi `_spawn_shard()`, không gọi `spawn_death_burst()`.
    - Kích hoạt `vfx.spawn_altar_seal_vfx()` và `arena.trigger_altar_flash()`.
  - Hàm `spawn_altar_seal_vfx()` và floating text `+N` trong `wall_dust.gd`.
  - Hiệu ứng chớp sáng bàn thờ trong `arena.gd`.
  - Constants trong `game_config.gd` (`ALTAR_SEAL_DURATION = 0.25`, `SHAKE_ALTAR_SEAL = 0.25`).
- **Không:**
  - Thay đổi vị trí, kích thước vùng Altar (`ALTAR_POSITION`, `ALTAR_SIZE`).
  - Cho phép Altar phong ấn Player (Player vẫn di chuyển bình thường qua Altar).
  - Spawn shard vật lý rơi ra sàn khi seal.

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| Kiểm tra Altar hiện tại | `_check_altar_collision()` gọi `take_damage(999, true)` gây chết giống đập tường | `enemy_base.gd:188` | VERIFIED_IN_REPO |
| Signal died | `died.emit(position, shard_drop, is_altar_seal, enemy_color)` đã có cờ `is_altar_seal` | `enemy_base.gd:144` | VERIFIED_IN_REPO |
| `_on_enemy_died` | Hiện tại vẫn lặp `_spawn_shard` và gọi `spawn_death_burst` bất kể `is_altar_seal` | `main.gd:274-277` | VERIFIED_IN_REPO |
| Altar drawing | Vẽ hình vuông tím tại `ALTAR_POSITION = (240, 90)` | `arena.gd:30-41` | VERIFIED_IN_REPO |
| Shard bonus Altar | `SHARD_ALTAR_BONUS = 2` | `game_config.gd:120` | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Quá trình Hút & Thu nhỏ (SEALING State)
- Khi quái chạm vùng Altar:
  - Chuyển `enemy_state = EnemyState.SEALING`.
  - `velocity = Vector2.ZERO`, `hp = 0` (không thể gây contact damage lên player).
  - Trong `0.25s` (`ALTAR_SEAL_DURATION`):
    - `position` hút dần về `Config.ALTAR_POSITION`.
    - `scale` thu nhỏ từ `Vector2.ONE` về `Vector2.ZERO`.
    - Quái đổi dần sang màu tím hư không `Config.COLOR_ALTAR` và fade alpha.
  - Hết 0.25s: phát `died.emit(Config.ALTAR_POSITION, Config.SHARD_ALTAR_BONUS, true, enemy_color)` và `queue_free()`.

### R02 — Tách biệt Hiệu ứng Chết
- Khi `is_altar_seal == true`:
  - KHÔNG gọi `spawn_death_burst` (không nổ mảnh vụn quái thông thường).
  - KHÔNG gọi `_spawn_shard` (không rơi shard vật lý ra sàn).
  - Phát hiệu ứng `vfx.spawn_altar_seal_vfx(Config.ALTAR_POSITION)` (vòng hạt tím xoáy vào tâm).
  - Bàn thờ chớp sáng tím `arena.trigger_altar_flash()` trong 0.2s.
  - Camera rung nhẹ `camera.add_trauma(Config.SHAKE_ALTAR_SEAL)`.

### R03 — Tự động Cộng Tiền (Auto-Collect)
- `shard_count += shard_amount` trực tiếp trong `_on_enemy_died()`.
- Hiện chữ số floating text `+2` màu vàng ánh kim bay nhẹ lên trên bàn thờ và mờ dần trong 0.5s.

### R04 — Hỗ trợ Mọi Loại Quái
- Slime, Speeder, Brute khi bị đẩy vào Altar đều bị hút và phong ấn ngay lập tức (kể cả Brute 2 HP).

## 5. Plan nhỏ nhất

| File | Thay đổi |
|---|---|
| [MODIFY] `scripts/core/game_config.gd` | Thêm `ALTAR_SEAL_DURATION = 0.25`, `SHAKE_ALTAR_SEAL = 0.25` |
| [MODIFY] `scripts/actors/enemies/enemy_base.gd` | Thêm state `SEALING`, hàm `_start_altar_seal()`, xử lý hút + shrink |
| [MODIFY] `scripts/actors/enemies/slime.gd` | Thêm case `SEALING` trong `_draw()` (chuyển sang tím hư không) |
| [MODIFY] `scripts/actors/enemies/speeder.gd` | Thêm case `SEALING` trong `_draw()` |
| [MODIFY] `scripts/actors/enemies/brute.gd` | Thêm case `SEALING` trong `_draw()` |
| [MODIFY] `scripts/world/arena.gd` | Thêm `trigger_altar_flash()` và vẽ flash chớp sáng |
| [MODIFY] `scripts/vfx/wall_dust.gd` | Thêm `spawn_altar_seal_vfx()` và floating text `+N` |
| [MODIFY] `scripts/main.gd` | Cập nhật `_on_enemy_died()` xử lý auto-collect và kích hoạt VFX Altar |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Quái bị hút vào tâm | Runtime | Chạm Altar lập tức bị hút về tâm và co nhỏ biến mất | PASS |
| AC02 | Không có VFX chết thường | Runtime | Tuyệt đối không có flash trắng chết, không nổ hạt màu quái | PASS |
| AC03 | Altar bùng sáng tím | Runtime | Bàn thờ chớp sáng tím rực rỡ kèm hạt xoáy hư không | PASS |
| AC04 | Tiền tự động cộng thẳng | Runtime | Shards tăng ngay lập tức trên HUD mà không có shard rơi ra sàn | PASS |
| AC05 | Floating text +2 | Runtime | Xuất hiện số `+2` màu vàng bay nhẹ lên trên bàn thờ | PASS |
| AC06 | Brute 2 HP vẫn bị seal 1-hit | Runtime | Đẩy Brute vào Altar vẫn bị hút chết ngay lập tức | PASS |
| AC07 | Đập tường thông thường không đổi | Runtime | Quái đập tường ngoài vẫn nổ particles và rớt shard bình thường | PASS |

## 7. Approval

- Chờ chủ dự án duyệt brief.
