# F012 — Spawn Pacing (Phased Enemy Introduction)

**Status:** DONE
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** HUMAN_PLAYTEST_PASSED (2026-09-08)

## 1. Kết quả người chơi nhận được

Nhịp độ xuất hiện của quái được phân tầng rõ rệt theo thời gian:
- **0:00 – 1:00 (Phút đầu):** 100% Slime. Người chơi thoải mái làm quen di chuyển, góc đẩy tường và nhặt Shards.
- **1:00 – 2:30 (Phút 1 đến 2.5):** Speeder bắt đầu xuất hiện và tăng dần tỉ lệ (0% → 40%). Nhịp game tăng tốc, thử thách phản xạ.
- **2:30+ (Sau 2.5 phút):** Brute bắt đầu xuất hiện (0% → 25%). Đòi hỏi kỹ năng xử lý quái trâu, kháng đẩy trong không gian hẹp.

## 2. Scope / Non-goals

- **Có:** 
  - Cấu hình mốc thời gian xuất hiện trong `game_config.gd` (`PHASE_SPEEDER_TIME = 60.0`, `PHASE_BRUTE_TIME = 150.0`, các tỉ lệ mục tiêu).
  - Cập nhật logic tính xác suất quái trong `main._spawn_enemy()` theo 3 giai đoạn `run_time`.
- **Không:**
  - Thay đổi stats của quái (HP, tốc độ, size, push weight).
  - Thay đổi tốc độ dồn quái tổng thể (spawn interval 2.0s → 0.8s và max concurrent 15 → 25 vẫn giữ nguyên theo F010).
  - Thêm wave UI hay text thông báo (giữ flow liền mạch).

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| `run_time` | Đã có, track thời gian chạy và reset khi restart | `scripts/main.gd:23, 85, 127` | VERIFIED_IN_REPO |
| `_spawn_enemy` | Tính xác suất quái dựa vào `run_time` | `scripts/main.gd:207-220` | VERIFIED_IN_REPO |
| Tỉ lệ cũ | Speeder và Brute có tỉ lệ xuất hiện ngay từ giây 0 | `scripts/core/game_config.gd:109-112` | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Giai đoạn 1 (0s – 60s)
- `speeder_chance = 0.0`
- `brute_chance = 0.0`
- 100% spawn Slime.

### R02 — Giai đoạn 2 (60s – 150s)
- `brute_chance = 0.0`
- `t = (run_time - 60.0) / (150.0 - 60.0)`
- `speeder_chance = lerpf(0.0, 0.40, t)`
- Slime chiếm phần còn lại: `1.0 - speeder_chance` (100% → 60%).

### R03 — Giai đoạn 3 (150s+)
- `t = clampf((run_time - 150.0) / 30.0, 0.0, 1.0)` (ramp từ 150s đến 180s)
- `brute_chance = lerpf(0.0, 0.25, t)`
- `speeder_chance = lerpf(0.40, 0.45, t)`
- Slime chiếm phần còn lại: `1.0 - speeder_chance - brute_chance` (60% → 30%).

### R04 — Reset
- Khi restart run mới, `run_time` reset về 0, chu kỳ trở lại Phase 1 (100% Slime).

## 5. Plan nhỏ nhất

| File | Thay đổi |
|---|---|
| [MODIFY] `scripts/core/game_config.gd` | Thay đổi constants tỉ lệ và thêm mốc thời gian phân tầng |
| [MODIFY] `scripts/main.gd` | Cập nhật hàm `_spawn_enemy()` theo công thức 3 giai đoạn |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Phút đầu chỉ có Slime | Runtime | 0 – 60s chỉ thấy Slime xanh, không có Speeder/Brute | PASS |
| AC02 | Phút thứ 1 Speeder mới ra | Runtime | Sau 60s Speeder cam bắt đầu xuất hiện | PASS |
| AC03 | Phút 2.5 Brute mới ra | Runtime | Trước 150s không có Brute; sau 150s Brute đỏ bắt đầu xuất hiện | PASS |
| AC04 | Restart reset chu kỳ | Runtime | Bấm R hoặc restart run mới: bắt đầu lại bằng 100% Slime | PASS |
| AC05 | Quái không bị đổi stats | Diff | Không đổi HP, speed, push_weight của quái | PASS |

## 7. Approval

- Đã duyệt và playtest đạt bởi chủ dự án (2026-09-08).
