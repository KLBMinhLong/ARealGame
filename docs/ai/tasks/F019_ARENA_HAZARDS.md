# F019 — Fixed Wave Arena Layouts & Impact Hazards

**Status:** DONE
**Owner approval:** GRANTED (2026-09-09)
**Evidence:** VERIFIED_IN_REPO — Unit tests 33/33 PASS + Owner playtest approval recorded

## 1. Kết quả người chơi nhận được

Thay vì một đấu trường tĩnh trống trải, người chơi trải nghiệm **Bố cục Đấu trường theo từng Wave (Fixed Wave Layouts)** cùng cơ chế cạm bẫy tác động va chạm (**Impact Hazards**):
- **Bố cục Đấu trường Cố định theo Wave (Wave-specific Layouts):**
  - Mỗi wave sở hữu một bố cục chướng ngại vật được định nghĩa trước (không random), giúp người chơi học tập và làm chủ địa hình.
  - Layout mới được kích hoạt an toàn trong giai đoạn **`PRE_WAVE`** (sau khi chọn thẻ nâng cấp và hết thời gian nghỉ Intermission), không bao giờ xuất hiện đột ngột đè lên vị trí người chơi.
- **Tường Gai Chấn Động (Spike Walls — F019B):**
  - Các đoạn tường biên gắn gai nhọn màu đỏ cam (`#ef4444` / `#f97316`) xuất hiện từ Wave 3.
  - **Khắc chế Brute 2 HP:** Khi quái bị Pulse đẩy va vào đoạn tường gai, quái nhận **2 sát thương** (`DAMAGE_SPIKE_SLAM = 2`). Brute 2 HP sẽ bị tiêu diệt ngay lập tức (1-hit kill) nếu người chơi căn góc đẩy hiểm hóc.
  - **Quy tắc va chạm một lần (Single Impact Resolution):** Va chạm ở góc đấu trường chỉ kích hoạt duy nhất một lần tính sát thương (ưu tiên Spike Wall = 2 damage, không cộng dồn 2 + 1 từ tường thường). Không gây lặp sát thương qua từng frame.
  - **Hiệu ứng va đập gai nhọn:** Camera shake mạnh hơn (`SHAKE_WALL_SLAM * 1.5`), hạt bụi đỏ tóe ra, âm thanh đập mạnh dứt khoát.
  - **An toàn cho người chơi:** Người chơi chạm vào tường gai không bị mất máu.
- **Vòng Khắc Cổ Ngữ (Rune Anchors — F019C):**
  - Vòng năng lượng cổ ngữ trên mặt đất (đường kính 20 px, viền vàng `#facc15`).
  - **Hoàn toàn xuyên qua với chuyển động thường:** Người chơi đi và Dash xuyên qua mượt mà (không ngắt Dash); quái di chuyển thường đi xuyên qua, **không cần thay đổi AI / pathfinding**.
  - **Bẫy bắt quái bị đẩy:** Chỉ khi quái đang ở trạng thái `PUSHED` va vào tâm Rune Anchor, lực đẩy bị hấp thụ (`velocity = Vector2.ZERO`), quái nhận 1 damage và bị giữ lại.

---

## 2. Phân kỳ Triển khai (Phased Delivery)

Theo kết luận phản biện của chủ dự án, F019 được phân tách thành các pha nhỏ kiểm chứng độc lập:
1. **F019A — Wave Layout Foundation:**
   - Cấu trúc dữ liệu 5 layout cố định trong `Config.ARENA_LAYOUTS`.
   - Chuyển đổi layout an toàn trong `PRE_WAVE` của `main.gd`.
   - Reset sạch layout về Wave 1 khi restart `_start_run()`.
   - Kiểm tra hình học: không đè Altar `(240, 90)`, không đè điểm spawn của Player `(240, 135)`.
2. **F019B — Spike Wall (Triển khai ưu tiên):**
   - Tận dụng hệ thống va chạm biên sẵn có trong `enemy_base.gd`.
   - Nhận diện phân loại bề mặt: `NORMAL_WALL` (1 dmg) vs `SPIKE_WALL` (2 dmg).
   - Đảm bảo quái chỉ nhận damage khi `enemy_state == EnemyState.PUSHED`.
   - Giải quyết va chạm góc: chỉ 1 `ImpactResult` duy nhất cho mỗi đợt PUSH, chống đa hit / re-trigger mỗi tick.
   - Thử nghiệm Heavy Push Tier 3 (700 px/s) không bị xuyên tường hoặc bỏ sót va chạm.
3. **F019C — Rune Anchor (Xuyên thấu, chỉ bắt quái bị PUSH):**
   - Vòng tròn năng lượng trên sàn đấu.
   - Không chặn AI thường, không kẹt Player/Dash.
