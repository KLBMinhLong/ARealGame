# Art & audio direction

## Starter

Phong cách kỹ thuật tối giản: nền xanh than, người chơi tròn xanh sáng, quái hình thoi cam, chữ dễ đọc, HUD tách khỏi sân. Không có asset hình/nhạc bên ngoài và hiện chưa có âm thanh. Geometry được vẽ bằng GDScript để nhẹ và dễ chỉnh.

## Định hướng v1

- Giữ silhouette khác nhau, không chỉ phân biệt bằng màu. Sprinter có dấu chỉ hướng và cảnh báo trước rõ.
- Không cần thay hình tạm bằng nhiều ảnh AI ngay. Trước tiên giữ tỉ lệ, hitbox, pivot, palette và animation nhất quán.
- Nút tối thiểu 44 logical px; ưu tiên chữ không bị cắt ở 1152×648. Kiểm tra viewport nhỏ hơn.
- Hit/xung/win/lose phải có dấu hiệu hình ảnh kể cả khi mute. Tránh flash mạnh, screen shake bắt buộc; có giảm hiệu ứng.
- Âm thanh ngắn, rõ, không lấn át; bus Master/Music/SFX riêng. Kiểm tra mức âm lượng thay vì chỉ thêm file.
- Nếu dùng ảnh AI: ghi công cụ, điều khoản tại ngày tạo, prompt/provenance cần thiết; kiểm tra chữ giả, watermark, logo/nhân vật nhận diện, méo hình và quyền thương mại. Không có bảo đảm pháp lý chỉ vì ảnh được tạo bởi AI.

## Asset pipeline

`assets/art/`, `assets/audio/`, `assets/fonts/` đã có thư mục. Với mỗi asset: file nguồn → kiểm tra license → import → kiểm tra trong scene → thêm register. Không commit asset không dùng. Giới hạn kích thước texture hợp lý cho laptop 8 GB; không tải pack khổng lồ chỉ để dùng một icon.

## Tiêu chí duyệt hình/âm

Không tràn/chồng UI; tương phản rõ; nhận ra nhân vật và nguy hiểm; animation không che hitbox; âm thanh không clipping; pause/settings tác động đúng. Xem/ nghe bản build thật, không chỉ ảnh preview trong công cụ tạo.
