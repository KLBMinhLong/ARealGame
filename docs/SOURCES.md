# Nguồn kỹ thuật tham khảo

Đối chiếu ngày 05/09/2026. Đường dẫn tài liệu có thể redirect theo phiên bản sản phẩm. Version/build hash của máy người dùng là thông tin họ cung cấp, không phải kết luận được kiểm tra từ website.

## Antigravity

- Rules: https://www.antigravity.google/docs/ide/rules
  - Workspace rules ở `.agents/rules/`; hỗ trợ cũ `.agent/rules/`.
  - UI Customizations → Rules; chế độ Always On/Manual/Model Decision/Glob.
  - Rule là Markdown, giới hạn 12.000 ký tự mỗi file. Bộ này dùng UI activation thay vì đoán metadata YAML.
- Workflows: https://antigravity.google/docs/ide/workflows
  - Workflows có thể tạo qua Customizations → Workflows và gọi `/workflow-name`.
  - Các file trong `prompts/` của bộ này là prompt copy/paste, KHÔNG mặc định đã đăng ký slash command.
  - Nếu muốn, người dùng tạo Workspace Workflow qua UI và dán prompt vào sau khi đã kiểm tra quy trình thủ công.

## Godot 4.6

- CLI: https://docs.godotengine.org/en/4.6/tutorials/editor/command_line_tutorial.html
  - `--headless`, `--import`, `--script`, `--quit-after`, `--export-release`.
  - Import/resource setup khác test runtime; export cần editor binary và templates phù hợp.
- Export overview (tham khảo khi phát hành): https://docs.godotengine.org/en/4.6/tutorials/export/exporting_projects.html
- Windows export (tham khảo khi phát hành): https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_windows.html
- License: https://godotengine.org/license/
- License compliance hướng dẫn: https://docs.godotengine.org/en/stable/about/complying_with_licenses.html

Hai trang export cụ thể không lấy được đầy đủ nội dung trong phiên chuẩn bị; hướng dẫn CLI đã truy cập được. Khi có thay đổi UI hoặc tùy chọn, kiểm tra trực tiếp editor đúng bản thay vì coi tên menu là bất biến.

## Không đưa ra khẳng định chưa xác minh

Bộ này không xác nhận tồn tại/tính năng/hạn mức của model được gọi là “Gemini 3.8 Flash High”. Chọn model thực sự có trong Antigravity của bạn. Không nhúng tên model vào runtime hoặc tạo dependency API.
