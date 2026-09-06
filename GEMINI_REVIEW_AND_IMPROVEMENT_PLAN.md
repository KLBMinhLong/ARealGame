# VÒNG VÂY — REVIEW SOURCE & KẾ HOẠCH NÂNG CHẤT LƯỢNG

**Ngày review:** 06/09/2026  
**Đối tượng thực hiện:** Gemini trong Antigravity IDE, phối hợp với chủ project.  
**Engine người dùng cung cấp:** Godot `v4.6.3.stable.official [7d41c59c4]`, GDScript, GL Compatibility.  
**Máy mục tiêu:** i5-1135G7 / RAM 8 GB / Intel Iris Xe. Chưa có benchmark độc lập từ lượt review này.

> **Mục tiêu thực của chủ project:** một game hay, hấp dẫn, có nhân vật và đồ họa riêng, animation có chất lượng, âm thanh và nhạc nền cuốn hút, gameplay có lý do để chơi lại, đủ chất lượng phát hành và có khả năng tạo doanh thu. Một prototype đủ menu/save/settings KHÔNG tự đáp ứng mục tiêu đó.
>
> **Trạng thái đề xuất:** functional prototype — đang cần thiết kế và sản xuất một lát cắt gameplay đạt chất lượng mục tiêu. Chưa đủ bằng chứng để gọi là release candidate. Không hứa doanh thu.

## 0. Cách sử dụng file này

1. Đặt file này tại root project, cùng cấp với `project.godot`.
2. Gemini đọc file này, rồi đối chiếu **source hiện tại**, không chỉ đọc báo cáo tiến độ cũ.
3. Dùng prompt ở cuối file để bắt đầu. Làm từng nhiệm vụ đã được duyệt, không triển khai toàn bộ tài liệu trong một lượt.
4. File này là phản hồi và kế hoạch đề xuất; **không tự ghi đè GAME_BRIEF, ART_AUDIO hoặc thiết kế sản phẩm trước khi chủ project duyệt thay đổi**. Các lỗi kỹ thuật cần kế hoạch sửa rõ và được giao thực hiện.
5. Lượt review này không sửa mã game, không thay đổi save và không phát hành gì. Dòng tham chiếu bên dưới ứng với ZIP mới gửi ngày 06/09/2026; sau khi sửa, tìm theo tên hàm/nội dung thay vì dựa cứng vào số dòng.

---

## 1. Nguồn và giới hạn của kết luận

Đã xem:
- Bản ZIP gửi lại: `ARealGame_Astra_Review.zip`, có `project.godot`, scenes, scripts, tests và docs.
- Video `2026-09-06 16-12-39.mp4`; kiểm tra các khung hình ở những thời điểm khác nhau và màn kết quả. Video cho thấy một lượt chơi, không phải chứng cứ hoàn thành toàn bộ bài test 180 giây.
- Luồng Main → Player/Enemy → HUD; SaveManager, SettingsManager, AudioManager; smoke test; các tài liệu thiết kế/tiến độ.

Đã thực hiện độc lập:
- Đọc script kiểm tra cấu trúc trước khi chạy. Chạy lại `tools/verify_structure.py`: **77/77 kiểm tra cấu trúc đạt**.
- Mô phỏng lịch spawn theo hằng số và logic source bằng Python ở bước thời gian 60 Hz, đối chiếu bằng cách tính theo sự kiện. Đây là mô hình logic, **không phải chạy Godot**.

Chưa thực hiện:
- Không có Godot executable trong môi trường review, nên chưa tự chạy import/GDScript runtime/smoke hoặc build Windows mới.
- Không có đủ bằng chứng nghe thử độc lập để chấm chất lượng mix/âm nhạc bằng tai. Kết luận thiếu nhạc nền bên dưới dựa vào source và danh mục tài nguyên, không dựa vào việc giả vờ đã nghe.
- Không xác nhận mọi nhận xét “chủ project đã duyệt” trong báo cáo cũ. Không xác nhận nhu cầu thị trường hoặc doanh thu.

**Không được biến giới hạn này thành lời khẳng định rằng game đã hoặc chưa vượt qua một test không có bằng chứng.**

## 2. Kết luận điều hành

### Phần có giá trị nên giữ

Source thực sự có thêm xung đẩy, Sprinter nhiều trạng thái, lưu kỷ lục, settings, menu phụ và SFX procedural. Đây không phải ba giờ làm việc vô ích. Nền điều khiển/state/signal hiện tại có thể tiếp tục sử dụng.

