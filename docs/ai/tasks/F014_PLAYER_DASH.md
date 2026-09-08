# F014 — Player Dash (Tactical Dodge)

**Status:** IMPLEMENTING
**Owner approval:** GRANTED (2026-09-08)
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Người chơi có thêm kỹ năng lướt cơ động: **Dash (Lướt né)**:
- **Phím kích hoạt:** Phím `Shift` (bàn phím) hoặc `Click chuột phải` (chuột).
- **Hành vi:** Lướt nhanh tức thì theo hướng di chuyển (hoặc hướng nhìn gần nhất nếu bấm Shift khi đứng yên; hoặc hướng trỏ chuột nếu bấm chuột phải).
- **Tốc độ & Khoảng cách:** Tốc độ 360 px/s trong 0.15s (~54px, tương đương 4.5 thân nhân vật). Tốc độ lướt thay thế tốc độ chạy thường (không cộng dồn).
- **Phòng thủ & Va chạm:** 
  - Miễn sát thương va chạm quái trong suốt 0.15s lướt (i-frame).
  - Nhân vật di chuyển xuyên qua quái an toàn trong lúc lướt (vì quái và player trong game dùng khoảng cách phát hiện sát thương, không có vật cản thể tích quái).
  - Nếu kết thúc lướt ngay trong phạm vi của quái, player sẽ nhận sát thương ngay ở frame kế tiếp.
  - Vẫn bị chặn bởi 4 bức tường ngoài của arena. Chạm tường sẽ dừng lướt và kết thúc bất tử sớm, vẫn tiêu hao cooldown.
- **Tách biệt bất tử:** Miễn sát thương do Dash hoàn toàn độc lập với thời gian bất tử sau khi dính đòn (Grace period). Hết Dash không xóa Grace period; hết Grace period không làm mất bảo vệ của Dash.
- **Hồi chiêu:** Thử nghiệm ban đầu **2.0s** (để so sánh với 1.2s). Hiển thị trạng thái `Dash: READY` hoặc `Dash: X.Xs` trên HUD.
- **Tương tác với Pulse:** Cho phép bấm Pulse trong lúc Dash để chọn góc đẩy linh hoạt. Pulse phát từ vị trí thực tế của player lúc nhấn. Bấm cả hai nút cùng lúc xử lý độc lập, không lặp.
- **Game Feel:** Để lại các bóng mờ cyan (ghost trail) cố định tại tọa độ world, mờ dần phía sau nhân vật.

## 2. Scope / Non-goals

- **Có:**
  - Cấu hình action `dash` trong `project.godot` (Shift và Right Mouse Button).
  - Constants trong `game_config.gd` (`DASH_SPEED = 360.0`, `DASH_DURATION = 0.15`, `DASH_COOLDOWN = 2.0`, `DASH_GHOST_INTERVAL = 0.03`, `DASH_GHOST_LIFETIME = 0.2`).
  - Xử lý chuyển động, hướng lướt, va tường sớm, i-frames độc lập và ghost trail trong `scripts/actors/player.gd`.
  - Cập nhật hiển thị `Dash` trên thanh HUD trong `scripts/ui/hud.gd`.
  - Truyền `dash_cooldown_left` từ `main.gd` sang `hud.gd`.
- **Không:**
  - Dash gây sát thương lên quái.
  - Dash đẩy lùi quái.
  - Dash xuyên tường biên arena.
  - Tăng sức mạnh quái để bù cho Dash.

## 3. Discovery

| Fact | Giá trị | Nguồn | Label |
|---|---|---|---|
| Cấu trúc body player & quái | Cả hai là `Node2D`, không dùng `CharacterBody2D` hay `CollisionShape2D`. Quái không cản bước đi của player về mặt vật lý; chỉ gây contact damage khi khoảng cách `< radius` | `player.gd:4`, `enemy_base.gd:5, 62` | VERIFIED_IN_REPO |
| Cơ chế bất tử hiện tại | Biến `grace_timer` và `is_invulnerable` trong `player.gd:14-15, 95-114` | `player.gd:14, 95` | VERIFIED_IN_REPO |
| Địa hình arena | Chỉ có 4 tường biên bao quanh (`ARENA_ORIGIN` đến `ARENA_END`) và bàn thờ Altar ở tâm-trên (không chặn player). Không có cột/vật cản bên trong | `arena.gd:11-42`, `game_config.gd:16-20` | VERIFIED_IN_REPO |
| Viewport & kích thước | 480×270 px. Player 12×12 px (`PLAYER_HALF = 6`). Tốc độ thường 120 px/s | `game_config.gd:8, 23-26` | VERIFIED_IN_REPO |
| Time domain & Pause | Game chạy trong `_process(delta)`. Khi pause, cây gameplay dừng lại. Hitstop dùng `Engine.time_scale` ảnh hưởng đồng bộ mọi delta | `main.gd:31-35`, `hitstop_system.gd` | VERIFIED_IN_REPO |

