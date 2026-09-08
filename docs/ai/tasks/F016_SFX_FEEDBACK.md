# F016 — Audio & SFX Feedback (Asset-Based SFX System)

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Người chơi nhận được phản hồi âm thanh (SFX) rõ ràng, giòn giã, có cá tính riêng biệt cho từng hành động cốt lõi:
- **Pulse (Space / Chuột trái):** Âm thanh sóng năng lượng xung kích phát ra ("whoosh-wave" trầm ấm, phân biệt rõ với tiếng đánh trúng đích).
- **Dash (Shift / Chuột phải):** Tiếng lướt gió ngắn, nhẹ ("zip/swoosh"), không lấn át tiếng va đập chiến đấu.
- **Wall Slam:** Tiếng va đập khối đá nặng và đanh ("heavy stone crunch"), rõ và trầm hơn tiếng quái va chạm.
- **Domino Hit:** Tiếng va chạm giữa hai quái nhẹ hơn ("clack/tap"), không bị nhầm với đập tường.
- **Altar Seal:** Tiếng ngân ma thuật hư không sâu thẳm ("void shimmer resonance", thời lượng ~0.5s ngân vang).
- **Shard Pickup:** Tiếng "ting" pha lê trong trẻo vừa phải, tạo cảm giác thưởng nhưng không chói tai khi nhặt liên tục.
- **Player Hurt:** Tiếng cảnh báo nguy hiểm sắc nét ("warning buzz/sting"), tách bạch hoàn toàn với tiếng va chạm quái để người chơi lập tức nhận biết mất máu giữa đám đông.
- **Combo Chain:** Âm điệu thăng hoa vui tai nâng dần theo chuỗi combo (x2, x3, x5...).
- **Game Over:** Giai điệu trầm buồn kết thúc hiệp đấu (~0.9s).

## 2. Scope / Non-goals

- **Có:**
  - Tạo bộ 9 file âm thanh `.wav` (16-bit, 44.1kHz, mono, tối ưu dung lượng vài KB/file) vào thư mục `assets/audio/sfx/` thông qua script sinh âm thanh offline (`scripts/tools/generate_sfx.py`), cho phép nghe thử, kiểm tra âm lượng và tinh chỉnh độc lập.
  - Tạo `SoundManager` (`scripts/systems/sound_manager.gd`) làm node con của `Main` trong `scenes/main.tscn`.
  - Nạp các file WAV qua `preload()` sẵn vào RAM lúc khởi động.
  - Sử dụng **RNG riêng** (`RandomNumberGenerator.new()`) cho audio variation (pitch jitter ±5%), không đụng tới RNG toàn cục của gameplay.
  - Hệ thống **Voice Priority & Voice Stealing**: Phân cấp ưu tiên để âm thanh quan trọng (Player Hurt, Game Over) không bao giờ bị tiếng nhặt Shard hay quái va đập cướp mất lượt phát.
  - Cân bằng âm lượng (Volume Headroom dB) và giới hạn số âm phát đồng thời (Polyphony Cap) cho từng loại âm thanh.
  - Throttling tối thiểu giữa các lần kích hoạt âm thanh cùng loại.
  - Điều kiện kích hoạt chuẩn xác (Trigger Gates): Chỉ phát âm thanh khi kỹ năng (Pulse, Dash) thực sự kích hoạt thành công, không phát khi đang trong cooldown.
  - Xử lý lifecycle: Dừng/ngắt âm khi Pause hoặc Restart game.
