# F001 — Screen Shake / Camera Trauma

**Status:** DRAFT · **Owner:** chủ dự án · **Implementation:** chưa thực hiện trong bộ kit.
**Prerequisite:** F000 khảo sát repo và xác nhận movement/Pulse/va chạm có thể kích hoạt để test. Nếu game chưa có vòng chơi tối thiểu, hoãn polish hoặc duyệt một harness visual riêng; không tự xây combat trong F001.

## 1. Kết quả mong muốn

Pulse, wall slam và chain tạo phản hồi camera có kiểm soát; người chơi đọc được tình huống, cảm nhận va chạm mà không bị rung liên tục. Bật/tắt shake không làm thay đổi kết quả gameplay.

## 2. Scope

**Có:** trauma accumulator/decay, offset visual, adapter nhận event hiện có, chống event spam, reset lifecycle, config enable/strength, focused tests và cách test bằng mắt.

**Không:** hit-stop mới, camera rotation/zoom, thay follow camera, combat/damage/force/cooldown, spawn/chain logic, VFX/audio mới, full Settings UI, physics rewrite, engine upgrade, addon hoặc autoload mới.

File nào có thể sửa phải được scout liệt kê từ repo thật. Tên `game_config.gd` và Camera2D là định hướng từ mô tả, chưa phải proof rằng path/controller/signal đã tồn tại.

## 3. Discovery checklist — bắt buộc trước READY

- [ ] Active Camera2D ở scene nào? Ai ghi position/offset? Camera có follow, limits, smoothing không?
- [ ] Tên và payload thật của Pulse / wall slam / chain event? Event phát theo impact, từng quái hay từng frame?
- [ ] Có chain ID hoặc lifecycle start/end/reset nào để dedupe theo từng chain?
- [ ] Config keys hiện có, đơn vị, default; key nào thiếu và đề xuất tối thiểu?
- [ ] Pause/hit-stop/restart/focus-loss hiện được xử lý thế nào?
- [ ] HUD hiện đã ở hệ tọa độ độc lập chưa? Render resolution và pixel snapping thực tế?
- [ ] Gameplay RNG là gì? Visual sẽ dùng nguồn riêng bằng cách nào?
- [ ] Test conventions, baseline command/output và lỗi có sẵn?

Nếu thiếu một event, không bịa tên hoặc tạo cả hệ thống gameplay. Nêu lựa chọn: tích hợp phần có thật + để check còn lại BLOCKED, hoặc xin duyệt adapter/event hook tối thiểu. Không tuyên bố feature đầy đủ khi một event chưa được kiểm tra.

## 4. Hợp đồng hành vi đề xuất

Chuyển thành contract hiện hành khi owner duyệt feature này. Nếu repo đã có quy ước khác, nêu khác biệt trước khi sửa.

### R01 — Ownership và giới hạn

- Một controller duy nhất áp dụng shake. Offset kết quả = offset nền của camera owner + shake offset.
- Không cộng offset mới lên offset đã chứa shake của frame trước; không tạo drift.
- Không thay player/world position, collision, input hoặc camera follow để mô phỏng rung.
- Không rotation trong F001; HUD không bị rung.

### R02 — Trauma và amplitude

- Trauma trong [0, 1]. Mức request là trauma bổ sung, không phải pixel.
- `amplitude = trauma² × max_offset_logical_px × shake_strength` theo từng trục.
- Mỗi frame thu các request, lấy giá trị lớn nhất trong frame, rồi cộng một lần vào trauma và clamp. Không cộng riêng từng quái va tường.
- Giảm trauma theo thời gian với đơn vị mỗi giây; không trừ một lượng cố định mỗi frame.
- Thứ tự add/evaluate/decay phải thống nhất giữa implementation và test; giải thích ngắn trong code nếu dễ hiểu nhầm.

### R03 — Event mapping

Giữ các mức khởi điểm trong yêu cầu: Pulse 0.20; wall slam 0.15. Đây không phải bảo đảm cảm giác đã được cân bằng.

Đề xuất mapping chain để làm rõ “x3+”: mốc 3 → 0.30; 5 → 0.40; 10 → 0.50. Nếu count nhảy qua nhiều mốc trong một event, dùng mức mạnh nhất vừa vượt. Mỗi mốc chỉ kích hoạt một lần trong cùng chain; cùng count cập nhật nhiều lần không được rung thêm. Reset tracking theo chain mới hoặc lifecycle thật.

Không đổi thuật toán đếm chain. Nếu không xác định được boundary/identity của chain, đó là câu hỏi tích hợp cần giải quyết, không đoán bằng một timer tùy ý.

### R04 — Noise và RNG

- Ưu tiên noise liên tục theo thời gian. Mọi component offset phải nằm trong giới hạn đã định.
- Dùng noise/RNG riêng cho visual; không consume hoặc reseed nguồn gameplay RNG.
- Không có request thì trauma giảm về zero; ở zero trả về offset nền và không tích lũy offset.

### R05 — Thời gian và lifecycle

