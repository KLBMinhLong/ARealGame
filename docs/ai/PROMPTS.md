# Prompt dùng ngay

Các prompt dưới đây điều khiển tác vụ, không thay thế quyền của công cụ. Chỉ copy prompt phù hợp; không dán cả tập tài liệu vào mỗi lần làm việc.

## 1. Khởi động F000 — dùng đầu tiên

```text
Đọc AGENTS.md, docs/ai/PROJECT_TRUTH.md, docs/ai/WORKFLOW.md và docs/ai/tasks/F001_SCREEN_SHAKE.md.
Chỉ thực hiện DISCOVERY cho F000; chưa sửa source gameplay/camera và chưa implement F001.
Khảo sát repo thực tế: engine/version, active camera và offset owner, signal producers/consumers/payload/frequency, config keys/units, pause/restart/hit-stop, HUD, RNG và test conventions.
Có thể dùng godot-scout nếu ứng dụng hỗ trợ; agent phụ chỉ đọc.
Kiểm tra các lệnh baseline có sẵn trong phạm vi quyền được cấp. Không tự cài dependency hoặc chạy runtime trên save thật; thiếu điều kiện thì ghi NOT_RUN/BLOCKED.
Báo: facts có bằng chứng, mâu thuẫn liên quan, file dự kiến sửa, plan nhỏ nhất và acceptance checks. Chỉ hỏi tối đa 3 câu thực sự blocking. Dừng chờ tôi duyệt implementation.
```

## 2. Duyệt và implement F001 — sau khi đã xem discovery

```text
Tôi duyệt scope và contract F001 đã thống nhất trong plan vừa rồi. Triển khai F001 theo AGENTS.md và task, xử lý từng lát cắt nhỏ.
Chỉ agent chính sửa repo. Agent phụ review chỉ đọc; không tự mở rộng gameplay hoặc thêm dependency.
Chạy focused checks và đọc log; sau patch cuối chạy lại checks liên quan. Đưa acceptance matrix và evidence thật.
Không commit/push/merge nếu tôi chưa cho phép. Nếu còn manual feel/visual check, để AWAITING_PLAYTEST và đưa hướng dẫn tôi thử, không tự ghi DONE.
```

## 3. Giao một feature mới

```text
Từ yêu cầu sau, tạo feature brief theo docs/ai/templates/FEATURE_BRIEF.md trong hệ thống task hiện có của repo.
Yêu cầu: [mô tả một kết quả nhỏ, rõ].
Trước khi viết code, khảo sát module liên quan và đề xuất contract, non-goals, file scope, edge cases, verification và rollback.
Nếu yêu cầu đã rõ thì không hỏi những fact đọc được trong repo. Chưa implement trước khi tôi duyệt scope/plan.
```

## 4. Sửa bug có kiểm chứng

```text
Bug: [thao tác tái hiện + expected + actual + log/clip nếu có].
Đọc rules và vùng code liên quan. Xác định reproduction nhỏ nhất; phân biệt nguyên nhân đã có bằng chứng với giả thuyết.
Không sửa nhiều chỗ theo phỏng đoán. Đề xuất/chạy focused check được phép, sửa tối thiểu và thêm regression check phù hợp.
Không bỏ test hoặc che lỗi để báo PASS. Ghi rõ baseline, bằng chứng sau sửa và điều chưa kiểm tra.
```

## 5. Review sau implementation

```text
Dùng qa-reviewer (hoặc SELF_REVIEW nếu không có delegation) đọc task, code/diff cuối cùng và evidence thực tế.
Đối chiếu từng acceptance ID. Tách static review, test đã chạy và manual check chưa làm.
Tìm stale logs, event spam, lifecycle/reset, RNG coupling và phạm vi bị nở nếu liên quan.
Không sửa file trong vai trò review. Trả findings có path/symbol và severity; không tự duyệt game feel thay tôi.
```

## 6. Phản hồi cảm giác chơi hữu ích

```text
Tình huống: [wave/scene/số quái/mode đang thử].
Thao tác: [tôi làm gì].
Quan sát: [rung quá lâu, mất dấu nhân vật, không phân biệt slam với Pulse...].
Mong muốn: [một thay đổi nhìn/nghe/cảm nhận được].
Hãy đề xuất thay đổi nhỏ nhất trong config/visual scope và cách A/B kiểm tra. Chưa thay gameplay để bù cho hiệu ứng.
```

## 7. Khi AI nói đã xong nhưng chưa có bằng chứng

```text
Đừng viết thêm feature. Hãy xuất handoff đúng template: file đã đổi, command thực sự đã chạy, exit code/log, acceptance matrix và check chưa làm.
Nếu chưa kiểm tra bằng mắt hoặc chưa có owner approval, sửa trạng thái về AWAITING_PLAYTEST. Không tạo log, screenshot hay kết quả giả để lấp chỗ trống.
```
