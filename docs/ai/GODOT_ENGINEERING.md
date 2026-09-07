# Godot engineering — chất lượng theo hành vi, không theo lượng code

## 1. Version, API và conventions

- Đọc `project.godot`, engine pin và output executable. `config/features` không thay thế việc kiểm tra binary đang chạy.
- Tra tài liệu đúng phiên bản; không sửa project sang version mới chỉ vì snippet dùng API khác.
- Giữ style hiện có; ưu tiên GDScript có type rõ ở public contract, config và dữ liệu dễ nhầm. Không làm mass-format ngoài task.
- Không thêm test framework, addon, MCP, formatter hoặc package chỉ để làm một feature nhỏ khi chưa được duyệt.

## 2. Trách nhiệm và ownership

- Mỗi state quan trọng có một chủ sở hữu: HP, wave state, chain identity, save data, camera offset.
- Dùng signal cho event giữa hệ thống khi hợp lý; giữ reference được inject hoặc reference scene rõ ràng cho quan hệ sở hữu ổn định. Tránh service locator/global registry mới.
- Thiết kế gốc ưu tiên không thêm autoload. Nếu repo đã có autoload, báo hiện trạng; không gỡ bỏ/refactor toàn bộ trong một task nhỏ.
- Tận dụng scene/component hiện có, không ép mỗi hiệu ứng thành một manager.
- Chỉ kết nối signal một lần mỗi lifecycle. Kiểm tra disconnect, node bị free và scene reload khi cấu trúc đòi hỏi.

## 3. Đơn vị và thời gian

- Phân biệt logical pixel, display pixel, world position, screen position và local position.
- Tên/contract cho biết đơn vị: seconds, pixels, pixels/second, normalized intensity, count.
- Gameplay physics theo chu kỳ physics phù hợp; visual interpolation theo chu kỳ render phù hợp. Không nhân delta hai lần cho API đã tự xử lý timestep.
- Phân biệt game time chịu time_scale và real time. Pause có chủ ý, hit-stop và focus loss không phải cùng một trạng thái.
- Mọi hiệu ứng có max/cap, reset, cancellation và trạng thái disabled rõ ràng.

## 4. Physics và chain

Chỉ áp dụng khi task có thay đổi combat; không dùng checklist này làm cớ sửa combat trong F001.

- Va chạm thông thường không tự trở thành powered hit.
- Một impact không được tính damage mỗi tick khi hai collider vẫn tiếp xúc.
- Chốt event/attack identity, pair dedupe, depth khác combo count, minimum velocity, attenuation và immunity.
- Chốt propagation/death order trước khi xóa entity; tránh gọi node đã free hoặc cùng một cái chết phát thưởng nhiều lần.
- Wave clear theo timer không tự áp dụng cho điều kiện thắng boss.
- Khi có nhiều kết quả cùng tick (player chết, boss chết, hết timer), thứ tự giải quyết phải theo contract, không ngẫu nhiên theo signal order.
- Ưu tiên luật arcade có thể kiểm soát và kiểm chứng; không thêm mô phỏng rigid-body phức tạp chỉ vì thiết kế dùng từ “physics”.

## 5. Presentation không làm thay đổi gameplay

- Camera shake là offset visual được compose với camera owner; không đẩy player/world, không thay collision hoặc force.
- Visual RNG dùng nguồn riêng. Không gọi seed/randomize vào global gameplay RNG để tạo shake hoặc particles.
- Giữ HUD độc lập theo cấu trúc hiện có. Không tự reparent UI để che lỗi camera mà chưa hiểu ảnh hưởng.
- Noise/VFX/audio có cap và event dedupe, tránh bùng nổ hiệu ứng khi nhiều quái chết.
- Với pixel art: kiểm tra integer scaling/snap theo renderer thực tế; rounding quá sớm có thể làm mất rung nhẹ. Không sửa toàn bộ cấu hình render trong task shake.
- Pause/restart/scene exit không để sót offset, timer, audio loop hoặc subscription.

## 6. Config

- Xác minh key thật trước khi dùng; không nói “đã có sẵn” dựa trên thiết kế.
- Mỗi thông số có type, đơn vị, default và giới hạn phù hợp.
- Thiếu key nhỏ có thể đề xuất thêm trong config theo convention, ghi rõ diff; không tạo config system thứ hai.
- Validate dữ liệu nhập; giá trị NaN/negative/out-of-range cần chính sách rõ cho phần tính toán nhạy cảm.
- Ưu tiên data-driven cho pool nâng cấp/wave khi đến task đó; không xây framework data trước khi cần.

## 7. Saves và input

- Không dùng save thật cho test phá hủy. Cần test profile/path hoặc bản sao đã được duyệt.
- Version schema, backup/migration và atomic replacement cần được xem xét khi làm save/load; không “reset save” để pass test.
- Khi đổi state menu/pause/gameplay, kiểm tra input không bị xử lý hai lần. Giữ action map hiện có.
- Khi làm keybind/controller/localization, thêm contract tương ứng; không tự port tất cả trong một feature không liên quan.

## 8. Hiệu năng

- Không cấp phát/raycast/quét scene tree quá mức mỗi frame nếu đã có reference hoặc event phù hợp.
- Tối ưu dựa trên profiler trên build và máy cụ thể, không dựa vào câu “2D nên chắc chắn nhẹ”.
- Không thêm pooling/ECS/worker threads trước khi có vấn đề đo được hoặc yêu cầu rõ ràng.
- Khẳng định FPS/RAM/load time phải có cấu hình máy, bản build, tình huống, thời lượng và kết quả đo.

## 9. Review checklist ngắn

- Đúng contract? Đúng engine? Đúng units? Một owner?
- Có double event, stale reference, repeated damage, RNG coupling hoặc pause bug?
- Có negative/lifecycle/regression test phù hợp?
- Diff có ra ngoài scope? Evidence có kiểm tra bản cuối?
