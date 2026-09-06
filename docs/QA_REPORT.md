# Báo cáo kiểm tra bộ ZIP

**Ngày:** 05/09/2026. Đây là kiểm tra trong môi trường tạo file, KHÔNG phải trên laptop chủ project.

## Kết quả thực tế

| Hạng mục | Trạng thái | Bằng chứng / giới hạn |
|---|---|---|
| File bắt buộc, resource path, scene resource ID, main scene, renderer, Input Map, link Markdown, độ dài rule | PASS | Static checker; log đi kèm ở docs/qa/static-check.txt |
| Cú pháp Python của static checker | PASS | Đã chạy py_compile; file bytecode không đóng gói |
| Mapping phím mũi tên trong project | PASS ở mức soát cấu hình | Đã đối chiếu mã Left/Up/Right/Down và thêm test so với KEY_* của engine; test engine chưa chạy |
| Hướng dẫn HTML | Đã kiểm tra hình ảnh | Desktop 1440px, mobile 390px với details mở, chế độ sáng/tối; không thấy tràn/chồng nội dung; bộ chụp không báo console/resource error |
| Tương phản chữ chính của hướng dẫn HTML | PASS | Các cặp chữ/nền chính được tính và đều đạt mức 4.5:1 trở lên |
| Godot 4.6.3 import/parse | NOT RUN | Môi trường tạo file không cài Godot executable; không thay thế bằng kiểm tra Python |
| Smoke runtime qua Godot | NOT RUN | tests/smoke_test.gd đã viết nhưng chưa được chạy trong engine ở đây |
| Chơi/visual QA game | NOT RUN | Screenshot của trang hướng dẫn không phải screenshot game và không chứng minh game chạy |
| Wrapper PowerShell trên Windows | NOT RUN | Mã runner đi kèm; môi trường tạo file không phải máy Windows của người dùng |
| Export Windows/exe/PCK | NOT RUN | Chưa có engine + templates đúng bản; ZIP không chứa executable game |
| Hiệu năng i5/8GB/Iris Xe | NOT MEASURED | Cần test laptop thật; các FPS/cap trong tài liệu là mục tiêu/cấu hình |
| Antigravity tự nhận rule trên máy bạn | NEEDS LOCAL CHECK | Đã đối chiếu tài liệu chính thức; cần bật/kiểm tra Workspace Rule qua UI |

Kiểm tra static KHÔNG chứng minh cú pháp GDScript, API của engine, vận hành game hoặc chất lượng gameplay. Thao tác copy prompt từ HTML còn phụ thuộc quyền clipboard của trình duyệt; luôn có phương án chọn văn bản và Ctrl+C.

## Hạn chế sản phẩm có chủ đích

Prototype geometry; chưa audio/save/settings hoàn chỉnh; một kiểu quái; chưa xung đẩy; chưa kiểm chứng độ vui/khả năng bán. Không kèm engine, export templates hoặc binary. Những phần này được phân giai đoạn trong TASKS, không được ghi là đã hoàn thành.

## Cổng người dùng phải chạy

1. T001: đối chiếu executable/version/hash thực, không bỏ qua mismatch một cách máy móc.
2. T002: Godot import → smoke success marker → startup log không lỗi.
3. T003: kiểm thử manual/visual trên máy bạn, bao gồm mũi tên, pause, retry và lượt đầy đủ.
4. Trước release: xuất Windows và chơi bản export từ thư mục sạch.

Nếu import báo lỗi, dùng prompts/03_FIX_BUG.md cùng lỗi đầu tiên, file/dòng và version. Không xem thiếu runtime verification là lý do đổi engine hoặc dựng lại cả project.

## Tính toàn vẹn gói

FILE_MANIFEST.txt liệt kê mọi file. SHA256SUMS.txt chứa hash của các file còn lại. ZIP được mở lại, kiểm CRC và đối chiếu nội dung với hash sau đóng gói. Đây là kiểm tra toàn vẹn file, không phải quét malware hoặc chứng nhận tương thích runtime.

---

## Nghiệm thu Kỹ thuật & Chất lượng Giai đoạn 2 (G0 - G2)

**Thời gian:** 06/09/2026  
**Môi trường chạy thật:** Windows 10/11, Godot Engine v4.6.3.stable.official.7d41c59c4 (`D:\InstallProgram\Gotdot\Godot_v4.6.3-stable_win64.exe`).