- **Không:**
  - Nhạc nền (BGM / Music) — để dành cho milestone sau.
  - Thay đổi bất kỳ thông số gameplay, tốc độ, sát thương hay quy tắc va chạm nào.

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| Audio Bus Layout | Bus `Master` (có Limiter threshold -1.5dB), Bus `Music`, Bus `SFX` | `default_bus_layout.tres` | VERIFIED_IN_REPO |
| Main Architecture | Các hệ thống phụ trợ (`PushSystem`, `HitstopSystem`, `Camera`, `VFX`) đều là node con của `Main` | `scenes/main.tscn:13-58` | VERIFIED_IN_REPO |
| Thư mục âm thanh | `assets/audio/sfx/` đã có sẵn trong repo (đang có `.gitkeep`) | `assets/audio/sfx/` | VERIFIED_IN_REPO |
| Pulse event | `player.pulse_fired(position, radius)` chỉ phát khi cooldown <= 0 | `player.gd:6, 195-200` | VERIFIED_IN_REPO |
| Dash event | Hiện tại `player.gd` set `is_dashing = true` ở dòng 122; cần thêm signal `dash_started` | `player.gd:122` | VERIFIED_IN_REPO |
| Wall slam event | `enemy.wall_slammed(at_position)` phát khi quái PUSHED chạm tường | `enemy_base.gd:8, 175` | VERIFIED_IN_REPO |
| Domino event | `push_system.chain_hit_visual(at_position, chain_count)` phát khi quái va quái | `push_system.gd:11, 107` | VERIFIED_IN_REPO |
| Altar seal event | `_on_enemy_died(..., is_altar_seal: true, ...)` | `main.gd:274-284` | VERIFIED_IN_REPO |
| Shard collect event | `_on_shard_collected(at_position)` | `main.gd:297-300` | VERIFIED_IN_REPO |
| Player hurt event | `player.player_hit(hp)` | `player.gd:7, 221` | VERIFIED_IN_REPO |
| Player died event | `player.player_died` | `player.gd:8, 224` | VERIFIED_IN_REPO |
| Pause handling | `Main` quản lý state PAUSED, dừng process các node gameplay | `main.gd:99-104` | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Nạp Asset & Audio Pool
- `SoundManager` quản lý một pool gồm 10 `AudioStreamPlayer` (đều gán `bus = &"SFX"`).
- Các file WAV được nạp sẵn qua `preload("res://assets/audio/sfx/sfx_*.wav")`.
- Tất cả audio player được cấu hình không loop.

### R02 — Hệ thống Ưu tiên Voice (Priority & Preemption)
- Bảng ưu tiên:
  - `PRIORITY_CRITICAL (4)`: `Player Hurt`, `Game Over`
  - `PRIORITY_HIGH (3)`: `Pulse`, `Altar Seal`
  - `PRIORITY_MEDIUM (2)`: `Wall Slam`, `Dash`, `Combo`
  - `PRIORITY_LOW (1)`: `Domino`, `Shard`
- Khi toàn bộ 10 player trong pool đều đang bận:
  - Nếu âm thanh mới có độ ưu tiên cao hơn âm thanh thấp nhất đang phát: Cướp lượt (preempt) player đang phát âm thấp nhất đó.
  - Nếu âm thanh mới có độ ưu tiên thấp hơn hoặc bằng: Bỏ qua (drop) âm thanh mới để bảo toàn các âm thanh quan trọng hơn.

### R03 — Bảng Cân bằng Âm lượng & Giới hạn Polyphony (Headroom Table)

| Âm thanh | File | Base Volume | Max Concurrent | Throttle Min Gap | Ưu tiên |
|---|---|:---:|:---:|:---:|:---:|
| `Pulse` | `sfx_pulse.wav` | -2.0 dB | 1 | 0.15s | HIGH |
| `Dash` | `sfx_dash.wav` | -4.0 dB | 1 | 0.10s | MEDIUM |
| `Wall Slam` | `sfx_wall_slam.wav` | -1.0 dB | 2 | 0.05s | MEDIUM |
| `Domino` | `sfx_domino.wav` | -6.0 dB | 2 | 0.04s | LOW |
| `Altar Seal` | `sfx_altar_seal.wav` | -1.5 dB | 2 | 0.10s | HIGH |
| `Shard` | `sfx_shard.wav` | -7.0 dB | 3 | 0.03s | LOW |
| `Player Hurt` | `sfx_player_hurt.wav` | 0.0 dB | 1 | 0.20s | CRITICAL |
| `Combo` | `sfx_combo.wav` | -3.0 dB | 1 | 0.10s | MEDIUM |
| `Game Over` | `sfx_game_over.wav` | 0.0 dB | 1 | 0.50s | CRITICAL |

### R04 — Độc lập RNG (RNG Isolation)
- `SoundManager` khởi tạo `var audio_rng := RandomNumberGenerator.new()`.
- Random pitch variation (±5% `audio_rng.randf_range(0.95, 1.05)`) CHỈ đọc từ `audio_rng`, không gọi hàm `randf()` hay `randi()` toàn cục, đảm bảo tính tái lập (reproducibility) của gameplay.

