# Asset register

Chỉ thêm asset vào bản phát hành khi quyền sử dụng rõ. UNKNOWN là trạng thái chặn, không phải “chắc được”.

| File/thành phần | Nguồn | Loại/license | Dùng thương mại? | Ghi công/điều kiện | Trạng thái |
|---|---|---|---|---|---|
| Geometry trong scripts/actors và world | Mã tạo cho bộ starter này | Không nhập ảnh/asset ngoài | Chủ project cần quyết định giấy phép sản phẩm/mã và kiểm tra quyền liên quan | Không cam kết độc quyền với nội dung AI | Đã ghi provenance |
| Godot runtime khi export | Godot Engine | MIT và notices phụ thuộc đi kèm | Theo giấy phép engine | Xem THIRD_PARTY_NOTICES và thông tin license bản engine sử dụng | Cần hoàn tất credits khi release |
| Font fallback của engine | Đi kèm Godot | Theo bộ third-party notices của bản engine | Kiểm tra notices bản dùng | Không thêm font tải ngoài mà bỏ qua license | Cần soát khi release |

## Mẫu cho asset mới

- Đường dẫn trong project:
- URL/file nguồn và tác giả:
- Ngày lấy/tạo:
- License chính xác và bản sao/link điều khoản:
- Điều kiện thương mại, sửa đổi, phân phối:
- Text credit bắt buộc:
- Công cụ AI/điều khoản nếu có:
- Người duyệt và trạng thái APPROVED / UNKNOWN / REJECTED:

Không đính kèm token tài khoản vào nguồn. Khi dùng dịch vụ tạo asset, lưu chứng cứ điều khoản cho đúng gói/tài khoản vào nơi riêng phù hợp, không bịa quyền.
