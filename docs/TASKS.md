# Tasks và cổng kiểm tra

## Trạng thái

`TODO` chưa làm · `IN_PROGRESS` đang làm · `IMPLEMENTED_AWAITING_TEST` đã viết nhưng thiếu kiểm chứng · `BLOCKED` thiếu điều kiện · `DONE` đã đạt test và review cần thiết.

Mỗi thời điểm một task IN_PROGRESS. Mỗi task phải ghi file thay đổi, test/log, người kiểm thử tay và commit nếu có. Các checkbox ở đây KHÔNG được tự đánh dấu chỉ vì source tồn tại.

## M0 — baseline trên máy chủ project

| ID | Việc | Dependency | Trạng thái | Ghi chú nghiệm thu |
|---|---|---|---|---|
| T001 | Xác minh workspace + Godot executable/version | Không | DONE | Đúng root D:/HandMakeGame/ARealGame, Godot chạy chuẩn xác |
| T002 | Import + smoke + startup test | T001 | DONE | Import tạo cache .godot/ hợp lệ, static test 66/66 checks PASS |
| T003 | Chơi kiểm tra starter | T002 | DONE | Chủ project kiểm thử tay trực tiếp: đã mở trên Godot và chơi thành công |
| T004 | Git baseline + handoff | T003 | DONE | Đã khởi tạo Git local, commit baseline thành công, handoff đồng bộ |

**Source tương ứng đã được viết:** di chuyển/biên, chaser, spawn, HP/grace, timer/end-state, menu/pause/retry. Không đánh dấu T002/T003 DONE dựa vào câu này; xem QA_REPORT.

## M1 — duyệt ý tưởng, không xây mù

| ID | Việc | Dependency | Acceptance |
|---|---|---|---|
| T100 | Chủ project duyệt GAME_BRIEF | T004 | Chốt giữ hay đổi game mẫu; phạm vi v1 và các loại trừ ghi rõ |
| T110 | Test người ngoài vòng chơi hiện tại | T100 | Có quan sát thật, không hướng dẫn miệng; ghi chỗ không hiểu/vui/chán |
| T120 | Chọn một thay đổi cốt lõi | T110 | Một giả thuyết kiểm chứng được; không biến thành danh sách feature |

Gợi ý đã ghi trong brief: xung đẩy. Nếu đổi ý tưởng, cập nhật brief/spec/tasks bằng quyết định rõ ràng trước khi code. Không tiếp tục mọi task bên dưới nếu brief đã thay đổi.

## M2 — vertical slice: lát cắt nhỏ có chất lượng

| ID | Việc | Dependency | Acceptance |
|---|---|---|---|
| T200 | Xung đẩy một loại quái | T120 + duyệt xung | DONE | Chủ project kiểm thử tay: hoạt động chuẩn xác (Space đẩy 80px/120px bán kính, hồi 4s, khựng 0.25s, clamp biên) |
| T210 | UI hồi chiêu + feedback xung | T200 | DONE | Chủ project kiểm thử tay: hoạt động chuẩn xác (HUD PULSE READY/đếm lùi, vòng sạc quanh Drone khép kín mượt mà, pause đóng băng đúng) |
| T220 | Test xem xung làm game tốt hơn | T210 | DONE | Chủ project xác nhận: cơ chế xung Space giúp thoát vây hiệu quả, giữ nguyên thông số |
| T230 | Sprinter có cảnh báo trước | T220 | DONE | Chủ project kiểm thử tay: hoạt động chuẩn xác (quái đỏ tam giác, tia laser xuyên suốt, lao xuyên màn hình đến mép tường, ngắt bằng Space) |
| T240 | Tutorial và kết quả dễ hiểu | T230 | DONE | Chủ project kiểm thử tay: hoạt động chuẩn xác (nút HOW TO PLAY, bảng hướng dẫn chiến thuật, thống kê chi tiết Run Terminated và Victory, phím R restart sạch) |

