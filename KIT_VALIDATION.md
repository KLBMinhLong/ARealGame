# Kit validation — phạm vi kiểm tra

Ngày soạn: 07/09/2026.

## Đã kiểm tra

- Required instruction, role, feature, template and helper files exist.
- CLAUDE.md imports canonical AGENTS.md; root operating rules stay under 200 lines.
- Three unique Claude Code agents have valid basic YAML and read-only tool allowlists.
- Authored Markdown fences and local Markdown links are structurally valid.
- All eight original design attachments are preserved byte-for-byte.
- Python files pass syntax compilation without executing game code.
- 19 helper unit tests passed with fake runner fixtures; no Godot/game tests were executed.
- Helper command-line help runs successfully.
- Actual helper CLI correctly reports BLOCKED for a folder without project.godot.

## Chưa kiểm tra

- Stone Knight repository integration: no source/build supplied.
- Godot executable/project execution: Godot is not installed in this authoring sandbox.
- Claude Code/Antigravity application loading and permissions: not run in either application.
- Game behavior, visuals, audio, performance and human playtest approval.

Test fixture và kiểm tra cấu trúc bộ kit không thay thế kiểm thử game. Không có gameplay feature nào được đánh dấu DONE bởi báo cáo này.