### Vì sao game vẫn giống starter?

1. **Tài liệu đã gọi giao diện prototype là thiết kế cuối.** `docs/ART_AUDIO.md:1–15` mang tiêu đề “v1 Final Specification”, quy định player hình tròn và quái hình học. Theo bộ tiêu chí này, AI có thể giữ nguyên hình tạm mà vẫn đánh dấu DONE.
2. **Chưa có bộ nhân vật/đồ họa như mục tiêu mới của người dùng.** `assets/art`, `assets/audio`, `assets/fonts` chỉ có `.gitkeep`; player và quái vẫn vẽ bằng `_draw()`.
3. **Chưa có nhạc nền.** AudioManager tạo các SFX ngắn; Music mới là bus dự phòng. Tạo bus tên Music không đồng nghĩa có soundtrack.
4. **Vòng chơi hiện tại còn hẹp:** di chuyển, lùa quái, dùng xung thoát vây, chờ đủ thời gian. Chưa có phần thưởng trong lượt, cách xử lý quái để tạo lợi thế, lựa chọn nâng cấp hoặc mục tiêu phụ.
5. **Nghiệm thu đang thiên về sự tồn tại của chức năng.** Menu mở được, file save có dữ liệu và hằng số đúng không chứng minh game có cảm giác tốt, cân bằng hoặc đáng mua.

Hình học tối giản và âm thanh procedural không mặc nhiên là kém chất lượng. Nhưng chúng chưa đáp ứng yêu cầu nhân vật/đồ họa/âm nhạc riêng mà chủ project vừa nêu. RAM 8 GB không bắt buộc một game 2D chỉ được dùng hình tròn và hình vuông.

**Không đập lại toàn bộ project. Giữ nền kỹ thuật có ích; thay tiêu chí sản phẩm và làm một đoạn chơi hoàn chỉnh về chất lượng trước khi tăng nội dung.**

---

## 3. Các phát hiện kỹ thuật có bằng chứng

### R01 — Ưu tiên cao: smoke test có đường ghi vào save chơi thật

**Nguồn:**
- `scripts/main.gd:17–18`: Main tạo SaveManager/SettingsManager bằng đường dẫn mặc định.
- `scripts/main.gd:29–30`: load dữ liệu ở `_ready()`.
- `scripts/main.gd:153–164`: `finish_run()` gọi `save_manager.record_run()`.
- `scripts/core/save_manager.gd:6, 80–107`: mặc định `user://save_data.json`; record_run thực hiện ghi file.
- `tests/smoke_test.gd:39–42`: tạo Main và add vào SceneTree, chưa gán manager dùng đường dẫn test riêng.
- `tests/smoke_test.gd:117–142` và `295–301`: tạo thua/thắng bằng logic test, trong đó nhảy elapsed tới gần 180 giây.
- `tools/verify.ps1:56–58`: chạy smoke trong cùng project, không thấy cơ chế profile dữ liệu riêng.

**Hậu quả có thể xảy ra:** chạy test theo cách hiện tại trên cùng profile có thể tăng số lượt, số thắng và ghi best time do test tạo vào save thật. Các bài SaveManager dùng `test_save_data.json` từ dòng 153 không bảo vệ phần integration test đã chạy trước đó.

**Không kết luận save trên máy người dùng đã bị thay đổi; đây là đường đi có rủi ro được xác định từ source.**

**Cách sửa đề xuất:**
- Cho integration test cấp SaveManager/SettingsManager dùng đường dẫn riêng **trước khi `root.add_child(game)` làm `_ready()` chạy**. Hai manager đã có constructor nhận custom path; tận dụng cấu trúc đó nếu phù hợp.
- Mỗi lượt test dùng thư mục test riêng/định danh riêng. Không dùng thư mục save mặc định và không xóa save thật để “làm sạch test”.
- Tách các hiệu ứng phụ của settings trong test nếu cần, tránh test đổi cửa sổ/volume của phiên chơi ngoài ý muốn.

**Nghiệm thu:**
- Tạo dữ liệu chơi mẫu; ghi hash/nội dung trước test.
- Chạy smoke hai lần. Save/settings thật không đổi; file test chỉ nằm trong nơi dành cho test.
- Chạy game bình thường sau đó: kỷ lục không tự nhảy lên 03:00, số thắng không tự tăng.
- Khi test fail giữa chừng, không làm mất dữ liệu người chơi.

