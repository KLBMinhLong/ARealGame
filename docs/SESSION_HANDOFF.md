# Bàn giao phiên

## Trạng thái ban đầu

- Source starter 0.1 và bộ tài liệu đã được kiểm chứng hoạt động.
- Engine và game đã chạy thực tế trên máy người dùng, người dùng đã chơi và xác nhận thành công (T001, T002, T003 hoàn thành).
- Cache `.godot/` đã sinh hợp lệ, static checks đạt 66/66 PASS.
- M0 hoàn thành với commit baseline Git local.
- Chủ project đã duyệt thực hiện tiếp (T100 đạt).

## Việc tiếp theo

Chuyển sang nhiệm vụ **T240 — Cập nhật Tutorial và Màn hình kết quả dễ hiểu**:
1. Bổ sung bảng hướng dẫn chơi chi tiết (phím điều khiển, cơ chế Xung đẩy Space, cách đối phó 2 loại quái Chaser và Sprinter).
2. Thêm nút "TUTORIAL" / "HOW TO PLAY" tại Menu để người chơi có thể xem lại bất kỳ lúc nào.
3. Cải tiến màn hình Kết quả (Won / Lost):
   - Thống kê thời gian sống sót, tỷ lệ hoàn thành trận đấu (%).
   - Số lượng Drone trên sân khi kết thúc.
   - Lời khuyên chiến thuật ngắn phù hợp theo thời điểm thua.
4. Đảm bảo phím Restart (`R` và nút bấm) mượt mà, không kẹt phím hay rò rỉ bộ đếm.

## Cập nhật phiên

```text
Ngày: 06/09/2026
Task: T230 — Sprinter có cảnh báo trước (DONE)
Commit gần nhất: aa45395 fix(enemy): make Sprinter dash penetrate through player to arena boundary
Thay đổi chưa commit: docs/TASKS.md, docs/SESSION_HANDOFF.md
Files/wiring vừa đổi: docs/TASKS.md, docs/SESSION_HANDOFF.md
Test đã chạy và log: tools/verify_structure.py (68/68 PASS), test manual bởi chủ project: hoạt động chuẩn xác
Test chưa chạy: Kiểm thử T240 (chưa code)
Bug còn: Không
Quyết định đang chờ chủ project: Duyệt thiết kế Tutorial và Result Screen (T240)
Task tiếp theo (chỉ một): T240 — Tutorial và kết quả dễ hiểu
```