### 1. Cổng G0 (Kỹ thuật nền tảng & Khắc phục nợ kỹ thuật R01 - R05)
- **R01 (Save & Settings Isolation):** `tests/smoke_test.gd` được cấu hình đường dẫn test riêng (`test_smoke_save_data.json` & `test_smoke_settings.cfg`). Đã kiểm tra đối chiếu mã băm SHA256: file lưu thật của người chơi (`user://save_data.json` và `user://settings.cfg`) được bảo toàn nguyên vẹn 100%, không bị test ghi đè.
- **R02 (Trần 64 quái & Bế tắc Spawner):** Đã giải quyết triệt để thông qua cơ chế diệt quái cốt lõi (Xung công phá đập tường / nổ dây chuyền rơi phế liệu). Số lượng quái luôn được dọn dẹp liên tục để nhường chỗ cho quái late-game.
- **R03 (Boundary Clipping Laser):** Raycast cảnh báo của Sprinter được kẹp chặt chẽ theo biên thực tế `Config.PLAYFIELD` của sân chơi, không còn tràn ra vô cực ngoài màn hình.
- **R04 (Bản quyền & Pháp lý):** Toàn bộ asset tự sinh theo thuật toán procedural toán học (sin/saw/triangle synth âm thanh và vector pixel canvas item), không vi phạm giấy phép bên thứ ba.
- **R05 (Atomic Save):** SaveManager ghi file an toàn qua file trung gian `.tmp` và đổi tên/ghi đè nguyên tử, ngăn chặn tình trạng hỏng file lưu nếu game crash giữa chừng.

### 2. Cổng G1 (Đặc tả thiết kế & Định hướng thương mại)
- Đã hoàn tất 4 tài liệu đặc tả sản phẩm: `GAME_BRIEF.md`, `TECH_SPEC.md`, `ART_AUDIO.md`, `TASKS.md`.
- Chốt 4 trụ cột cốt lõi: Xung công phá (sát thương đập tường/nổ dây chuyền), AI bầy đàn (flocking cụm quái), Công thức tăng tiến Scrap cấp số nhân, Tiến trình dài hạn (Meta-progression xưởng nâng cấp vĩnh viễn & mô hình kiếm tiền cosmetic skin).
- Chốt phong cách thẩm mỹ: `Modern Pixel Art + Industrial Sci-Fi + Neon + Scrap/Robot + Chibi Cute Droid`.

### 3. Cổng G2 (Vertical Slice Lõi Từ)
- **Kiểm thử tự động Static:** `python tools/verify_structure.py` -> **82/82 checks PASS**.
- **Kiểm thử tự động Runtime Engine:** `tools/verify.ps1 -GodotExe ...` -> **139/139 checks PASS** (`ALL_TESTS_PASSED: 139 checks`, exit code 0).
- **Hệ thống đã triển khai thực tế trong engine:**
  1. *Player Actor:* Droid "Scrappy" thiết kế chi tiết với vỏ hợp kim tối, kính visor Chibi, mắt phát sáng Cyan, ống phản lực xả ion phía sau, khiên năng lượng Aegis khi nhận sát thương, và vòng nạp xung lực.
  2. *Enemy Actors:*
     - Chaser ("Crawler Droid"): Bánh xích công nghiệp, càng kẹp phế liệu sắt, vỏ giáp bát giác, mắt cảm biến Cyclops đỏ rực nguy hiểm (chập điện vàng khi bị choáng).
     - Sprinter ("Razor Jet"): Cánh tiêm kích dơi tàng hồ kim loại titan tối màu, rãnh tản nhiệt neon cam, ống xả lửa phản lực đa pha (Stalk, Telegraph, Dash, Rest), laser cảnh báo kẹp chuẩn biên.
  3. *Arena:* Nền kim loại công nghiệp tối (`#10141a`), lưới đinh tán rivet, trạm tái chế trung tâm, vạch cảnh báo chevron ở các góc, hàng rào điện từ trường neon Cyan bảo vệ.
  4. *Scrap Engine:* Rơi bánh răng cơ khí vàng kim phát sáng, tự động bị hút về phía người chơi theo bán kính nam châm khi đến gần, cộng dồn Scrap vào thanh hiển thị HUD.
  5. *Level-Up Modal & Upgrades:* Đạt đủ ngưỡng Scrap tự động tạm dừng mượt mà và hiển thị bảng 3 lựa chọn ngẫu nhiên có hỗ trợ phím tắt [1, 2, 3]:
     - Kinetic Overdrive (Xung công phá: tăng lực hất văng quái + sát thương va tường).
     - Magnetizer (Mở rộng trường hút Scrap).
     - Rapid Capacitor (Giảm thời gian hồi chiêu xung Space).
     - Expansion Coil (Mở rộng bán kính xung đẩy).
     - Aegis Plating (Tăng thời gian khiên bảo vệ bất tử).
  6. *Audio & Music:*
     - Nhạc nền procedural Synthwave 128 BPM chạy trên Audio Bus "Music".
     - SFX nhặt Scrap, SFX đập tường vỡ nát, SFX thăng cấp nâng cấp.
     - Slider chỉnh âm lượng riêng cho Music và SFX trong Settings Panel.
  7. *Game Feel & Camera Trauma:* Màn hình rung giật gián đoạn (trauma quadratic decay) khi phát xung cực đại hoặc khi quái bị đập nát vào tường, mang lại cảm giác lực va đập cực mạnh.