**Sửa R01 trước khi dùng smoke suite hiện tại làm bằng chứng cho các task khác.**

### R02 — Pacing: đạt trần quái thì hệ thống ngừng đưa quái mới vào lượt chơi

**Nguồn:**
- `scripts/main.gd:132–143`: đủ `MAX_ENEMIES` thì `spawn_one()` return.
- `scripts/main.gd:166–169`: chỉ dọn quái khi reset/menu; chưa có cơ chế hạ quái trong một lượt.
- `scripts/actors/enemy.gd:19–22, 52–54`: tốc độ Chaser nhận khi configure, không được cập nhật theo elapsed trong tick.
- `scripts/core/game_config.gd:12–16, 40–44`: hằng số tốc độ/tần suất cuối lượt không đồng nghĩa chúng được áp dụng vào quái đang sống.

**Mô hình nguồn:** giả sử người chơi còn sống, không xóa quái giữa lượt và chạy bước 60 Hz, quái thứ 64 xuất hiện khoảng **74,5 giây**. Sau đó không có spawn thành công mới trong phần còn lại của lượt 180 giây. Tốc độ cấu hình cao nhất có thể được gán cho một Chaser tại các thời điểm spawn đó khoảng **91 px/s**, không chạm mức 118 px/s cuối công thức. Đây là mô phỏng logic, không phải số đo runtime.

**Điều này không chứng minh nửa sau dễ:** Sprinter vẫn hoạt động và đàn quái vẫn nguy hiểm. Nó chứng minh mô tả “pacing tiếp tục tăng qua spawn/tốc độ đến cuối lượt” chưa được thực hiện như báo cáo gợi ý.

**Cách sửa:** chọn một chủ đích thiết kế sau khi được duyệt:
- Nếu giữ pure survival: thiết kế wave/refresh/thay đổi hành vi an toàn ở mức cap, hoặc cập nhật tốc độ đang sống có chủ đích.
- Nếu duyệt hướng gameplay mới ở mục 5: quái bị xử lý/tái chế sẽ giải phóng slot; wave director kiểm soát áp lực và khoảng nghỉ.
- Không đơn giản tăng cap lên hàng trăm quái và gọi đó là cân bằng.

**Nghiệm thu:** test đi qua toàn bộ lịch lượt chơi, ghi số quái và các pha. Không nhảy đồng hồ từ đầu lên 179,95 giây rồi coi đó là kiểm thử nhịp độ. Sau kiểm tra tự động, vẫn phải chơi đủ lượt và quan sát người ngoài.

### R03 — Telegraph Sprinter tràn khỏi đấu trường

**Nguồn:** `scripts/actors/enemy.gd:117–122` vẽ ray dài cố định 1200 px, không giới hạn tại biên sân. `scenes/main.tscn` không có vùng cắt tương ứng cho world. Ảnh người dùng gửi trước đó cũng cho thấy đường đỏ đi xuống vùng hướng dẫn dưới sân.

**Sửa:** tính giao điểm của hướng tia với hình chữ nhật sân, hoặc dùng cơ chế clipping phù hợp. Kiểm tra local/global coordinates vì enemy có rotation. Không chỉ rút ngắn tia tùy ý rồi làm cảnh báo sai phạm vi lao.

**Nghiệm thu:** nhiều vị trí/góc gần cả bốn mép; cảnh báo không chạy vào HUD/footer, vẫn chỉ rõ đường lao thực tế.

### R04 — Credits đang tự tuyên bố license chưa được chứng minh

**Nguồn:**
- `scripts/ui/hud.gd:452`: gắn “License: MIT License” cho project/game.
- `scripts/ui/hud.gd:454`: tuyên bố tài nguyên “100% royalty-free MIT / CC0”.
- `docs/ASSET_REGISTER.md:9–12`: các mục đã được APPROVED.
- `THIRD_PARTY_NOTICES.md:7`: tài liệu vẫn nói chưa tự chọn giấy phép mã game thay người dùng.

**Sửa:** tách giấy phép Godot khỏi giấy phép game và từng asset. Hỏi chủ project nếu chưa có quyết định cấp phép thật. Không mặc định nội dung AI là CC0 hoặc quyền độc quyền. Sửa mô tả/đăng ký tài nguyên theo nguồn và điều khoản có bằng chứng.

