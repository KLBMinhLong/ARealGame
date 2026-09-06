# Bắt đầu trên máy bạn

## 0. Bạn đang nhận được gì?

Một bộ project source + tài liệu + prompt, không phải bộ cài game. Bạn không cần tạo project mới và không cần tự gắn từng script: các scene đã có đường dẫn liên kết. Kiểm chứng runtime trên máy bạn vẫn là bước bắt buộc.

Hướng dẫn chính giả định Windows vì cấu hình bạn đưa có dạng Windows. Nếu dùng hệ điều hành khác, giữ nguyên source và nhờ AI chuyển lệnh chạy, không đổi thiết kế game.

## 1. Giải nén đúng chỗ

- Giải nén ZIP vào một thư mục riêng trong máy, ví dụ `Documents\GameDev\vong-vay-ai-starter`.
- Thư mục bạn mở phải chứa trực tiếp `project.godot`, `README.md`, `AGENT_RULES.md`, `scenes/`, `scripts/`.
- Không mở file khi còn nằm bên trong ZIP. Không giải nén đè lên project cũ.
- Nếu đã có dự án đang làm, dùng thư mục khác; sau khi bạn duyệt mới chuyển phần cần thiết.
- Không cần tải Unity, C#, Node.js, npm, asset pack hoặc plugin để chạy bộ này. Python chỉ là tùy chọn để chạy kiểm tra cấu trúc; game không phụ thuộc Python.

## 2. Chạy bằng Godot trước khi nhờ AI thêm tính năng

1. Mở Godot Project Manager đang cài.
2. Chọn **Import**, chọn file `project.godot` vừa giải nén, mở project.
3. Chờ import lần đầu xong. Renderer của project là **Compatibility**.
4. Bấm **F5**. Nếu chưa nhận main scene, chọn `scenes/main.tscn` khi Godot hỏi.
5. Kỳ vọng: menu “VONG VAY”, nút Start Run, hướng dẫn WASD/phím mũi tên.
6. Bấm Start Run. Thử di chuyển, chạy vào biên, chạm quái, Esc để pause/resume, thử thua và chơi lại.
7. Bấm **F8** để dừng game đang chạy từ editor.

Nếu lỗi: **đừng đổi engine hoặc tạo lại project**. Mở Output/Debugger, sao chép lỗi ĐẦU TIÊN kèm file và dòng; dùng `prompts/03_FIX_BUG.md`. Một lỗi parse có thể gây hàng loạt lỗi phụ.

Máy 8 GB: chỉ mở một Godot editor, một Antigravity, ít tab. Không chạy nhiều agent cùng sửa project. Nếu thiếu bộ nhớ, đóng app trước; không tự đổi sang renderer nặng hơn.

## 3. Mở đúng workspace trong Antigravity

1. Mở Antigravity IDE và dùng thao tác mở thư mục/workspace để chọn chính thư mục chứa `project.godot`.
2. Trong Explorer, xác nhận thấy `AGENT_RULES.md`, `docs/`, `prompts/`, `.agents/rules/00-project.md`. Thư mục bắt đầu bằng dấu chấm có thể bị ẩn ở File Explorer Windows.
3. Ở bảng agent, mở menu **… → Customizations → Rules**.
4. Nếu rule `00-project` được nhận, đặt activation là **Always On**. Nếu không được nhận, tạo **Workspace Rule**, dán nguyên nội dung `.agents/rules/00-project.md`, rồi đặt Always On.
5. Không ghi đè Global Rules của bạn. Rule này chỉ dành cho project này.
6. Chọn model hiện có trong IDE của bạn. Bộ này không phụ thuộc tên “Gemini 3.8 Flash High”, không cấu hình API key và không khẳng định model đó có trong mọi tài khoản.
7. Chọn chế độ yêu cầu bạn duyệt thay đổi/lệnh nếu IDE có tùy chọn đó. Không cho tự duyệt mọi lệnh terminal, xóa file hoặc thao tác ngoài project.

Tài liệu Antigravity hiện dùng `.agents/rules/`, đồng thời mô tả tương thích với `.agent/rules/`. Không nhân đôi hai thư mục mặc định vì có thể nạp hai lần. Cấu trúc rule có thể thay đổi theo phiên bản IDE; dùng UI tạo rule là cách dự phòng. Việc “đặt file ở đó” không thay thế kiểm tra agent đã đọc.

## 4. Dán prompt đầu tiên

Mở `prompts/00_BOOTSTRAP.md`, copy toàn bộ phần nằm trong khối code và dán vào agent. Prompt yêu cầu:

- Đọc brief, sơ đồ wiring, rules, task hiện tại, báo cáo QA.
- Xác định đúng Godot executable và báo version.
- Chạy kiểm tra import + smoke nếu môi trường cho phép.
- Không thêm tính năng, không tải gói, không tự nâng cấp engine.
- Báo PASS/FAIL/BLOCKED theo bằng chứng, không nói “xong” chỉ vì đã sửa file.

Nếu agent không tìm thấy Godot, bạn đưa **đường dẫn file exe trên máy**, không đưa mật khẩu hay token. Bản Windows thường có executable dạng `Godot_..._win64_console.exe` bên cạnh executable thường; dùng bản console để xem log rõ hơn.

