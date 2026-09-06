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