**Nghiệm thu:** Credits, notices và asset register khớp quyết định chủ project cùng quyền sử dụng thực tế. Không có câu “100% hợp pháp/thương mại” chỉ dựa vào việc chưa tải asset ngoài. Đây là cổng phát hành, không phải tư vấn pháp lý hoàn tất.

### R05 — Độ bền save cần hoàn thiện trước phát hành

**Nguồn:** `scripts/core/save_manager.gd:80–101` ghi trực tiếp file đích; `record_run()` không đưa kết quả `save_data()` vào phản hồi cho Main/HUD.

**Rủi ro:** ghi bị gián đoạn có thể làm file hỏng; lỗi lưu có thể chỉ xuất hiện ở warning trong khi UI vẫn hiển thị tiến bộ như bình thường. `schema_version` được đọc ở dòng 59 nhưng chưa có chính sách hỗ trợ/migrate/reject phiên bản rõ.

**Nghiệm thu:** chiến lược ghi tạm/backup phù hợp; thông báo lỗi lưu có kiểm soát; test thiếu file, hỏng file, sai kiểu, phiên bản không hỗ trợ và lỗi quyền ghi. Không im lặng xóa dữ liệu cũ để vượt test.

### R06 — Bằng chứng test và tài liệu chưa đồng bộ

- `tests/smoke_test.gd:280–293` kiểm tra nhiều hằng số/công thức. Nó không chứng minh độ vui, công bằng hoặc phản xạ của người chơi.
- `tests/smoke_test.gd:276` dùng `expect(true, ...)` sau các lệnh play. Không dùng dòng này để kết luận mix tốt hoặc không clipping.
- `docs/SESSION_HANDOFF.md:35–38` dẫn static check nhưng ghi “Test chưa chạy: Không / Bug còn: Không”.
- `docs/QA_REPORT.md` vẫn mang nhiều nội dung của bộ starter ban đầu, chưa mô tả đúng code mới. Đây là tài liệu cũ cần cập nhật, không phải chứng cứ rằng không ai từng chạy Godot trên máy người dùng.

**Nghiệm thu:** với mỗi task, ghi riêng: đã viết; test nào thực sự chạy/lệnh/log; test chưa chạy; người dùng đã duyệt phần gì; bug/giới hạn còn lại. Không lấy “tôi đã chơi thử” làm chấp thuận toàn bộ art, audio, balance và phát hành.

---

## 4. Thiếu hụt sản phẩm phải được đưa vào backlog, không gọi là “polish tùy chọn”

### Nhân vật và đồ họa

Hiện tại:
- `scripts/actors/player.gd:61–84`: các vòng tròn, kim hướng, vòng cooldown và vòng xung.
- `scripts/actors/enemy.gd:98–122`: hình thoi/tam giác và ray.
- Chưa có bộ sprite/animation nhân vật trong assets. Có chuyển động hình học, nhưng chưa có bộ diễn hoạt nhận diện nhân vật theo mong muốn của chủ project.

Cần:
- Một art direction được duyệt bằng hình mục tiêu, không chỉ một tên phong cách.
- Một nhân vật chính dễ nhận ra ở kích thước chơi thực, không chỉ biểu tượng HUD di chuyển.
- Bộ trạng thái thật được nối vào gameplay: idle, move/turn, chuẩn bị/phát xung, trúng đòn, mất năng lượng/thua.
- Enemy thể hiện rõ chuẩn bị tấn công → hành động → hồi phục. Không chỉ đổi màu.
- Môi trường, UI, VFX và nhân vật dùng chung ngôn ngữ màu/chất liệu/tỉ lệ.

### Âm thanh và âm nhạc

Hiện tại:
- `scripts/core/audio_manager.gd:9–14, 43–80`: các cue pulse/hit/telegraph/dash/win/game over.
- Các AudioStreamPlayer ở dòng 24–29 đều được gán vào SFX.
- Music chỉ được tạo ở dòng 31–36; `docs/ART_AUDIO.md:34` cũng gọi nó là kênh dự trữ.
- Settings hiện chỉ điều khiển Master và SFX.

