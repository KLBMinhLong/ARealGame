# Technical specification

## Stack khóa cho starter

- Engine: `v4.6.3.stable.official [7d41c59c4]`, theo người dùng. Kiểm tra binary thực tế trước khi thay đổi.
- GDScript; renderer GL Compatibility; không C#, plugin, npm, backend hoặc network request.
- Mục tiêu đầu tiên: Windows x86_64, bàn phím; logical viewport 1152×648, stretch canvas_items + keep aspect.
- Physics tick 60; giới hạn render 60 FPS qua `Engine.max_fps`. Đây là cấu hình mục tiêu, không phải đo được 60 FPS trên máy người dùng.

## Cấu trúc runtime thật

```text
Main (Node2D)                         scripts/main.gd
├── Arena (Node2D)                    scripts/world/arena.gd
├── World (Node2D)
│   ├── Enemies (Node2D)              Main thêm enemy.tscn lúc chạy
│   └── Player (Node2D)               scenes/player.tscn → actors/player.gd
└── HUD (CanvasLayer)                 scripts/ui/hud.gd
    └── Root (Control)               được tạo bằng code ở HUD._ready()
        ├── các nhãn HUD
        ├── Shade (ColorRect)
        └── PanelContainer
            └── VBoxContainer → nhãn và nút
```

`scenes/main.tscn` là main scene trong project settings. Các đường dẫn `$World/Player`, `$World/Enemies`, `$HUD` là contract của main.gd; đổi tên node phải đổi wiring và test cùng lúc.

## Sở hữu trách nhiệm

| File | Chịu trách nhiệm | Không chịu trách nhiệm |
|---|---|---|
| `scripts/core/game_config.gd` | Hằng số, clamp, spawn sampling, độ khó | UI, scene lifecycle |
| `scripts/main.gd` | State machine, thứ tự tick, spawn, end run, wiring | Vẽ hình chi tiết, save chưa có |
| `scripts/actors/player.gd` | Input vector, move, HP, grace timer, draw | Tự kết luận thắng/thua |
| `scripts/actors/enemy.gd` | Di chuyển về mục tiêu và draw | Tự spawn, tự xử lý pause |
| `scripts/world/arena.gd` | Nền, lưới, biên sân | Va chạm physics |
| `scripts/ui/hud.gd` | Nhãn/nút/modal, phát signal từ thao tác UI | Đổi state trực tiếp |

## Wiring bắt buộc

```text
project.godot Input Map
   ↓ Input.get_vector(...) trong Player.tick(delta)
Main._physics_process(delta)
   ├─ Player.tick → move_by → clamp_inside
   ├─ elapsed → kiểm tra thắng
   ├─ spawn_one → enemy.tscn.instantiate → Enemies.add_child
   ├─ Enemy.tick → kiểm tra khoảng cách → register_hit
   │                                     └─ Player.take_hit → health_changed
   └─ HUD.update_run                                  ↓
                                               HUD.set_health

HUD.start_requested  → Main.start_run
HUD.resume_requested → Main.resume_run
HUD.menu_requested   → Main.return_to_menu
HUD.quit_requested   → SceneTree.quit
```

Signal được nối bằng code trong `_ready()`, không có bước nối tay còn thiếu trong editor. Node UI được tạo bằng code nên sẽ xuất hiện ở Remote scene tree khi chạy, không nằm sẵn dưới HUD trong scene tree local.

## State machine

MENU → RUNNING → PAUSED → RUNNING. RUNNING → WON hoặc LOST. Màn kết quả có thể start_run lại hoặc về MENU. Không có active gameplay tick ngoài RUNNING.

Không dùng `SceneTree.paused` ở starter; Main là chủ vòng tick và return ngay khi không RUNNING. Player/Enemy không có `_physics_process` riêng. Nếu thêm Timer/Tween/AnimationPlayer/audio về sau, phải kiểm tra pause của thành phần mới vì nó không tự được pause bởi state này.

## Va chạm và tọa độ

Player và Enemy đều là **Node2D**, không phải CharacterBody2D/Area2D. Chạm dựa trên khoảng cách tâm ≤ tổng bán kính; biên sân dùng clamp. Đây là quyết định đơn giản hóa cho sân trống, không phải collision engine tổng quát. Nếu thêm tường/chướng ngại cần ADR và chuyển sang physics có chủ đích, không pha trộn hai cách một cách vô thức.

Actors dùng tọa độ local dưới `World`; World có transform identity. Arena dùng cùng hệ tọa độ. Đổi transform World phải cập nhật phép đo khoảng cách/spawn hoặc dùng global_position nhất quán.

## Reset/retry

`_clear_enemies` gỡ child khỏi container trước khi queue_free, vì vậy bộ đếm trở về 0 ngay. `start_run` reset HP, grace, thời gian và spawn delay. HUD không reload scene; signal không được nối lại mỗi lần retry.

## Input contract

- `move_left`: physical A + Left.
- `move_right`: physical D + Right.
- `move_up`: physical W + Up.
- `move_down`: physical S + Down.
- `pause_game`: Esc.
- `restart_game`: R, chỉ màn kết quả.
- Các action xung và remap phím ở v1 chưa được tạo; không nói đã có.

## Save/settings tương lai

Dùng `user://` và ConfigFile hoặc JSON có schema_version. Không ghi save vào `res://`. Validate kiểu/dải, fallback khi file mất/hỏng, cập nhật nguyên tử theo khả năng nền tảng, test không quyền ghi. Không lưu định danh cá nhân. Chưa có file save manager trong starter; T310/T320 sẽ thêm đúng nhu cầu.

## Export

`export_presets.cfg` có preset Windows Desktop x86_64. PCK chưa nhúng vào exe; khi export phải gửi cả `.exe` và `.pck` cùng các file bắt buộc được sinh ra. Không đổi tên exe một mình sau export. Tắt resource modification/signing ở starter để không phụ thuộc rcedit/chứng chỉ. Mã nguồn docs/tests/tools loại khỏi export qua filters; vẫn phải kiểm tra nội dung bản build trước phát hành.

Export templates phải phù hợp engine thực tế. Không đính kèm engine/template vào ZIP này, không tự tải bản khác. Cách xác minh: `docs/RELEASE_CHECKLIST.md`.

## Quy ước chỉnh sửa

Tab trong GDScript, snake_case cho biến/hàm/file, tên node PascalCase. `.gd.uid` do Godot tạo cần lưu Git; `.godot/` là cache cần bỏ. Không tái tạo UID để che lỗi đường dẫn. Tách module khi có trách nhiệm thực sự, không chia hàng chục file rỗng.
