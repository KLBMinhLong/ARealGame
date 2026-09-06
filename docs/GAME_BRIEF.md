# Game brief — Vòng Vây

**Trạng thái:** đề xuất mặc định, chờ chủ project duyệt ở T100. Tên làm việc, chưa kiểm tra nhãn hiệu. Không phải cam kết phát hành hoặc doanh thu.

## Mục tiêu

Hoàn thành một game PC chơi đơn nhỏ bằng Godot và AI, chứng minh quy trình từ source đến bản build độc lập. Sau khi có người ngoài chơi thử mới quyết định đầu tư để bán.

## Một câu mô tả

Điều khiển một drone trong đấu trường, tránh bị bao vây và sống sót qua lượt chơi 3 phút. Bản starter chỉ có né; bản v1 đề xuất bổ sung một xung đẩy ngắn tạo đường thoát.

## Người chơi giả định

Người chơi PC thích lượt chơi ngắn, điều khiển đơn giản, dễ thử lại. Đây là giả thuyết sản phẩm, chưa có dữ liệu chứng minh nhu cầu.

## Vòng lặp

Menu → bắt đầu → quan sát quái → di chuyển/né → dùng xung khi cần ở v1 → sống sót hoặc hết máu → xem kết quả → thử lại.

## Starter 0.1 — source đã được viết

- Sân cố định, 1152×648 logical viewport; người chơi hình tròn, quái hình thoi.
- WASD và mũi tên; không chuột, không tấn công, chưa có xung đẩy.
- 3 HP, mất 1 HP mỗi va chạm hợp lệ; bảo vệ 1,2 giây sau hit, không nhấp nháy.
- Thắng khi đủ 180 giây; hết HP thì thua. Đồng thời chạm mốc thời gian trong một tick: kiểm tra thắng trước va chạm theo code hiện tại.
- Một loại quái đuổi, spawn ở rìa cách người chơi tối thiểu 210 pixel; tối đa 64 quái.
- Esc pause/resume; R chỉ retry ở màn kết quả; rời focus tự pause.
- Chưa có save, audio, achievement, tiến trình dài hạn hoặc monetization.

## Phạm vi v1 đề xuất sau khi được duyệt

1. Giữ một arena và lượt 180 giây.
2. **Một cơ chế chính mới: xung đẩy bằng Space.** Bán kính gợi ý 120 px, đẩy quái 80 px, hồi 4 giây, làm khựng 0,25 giây; không gây damage, không làm người chơi bất tử. Các số là điểm khởi đầu để test, không phải cân bằng đã đo.
3. Hai loại quái: chaser hiện tại và sprinter có báo trước. Không thêm loại thứ ba trước release candidate.
4. Tutorial ngắn trong game, phản hồi hit/xung/thắng/thua rõ nhưng không bắt buộc rung/flash.
5. Save best survival và số lượt thắng, có xử lý dữ liệu thiếu/hỏng.
6. Settings: master/music/SFX volume, fullscreen/windowed, giảm hiệu ứng; remap phím nếu hoàn thành đúng và đủ test.
7. Menu, kết quả, credits/giấy phép, âm thanh nhẹ, build Windows x86_64 đã kiểm thử.

## Chưa làm

Multiplayer, server, đăng nhập, leaderboard online, gacha, quảng cáo, IAP, nhiều nhân vật, inventory phức tạp, cốt truyện dài, procedural world, mobile/web export, modding. Không thêm để làm game trông “lớn hơn”.

## Điều kiện đổi hướng

Nếu người ngoài không hiểu cách chơi hoặc không muốn thử lại, sửa cơ chế và độ rõ trước khi thêm nội dung. Nếu game vẫn không tạo hứng thú, có thể dùng repo này làm bài học rồi đổi ý tưởng; không coi thời gian đã bỏ ra là lý do bắt buộc phải bán.

## Định nghĩa hoàn thiện

Mọi task v1 bắt buộc qua test; không còn bug chặn/crash; settings/save hoạt động; licensing rõ; build chạy trên máy không mở editor; chủ project duyệt trải nghiệm và trang phát hành. “Hoàn thiện kỹ thuật” vẫn chưa chứng minh khả năng bán.
