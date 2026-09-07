# F___ — Tên feature

**Status:** DRAFT
**Owner approval:** NOT_GRANTED
**Evidence:** NOT_RUN

## 1. Kết quả người chơi nhận được

Một câu mô tả hành vi/kết quả quan sát được. Không dùng “hoàn thiện hệ thống”, “code sạch” hoặc “feel tốt” làm tiêu chí duy nhất.

## 2. Scope / Non-goals

- Có:
- Không:
- Prerequisite:

## 3. Discovery

| Fact | Giá trị | Nguồn path/symbol/command | VERIFIED_IN_REPO / FROM_DESIGN_DOC / PROPOSED / UNKNOWN |
|---|---|---|---|
| Engine version | Chưa xác minh | Chưa có | UNKNOWN |

Tìm producer/consumer, ownership, config/units, lifecycle, tests và baseline errors liên quan. Không liệt kê file tưởng tượng.

## 4. Contract

R01 — trigger và điều kiện.
R02 — input/output/state/units.
R03 — repeated events/caps/empty/invalid cases.
R04 — pause/restart/teardown và config disabled.
R05 — điều không được thay đổi.

## 5. Plan nhỏ nhất

- Touched files và lý do.
- Lát cắt implementation.
- Rủi ro và câu hỏi blocking (nếu có).
- Rollback bảo toàn thay đổi có sẵn.

## 6. Acceptance

| ID | Observable behavior | Check tự động/thủ công | Expected result | Evidence | Status |
|---|---|---|---|---|---|
| AC01 | Điền trước implementation | Điền | Điền | Chưa có | NOT_RUN |

N/A phải có lý do. Không thay expected result để khớp code sai mà không có quyết định thiết kế.

## 7. Approval và completion

- Owner cho phép scope ngày: chưa có.
- Chưa kiểm tra:
- Manual playtest cần owner:
- Findings chưa xử lý:
- Kết luận: không đặt DONE trước khi đủ evidence và gate áp dụng.