Cần:
- Nhạc nền có giai điệu/đặc điểm nhận diện, không phải chỉ một bus hay tiếng thắng ngắn.
- Một loop gameplay hoàn chỉnh trước; sau đó thêm lớp/cường độ hoặc chuyển đoạn khi áp lực tăng nếu thật sự hữu ích.
- Music volume riêng, ghi nhớ setting, mute được; hành vi pause/resume được thiết kế rõ.
- SFX có trọng lượng và ưu tiên: nhiều Sprinter cùng cảnh báo không được làm mất cue quan trọng hoặc gây mệt tai.
- Nghe bản game thật với âm lượng bình thường và chơi lặp; dữ liệu âm thanh không rỗng không đủ nghiệm thu.

### Lối chơi và động lực chơi lại

Không yêu cầu thêm thật nhiều hệ thống. Yêu cầu một câu trả lời rõ: **người chơi có quyết định thú vị nào ngoài chạy tránh quái và đợi cooldown?**

Một cơ chế đặc trưng có thể quan trọng hơn hàng loạt menu hoặc thêm nhiều màu quái. Thay đổi gameplay phải được kiểm chứng, không tự khẳng định “cuốn” bằng lời.

---

## 5. Hướng sản phẩm đề xuất — chờ chủ project duyệt

### “Vòng Vây: Lõi Từ” — tên làm việc, chưa kiểm tra nhãn hiệu

**Một câu mô tả:** một robot bảo trì nhỏ dùng xung từ để dồn máy hỏng vào trạm tái chế, thu linh kiện và mở đường thoát khỏi một xưởng tự động mất kiểm soát.

**Lợi ích so với bản hiện tại:** xung không chỉ giúp sống lâu hơn; nó tạo một hành động chủ động, kết quả dễ nhìn, phần thưởng và lựa chọn vị trí.

**Vòng chơi đề xuất:**

Di chuyển/lùa quái → chọn vị trí gần trạm → phát xung đúng thời điểm → quái bị xử lý → thu linh kiện → chọn một cải tiến → đối phó tổ hợp quái tiếp theo → mở lối thoát.

Đây là giả thuyết thiết kế, không phải lời hứa sẽ vui hoặc bán được. Có thể bỏ nếu người dùng không thích hoặc playtest không ủng hộ.

### Một lát cắt 60–90 giây cần làm trước

- Một nhân vật robot có thiết kế riêng.
- Một căn phòng hoàn thiện về hình ảnh, không làm nhiều map trước.
- Hai loại quái kế thừa Chaser/Sprinter nhưng có hình và hành vi đọc được.
- Một trạm/vùng tái chế tương tác rõ với xung; không thêm nhiều hệ thống vật lý cùng lúc.
- Một phần thưởng và một lựa chọn nâng cấp đơn giản để kiểm tra động lực.
- Một loop nhạc thật, SFX đã phối và UI/VFX đúng style.
- Có mở đầu, cao trào ngắn, kết quả và retry.

**Không làm ở lượt này:** multiplayer, online accounts, inventory lớn, open world, nhiều nhân vật, nhiều boss, crafting, mobile port, nhiều currency hoặc mua bán trong game.

Chỉ sau khi lát cắt này được người dùng duyệt và người ngoài hiểu/chơi lại, mới chốt lượng nội dung cho bản bán. Không tự quyết định “cần 20 màn” hoặc “một màn là đủ bán” khi chưa kiểm chứng.

## 6. Quy trình sản xuất hình ảnh và animation

1. **Duyệt art target:** một mockup gameplay thể hiện nhân vật, quái, sân, HUD và palette. Ghi rõ đây là concept, không giả làm ảnh game đã chạy.
2. **Chọn một nhân vật:** làm sheet nhận diện cùng hướng nhìn và trạng thái; tránh tạo mỗi frame bằng prompt độc lập khiến nhân vật biến dạng.
3. **Chốt hợp đồng asset:** cell/frame size, pivot, tỉ lệ render, tên animation, tốc độ, nền trong suốt và quyền sử dụng.
4. **Tích hợp nhân vật trước:** thay phần trình bày của Player, giữ hợp đồng input/HP/state nếu không cần đổi. Không phá root/node path mà bỏ quên Main hoặc tests.
5. **Tích hợp enemy và VFX:** đủ dấu hiệu báo trước, hành động, hồi phục; hitbox ăn khớp hình nhìn thấy. Xung và điểm va chạm phải dễ hiểu.
6. **Tích hợp môi trường/HUD sau:** giảm nhiễu nền, bảo đảm vùng nguy hiểm rõ; không để animation/hiệu ứng che mục tiêu.
7. **Kiểm tra bằng capture từ Godot:** trạng thái đứng, di chuyển, hit, pulse, lose; kiểm tra nhiều kích thước cửa sổ và reduced effects.