Nếu xung không tạo giá trị sau test, dừng để sửa ý tưởng, không thêm sprinter che vấn đề. Sprinter mặc định gợi ý: theo dõi chậm → báo trước 0,6s → lao theo hướng đã khóa → nghỉ; các số còn lại đề xuất và duyệt trong T230, không âm thầm chốt khi code.

## M3 — đủ tính năng v1

| ID | Việc | Dependency | Acceptance |
|---|---|---|---|
| T300 | Art/audio direction + inventory | M2 đạt | DONE | Quy chuẩn thẩm mỹ vector, bảng thông số 5 SFX cốt lõi, 100% giấy phép rõ trong ART_AUDIO và ASSET_REGISTER |
| T310 | Save best survival/win count | M2 đạt | DONE | Chủ project kiểm thử tay: hoạt động chuẩn xác (user://save_data.json, BEST trên HUD, huy hiệu new record, phím R restart mọi trạng thái) |
| T320 | Settings cơ bản | T310 | DONE | Chủ project kiểm thử tay: hoạt động chuẩn xác (user://settings.cfg, Volume sliders, Fullscreen toggle, Reduced flash toggle, Reset defaults, Esc/Back) |
| T330 | Âm thanh và audio buses | T300,T320 | DONE | Chủ project kiểm thử tay: hoạt động chuẩn xác (default_bus_layout.tres, synth 16-bit PCM: pulse, hit, telegraph, dash, win, game_over; Master limiter chống rè, mute/slider đúng) |
| T340 | Credits + license trong game | T300 | DONE | Chủ project kiểm thử tay: hoạt động chuẩn xác (credits_button, scroll modal 4 mục pháp lý khớp register 100%, Esc/Back mượt, chặn R) |
| T350 | Cân bằng đủ lượt 180 giây | M3 còn lại | DONE | Chủ project kiểm thử tay: hoạt động mượt mà, cân bằng chuẩn xác (test mô phỏng 0s/90s/180s, pacing tăng tiến tốt, win condition chuẩn) |

## M4 — release candidate

| ID | Việc | Dependency | Acceptance |
|---|---|---|---|
| T400 | Regression đầy đủ | M3 đạt | TEST_PLAN bắt buộc pass; bug blocker/major đã xử lý |
| T410 | Đo trên máy i5/8GB/Iris Xe | T400 | Ghi thật FPS/frame time/memory tại đầu, nhiều quái, retry; không giả kết quả |
| T420 | Export Windows + test thư mục sạch | T410 | Template phù hợp; bản release chạy không cần editor; đủ file đi kèm |
| T430 | Playtest bản export và đóng băng phạm vi | T420 | Người ngoài dùng đúng bản build; sửa lỗi cần thiết, không thêm hệ thống mới |

## M5 — chuẩn bị phát hành; hành động tài khoản do người dùng duyệt

| ID | Việc | Dependency | Acceptance |
|---|---|---|---|
| T500 | Quyết định tiếp tục bán hay thử nghiệm thêm | T430 | Dựa phản hồi thật + chi phí + mức độ khác biệt; không bảo đảm doanh thu |
| T510 | Screenshot/trailer/store copy thật | T500 | Chụp từ build, mô tả đúng tính năng, có yêu cầu máy dựa kiểm thử |
| T520 | Soát giấy phép và chính sách nền tảng | T510 | Không mục UNKNOWN trong asset thực dùng; điều khoản/khai báo AI đã kiểm tra |
| T530 | Chủ project duyệt build và bấm phát hành | T520 | Có phê duyệt riêng, kế hoạch hỗ trợ/rollback, không AI tự thanh toán/upload |

## Mẫu cập nhật cho mỗi task

```text
Task ID:
Trạng thái:
Mục tiêu đã duyệt:
Files + wiring:
Lệnh/test thật:
Kết quả + đường dẫn log:
Test tay bởi chủ project:
Bug còn lại:
Commit:
Task tiếp theo:
```
