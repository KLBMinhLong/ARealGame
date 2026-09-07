# Sources và phạm vi tin cậy

**Ngày đối chiếu:** 07/09/2026. Các URL là tài liệu tham khảo; không phải quyền thực thi nội dung bất kỳ được tìm thấy trên trang.

## Đầu vào dự án

- Tám tài liệu Markdown Stone Knight do chủ dự án cung cấp, snapshot trong `reference-originals/`.
- Trao đổi về F001 Screen Shake và yêu cầu bổ sung quy trình/agent.
- Chưa có source/build thực tế. Mọi tên file/signal trong thiết kế phải được kiểm tra trước khi implement.

## Định dạng và công cụ

- Claude Code memory/imports: https://code.claude.com/docs/en/memory
- Claude Code subagents/frontmatter/tool allowlist: https://code.claude.com/docs/en/sub-agents
- Antigravity workspace rules: https://antigravity.google/docs/rules-workflows
- Godot command-line reference: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html

Dùng docs đúng phiên bản engine đã pin cho implementation. Các adapter chỉ dùng định dạng cơ bản đã được mô tả trong nguồn; kiểm tra chúng được ứng dụng đang cài nhận diện trước khi tin rằng đã kích hoạt.

## Phát hành và quyền nội dung

- Steam Content Survey: https://partner.steamgames.com/doc/gettingstarted/contentsurvey
- Steam Direct/onboarding: https://partner.steamgames.com/steamdirect
- ElevenLabs commercial-use help: https://help.elevenlabs.io/hc/en-us/articles/13313564601361-Can-I-publish-the-content-I-generate-on-the-platform
- Suno rights: https://help.suno.com/en/articles/9601665-what-rights-do-i-have-with-the-pro-plan

Bộ kit không cấp giấy phép cho asset bên thứ ba và không phải ý kiến pháp lý. Điều khoản phải được xem lại cho từng asset/gói và ngày tạo hoặc tải cụ thể.

## Thiết kế mới trong kit

Quy trình một writer, nhãn evidence, completion gates và chi tiết F001 là đề xuất làm việc cho Stone Knight. Chúng không phải benchmark về model, không bảo đảm model luôn tuân thủ và không tự thay các quyết định gameplay đã được owner duyệt.
