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

## Wiring hiện tại và Cổng G2

```text
project.godot Input Map (move_*, pause_game, restart_game, pulse)
   ↓
Main._physics_process(delta) [khi state == RUNNING]
   ├─ Player.tick → move_by → clamp_inside
   ├─ Player.tick_cooldowns (Pulse cooldown)
   ├─ elapsed → kiểm tra thắng (180s)
   ├─ spawn timer → spawn_one (Chaser & Sprinter)
   ├─ Enemies.tick(delta, player_pos)
   │     ├─ Chaser: Flocking bầy đàn + đuổi theo người chơi
   │     └─ Sprinter: Stalk → Telegraph (laser) → Dash → Rest
   ├─ Xử lý Xung Space Pulse:
   │     ├─ Đẩy quái trong bán kính ra xa, áp dụng Stun
   │     ├─ Va chạm quái vào tường (Wall Slam) → Sát thương va đập / Nổ sinh Scrap
   │     └─ Va chạm quái với quái (Domino Collisions) → Truyền động lượng + Nổ lan
   ├─ Thu thập Scrap từ tính:
   │     ├─ Scraps hút về người chơi khi vào bán kính nam châm
   │     └─ Đạt ngưỡng Scrap → Kích hoạt Upgrade Modal (3 lựa chọn tăng sức mạnh)
   ├─ Va chạm quái - player → Player.take_hit (nếu không trong thời gian bất tử)
   └─ HUD.update_run / update_pulse_cooldown / update_scrap_progress

HUD.start_requested    → Main.start_run
HUD.resume_requested   → Main.resume_run
HUD.menu_requested     → Main.return_to_menu
HUD.settings_requested → HUD.show_settings_panel
HUD.credits_requested  → HUD.show_credits_panel
HUD.upgrade_selected   → Main.apply_upgrade
```

## State machine

MENU → RUNNING → PAUSED → RUNNING.  
RUNNING → UPGRADE_SELECT (làm chậm bullet-time/tạm dừng để chọn nâng cấp) → RUNNING.  
RUNNING → WON hoặc LOST.  
Màn kết quả có thể start_run lại (R) hoặc về MENU.

## Input contract

- `move_left`: physical A + Left.
- `move_right`: physical D + Right.
- `move_up`: physical W + Up.
- `move_down`: physical S + Down.
- `pause_game`: Esc.
- `restart_game`: R (màn kết quả hoặc retry nhanh).
- `pulse`: Space (kích hoạt sóng xung kích từ trường).

## Quản lý Dữ liệu & Lưu trữ (Save & Settings)

- `scripts/core/save_manager.gd`: Lưu trữ `best_survival_seconds`, `win_count`, `total_runs` (chuẩn bị mở rộng schema v2 lưu `core_chips` và nâng cấp vĩnh viễn) vào `user://save_data.json`.
- `scripts/core/settings_manager.gd`: Lưu trữ `master_volume`, `sfx_volume`, `fullscreen`, `reduced_effects` (chuẩn bị thêm `music_volume`) vào `user://settings.cfg`.
- Hỗ trợ Dependency Injection đường dẫn tùy biến (`custom_save_path`, `custom_settings_path`) để cô lập 100% môi trường test tự động, không can thiệp save thật của người chơi.

## Quy ước chỉnh sửa

Tab trong GDScript, snake_case cho biến/hàm/file, tên node PascalCase. `.gd.uid` do Godot tạo cần lưu Git; `.godot/` là cache cần bỏ. Không tái tạo UID để che lỗi đường dẫn. Tách module khi có trách nhiệm thực sự, không chia hàng chục file rỗng.