4. **F019D — Solid Obstacles & Steering:**
   - **HOÃN LẠI** sang milestone sau khi có hệ thống pathfinding / steering riêng cho quái.

---

## 3. Contract Chi tiết

### R01 — Cơ chế Va chạm Spike Wall & Single Impact Resolution
```gdscript
# Chỉ kích hoạt khi quái đang bị đẩy
if enemy_state == EnemyState.PUSHED and not impact_processed:
    var hit_pos := position
    var is_spike := arena.is_spike_contact(hit_pos)
    var dmg := Config.DAMAGE_SPIKE_SLAM if is_spike else Config.DAMAGE_WALL_SLAM
    
    impact_processed = true
    velocity = Vector2.ZERO
    take_damage(dmg)
    wall_slammed.emit(hit_pos, is_spike)
```
- `impact_processed = true` khóa lập tức va chạm trong đợt đẩy hiện tại, reset về `false` khi quái nhận đợt `receive_push` mới.
- Ở góc sân (chạm cả tường X và tường Y): chỉ tính toán 1 lần duy nhất, nếu 1 trong 2 cạnh là Spike Wall thì ưu tiên Spike Wall.

### R02 — Quy định Bố cục 5 Wave Cố định (`Config.ARENA_LAYOUTS`)
- **Wave 1 ("Awakening"):** Sân cơ bản, 0 Spike Wall, 0 Rune Anchor.
- **Wave 2 ("The Hunt"):** Giới thiệu 2 Rune Anchors tại `(160, 160)` và `(320, 160)` (F019C).
- **Wave 3 ("Heavy Impact"):** Giới thiệu Spike Wall: 2 đoạn tường gai bên thành trái `(30, 90, 6, 60)` và thành phải `(444, 90, 6, 60)` (chiếm ~10% chu vi sân, buộc người chơi phải căn góc đẩy Brute).
- **Wave 4 ("The Swarm"):** 2 đoạn tường gai trên đỉnh 2 bên Altar: `(100, 30, 60, 6)` và `(320, 30, 60, 6)`.
- **Wave 5 ("Final Stand"):** 3 đoạn tường gai phân bổ chiến lược (Trái, Phải, Đáy), người chơi phải chọn góc đứng thay vì đẩy hướng nào cũng trúng gai.

### R03 — Chu kỳ Chuyển đổi Layout An toàn (Safe Transition Sequence)
Trình tự đổi layout:
$$\text{Wave Cleared} \to \text{Upgrade Selection} \to \text{Intermission (3s)} \to \text{PRE\_WAVE (1.2s: Gọi set\_layout)} \to \text{Spawn Phase}$$
- Không đổi layout khi người chơi đang chọn thẻ hoặc đang trong lúc combat.
- Khi Restart (`R`), gọi ngay `arena.set_layout(1)`.

---

## 4. Acceptance Matrix

| ID | Tiêu chí | Kiểm tra | Kỳ vọng chính xác | Trạng thái |
|---|---|---|---|---|
| AC01 | Spike Wall chỉ kích hoạt khi PUSH | Runtime | Quái đi thường chạm tường gai không nhận sát thương; chỉ nhận khi bị Pulse đẩy | PASS |
| AC02 | Spike Wall gây đúng 2 damage | Runtime | Quái Brute (2 HP) bị đẩy vào Spike Wall chết ngay lập tức (1-hit kill) | PASS |
| AC03 | Single Impact Resolution ở góc | Runtime | Quái va vào góc sân giao giữa tường thường và tường gai chỉ nhận duy nhất 2 damage, không bị cộng dồn thành 3 | PASS |
| AC04 | Không re-trigger mỗi physics tick | Runtime | Quái nằm sát tường gai sau impact không bị trừ máu liên tục qua từng frame | PASS |
| AC05 | Heavy Push Tier 3 không xuyên tường | Runtime | Quái ở vận tốc 700 px/s va vào Spike Wall được chặn lại an toàn, không lọt ra ngoài biên | PASS |
| AC06 | Layout áp dụng đúng phase PRE_WAVE | Runtime | Layout chỉ đổi khi bắt đầu PRE_WAVE; không đổi đột ngột giữa trận | PASS |
| AC07 | Reset sạch sẽ khi chơi lại | Runtime | Nhấn R: sân lập tức quay về layout Wave 1 (không còn tường gai của Wave 3/4/5) | PASS |
| AC08 | Tọa độ hợp lệ & không đè Altar | Logic/Unit | Toàn bộ hazard nằm hoàn toàn trong sân và cách Altar tối thiểu 30 px | PASS |

## 5. Approval

- Chủ dự án đã nghiệm thu và phê duyệt (2026-09-09). Toàn bộ tiêu chí đạt yêu cầu.
