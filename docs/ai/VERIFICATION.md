# Verification — bằng chứng thay cho “đã test”

## Mức kiểm tra không thể thay thế nhau

| Mức | Chứng minh được | Không chứng minh được |
|---|---|---|
| Review code | Một số lỗi logic/ownership rõ trong code | Runtime chắc chắn đúng hoặc cảm giác chơi tốt |
| Version + import | Binary phù hợp; import đã chạy và không phát lỗi đã phát hiện | Tất cả script/path được exercise, feature đúng |
| Focused automated test | Các assertion cụ thể của phần được test | Mọi hành vi hoặc chất lượng hình ảnh/âm thanh |
| Bounded smoke scene | Scene khởi động/chạy trong số vòng lặp đã nêu | Full run, save stability, game feel hoặc FPS mục tiêu |
| Visible/manual playtest | Quan sát thực tế trên tình huống/máy đã thử | Toàn bộ máy người chơi hay doanh thu/retention |
| Exported-build test | Bản đóng gói chạy trong điều kiện đã thử | Mọi hệ điều hành nếu chưa thử |

## Trước khi chạy

- Xác nhận project tin cậy, engine đã được chọn và quyền thực thi của môi trường.
- Import editor có thể chạy tool scripts/editor plugins và tạo cache `.godot`. Không chạy project/addon lạ mà chưa xem xét.
- Runtime có thể ghi save. Smoke scene phải dùng dữ liệu test hoặc được xác minh không đụng save thật. Một Git worktree riêng không mặc nhiên tách `user://`.
- Kiểm tra test framework/lệnh có sẵn. Nếu chưa có, dùng một check nhỏ theo conventions hoặc đề xuất công cụ; không tự cài GUT/GdUnit chỉ để hợp thức hóa câu “có test”.

## Công cụ hỗ trợ trong kit

Yêu cầu Python 3.10+ và một Godot editor binary được cài riêng. Script không tải engine, không cài dependency, không tự chạy test game hay export.

Ví dụ dùng executable trên PATH (chỉ nếu đã xác minh tên lệnh):

```text
python scripts/ai/verify_godot.py --project . --godot godot --expected-version "<toàn bộ chuỗi godot --version thực tế>"
```

Windows cũng nhận đường dẫn executable có khoảng trắng qua `--godot`. Đổi các placeholder trước khi chạy. Có thể chạy lần đầu không truyền `--expected-version` để khảo sát version; báo cáo sẽ ghi version chưa được đối chiếu pin.

Lệnh tương đương mà script thực thi:

```text
<godot> --version
<godot> --headless --path <project> --import
```

`--import` tự chờ import rồi thoát. Đây **không phải parse-all hoặc integration test**. Những runtime path không được load vẫn cần test riêng.

Smoke scene chỉ chạy khi chỉ rõ scene và cho phép runtime:

```text
python scripts/ai/verify_godot.py --project . --godot godot --smoke-scene res://<scene-test-da-xac-minh>.tscn --allow-runtime --iterations 120
```

`--quit-after` tính theo **iterations**, không phải giây. Mặc định mọi subprocess còn có timeout hữu hạn. Scene tồn tại không có nghĩa nó an toàn với save; trách nhiệm xác minh thuộc người chạy.

## Output và cách đọc

Mỗi lần chạy tạo một thư mục mới dưới `.artifacts/ai/` (hoặc `--output-dir`):
- `report.json`: lệnh, version, exit status, duration, result và phạm vi chưa kiểm tra.
- `*.stdout.log`, `*.stderr.log`: output đầy đủ của từng bước.

Script fail khi executable/project không hợp lệ, version đã yêu cầu không khớp, timeout, exit code khác zero hoặc tìm thấy mẫu lỗi engine/script được nhận diện. Warning được ghi lại, không tự coi như lỗi gameplay.

Bộ lọc log không thể nhận diện mọi lỗi. Agent vẫn phải đọc log và chạy các acceptance checks thật. `overall: PASS` trong báo cáo chỉ nói **những command đã được chọn** vượt qua các check của helper; không đặt task thành DONE.

## Kiểm tra bản thân helper

```text
python -m unittest discover -s scripts/ai/tests -v
```

Các test này dùng runner giả lập để kiểm tra logic helper, không cần Godot. Chúng không chứng minh CLI hoạt động với binary/project chưa được cung cấp.

## Evidence tối thiểu cho mỗi check

- Acceptance ID và loại check.
- Build/commit hoặc diff đang kiểm tra; lỗi đã có từ baseline hay mới xuất hiện.
- Lệnh chính xác, working directory, phiên bản, exit code, ngày/giờ và log path.
- Kết quả quan sát hoặc assertion; PASS/FAIL/NOT_RUN/BLOCKED/N/A.
- Giới hạn kiểm tra. Screenshot không chứng minh input latency; headless không chứng minh sound mix.

Không chạy lệnh vô hạn để làm “smoke test”. Không công bố log chứa secrets; giữ bản gốc cục bộ và tạo bản redacted khi được phép chia sẻ.

## Bộ check phổ biến

- Normal path, empty/zero input, cap/max, repeated events, duplicated connections.
- Pause/resume, restart, scene teardown, owner freed.
- Config disabled, reduced effects, different supported resolutions.
- Feature bật/tắt không đổi hành vi ngoài contract.
- Khi sửa lỗi: có reproduction trước và regression check sau.

Export chỉ dùng preset thật trong `export_presets.cfg` và export templates tương ứng. Không đoán preset “Windows Desktop” tồn tại; không dùng export thành công để tuyên bố đã thử trên Windows.