Hướng mỹ thuật gợi ý: robot công nghiệp nhỏ, dễ mến nhưng rõ chức năng; kim loại ấm/cũ kết hợp ánh sáng xanh từ trường. Giữ ít màu chủ đạo và silhouette riêng. Đây là gợi ý, cần người dùng duyệt trước khi sản xuất hàng loạt.

Nếu dùng AI tạo ảnh, asset thuê/mua hoặc thư viện ngoài: chỉ lấy khi được cho phép, ghi nguồn/điều khoản trong register, kiểm tra consistency và giấy phép thương mại. Không tự hứa quyền độc quyền, không sao chép nhân vật/logo nhận diện từ game khác. Đồ họa riêng không bắt buộc tất cả phải tạo bằng GDScript.

## 7. Quy trình làm nhạc và sound design

1. Chủ project duyệt một mô tả âm nhạc: tâm trạng, nhịp năng lượng, nhạc cụ/chất âm và điều cần tránh.
2. Tạo/chọn một bản gameplay loop có quyền sử dụng rõ. Có thể dùng composer, tài nguyên được cấp phép hoặc công cụ AI sau khi được duyệt; không bắt buộc một phương án trả tiền.
3. Nhập vào game và phát thật qua Music; làm Music volume riêng trong SettingsManager/HUD.
4. Chốt hành vi menu/game/pause/win/lose. Nếu crossfade hoặc layer, kiểm tra không chồng lặp mỗi lần retry.
5. Phối SFX với nhạc: báo đòn phải nghe ra; hit và pulse khác nhau; win/lose không bị cue quái cắt mất vô lý.
6. Kiểm tra loop không bị hẫng, âm lượng không gây mệt, mute hoạt động và setting tồn tại sau restart. Limiter không phải bảo đảm mọi nguồn âm đã sạch hoặc không méo ở bước trước.
7. Duyệt bằng clip gameplay có audio thật và nghe trực tiếp, không bằng `AudioStreamWAV.data.size() > 0`.

---

## 8. Roadmap mới theo cổng chất lượng

| Cổng | Việc chính | Điều kiện đi tiếp |
|---|---|---|
| G0 — Nền an toàn | Sửa R01, chuẩn hóa bằng chứng test; ghi nhận R02–R06 | Không đụng save thật khi test; trạng thái/bằng chứng trung thực |
| G1 — Chốt sản phẩm | Chủ project duyệt core loop, phạm vi, art target và audio target | Có quyết định rõ; không gọi hình placeholder là final |
| G2 — Một lát cắt có chất lượng | Một phòng + nhân vật + cơ chế đặc trưng + nhạc/SFX + animation | Clip/bản chơi thật; chủ project duyệt trải nghiệm, không chỉ source |
| G3 — Kiểm chứng chơi lại | Người ngoài chơi không cần giải thích miệng; ghi quan sát và sửa | Hiểu mục tiêu, hiểu thua vì sao, có hành vi muốn thử lại; không suy ra doanh thu từ mẫu nhỏ |
| G4 — Mở rộng vừa đủ | Chốt nội dung v1 dựa trên lát cắt; hoàn thiện save/settings/tutorial/accessibility | Không tăng scope tùy hứng, không dùng nội dung mới để che core loop yếu |
| G5 — Release candidate | Regression, hiệu năng trên máy thật, license, Windows export sạch | Build chạy độc lập, không bug chặn, quyền tài nguyên rõ, chủ project duyệt |
| G6 — Chuẩn bị kinh doanh | Demo/store assets thật, định giá/chi phí/chính sách nền tảng, hỗ trợ | Hành động tài khoản/chi phí/upload/phát hành có phê duyệt riêng |

Có thể xuất build thử sớm để test; chỉ không được gọi việc xuất được exe là bằng chứng game đủ chất lượng để bán.

### Biên bản nghiệm thu cho mỗi task

```text
Task ID:
Mục tiêu đã được duyệt:
Trạng thái triển khai:
File/scene/node/signal thay đổi:
Test đã chạy — lệnh, engine, log:
Test chưa chạy — lý do:
Ảnh/video/bản build được kiểm tra:
Phản hồi thật của chủ project:
Quan sát của người chơi ngoài (nếu có):
Bug/giới hạn còn lại:
Có được chuyển cổng không? Ai duyệt?
Commit/handoff:
```

