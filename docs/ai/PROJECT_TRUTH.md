# Project truth — phân biệt thiết kế và sự thật trong code

**Ngày lập:** 07/09/2026. Bộ kit chưa được tích hợp vào repository Stone Knight.

## Nhãn bắt buộc

- `VERIFIED_IN_REPO`: đã đọc code/config hoặc có kết quả thực thi cụ thể. Ghi nguồn.
- `FROM_DESIGN_DOC`: có trong tài liệu thiết kế, chưa chứng minh implementation.
- `PROPOSED`: khuyến nghị mới, không tự biến thành yêu cầu đã duyệt.
- `UNKNOWN`: chưa có bằng chứng.

## Những điều đã biết từ thực tế Repository & Định vị Milestone

| Chủ đề | Nội dung | Trạng thái |
|---|---|---|
| Game | Stone Knight; top-down arena action roguelite; cơ chế Pulse đẩy và chain domino | VERIFIED_IN_REPO |
| Công nghệ | Godot 4.x, GDScript, 2D, Viewport 480×270, Compatibility renderer | VERIFIED_IN_REPO |
| Nền tảng | PC/Windows, offline, một người chơi | VERIFIED_IN_REPO |
| **Định vị Milestone hiện tại** | **Mới hoàn thành khung Greybox / Alpha logic (F001–F021), chiếm < 10% của bản 1.0. Toàn bộ nhân vật, quái, sàn đấu, âm thanh, animation và UX thương mại đều thuộc giai đoạn M2+ sắp tới.** | **VERIFIED_IN_REPO** |
| Quy trình hợp tác bắt buộc | **Chu trình 9 bước tuần tự**: AI đề xuất → Chủ duyệt chọn → AI soạn spec → Chủ nhận xét → AI sửa đến khi DUYỆT spec → AI code & test → Chủ playtest thực tế → AI sửa đến khi DUYỆT code → Lặp lại | **VERIFIED_IN_REPO** |
| Quy trình High-Touch | Mảng UX/UI, Animation, Audio, Assets bắt buộc mở rộng các chặng: Moodboard/Ref → Spec/Sheet → Engine Integration → Game Feel Tuning → Playtest Gate | **VERIFIED_IN_REPO** |
| Khung Gameplay hiện có | Player (Pulse + Dash), 3 quái thường (Slime, Speeder, Brute), Boss Warden, 5 Wave, Hazards, 6 In-Run Upgrades, 6 Permanent Upgrades trong Rune Forge | VERIFIED_IN_REPO |
| Lưu trữ dữ liệu | Atomic Write (.tmp) + Backup (.bak) + Corrupt isolation tại `user://save_data.json` | VERIFIED_IN_REPO |

## Thứ tự giải quyết yêu cầu

1. Yêu cầu mới nhất được chủ dự án chấp thuận và quyết định đã ghi rõ người/ngày duyệt.
2. Hợp đồng feature đã duyệt và các acceptance criteria của feature.
3. Các quyết định hiện hành đã duyệt trong task/hồ sơ quyết định của repo.
4. `05_SCOPE.md` dùng để hiểu phạm vi v1 đã cắt; `04_GDD.md` và `03_CORE_LOOP.md` cung cấp chi tiết liên quan nếu không xung đột.
5. Các tài liệu vision/research cũ là tham khảo, không có quyền tự mở rộng scope.

Code hiện tại cho biết hệ thống đang hoạt động thế nào, không tự có quyền lấn át thiết kế đã duyệt. Nếu code khác contract, báo rõ bug/migration/compatibility risk; không âm thầm chọn bên nào.

## Các mâu thuẫn đã phát hiện — không được “đoán cho xong”

| ID | Vấn đề | Quy tắc xử lý |
|---|---|---|
| D01 | GDD dùng viewport/sân khác Scope; lưới 16×9 với viền một ô cho phần trong 14×7, không phải 14×8 | Đọc config thực tế; chốt tọa độ và đơn vị trước khi sửa giá trị gameplay |
| D02 | Các quái 1 HP cùng chết khi domino; quái đi bình thường có thể vô tình bị tính va chạm damage | Chốt powered-hit gate, death/propagation order, dedupe và reward ownership trước feature vật lý |
| D03 | Wave hết timer nhưng boss yêu cầu bị tiêu diệt | Hợp đồng thắng/thua boss phải riêng; không dùng timer-clear mặc định để cho thắng |
| D04 | 05_SCOPE cắt Memory Wall/Golem nhưng tài liệu sau còn nhắc | Không phục hồi tính năng bị cắt chỉ vì thấy trong wireframe hoặc checklist cũ |
| D05 | Giá permanent theo bảng Scope cộng thành 350 RS, phần chữ ghi khoảng 410 | Không tự cân bằng progression theo số tổng chưa sửa; hỏi khi làm economy |
| D06 | Bảng việc M2 là 23,5 ngày, target 18; tổng M0–M3 là 54,5 ngày trước buffer | Không dùng các ước lượng này làm cam kết ngày ship |
| D07 | Vị trí chọn upgrade/chi tiêu shard/carry-over chưa thành một contract duy nhất | Chốt trước feature upgrade, không cản task camera nếu không liên quan |

Các số trên là phép kiểm tra tài liệu, không phải số đo hiệu năng hoặc retention. Chỉ đưa một vấn đề vào blocker khi nó ảnh hưởng task đang làm; không bắt sửa toàn bộ GDD trước Screen Shake.

## Cập nhật sự thật sau F000

Ghi vào task F000 hoặc tài liệu hiện hành tương đương:
- Đường dẫn root, main scene, active camera và script chủ sở hữu.
- Phiên bản executable, engine pin và renderer/viewport thực tế.
- Tên signal + payload + nguồn phát + tần suất.
- Config thật với đơn vị và mức kiểm chứng.
- Lệnh test/run/export có sẵn, trạng thái baseline và lỗi có từ trước.
- Những quyết định cần chủ dự án chốt. Không ghi UNKNOWN thành VERIFIED chỉ để hoàn thành bảng.

## Tài liệu gốc

Bản sao tám file nằm ở `docs/ai/reference-originals/`, giữ nguyên nội dung. Đây là snapshot tham khảo; không tự cập nhật hoặc coi câu “đã chốt” trong snapshot là bằng chứng runtime.
