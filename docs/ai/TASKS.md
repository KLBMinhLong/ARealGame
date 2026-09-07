# Task board ban đầu

| Task | Mục tiêu | Trạng thái | Dependency |
|---|---|---|---|
| F000 | Khảo sát repo, baseline, hiện trạng camera/event/config và plan F001 | DRAFT | Cần mở repo thật và owner cho phép các bước kiểm tra |
| F001 | Screen Shake theo task chi tiết | DRAFT | F000 + movement/Pulse/va chạm có thể test |

## F000 không được làm

Không tự implement F001, không sửa tám tài liệu gốc, không đổi engine, không tạo project mới để thay project đang có.

## Nếu gameplay chưa tồn tại

Đề xuất prerequisite riêng: movement + một enemy + Pulse tối thiểu trước polish. Owner chọn làm prerequisite hoặc harness visual riêng; F001 không âm thầm mở rộng thành toàn bộ greybox.

## Parking lot — chưa được cấp quyền triển khai

Hit-stop, SFX nâng cao, boss, progression, story, nhiều loại enemy, asset hoàn chỉnh, Settings UI và release tooling. Chỉ lấy một mục ra khi có feature brief và ưu tiên rõ ràng.

## Decision record ngắn (tạo khi cần)

- ID / task liên quan / trạng thái PROPOSED hoặc APPROVED.
- Vấn đề, các lựa chọn, khuyến nghị và trade-off.
- Người duyệt + ngày duyệt; bằng chứng nếu đã kiểm chứng.
- Phạm vi ảnh hưởng và cách rollback.

Đề xuất của AI không tự được ghi APPROVED. Không cần xây hệ thống ADR phức tạp cho mỗi tên biến.
