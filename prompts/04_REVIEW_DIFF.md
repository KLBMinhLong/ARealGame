# Review độc lập, chỉ đọc

Copy phần trong khối dưới vào agent. Đây là prompt thông thường, không tự đăng ký slash command.

```text
Đóng vai reviewer CHỈ ĐỌC cho task gần nhất. Không sửa file và không chạy lệnh gây thay đổi dữ liệu. Đọc AGENT_RULES.md, brief/spec/task đã duyệt, git diff và các file/scene thực sự liên quan.

Tìm lỗi thực tế: node path sai, script chưa gắn, signal chưa nối/nối lặp, input không hoạt động, code không được gọi, lỗi version API, reset/pause thiếu, dữ liệu save không an toàn, export thiếu resource, dependency/secret/asset license không rõ.

Không coi sự tồn tại của test hoặc báo cáo agent trước là bằng chứng test đã chạy. Soát log và tách runtime/visual/manual chưa xác minh.

Trả findings theo mức độ, mỗi finding có file/dòng hoặc node, đường đi gây lỗi, cách tái hiện và cách sửa gợi ý. Không bịa finding để đủ số lượng. Nếu không thấy lỗi, nói phạm vi đã xem và giới hạn, không tuyên bố chắc chắn không có bug.
```
