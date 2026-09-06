# Art & audio direction (v1 Final Specification)

## 1. Triết lý thẩm mỹ thị giác (Visual Direction)

Trò chơi áp dụng phong cách **Minimalist Sci-Fi Radar Lab**:
- Toàn bộ đồ họa được dựng bằng hình học vector thuần túy (`_draw()`), giúp tối ưu hóa hiệu năng tuyệt đối (60 FPS mượt mà trên laptop i5/8GB RAM/Iris Xe mà không cần tải texture nặng).
- **Phân biệt hình dạng (Silhouette):** Không chỉ phân biệt bằng màu mà phân biệt bằng hình dạng rõ rệt:
  - **Player Drone:** Hình tròn bán kính 14px, màu Cyan (`#64b7ff`), có kim định hướng buồng lái góc nhọn (`#102230`), vòng bảo hộ khi trúng đòn (`#f2e5be`), vòng cung sạc Space Pulse (`#64b7ff`), và sóng xung kích Shockwave lan tỏa đến 120px.
  - **Chaser Drone:** Hình thoi (diamond) bán kính 12px, màu cam hổ phách (`#ff9f43`), lõi xoay cảnh báo.
  - **Sprinter Drone:** Mũi tên tam giác sắc nhọn bán kính 12px, màu đỏ tươi (`#ff4757`), có tia laser cảnh báo (Telegraph) 1200px đỏ rực trước khi lao.
- **Không gian đấu trường (Arena):** Nền xanh than công nghệ (`#080f14`), viền bo đấu trường (`#182a37`) kích thước 1072×480 px, tách biệt hoàn toàn với thanh HUD trạng thái.
- **Giao diện người dùng (UI / HUD):**
  - Sử dụng typography tương phản cao: Màu mực sáng (`#eef5fa`), màu phụ (`#afc2d0`), màu hổ phách kỷ lục (`#ffe5ad`).
  - Nút bấm chuẩn tối thiểu 44px logical height với hiệu ứng hover/pressed/focus rõ ràng.
  - Hỗ trợ chế độ **Reduced Effects** (giảm độ gắt của chớp sáng và sóng xung kích, bảo vệ thị giác người chơi).

## 2. Định hướng âm thanh & Danh mục SFX (Audio Direction & SFX Inventory)

Âm thanh được thiết kế ngắn gọn, đanh chắc, phong cách tương lai (cyberpunk/radar tech), không gây chói tai hay mệt mỏi khi chơi lặp lại:

| Mã SFX | Mục đích | Mô tả âm thanh | Độ dài | Mức âm lượng chuẩn |
|---|---|---|---|---|
| `pulse` | Kích hoạt sóng đẩy Space | Tiếng sóng siêu âm trầm (Whoosh / Sub-bass pulse) | ~0.25s | -3.0 dB |
| `hit` | Drone va chạm / Mất máu | Tiếng va chạm cảnh báo kim loại (Hull breach thud) | ~0.18s | -2.0 dB |
| `telegraph` | Sprinter chuẩn bị lao | Tiếng laser sạc tần số cao tăng dần (Charge alert) | ~0.55s | -4.0 dB |
| `dash` | Sprinter phóng qua sân | Tiếng rít xé gió tốc độ cao (Sonic rush) | ~0.35s | -3.0 dB |
| `win` | Sống sót đủ 03:00 | Hợp âm ngân vang chiến thắng (Victory chime) | ~0.80s | -2.0 dB |
| `game_over` | Mất toàn bộ 3 Hull | Tiếng tụt áp ngắt nguồn hệ thống (Power-down tone) | ~0.60s | -3.0 dB |

## 3. Kiến trúc Audio Buses (sẽ triển khai trong T330)

Hệ thống quản lý âm thanh qua 3 audio bus riêng biệt:
- **Master Bus:** Điều chỉnh tổng thể, có Compressor / Limiter để chống clipping âm thanh khi nhiều tiếng động phát cùng lúc.
- **Music Bus:** Kênh dự trữ cho nhạc nền / ambient loop nền tĩnh.
- **SFX Bus:** Điều khiển độc lập âm lượng các hiệu ứng âm thanh trong trận đấu.
- **Tương thích:** Đồng bộ tức thời với `user://settings.cfg` qua `settings_manager.gd` (thanh trượt Master & SFX Volume).

## 4. Quản lý bản quyền tài nguyên

- 100% tài nguyên đồ họa tự tạo qua GDScript.
- Tài nguyên âm thanh sử dụng thuật toán tạo sóng trực tiếp hoặc mẫu âm thanh CC0 Public Domain / MIT, được đăng ký chi tiết trong `docs/ASSET_REGISTER.md`.