### R05 — Trigger Gate Chính xác
- Âm thanh `Pulse` chỉ phát khi `_fire_pulse()` thực sự diễn ra (không phát khi bấm Space lúc đang cooldown).
- Âm thanh `Dash` chỉ phát khi `is_dashing` bắt đầu bật thành công (không phát khi bấm Shift/Chuột phải lúc đang cooldown).

### R06 — Lifecycle & State Transitions
- Khi `PAUSED`: Toàn bộ các kênh âm thanh đang phát bị pause hoặc ngắt; không nhận thêm SFX gameplay mới.
- Khi `RESTART` / `MENU`: Gọi `sound_manager.clear()` dừng toàn bộ các player đang phát.
- Khi `DEAD`: Dừng các âm thanh chiến đấu thường, phát `sfx_game_over`.

## 5. Plan nhỏ nhất

| File | Thay đổi |
|---|---|
| [NEW] `scripts/tools/generate_sfx.py` | Script Python chuẩn hóa tạo 9 file WAV 16-bit sạch vào `assets/audio/sfx/` |
| [NEW] `assets/audio/sfx/sfx_*.wav` | 9 file âm thanh WAV theo đúng thiết kế |
| [NEW] `scripts/systems/sound_manager.gd` | Node SoundManager quản lý pool, priority, throttling, independent RNG |
| [MODIFY] `scenes/main.tscn` | Thêm node `SoundManager` |
| [MODIFY] `scripts/core/game_config.gd` | Thêm các hằng số audio (`SFX_ENABLED`, `SFX_MASTER_VOLUME`) |
| [MODIFY] `scripts/actors/player.gd` | Thêm `signal dash_started` và emit khi dash bắt đầu |
| [MODIFY] `scripts/main.gd` | Wire các sự kiện gameplay vào `sound_manager`, xử lý stop/clear lúc pause/death/restart |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Tiếng Pulse khi kích hoạt thành công | Runtime | Phát tiếng whoosh sóng xung kích; KHÔNG phát khi đang cooldown | NOT_RUN |
| AC02 | Tiếng Dash khi lướt thành công | Runtime | Phát tiếng gió lướt nhanh, nhẹ; KHÔNG phát khi đang cooldown | NOT_RUN |
| AC03 | Tiếng Wall Slam | Runtime | Phát tiếng đập đá nặng, đanh; khác biệt rõ so với Domino | NOT_RUN |
| AC04 | Tiếng Domino khi quái va chạm | Runtime | Phát tiếng cộc nhẹ; tối đa 2 âm đồng thời, không át tiếng khác | NOT_RUN |
| AC05 | Tiếng Altar Seal | Runtime | Phát tiếng ngân ma thuật hư không dài ~0.5s đầy đặn | NOT_RUN |
| AC06 | Tiếng Shard khi nhặt | Runtime | Phát tiếng ting trong trẻo nhẹ nhàng (-7dB), không chói tai khi nhặt nhiều | NOT_RUN |
| AC07 | Tiếng Player Hurt | Runtime | Phát tiếng cảnh báo nguy hiểm sắc nét (0dB), nổi bật trên đám đông | NOT_RUN |
| AC08 | Tiếng Combo Chain | Runtime | Phát âm điệu thăng hoa khi đạt mốc combo (x2, x3, x5...) | NOT_RUN |
| AC09 | Tiếng Game Over | Runtime | Dừng âm combat, phát chuỗi âm điệu kết thúc (~0.9s) | NOT_RUN |
| AC10 | Voice Priority & Chống rách tiếng | Runtime | Khi nhiều quái đập tường/shard cùng lúc, tiếng Player Hurt vẫn phát rõ ràng, không clipping | NOT_RUN |
| AC11 | Pause & Restart Lifecycle | Runtime | Bấm Esc pause ngắt âm ngay lập tức; bấm R restart xóa toàn bộ âm dở | NOT_RUN |

## 7. Approval

- Chờ chủ dự án xem xét và duyệt bản brief đã tinh chỉnh.
