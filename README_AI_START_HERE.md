# Stone Knight — AI Coding Kit v1

**Ngày soạn:** 07/09/2026 · **Ngôn ngữ làm việc:** tiếng Việt · **Phạm vi:** hướng dẫn phát triển, không phải source game.

> Một AI viết code. Các agent phụ đọc và phản biện. Người làm game quyết định thiết kế, kiểm tra cảm giác chơi và duyệt phát hành.

## Bắt đầu trong 5 bước

1. Giải nén bộ kit **ra một thư mục riêng**, không giải nén đè trực tiếp vào repo đang làm.
2. Kiểm tra `git status`, lưu công việc hiện tại. So sánh trước khi đưa các file vào repo. Nếu đã có `AGENTS.md`, `CLAUDE.md` hoặc rules, **merge nội dung có chủ đích**, không ghi đè.
3. Chép các file hướng dẫn cần thiết vào đúng đường dẫn tính từ root repo. Giữ tám tài liệu gốc hiện có; bản sao trong `docs/ai/reference-originals/` chỉ là tài liệu tham khảo lịch sử.
4. Chọn cách nạp hướng dẫn ở mục bên dưới. Chỉ cần một coding agent chính; không cần mua thêm model hoặc cài framework agent.
5. Dán prompt **Khởi động F000** trong [PROMPTS](docs/ai/PROMPTS.md). Bước đầu là khảo sát repository, chưa phải tự động viết Screen Shake.

## Nếu dùng Claude Code

- Root `CLAUDE.md` import `AGENTS.md`. Đây là cách giữ một bộ luật chung, tránh hai tài liệu mâu thuẫn.
- `.claude/agents/` chứa ba subagent **chỉ đọc**: `godot-scout`, `gameplay-reviewer`, `qa-reviewer`.
- Các subagent dùng `model: inherit`: dùng model của phiên làm việc chính, không hard-code một phiên bản model.
- Mở Claude Code tại root repo. Nếu thư mục agents vừa được tạo mà agent chưa được nhận diện, khởi động lại phiên.
- Gọi bằng ngôn ngữ tự nhiên, ví dụ: “Dùng godot-scout khảo sát Camera2D và đường đi của các sự kiện cho F001”.
- Kiểm tra agent thực sự đã nạp quy tắc và công cụ chỉ đọc. File hướng dẫn **không phải một cơ chế cưỡng chế bảo mật**.

## Nếu dùng Opus trong Antigravity

Model và ứng dụng chạy model là hai thứ khác nhau. Các file `.claude/agents/` không tự biến thành agent native của Antigravity.

- Dùng `AGENTS.md` và các tài liệu `docs/ai/` làm nguồn quy tắc chung.
- Có sẵn `.agents/rules/stone-knight.md`. Trong phần Customizations → Rules, kiểm tra rule và chọn **Always On** cho workspace này; không giả định chép file là đã kích hoạt.
- Antigravity hiện dùng `.agents/rules`, vẫn hỗ trợ `.agent/rules`. Chọn **một** vị trí phù hợp với bản đang cài, tránh nạp hai lần.
- Nếu không nhận rule, đính kèm/mention trực tiếp `AGENTS.md` và task đang làm.
- Có thể chạy vai trò scout/reviewer bằng prompt riêng. Nếu ứng dụng không hạn chế được quyền của vai trò phụ, **không coi lời hứa “read-only” là bảo đảm kỹ thuật**; duy trì một người/agent duy nhất sửa repo.

## Nên đọc gì trước?

| Cần làm | Tài liệu |
|---|---|
| Luật bắt buộc, cách chọn tài liệu | [AGENTS.md](AGENTS.md) |
| Những gì đã biết và còn chưa xác minh | [PROJECT_TRUTH](docs/ai/PROJECT_TRUTH.md) |
| Quy trình một feature và quyền duyệt | [WORKFLOW](docs/ai/WORKFLOW.md) |
| Chất lượng code Godot | [GODOT_ENGINEERING](docs/ai/GODOT_ENGINEERING.md) |
| Lệnh kiểm tra và bằng chứng | [VERIFICATION](docs/ai/VERIFICATION.md) |
| Task hiện tại | [F001_SCREEN_SHAKE](docs/ai/tasks/F001_SCREEN_SHAKE.md) |
| Tạo feature mới hoặc bàn giao | [FEATURE_BRIEF](docs/ai/templates/FEATURE_BRIEF.md), [HANDOFF](docs/ai/templates/HANDOFF.md) |
| Art, animation, âm thanh, giấy phép | [ASSET_PIPELINE](docs/ai/ASSET_PIPELINE.md) |
| Playtest, milestone, phát hành | [PLAYTEST_RELEASE](docs/ai/PLAYTEST_RELEASE.md) |

## Bộ kit cố ý không làm gì?

- Không thay thế source game; không chứa `project.godot`, scene hoặc script gameplay có thể giả vờ đã tích hợp.
- Không tự sửa tám tài liệu thiết kế gốc.
- Không cài plugin, MCP, hooks, dependency hoặc quyền tự động chạy shell.
- Không commit, push, đăng Steam hoặc đọc/upload bí mật.
- Không tuyên bố “game vui”, “60 FPS” hay “không còn bug” từ việc code parse thành công.

## Công cụ kiểm tra có kèm theo

`scripts/ai/verify_godot.py` dùng Python 3.10+ và thư viện chuẩn. Nó kiểm tra version + import, ghi lệnh, exit code và log; smoke scene là tùy chọn cần cho phép rõ ràng. Nó **không phải bộ test của Stone Knight**.

Đọc [VERIFICATION](docs/ai/VERIFICATION.md) trước khi chạy. Import có thể chạy editor plugin / tool script và tạo cache `.godot`; runtime có thể tác động save. Chỉ dùng trên project tin cậy và dữ liệu test phù hợp.

## Hạn chế đã biết

Chưa có repository hoặc bản chạy Stone Knight tại thời điểm soạn kit. Chưa xác minh các tên signal, config, camera controller hay phiên bản engine đang dùng. Công cụ hỗ trợ được kiểm tra riêng; kết quả không chứng minh game đã được kiểm tra.
