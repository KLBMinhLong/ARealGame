# Checklist hoàn thiện và xuất game

## A. Cổng chất lượng

- [ ] M0 đến M4 trong TASKS có bằng chứng, không chỉ check bằng lời.
- [ ] Không còn crash, save loss, lỗi vào/thoát game hoặc bug chặn tiến trình.
- [ ] Menu/tutorial/pause/retry/settings/credits hoàn chỉnh theo brief đã duyệt.
- [ ] Asset register không còn UNKNOWN cho nội dung thực dùng.
- [ ] Hiệu năng đã đo trên máy thật; yêu cầu máy không được bịa.
- [ ] Không có secret, API key, debug cheat hoặc dữ liệu riêng trong bản export.

## B. Export Windows lần đầu

1. Lưu project và commit release candidate sau test.
2. Trong Godot, mở **Editor → Manage Export Templates** (tên/menu có thể khác theo ngôn ngữ UI). Cài template đúng phiên bản engine thực tế. Đây có thể là lượt tải lớn; chủ project quyết định tải, agent không tự chuyển sang template bản khác.
3. Mở **Project → Export**. Bộ này đã có preset `Windows Desktop`, x86_64; kiểm tra lỗi cảnh báo trong UI trước export.
4. Tạo thư mục `builds/windows/` nếu chưa có. Nhấn **Export Project**, chọn `builds/windows/VongVay.exe`. Bỏ **Export With Debug** khi chuẩn bị release thật.
5. Preset hiện không nhúng PCK. Giữ `.exe`, `.pck` cùng những file runtime cần thiết engine tạo ra. Không chỉ gửi một `.exe`.
6. Đóng editor. Copy output cần thiết sang một thư mục sạch, chạy exe tại đó.
7. Test lại gameplay/input/pause/audio/save/settings. Nếu có máy Windows khác, kiểm tra thêm mà không cài Godot.
8. Nén thư mục build để gửi người test, không gửi toàn bộ source repo nếu không chủ định.

Lệnh PowerShell tương đương, chỉ dùng khi templates đã sẵn và đúng bản:

```powershell
$Godot = 'C:\DUONG_DAN_THAT\Godot_console.exe'
New-Item -ItemType Directory -Force .\builds\windows | Out-Null
& $Godot --headless --path . --export-release 'Windows Desktop' 'builds/windows/VongVay.exe'
```

Xem log và exit code. Export thành công không bảo đảm bản exe chạy đúng. Không nhờ người test tắt antivirus/SmartScreen để né cảnh báo. Nếu gặp cảnh báo, kiểm tra nguồn build, chữ ký, cách phân phối và hướng dẫn nền tảng; không mặc định file an toàn chỉ vì do mình export.

## C. Bản phát hành cho người chơi cần gì?

- [ ] Game runtime và các file đi kèm, không cần editor.
- [ ] Version, hướng dẫn phím, cách báo lỗi và credits/license phù hợp.
- [ ] Screenshot/trailer từ build hiện hành, mô tả trung thực và không giả đánh giá.
- [ ] Trang sản phẩm dự thảo, hướng dẫn hỗ trợ; chỉ công bố sau phê duyệt.
- [ ] Có bản release trước hoặc source tag để có thể sửa/rollback.
- [ ] Test đường dẫn có khoảng trắng, user thường, save location và quyền ghi.

## D. Quyền và tài khoản

Giấy phép Godot cho phép dự án thương mại theo điều kiện của nó; engine license không tự quyết định giấy phép game/code/asset của bạn. Hoàn tất thông báo engine/dependencies theo đúng bản sử dụng; xem nguồn Godot trong SOURCES và THIRD_PARTY_NOTICES.

Bộ này không áp MIT hay một giấy phép mã nguồn mở cho toàn bộ game thay bạn. Tên game/asset/nội dung AI và tính độc quyền cần bạn xem xét. Không tự điền thông tin pháp lý, tài khoản thuế, thanh toán hoặc trả phí nền tảng.

## E. Chỉ người dùng duyệt phát hành

Agent có thể soát build, draft store copy và chuẩn bị checklist. Upload/publish/push public/mua asset/trả phí cần xác nhận riêng về nơi đến, nội dung và chi phí. Không xem task “hoàn thiện game” là cho phép tự bán hoặc tự mở tài khoản.