## 5. Kiểm thử tự động trên Windows

Trước khi import/test từ terminal: lưu scene, dừng game; nên đóng Godot editor để tránh hai tiến trình import cùng một project. Antigravity vẫn có thể mở.

Mở PowerShell tại thư mục project. Thay ví dụ dưới bằng đường dẫn exe THẬT trên máy:

```powershell
& .\tools\verify.ps1 -GodotExe 'C:\DUONG_DAN_THAT\Godot_console.exe'
```

Script chỉ chạy local, có timeout mỗi bước, không tải phần mềm, không yêu cầu admin. Nó kiểm tra cả phiên bản/build hash bạn cung cấp. Nếu khác: báo người dùng để xác minh `ENGINE_VERSION.txt`; không dùng cờ override một cách máy móc.

Nếu Windows chặn chạy file `.ps1`, **không cần tắt bảo vệ hoặc đổi policy toàn hệ thống**. Nhờ AI chạy trực tiếp các lệnh tương đương:

```powershell
$Godot = 'C:\DUONG_DAN_THAT\Godot_console.exe'
& $Godot --version
& $Godot --headless --path . --import
& $Godot --headless --path . --script res://tests/smoke_test.gd
& $Godot --headless --path . --quit-after 120
```

Chỉ chạy bước sau khi bước trước không lỗi. Cần xem cả Output/stderr lẫn exit code. Smoke test phải in `ALL_TESTS_PASSED`; log có `SCRIPT ERROR`, `Parse Error` hoặc `ERROR:` thì không được xem là đạt chỉ vì exit code là 0. Wrapper `verify.ps1` thực hiện kiểm tra này tự động.

`--quit-after 120` nghĩa là 120 vòng/frame xử lý, KHÔNG phải 120 giây và KHÔNG thay thế việc chơi đủ 3 phút.

Kiểm tra cấu trúc tùy chọn, nếu đã cài Python:

```powershell
python .\tools\verify_structure.py
```

## 6. Tạo mốc Git khi baseline đã chạy

Nếu máy có Git, chạy trong thư mục project:

```powershell
git init
git status
git add .
git commit -m "chore: add verified Godot starter baseline"
```

Xem `git status` trước `git add .` để không đưa file riêng tư vào Git. `.gitignore` bỏ cache `.godot/`, log, build và nhiều file bí mật phổ biến nhưng không bảo vệ khỏi mọi bí mật.

Nếu Git yêu cầu name/email, cấu hình bằng danh tính bạn muốn dùng trên máy; đừng nhờ AI bịa. Không cần GitHub để dùng Git local. Không tự đẩy repo public.

Sau mỗi task đã test, tạo commit riêng. Đừng dùng `git reset --hard` hay `git clean -fd` để “sửa nhanh” khi chưa hiểu dữ liệu sẽ mất. Dùng bản sao/branch và xem diff trước.

## 7. Làm game theo từng cổng kiểm tra

- **M0:** xác minh source starter trên máy bạn. Không thêm feature.
- **M1:** duyệt brief và kiểm chứng cơ chế chính có vui không.
- **M2:** thực hiện lát cắt nhỏ có chất lượng: một cơ chế đặc trưng, đủ tutorial/feedback để người khác tự chơi.
- **M3:** bổ sung phần bắt buộc cho v1: save, settings, âm thanh/credits, cân bằng.
- **M4:** test, tối ưu trên máy bạn, xuất bản Windows sạch.
- **M5:** chỉ chuẩn bị phát hành sau khi có phản hồi người chơi và đã xử lý quyền sử dụng tài nguyên.

Mở `docs/TASKS.md`. Mỗi lần dùng `prompts/01_NEXT_TASK.md` để chọn đúng một task chưa bị chặn. Agent lập kế hoạch nhỏ → bạn duyệt → agent làm → kiểm thử → bạn chơi → commit → cập nhật bàn giao.

## 8. Một phiên làm việc tiêu chuẩn

1. Đọc `docs/SESSION_HANDOFF.md` và task hiện tại.
2. Chốt đúng một kết quả quan sát được; hỏi lại nếu thiết kế còn mâu thuẫn.
3. Agent chỉ sửa phạm vi cần thiết, ghi cả script + scene + input + signal liên quan.
4. Chạy import/smoke; bạn chơi checklist tương ứng.
5. Nếu không chạy được, ghi BLOCKED hoặc IMPLEMENTED_AWAITING_TEST. Không chuyển task thành DONE.
6. Bạn kiểm tra diff. Commit, ghi bug còn lại, cập nhật handoff.
7. Dừng phiên ở mốc rõ ràng. Phiên mới không phải nhớ toàn bộ chat cũ.

## 9. Bạn vẫn phải làm phần nào?

Bạn quyết định ý tưởng, giới hạn công việc, đánh giá vui/chán, chơi thử, duyệt asset/chi phí, và chịu trách nhiệm tài khoản phát hành. AI hỗ trợ code, docs, debugging và chuẩn bị build; không thay thế kiểm thử thực tế hoặc chứng minh có người mua.

**Bài tập đầu tiên hôm nay:** chạy menu → di chuyển → thua → retry → pause/resume; lưu lỗi nếu có. Chỉ khi vòng này hoạt động mới chọn cơ chế mới.