- Đề xuất: shake dùng thời gian thực cho decay khi có hit-stop; pause/menu/restart/scene exit chủ động clear trauma, pending requests và restore offset nền.
- Không đổi `Engine.time_scale` hoặc pause cả cây để triển khai shake.
- Khi resume không phát lại các request cũ. Node teardown không để subscription/dangling reference.
- Focus loss theo pause policy hiện có, không tự tạo policy pause mới.
- Nếu lựa chọn timing khác phù hợp hơn với repo, ghi decision và kiểm tra hành vi cụ thể trước khi áp dụng.

### R06 — Config và accessibility

- Đọc config thật. Cần tách request amounts, max offset theo logical pixel, decay/sec, noise speed và strength/enabled.
- Strength zero hoặc disabled phải dừng rung, xóa pending state phù hợp và khôi phục offset nền ngay.
- Không xây Settings UI. Tái dùng reduced-effects setting nếu nó tồn tại và có contract phù hợp.
- Thông số visual còn thiếu có thể chọn giá trị bảo thủ, ghi là PROPOSED và kiểm tra bằng mắt; không giả vờ đã tồn tại trong repo hoặc đã được playtest.
- Kiểm tra finite/range cho input intensity/config ở phần tính toán liên quan. Không tạo một hệ thống validation chung ngoài scope.

## 5. Lát cắt triển khai

1. **F001.1:** trauma/decay/aggregation + offset ownership; focused checks hoặc harness cô lập. Chưa nối tất cả gameplay.
2. **F001.2:** adapter event thật + chain dedupe + RNG isolation. Chạy negative/repeated-event checks.
3. **F001.3:** pause/restart/disabled, visible test và handoff. Tuning chỉ các thông số visual, không sửa gameplay cho “có cảm giác mạnh”.

Một writer. Sau mỗi lát cắt kiểm tra phần vừa thay đổi; không commit/push nếu chưa có quyền.

## 6. Acceptance matrix — tất cả đang NOT_RUN

| ID | Check | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|
| AC01 | Contract/scope | Diff + review | Không thay combat/input/timers/spawn hoặc camera follow ngoài hợp đồng |
| AC02 | Clamp/aggregation | Focused test | Nhiều request cùng frame dùng max; trauma luôn [0,1]; invalid input xử lý theo policy |
| AC03 | Decay/time | Focused test với tổng thời gian và event timestamps tương đương | Kết quả không phụ thuộc cách chia frame ngoài sai số timestep đã nêu |
| AC04 | Chain dedupe | Cùng chain phát 2,3,3,4,5,5,10; rồi chain mới | Mỗi mốc chỉ phát một lần; chain mới không bị trạng thái cũ chặn |
| AC05 | Offset/no drift | Test với baseline offset khác zero + kiểm tra runtime | Hết rung trả đúng baseline; follow đang hoạt động không bị ghi đè |
| AC06 | Disable/reset | Đang rung → disable/pause/restart/scene exit | Không offset tồn dư, request cũ hoặc double connection |
| AC07 | Gameplay independence | Kiểm tra RNG ownership và regression phù hợp repo | Bật/tắt shake không đổi các kết quả gameplay được theo dõi với cùng input/seed |
| AC08 | Real event wiring | Runtime kích hoạt từng event thật | Pulse/slam/chain đều tác động như contract; không chỉ mock tự phát |
| AC09 | HUD/readability | Người thật quan sát ở scale/resolution đang hỗ trợ | HUD đứng yên, nhân vật/hazard đọc được, không rung tối đa kéo dài |
| AC10 | Camera edges/hit-stop | Runtime ở rìa sân và trong state transitions | Không lộ vùng không mong muốn hoặc bị kẹt offset; timing đúng policy |
| AC11 | Build/log | Version/import + checks liên quan + visible run | Không có lỗi mới liên quan; log được xem, giới hạn được ghi rõ |
| AC12 | Owner feel gate | Owner so sánh bật/tắt ở cùng tình huống | Chấp nhận độ nặng/rõ/thoải mái; có ghi nhận, không do AI tự chấm |

Test helper của kit không tự kiểm tra AC02–AC10 hoặc AC12. Agent cần tạo/chạy check phù hợp repo và giữ evidence thật.

## 7. Manual playtest ngắn cho owner

1. Bật shake, kích hoạt Pulse đơn rồi wall slam đơn; nhận biết phản hồi và vị trí nhân vật.
2. Tạo nhiều va chạm + chain; xem có rung liên tục che mất tình huống không.
3. Đang rung thì pause, resume và restart; camera/HUD có trở lại đúng không?
4. Tắt shake bằng cơ chế được cung cấp; chơi cùng tình huống, xác nhận chỉ visual thay đổi.
5. Thử ở rìa sân và scale/window mode đang hỗ trợ. Ghi “quá yếu / vừa / quá mạnh”, tình huống và clip nếu thuận tiện.

Trạng thái sau code thường là AWAITING_PLAYTEST. Chỉ DONE khi các check áp dụng đạt và owner đã xác nhận gate manual.
