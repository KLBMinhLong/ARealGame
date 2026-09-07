# Playtest, milestone và phát hành

## Mục tiêu

Đo xem người chơi hiểu và muốn thực hiện hành động cốt lõi hay không. Không dùng “dopamine schedule”, số run ước lượng hoặc agent tự khen làm proof retention.

## Một buổi playtest nhỏ

- Dùng đúng build, ghi version/ngày và phần đang test.
- Mời một nhóm nhỏ người chưa đọc tài liệu; không giải thích trước ngoài thông tin cần thiết để bắt đầu.
- Quan sát họ hiểu gì, mắc ở đâu, nguyên nhân chết có rõ không, có tự tạo combo hay chỉ chạy vòng tròn.
- Hỏi câu mở: “Bạn nghĩ vừa xảy ra điều gì?”, “Lúc nào bạn mất dấu nhân vật?”, “Bạn muốn thử thêm không, vì sao?”.
- Ghi thời điểm/tình huống cụ thể. Không dẫn dắt bằng câu “đã hơn rồi đúng không?”.
- Clip/video chỉ ghi và chia sẻ khi người tham gia đồng ý; tránh thu dữ liệu cá nhân không cần thiết.
- Nhóm nhỏ cho tín hiệu định tính, không đủ để kết luận retention hay win-rate thị trường.

## Gate theo milestone

### M0 — cơ chế có đáng tiếp tục?

- Movement/Pulse rõ và phản hồi nhất quán.
- Người mới hiểu ít nhất cách tạo một kill có chủ đích, không chỉ được giải thích bằng miệng.
- Positioning tạo khác biệt quan sát được; chain đọc được, không chỉ là số đếm.
- Có người muốn chơi thêm vì core loop.
- Không có lỗi chặn vòng chơi.

Nếu Pulse không vui/rõ, không vượt gate chỉ vì menu và VFX đẹp. Ưu tiên sửa cơ chế/readability thay vì thêm progression.

### M1 — vòng chơi đầy đủ

- Start → chơi → wave/upgrade → thắng/thua → restart có contract và test.
- Boss victory/loss/timeout phân biệt rõ; reward được cấp đúng một lần.
- Có test các transition cùng tick, pause, repeated input và restart liên tục.

### M2 — chất lượng và lưu trữ

- Art/audio nhất quán trong game, không chỉ trong gallery.
- Save/load, config, mất/malformed save và migration được thử bằng dữ liệu test.
- Menu, keyboard navigation, readability, reduced effects và audio settings trong scope được kiểm tra.
- Giấy phép/provenance asset được owner xác nhận.

### M3 — bản xuất có thể bàn giao

- Test bản export trên nền tảng/máy mục tiêu; Godot editor chạy được không thay thế việc này.
- Chạy session đại diện và ghi crash/blocker; không gọi vài run là “đảm bảo không có bug”.
- Kiểm tra paths/resource case-sensitivity, settings persist, focus/fullscreen và input đang hỗ trợ.
- Chốt các nền tảng thực sự đã thử. Export được Linux/macOS không tự đồng nghĩa đã QA hai nền tảng đó.
- Đo FPS/frame time/load time/RAM khi cần, kèm hardware/build/scenario/duration. Chưa đo ghi UNMEASURED, không gán 60 FPS từ spec.

## Phát hành và AI

- Owner chịu trách nhiệm tài khoản, ngân hàng/thuế, phí, giá, giấy phép và quyết định phát hành.
- Chuẩn bị store page, build review và các mốc chờ của cửa hàng sớm. Không xem “Steam prep 0,5 ngày” là toàn bộ thời gian được phép phát hành.
- Kiểm tra Content Survey hiện hành của Steam: nội dung AI được người chơi tiếp nhận khác với công cụ chỉ tăng hiệu suất nội bộ; pre-generated khác live-generated.
- Stone Knight không cần LLM lúc chơi chỉ vì dùng AI để sản xuất. Offline/state machine thông thường là lựa chọn mặc định của thiết kế.
- Không hứa “game duy nhất”, “chưa ai làm”, “không trùng tên” hoặc “chắc chắn bán được” nếu chưa kiểm chứng.
- Không tự public repo, upload game/log/asset ra dịch vụ mới, trả tiền hay bấm release.

Xem URL tham khảo trong SOURCES; kiểm tra lại tại thời điểm phát hành vì điều khoản có thể thay đổi.
