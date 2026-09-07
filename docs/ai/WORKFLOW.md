# Workflow — làm một feature đến nơi đến chốn

## Vai trò và quyền

- **Chủ dự án:** duyệt mục tiêu/scope và thay đổi gameplay; xác nhận playtest; quyết định ngân sách, dependency, merge/publish.
- **Agent chính:** khảo sát, lên kế hoạch, viết code, chạy lệnh được phép, giữ bằng chứng, sửa findings và bàn giao. Đây là writer duy nhất.
- **Godot scout:** tìm integration points, chỉ đọc.
- **Gameplay reviewer:** phản biện contract/edge cases, chỉ đọc.
- **QA reviewer:** so sánh code + evidence với acceptance, chỉ đọc; không tự chạy test.

Không bắt buộc gọi cả ba subagent. Feature camera thường cần scout khi chưa hiểu project và QA reviewer sau implementation. Lỗi phức tạp có thêm gameplay reviewer. Không có cơ chế delegation thì tự review với nhãn SELF_REVIEW, không giả vờ có ý kiến độc lập.

## State machine công việc

`DRAFT → DISCOVERY → READY → IMPLEMENTING → VERIFYING → AWAITING_PLAYTEST → DONE`

`BLOCKED` có thể xuất hiện ở bất kỳ bước nào. Task chỉ thay tài liệu hoặc logic không có gate manual có thể đi từ VERIFYING sang DONE khi mọi check áp dụng đã được đáp ứng; giải thích N/A thay vì bỏ qua.

### 1. DRAFT — xác định vấn đề

Điền FEATURE_BRIEF: kết quả người chơi nhận được, non-goals, hợp đồng hành vi, rủi ro, cách kiểm tra. Không dùng tên feature thay cho tiêu chí hoàn thành.

### 2. DISCOVERY — hiểu thứ đang tồn tại

Trước khi sửa source:
- Kiểm tra thay đổi có sẵn, file instructions hiện hành và project layout.
- Đọc cả bên phát và bên nhận signal, không chỉ file muốn sửa.
- Xác nhận engine/version, camera owner, config keys, lifecycle và test conventions liên quan.
- Lập baseline từ code và lệnh được phép. Ghi lỗi có sẵn; chưa chạy thì NOT_RUN.
- Liệt kê touched-file dự kiến; file mới phải có lý do.

Thiếu fact trong repo: tự tìm trước khi hỏi. Conflict về hành vi/ownership/save/dependency: hỏi chủ dự án. Không cần hỏi về mọi tên biến hoặc hằng số visual có thể đổi lại.

### 3. READY — chốt kế hoạch có thể kiểm chứng

Điều kiện vào READY:
- Chủ dự án đã cho phép thực hiện feature và scope đang áp dụng.
- Prerequisite đã được kiểm tra; không còn blocker ảnh hưởng correctness hoặc safety.
- Có acceptance IDs, check tự động/thủ công tương ứng và cách rollback.

Việc yêu cầu tạo bộ tài liệu không tự cấp quyền chạy implementation trong một repo chưa được cung cấp.

### 4. IMPLEMENTING — lát cắt nhỏ

1. Tạo failing check hoặc reproduction rõ ràng cho hành vi cần thay đổi khi phù hợp.
2. Implement phần nhỏ nhất; tái sử dụng cấu trúc hiện hành.
3. Chạy kiểm tra tập trung sau mỗi lát cắt.
4. Chỉ refactor phần bị tác động khi cần cho tính đúng; không dùng feature nhỏ để làm lại kiến trúc.

Nếu discovery phát hiện thiếu hệ thống lớn, không xây luôn. Tách prerequisite task hoặc dùng harness/test scene cô lập trong phạm vi được duyệt.

### 5. VERIFYING — chứng minh thay đổi

- Version/import kiểm tra cơ bản.
- Focused behavior tests; negative cases; lifecycle và regression phù hợp.
- Đọc log kể cả exit code zero.
- Kiểm tra diff, runtime path và code ngoài phạm vi.
- Nếu review nêu bug: xác minh → sửa nhỏ → chạy lại check liên quan.
- Evidence phải được thu sau thay đổi cuối cùng liên quan; không tái dùng log cũ như proof mới.

Sau nhiều lần sửa mà nguyên nhân vẫn mơ hồ: dừng “đổi thử”, thu reproduction + log + giả thuyết, cô lập nguyên nhân trước khi thêm patch.

### 6. AWAITING_PLAYTEST — bàn giao cho người thật

Gửi tối đa một checklist ngắn với thao tác cụ thể và điều cần quan sát. Agent có thể chủ động tạo scene test/debug control khi đã được cho phép; không yêu cầu chủ dự án đoán cách kích hoạt tính năng.

Nếu owner chưa chơi, giữ đúng trạng thái. Không gán cảm giác vui/mượt/đã tay từ một ảnh chụp hoặc import thành công.

### 7. DONE — có đủ bằng chứng

- Mọi acceptance áp dụng đạt; N/A có giải thích được chấp thuận.
- Không còn blocker/major finding chưa được xử lý hoặc chấp thuận ngoại lệ rõ ràng.
- Có kết quả manual cần thiết từ owner/player và build/commit được kiểm tra.
- Có handoff: thay đổi, kiểm tra, chưa kiểm tra, known risks, rollback.
- Commit/push/merge chỉ thực hiện nếu được cho phép riêng hoặc có quy ước repo được owner chấp thuận.

## Kỷ luật scope

Mọi ý tưởng ngoài task vào parking lot, không triển khai. “Tốt hơn” không phải lý do đủ để thêm manager, autoload, plugin, menu hoặc hệ thống mới.

Ví dụ F001: thêm hệ số tắt shake có thể trong scope; tạo toàn bộ Settings Screen hoặc viết lại combat để có signal không nằm trong scope.

## Context và chi phí

Chỉ đọc luật chung + task + các module liên quan. Subagent nhận câu hỏi hẹp, paths cụ thể, contract IDs và evidence cần xem. Kết thúc mỗi task cập nhật trạng thái ngắn; không chép toàn bộ lịch sử chat vào CLAUDE.md.

## Khi giao việc ở phiên mới

Luôn xác nhận lại working tree và trạng thái task. Handoff cũ là điểm bắt đầu, không phải bằng chứng code hiện tại vẫn giống lần trước.
