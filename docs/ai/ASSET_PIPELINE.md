# Asset pipeline — AI tạo bản đầu, con người duyệt chất lượng

## Khi nào bắt đầu?

Chỉ đầu tư art/animation đầy đủ sau khi greybox chứng minh được loop cần giữ. Trong M0, primitive và SFX tạm là đủ. Không tạo hàng trăm sprite trước khi chốt kích thước và góc nhìn.

## Art bible nhỏ trước batch generation

Chốt một mẫu chuẩn cho Stone Knight và một enemy:
- Top-down/góc nhìn cụ thể, silhouette, kích thước sprite (tài liệu còn lựa chọn 24×24 hoặc 32×32 — phải chốt, không trộn).
- Palette, outline, light direction, mức tương phản và độ chi tiết.
- Anchor/pivot, collision footprint và padding.
- Animation states, hướng nhìn, frame counts, frame timing, looping và ý nghĩa của impact frame.

Tham khảo palette/cảm xúc ở 04_GDD; không tự coi mọi con số ở đó đã được thử trong viewport hiện tại. UI/gameplay readability quan trọng hơn hình ảnh concept riêng lẻ.

## Quy trình một asset

1. Brief ngắn + reference được quyền dùng.
2. Tạo ít biến thể, chọn một hướng với owner.
3. Tạo animation/rotations theo reference đã chọn, không sinh độc lập từng frame không có kiểm soát.
4. Kiểm tra kỹ thuật: kích thước, alpha, sheet slicing, frame alignment, palette, loop, import filter.
5. Kiểm tra trong Godot ở scale thực: silhouette, pivot drift, chân trượt, kích thước/hướng nhảy, readability khi nhiều quái.
6. Owner chấp nhận; ghi provenance; chỉ sau đó nhân rộng.

Không “sửa” hitbox để ép khớp animation lỗi nếu làm thay đổi gameplay ngoài task. Sửa asset hoặc đề xuất đổi contract rõ ràng.

## VFX

- Thông tin chiến đấu phải đọc được khi hiệu ứng được giảm/tắt.
- Có duration, max count, cleanup, lifetime và event throttling.
- Khi chain lớn, cap feedback để tránh nhấp nháy/rung/che hết màn hình.
- Kiểm tra tương phản, màu không phải dấu hiệu duy nhất, reduced motion/flashes.

## Audio

- Tạo riêng layer cần thiết, trim đầu/cuối, kiểm tra click/pop và điểm loop.
- Cân Master/Music/SFX theo bus hiện có; không để nhiều collision cùng lúc gây clipping.
- Kiểm tra polyphony, voice priorities, cooldown/aggregation và volume khi chain dài.
- So sánh trong gameplay, không chỉ nghe từng file riêng.
- Sinh nhạc/SFX bằng AI không tự bảo đảm quyền thương mại, chất lượng loop hoặc tính độc quyền.

## Asset register tối thiểu

Mỗi asset đưa vào build cần: asset ID, file, mục đích, nguồn/tool, model/version nếu biết, ngày tạo/tải, gói/giấy phép áp dụng, reference/input có quyền dùng, chỉnh sửa của con người, trạng thái review và nơi lưu evidence về quyền.

Không lưu API keys, tài khoản hoặc thông tin thanh toán vào register. Quyền sử dụng thương mại, quyền tác giả và khả năng độc quyền là các vấn đề khác nhau. Có nghi ngờ thì không đưa vào bản phát hành; owner kiểm tra điều khoản hiện hành hoặc tư vấn phù hợp.

## Definition of ready cho asset production

- Gameplay cần asset đã ổn định đủ.
- Có mẫu chuẩn được owner duyệt.
- Có import contract và cách xem trong engine.
- Có provenance/license record; không chỉ có prompt “in the style of...” và một file PNG.
