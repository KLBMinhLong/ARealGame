# Vòng Vây — bộ khởi đầu làm game với AI

**Dành cho:** người mới dùng Godot, làm việc với Antigravity IDE.
**Engine theo thông tin bạn cung cấp:** `v4.6.3.stable.official [7d41c59c4]`.
**Ngày chuẩn bị:** 05/09/2026.
**Mục tiêu máy phát triển:** i5-1135G7, RAM 8 GB, Intel Iris Xe. Đây là mục tiêu kiểm thử, không phải kết quả benchmark.

> Đây là mã nguồn starter và bộ tài liệu phát triển, KHÔNG phải bản game thương mại hoàn thiện. Ý tưởng “Vòng Vây” là mẫu mặc định để bắt đầu; tên và phạm vi sản phẩm cần bạn duyệt. Đọc [báo cáo kiểm tra](docs/QA_REPORT.md) để biết chính xác phần nào đã được kiểm chứng.

## Bắt đầu từ đây

1. Đọc [START_HERE.md](START_HERE.md), hoặc mở `START_HERE.html` bằng trình duyệt.
2. Mở đúng thư mục chứa `project.godot` trong Antigravity.
3. Import `project.godot` vào Godot đang cài; bấm **F6** chỉ chạy scene hiện tại, **F5** mới chạy cả project. Dùng F5 cho bộ này.
4. Chạy nhiệm vụ M0 trong [TASKS](docs/TASKS.md), không nhảy sang làm tính năng.
5. Dán [prompt khởi động](prompts/00_BOOTSTRAP.md) vào agent.

## Source starter đã có gì?

- Một đấu trường 2D dùng hình học đơn giản, không tải asset ngoài.
- WASD/phím mũi tên; đi chéo được chuẩn hóa; nhân vật bị giới hạn trong sân.
- Một loại quái đuổi theo; sinh từ rìa, tránh sinh sát người chơi; giới hạn 64 quái.
- 3 máu; khoảng bảo vệ sau va chạm; thắng khi sống sót đủ 180 giây.
- Menu, pause/resume, thắng/thua, chơi lại, về menu, tự pause khi mất focus.
- Script smoke test, kiểm tra cấu trúc tùy chọn, preset xuất Windows.

**Chưa có:** cơ chế đặc trưng được người chơi xác nhận là vui, âm thanh, lưu dữ liệu, settings đầy đủ, credits trong game, bản build Windows đã kiểm thử trên máy bạn, trang bán hàng hoặc doanh thu. Hình học hiện tại là đồ họa prototype có chủ đích.

## Bản đồ tài liệu

| Cần làm | Đọc file |
|---|---|
| Bắt đầu trên máy Windows | [START_HERE.md](START_HERE.md) |
| AI phải tuân thủ điều gì | [AGENT_RULES.md](AGENT_RULES.md) |
| Game làm gì, không làm gì | [GAME_BRIEF](docs/GAME_BRIEF.md) |
| Scene, script, tín hiệu nối ra sao | [TECH_SPEC](docs/TECH_SPEC.md) |
| Làm việc nào tiếp theo | [TASKS](docs/TASKS.md) |
| Kiểm thử thế nào | [TEST_PLAN](docs/TEST_PLAN.md) |
| Dùng AI từng phiên | [AI_WORKFLOW](docs/AI_WORKFLOW.md) |
| Cẩm nang Mỹ thuật & Chuẩn thị giác | [ART_BIBLE](docs/ART_BIBLE.md) |
| Hình ảnh, âm thanh | [ART_AUDIO](docs/ART_AUDIO.md) |
| Kiểm chứng khả năng bán | [MARKET_VALIDATION](docs/MARKET_VALIDATION.md) |
| Xuất game và phát hành | [RELEASE_CHECKLIST](docs/RELEASE_CHECKLIST.md) |
| Trạng thái kiểm tra bộ ZIP | [QA_REPORT](docs/QA_REPORT.md) |

## Nguyên tắc quan trọng nhất

**AI viết xong ≠ game chạy đúng ≠ game vui ≠ game bán được.** Kiểm tra riêng từng lớp. Không để agent tự mua tài nguyên, nhập thông tin thanh toán, tạo tài khoản, công khai repository hay phát hành game.
