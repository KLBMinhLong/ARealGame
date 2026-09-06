# Sửa lỗi dựa trên bằng chứng

Copy phần trong khối dưới vào agent. Đây là prompt thông thường, không tự đăng ký slash command.

```text
Tôi sẽ gửi lỗi hoặc bug report. Hãy đọc AGENT_RULES.md, docs/TECH_SPEC.md, git diff và file thật được nhắc tới.

Nếu thông tin chưa đủ, hỏi đúng điều cần: bước tái hiện, lỗi đầu tiên nguyên văn, file/dòng, version engine, editor hay export. Không đoán rồi tạo lại cả project.

Tách nguyên nhân gốc và lỗi kéo theo. Nêu một giả thuyết có thể kiểm tra, dẫn file/dòng và wiring liên quan. Đề xuất bản sửa nhỏ; hỏi trước nếu phải đổi phạm vi/kiến trúc.

Sau khi sửa được duyệt: tái hiện ca lỗi, chạy regression, kiểm tra pause/reset và báo log thật. Không đổi engine/renderer, xóa cache/project hàng loạt hay cài plugin như biện pháp mặc định. Ghi rõ nếu chưa tái hiện hoặc chưa chạy được.

Kết thúc bằng nguyên nhân, diff, test đã chạy, test tôi cần làm và cập nhật handoff.
```