Các trạng thái phải tách riêng: `IMPLEMENTED`, `TECHNICALLY_VERIFIED`, `USER_ACCEPTED`, `RELEASE_APPROVED`. Nếu cần giữ hệ TODO/DONE cũ, lưu các cổng này thành trường riêng. Không tự đổi phát biểu của người dùng thành lời khen toàn diện cho sản phẩm.

## 9. Lưu ý phát hành và kiếm tiền

- Một game hoàn thiện kỹ thuật vẫn có thể không bán được. Cần điểm khác biệt, người chơi mục tiêu, cách giới thiệu và phản hồi thật.
- Screenshot/trailer phải từ build thật; concept art được gắn nhãn concept. Không tạo review/wishlist/người chơi giả.
- Đừng đặt minimum specs chỉ từ một lần chạy F5; đo bản export trên máy thật.
- Kiểm tra điều khoản nền tảng, khai báo nội dung AI nếu áp dụng, asset license, hỗ trợ người chơi và chi phí trước khi trả phí/đăng bán.
- Không tự mở tài khoản, thanh toán, upload source, push public hoặc publish khi chưa có xác nhận riêng.
- Không cam kết hoàn thành trong một số giờ/ngày cố định. Ưu tiên cổng chất lượng; giảm scope nếu nguồn lực không đáp ứng.

---

## 10. PROMPT KHỞI ĐỘNG — copy phần dưới vào Gemini

```text
Đọc toàn bộ GEMINI_REVIEW_AND_IMPROVEMENT_PLAN.md ở root project, rồi đọc source thật liên quan. Đây là phản hồi mới của tôi về mục tiêu sản phẩm; không lấy nhãn M3/M4 hoặc các dòng DONE trước đây làm bằng chứng đã đạt chất lượng để phát hành.

Tôi muốn một game có nhân vật/đồ họa riêng, animation, nhạc nền và SFX có chất lượng, gameplay hấp dẫn và có lý do chơi lại. Tôi chưa chấp nhận việc giữ hình prototype rồi gọi đó là final.

Lượt này chỉ audit và lập kế hoạch sửa R01 (test ghi vào save thật), chưa thêm feature mới:
1. Đọc Main, SaveManager, SettingsManager, smoke_test và verify.ps1. Chỉ ra đường đi từ scene test tới việc ghi user://save_data.json. Kiểm tra git status, không đè thay đổi của tôi.
2. Đề xuất sửa nhỏ để inject manager/đường dẫn test trước _ready, cô lập dữ liệu test và chứng minh save/settings thật không đổi sau test. Không xóa save thật, không đổi engine và không reset toàn project.
3. Đối chiếu R02–R06 với code hiện tại: nêu đồng ý/không đồng ý cùng bằng chứng file/hàm. Chưa refactor hay sửa hàng loạt ở lượt này.
4. Tách việc đã code, đã test, tôi đã duyệt và đủ phát hành. Không bịa log, không tự ghi test chưa chạy = Không hoặc bug còn = Không.
5. Trả danh sách file sẽ thay đổi và acceptance tests cho R01, rồi chờ tôi duyệt để thực thi. Sau R01 được xác minh, chúng ta mới duyệt core loop và art/audio target ở G1.

Hướng Vòng Vây: Lõi Từ trong review là đề xuất, chưa phải lệnh tự động làm tất cả. Không tự mua/tải asset, đổi license sang MIT/CC0, public repo hay phát hành. Không xây lại toàn bộ game. Mỗi lần một task có bằng chứng và handoff rõ.
```

### Prompt sau khi đã duyệt kế hoạch R01

```text
Thực hiện đúng kế hoạch R01 tôi vừa duyệt. Không sửa gameplay/art/audio hoặc các phần ngoài phạm vi. Chạy test chỉ với dữ liệu đã cô lập, ghi lệnh và kết quả thật; nếu chưa chạy được Godot thì ghi BLOCKED, không nói PASS. Kiểm tra save/settings thật không đổi, báo diff và test tay cần tôi thực hiện. Cập nhật handoff và đề xuất commit; không push/publish.
```

**Đích đến không phải một bộ tài liệu đẹp hơn. Đích đến là một bản chơi thật mà chủ project và người chơi có thể quan sát, nghe, hiểu và muốn chơi lại. Tài liệu chỉ có giá trị khi buộc mỗi bước sản xuất tiến gần đích đó.**