## 4. Contract

### R01 — Input & Khóa Hướng
- Action `dash` gán cho phím `Shift` và `Click chuột phải`.
- Chỉ kích hoạt khi `event.is_action_pressed("dash")` (vừa nhấn, không auto-repeat khi giữ phím).
- Chỉ kích hoạt khi `dash_cooldown_left <= 0.0`, `not is_dashing`, `state == GameState.RUNNING`, và `hp > 0`.
- Hướng lướt (`dash_direction`):
  - Nếu đang giữ phím di chuyển (`input_dir.length_squared() > 0.01`): `dash_direction = input_dir.normalized()`.
  - Nếu đứng yên và kích hoạt bằng Shift: `dash_direction = last_facing_dir` (tránh bất ngờ vì vị trí chuột cũ).
  - Nếu đứng yên và kích hoạt bằng chuột phải: `dash_direction = (mouse_pos - player_pos).normalized()`. Nếu chuột trùng player (`dist < 4px`): dùng `last_facing_dir`.
- Hướng được khóa cố định trong suốt 0.15s, không thể bẻ lái giữa chừng.

### R02 — Tốc độ, Quãng đường & Va chạm Biên Arena
- Tốc độ: `360.0 px/s` thay thế tốc độ chạy thường (không cộng dồn). Thời lượng tối đa `0.15s`. Quãng đường tối đa ~54px.
- Vị trí cập nhật: `position += dash_direction * Config.DASH_SPEED * delta`.
- Biên arena: Player không vượt qua bốn biên ngoài, có tính kích thước thân nhân vật (`Config.PLAYER_HALF = 6px`).
- Bị chặn bởi biên: Chỉ khi Dash bị biên CHẶN THEO HƯỚNG LƯỚT (`dash_direction` hướng vào biên đã chạm, ví dụ `dash_direction.x < 0` khi chạm biên trái):
  - Kẹp vị trí tại mép biên.
  - Dash và phần bảo vệ của Dash kết thúc sớm; cooldown vẫn tiêu hao bình thường.
- Lướt dọc biên: Đang sát tường nhưng lướt song song (ví dụ sát tường trái nhưng lướt lên/xuống) hoặc lướt ra xa tường KHÔNG tự động hủy Dash.

### R03 — Miễn Sát Thương, Xuyên Quái & Kết Thúc Dash
- Miễn sát thương: Player miễn sát thương va chạm quái khi Dash còn hiệu lực, tối đa 0.15 giây. Phần bảo vệ này độc lập với bất tử sau khi nhận damage (`grace_timer`).
- Xuyên quái: Player có thể di chuyển xuyên qua quái trong Dash vì quái không chặn chuyển động bằng collider vật lý. Không thay đổi cơ chế collision hoặc phát hiện sát thương chung.
- Kết thúc Dash: Chỉ gỡ phần miễn sát thương do Dash (`is_dashing = false`). Từ lần kiểm tra contact damage tiếp theo trong vòng cập nhật vật lý, player có thể nhận sát thương nếu vẫn nằm trong phạm vi gây damage của quái và không còn nguồn bảo vệ khác. Không tự gây damage chỉ vì Dash kết thúc.
- Hàm kiểm tra: `func is_damage_immune() -> bool: return grace_timer > 0.0 or is_dashing`.
- Khi dính đòn: nếu `is_damage_immune()` thì bỏ qua. Hết Dash không xóa `grace_timer`; hết `grace_timer` không làm mất bảo vệ của Dash.

### R04 — Tương tác Dash và Pulse
- Trong lúc Dash, player VẪN ĐƯỢC PHÉP bấm Pulse nếu `pulse_cooldown_left <= 0.0`.
- Pulse phát ra tại vị trí tọa độ thực tế của player tại frame bấm.
- Radius, force, cooldown của Pulse giữ nguyên. Dash không tự kích hoạt Pulse và không reset cooldown Pulse.
- Bấm cả hai nút cùng lúc: xử lý cả hai độc lập tại frame đó, không bị lặp.

