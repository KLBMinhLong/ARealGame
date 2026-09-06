# Test plan

## Bốn lớp kiểm tra độc lập

1. **Static:** file/link/reference có tồn tại. `tools/verify_structure.py` không parse GDScript.
2. **Import/parse:** Godot đúng bản đọc được project/resources/scripts. Log không lỗi.
3. **Automated runtime:** `tests/smoke_test.gd` chạy logic/scene/signal thật qua engine.
4. **Manual + build:** người thật nhìn/chơi; kiểm tra GPU/UI/audio/focus/save và file export độc lập.

Không lớp nào tự chứng minh game vui hoặc bán được. Bằng chứng cần ghi version, hệ điều hành, commit, lệnh, kết quả và log.

## Lệnh tự động

Chạy `tools/verify.ps1` theo START_HERE, hoặc các lệnh tương đương. Import trước smoke vì Godot cần chuẩn bị resource/class cache. Test chính có kiểm tra input, scene boot, signal start/resume, diagonal, biên, spawn, cap, reset, HP/grace, pause và thắng/thua.

Smoke test trực tiếp gọi một số method để kiểm tra logic; nó không tự bấm phím như người chơi và không chứng minh hitbox nhìn đúng. Bổ sung test manual sau.

## Checklist manual starter

- [ ] F5 mở menu, chữ/nút không tràn ở 1152×648; menu dùng chuột và Tab/Enter được.
- [ ] Start bắt đầu một lượt; nhãn máu/thời gian đúng.
- [ ] WASD và từng phím mũi tên đều đúng hướng. Bấm hai hướng ngược nhau không trôi.
- [ ] Đi chéo không nhanh hơn đi thẳng. Thả phím dừng di chuyển.
- [ ] Thử cả bốn mép và góc: nhân vật không ra khỏi sân.
- [ ] Quái theo người chơi, nhìn khác hình nhân vật; không spawn ngay sát người chơi.
- [ ] Chạm quái giảm một HP. Trong thời gian bảo vệ không mất thêm ngay; hết bảo vệ có thể bị hit tiếp.
- [ ] HP về 0 → thua; gameplay dừng; Retry và R reset timer, HP, quái.
- [ ] Sống đủ 180 giây → thắng, không xử lý như thua. Nếu khó đạt, dùng nhánh QA riêng điều chỉnh duration tạm và hoàn nguyên; vẫn test lượt thật trước release.
- [ ] Esc khi đang chạy → pause; chờ một lúc thấy timer/quái/grace không tiếp tục.
- [ ] Resume không nhảy timer/spawn bất thường; về menu rồi start không lặp signal.
- [ ] Alt-Tab/mất focus → pause; quay lại không tự thua trong nền.
- [ ] Resize 1152×648, 960×540, thử khung không cùng tỉ lệ: không cắt HUD, không click lệch.
- [ ] Chơi/retry nhiều lượt; bộ đếm quái reset, không tăng vô hạn, không lỗi mới trong Output/Debugger.
- [ ] Nút Quit đóng game. Đóng cửa sổ cũng hoạt động.

## Các ca bổ sung khi feature tương ứng tồn tại

### Xung đẩy

- [ ] Chỉ quái trong bán kính bị tác động; ngoài bán kính không bị.
- [ ] Hết hồi chiêu mới dùng lại; giữ phím không phát xung vô hạn.
- [ ] Pause đóng băng cooldown/stun/effect timer; retry reset sạch.
- [ ] Quái bị đẩy không ra ngoài biên hoặc kẹt mãi.

### Save/settings

- [ ] Lần chạy đầu không có save vẫn chạy.
- [ ] Best score và settings còn sau khi đóng/mở.
- [ ] File hỏng, sai kiểu, version cũ có fallback có kiểm soát.
- [ ] Không quyền ghi được báo/giải quyết an toàn, không crash.
- [ ] Volume slider điều khiển đúng audio bus; mute thật sự im.
- [ ] Fullscreen, giảm hiệu ứng và remap (nếu có) áp dụng thực sự, không chỉ đổi UI.

### Performance — chỉ ghi số đo thật

- Mục tiêu ban đầu: cảm giác mượt gần 60 FPS tại 1152×648, không đóng băng dài, không tăng RAM liên tục sau retry. Chưa tuyên bố minimum specs.
- Dùng Debugger/Monitors/Profiler của Godot và Task Manager để quan sát. Ghi tình huống, số quái, FPS/frame time/memory, app đang mở.
- Test bản export release riêng; overhead editor làm số đo khác runtime standalone.
- Nếu không đạt: đo → tìm nút thắt → giảm allocation/draw/đối tượng → đo lại. Không viết object pool/kiến trúc lớn trước khi có bằng chứng.

### Export

- [ ] Chạy từ thư mục mới không có source/.godot/editor.
- [ ] Không thiếu exe/PCK/file runtime bắt buộc; không cần cài Godot để chơi.
- [ ] Test bàn phím, pause, audio, save, fullscreen trên bản xuất.
- [ ] Không đóng gói secret, log, repo, tài liệu nội bộ hoặc asset không dùng.
- [ ] Chạy bằng tài khoản người dùng thường, không cần admin.

## Mẫu ghi kết quả

| Ngày / commit / engine | Môi trường | Ca test | PASS/FAIL/BLOCKED | Bằng chứng / bug |
|---|---|---|---|---|
| Chưa thực hiện | Máy chủ project | M0 manual | BLOCKED | Chờ người dùng chạy |

Không đánh dấu sẵn các checkbox. Báo cáo QA đóng gói ban đầu nằm ở QA_REPORT, không phải kết quả M0 trên laptop của bạn.
