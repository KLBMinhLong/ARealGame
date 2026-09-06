# Quy trình dùng AI để hoàn thành game

## Phân công

Bạn là người quyết định sản phẩm và duyệt kiểm thử. Agent là người đọc repo, đề xuất thay đổi, viết/sửa code và chạy công cụ được cho phép. Reviewer có thể là một phiên chat mới đọc diff; không cần nhiều model và không nên nhiều agent ghi cùng repo trên máy 8 GB.

## Bắt đầu mỗi phiên

Dùng `prompts/00_BOOTSTRAP.md` lần đầu; các lần sau đọc handoff và `prompts/01_NEXT_TASK.md`. Yêu cầu agent tóm tắt trạng thái thật, task hiện tại, file/scene liên quan và điều chưa được xác minh. Đừng dán toàn bộ chat cũ khi handoff ngắn đã đủ.

## Vòng làm việc

1. **Chốt task:** một hành vi kiểm tra được. Ví dụ: Space phát xung một lần, quái trong bán kính bị đẩy, có hồi chiêu.
2. **Đọc kiến trúc:** nơi lấy input, nơi update, ai sở hữu state, signal nào đến UI, chỗ reset/pause.
3. **Kế hoạch nhỏ:** file cần sửa/tạo, cách giữ tương thích starter, test cần thêm. Bạn duyệt.
4. **Thực thi:** sửa từng bước; không thêm asset/backend hoặc refactor ngoài phạm vi.
5. **Kiểm tra:** import, smoke/regression, test tay. Nếu lỗi thì quay về lỗi đầu tiên, không viết thêm feature đè lên.
6. **Review diff:** code chết? node path sai? signal chưa nối? pause/reset/save đúng? có secret/dependency không cần?
7. **Đóng task:** cập nhật trạng thái, handoff và commit khi đạt. Chưa chạy thì giữ AWAITING_TEST.

## Khi AI nói “đã hoàn thành”

Hỏi ba điều: “Lệnh nào đã chạy? Kết quả/log đâu? Tôi cần thao tác gì để nhìn thấy tính năng?” Nếu agent chỉ kể file đã tạo, chưa đủ. Kiểm tra rằng luồng được gọi từ main scene, không phải demo scene bỏ quên.

## Khi AI sửa mãi vẫn lỗi

- Dừng thêm chức năng. Chụp/copy lỗi đầu tiên, đường dẫn và dòng, thao tác tái hiện.
- Cho agent đọc lại file thật, không suy đoán từ ký ức chat.
- Yêu cầu nêu một giả thuyết và một cách xác minh; sửa tối thiểu.
- Nếu lỗi xuất hiện sau task gần nhất, so sánh diff với commit chạy tốt. Không xóa toàn bộ repo.
- Sau nhiều vòng không tiến triển, dùng prompt review trong phiên mới, đưa bug report và diff. Không bịa một con số “chắc chắn sửa xong”.

## Dùng model hiệu quả

Không có model nào được bảo đảm hoàn thành cả sản phẩm tự động. Model đang có trong tài khoản của bạn có thể đủ cho task nhỏ. Dùng mức suy luận cao nếu công cụ có cho thiết kế/debug khó; task lặp nhỏ có thể dùng cấu hình tiết kiệm. Không mặc định phải mua thêm gói hay đổi model khi chưa xác định lỗi nằm ở đâu.

Tránh sinh toàn bộ game trong một prompt: ngữ cảnh dài, thay đổi khó review, khó biết lỗi bắt đầu ở đâu. Tránh “hãy tiếp tục tới khi hoàn tất mọi thứ” vì agent có thể tự coi test chưa chạy là đạt.

## Cổng người dùng phải duyệt

- Đổi thể loại/phạm vi/engine.
- Thêm tài nguyên/dependency có license hoặc chi phí.
- Lệnh phá hủy, sửa ngoài project, public repo/upload/publishing.
- Kết luận trải nghiệm đủ vui và quyết định bán.

Các cổng này không có nghĩa bạn phải duyệt từng dòng code; bạn duyệt kế hoạch/task, kiểm tra diff và kết quả.

## Handoff tối thiểu

Task đang làm, commit gần nhất, thay đổi chưa commit, lệnh/test đã chạy, bug còn, quyết định chưa chốt, việc tiếp theo. Không đưa token/mật khẩu vào handoff.