### R05 — Ghost Trail (Vệt bóng mờ)
- Cứ mỗi 0.03s trong lúc Dash, ghi nhận một bóng mờ tại tọa độ world: `{ "world_pos": global_position, "alpha": 0.6 }`.
- Tối đa 5 bóng. Mỗi bóng mờ dần và tự hủy sau 0.2s.
- Trong `_draw()`: chuyển sang tọa độ local `to_local(ghost.world_pos)` để bóng nằm lại đúng vị trí world mà nhân vật vừa đi qua.
- Xóa sạch danh sách bóng khi restart hoặc reset run.

### R06 — Cooldown & Reset
- Cooldown thử nghiệm: `2.0s`. Bắt đầu tính ngay khi Dash được kích hoạt.
- Reset khi restart run: `is_dashing = false`, `dash_timer = 0.0`, `dash_cooldown_left = 0.0`, `ghost_trail.clear()`.
- HUD hiển thị: `Pulse: READY / CD   Dash: READY / CD`.

## 5. Plan nhỏ nhất

| File | Thay đổi |
|---|---|
| [MODIFY] `project.godot` | Thêm input action `dash` (Shift + Right Mouse Button) |
| [MODIFY] `scripts/core/game_config.gd` | Thêm hằng số `DASH_SPEED`, `DASH_DURATION`, `DASH_COOLDOWN = 2.0`, `DASH_GHOST_*` |
| [MODIFY] `scripts/actors/player.gd` | Tách i-frame, logic Dash có khóa hướng, dừng sớm khi va tường, ghost trail |
| [MODIFY] `scripts/ui/hud.gd` | Hiển thị Dash cooldown trên thanh trạng thái |
| [MODIFY] `scripts/main.gd` | Truyền `dash_cooldown_left` vào `hud.update_hud()` |

## 6. Acceptance

| ID | Observable behavior | Check | Expected | Status |
|---|---|---|---|---|
| AC01 | Kích hoạt Dash | Runtime | Nhấn Shift hoặc Click phải phóng nhanh 360 px/s trong 0.15s (~54px) | NOT_RUN |
| AC02 | Hướng nhất quán | Runtime | Lướt ngang/chéo cùng tốc độ; không bẻ lái giữa chừng; đứng yên Shift theo hướng nhìn gần nhất; đứng yên Click phải theo chuột | NOT_RUN |
| AC03 | Input an toàn | Runtime | Giữ Shift không tự dash lại; bấm Shift + Right Click đồng thời chỉ tạo 1 Dash | NOT_RUN |
| AC04 | Lướt qua quái an toàn | Runtime | Lướt xuyên qua quái không mất máu trong lúc đang dash | NOT_RUN |
| AC05 | Kết thúc trong quái nhận damage | Runtime | Dash dừng lại ngay trên quái sẽ nhận damage ở frame kế tiếp | NOT_RUN |
| AC06 | Chạm tường dừng sớm | Runtime | Dash đâm thẳng vào tường ngoài bị chặn lại, dừng dash ngay, không lọt ra ngoài | NOT_RUN |
| AC07 | Lướt dọc/ra xa biên | Runtime | Đang đứng sát tường nhưng lướt song song mép tường hoặc hướng ra xa tường không bị hủy Dash sớm | NOT_RUN |
| AC08 | Tách biệt bất tử | Runtime | Bị đánh rồi Dash ngay: hết Dash vẫn còn nhấp nháy bất tử của Grace period; hết Grace period trong lúc Dash không làm mất bảo vệ của Dash | NOT_RUN |
| AC09 | Pulse trong lúc Dash | Runtime | Đang Dash bấm Space vẫn nổ Pulse từ vị trí hiện tại của player | NOT_RUN |
| AC10 | Ghost trail cố định world | Runtime | Vệt bóng mờ cyan nằm lại phía sau tại đúng vị trí đã đi qua, mờ dần rồi mất | NOT_RUN |
| AC11 | Cooldown 2.0s & HUD | Runtime | Cooldown 2 giây đếm ngược trên HUD, không thể spam | NOT_RUN |
| AC12 | Lifecycle & Reset | Runtime | Chết/Restart/Pause giữa lúc Dash không gây kẹt trạng thái hay sót bóng mờ | NOT_RUN |

## 7. Approval

- Chờ chủ dự án duyệt bản brief chi tiết.
