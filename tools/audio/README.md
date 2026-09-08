# Stone Knight - Professional SFX Generation Tool

Bộ công cụ sinh âm thanh chuyên nghiệp offline cho dự án game Stone Knight, sử dụng kỹ thuật pure digital synthesis với NumPy và SciPy, tuân thủ tiêu chuẩn âm thanh Godot 4.6+.

---

## 1. Tổng quan dự án

Công cụ này đảm nhiệm việc thiết kế và sinh offline toàn bộ **9 file âm thanh SFX** chuẩn WAV trong game Stone Knight thay thế các file âm thanh ban đầu. Sử dụng phương pháp thuần tổng hợp số (pure procedural synthesis) thay vì thư viện sample mẫu:
- **Kiểm soát tuyệt đối**: Tự do điều chỉnh từng harmonic, ADSR envelope, filter curve và reverb tail.
- **Tái lập 100% (Deterministic)**: Tách biệt hoàn toàn visual/audio RNG với gameplay RNG, cho phép tái sinh chính xác mọi lúc với cùng config.
- **Tối ưu chuẩn kỹ thuật**: Đảm bảo headroom -0.5 dBFS, không clipping, zero leading silence (< 5ms), natural decay không click transient.

### Thông số kỹ thuật chuẩn (Technical Compliance)
- **Định dạng**: WAV format, 16-bit PCM (Signed Int16 Little-Endian).
- **Tần số lấy mẫu (Sample Rate)**: 44,100 Hz (Chuẩn CD Audio / Game Audio).
- **Kênh (Channels)**: 1 channel (Mono) - tương thích hoàn hảo positional/bus panning trong Godot.
- **Peak Level**: Chuẩn hóa chính xác ở `-0.5 dBFS` (an toàn chống inter-sample peak).
- **Kích thước file**: 6 KB đến 128 KB (tùy thời lượng 45ms – 1.45s).

---

## 2. Cấu trúc thư mục

```
tools/audio/
├── pytest.ini                     # Cấu hình đường dẫn cho pytest
├── requirements.txt               # Danh sách thư viện Python
├── sound_design_config.json       # Bảng tham số thiết kế âm thanh cho 9 SFX
├── sound_design_config.schema.json# JSON Schema kiểm thực tính hợp lệ của config
├── generate_sfx.py                # CLI chính để tổng hợp và xuất file WAV
├── verify_spectral_balance.py     # CLI phân tích FFT phổ tần số và ma trận masking
├── spectral_analysis_report.json  # Báo cáo kết quả phân tích phổ tần số
├── generation_report.json         # Báo cáo kết quả sinh và kiểm tra kỹ thuật
├── README.md                      # Tài liệu này
└── synthesis/                     # Thư viện core procedural synthesis
    ├── __init__.py
    ├── config.py                  # Module nạp & validate schema config
    ├── waveforms.py               # Sine, sweep, FM, karplus-strong, modal, whoosh
    ├── envelopes.py               # ADSR, exponential decay, S-curve, multi-segment
    ├── effects.py                 # Butterworth filters, Schroeder reverb, compressor, delay
    ├── mixing.py                  # Multi-layer mixing, soft limiter, normalization, trimming
    ├── test_waveforms.py          # Unit tests cho waveforms
    ├── test_envelopes.py          # Unit tests cho envelopes
    ├── test_effects.py            # Unit tests cho audio effects
    ├── test_mixing.py             # Unit tests cho mixing & limiter
    ├── test_config.py             # Unit tests cho schema & parameters
    ├── test_generation.py         # Unit tests cho flow sinh âm thanh
    └── test_final_validation.py   # Suite kiểm tra 7 tiêu chí kỹ thuật trên 9 file WAV xuất
```

Thư mục lưu trữ tham chiếu baseline phục vụ regression test:
```
tests/audio_references/            # Bản sao lưu 9 file WAV đã qua thẩm âm và phê duyệt
```

---

## 3. Bảng phân tích kỹ thuật 9 âm thanh SFX

| Tên File | Vai trò / Mood | Thời lượng | Peak Freq | Centroid | Target Headroom | Đặc tả thiết kế âm thanh |
|:---|:---|:---:|:---:|:---:|:---:|:---|
| `sfx_pulse.wav` | Vòng sóng xung năng lượng | 348 ms | 94.7 Hz | 674.3 Hz | -0.5 dBFS | Sub-bass trầm sâu ấm áp (70Hz) kết hợp body năng lượng cộng hưởng và sweep gió nhẹ |
| `sfx_dash.wav` | Hiệp sĩ lướt xé gió | 150 ms | 706.7 Hz | 1,220.8 Hz | -0.5 dBFS | Tiếng vụt xé gió khí động học (Doppler sweep 1000Hz → 250Hz), sắc nét, không gắt |
| `sfx_wall_slam.wav` | Va chạm tường đá nặng | 389 ms | 59.1 Hz | 895.8 Hz | -0.5 dBFS | Thud va chạm cực nặng tần số siêu trầm (50-70Hz) kết hợp tiếng vỡ vụn đá và pink noise |
| `sfx_domino.wav` | Khối đá chạm gõ nhẹ | 70 ms | 1,204.7 Hz | 1,845.5 Hz | -0.5 dBFS | Tiếng gõ chạm đá sắc mảnh (wood/stone tap transient), decay siêu ngắn, không vang đuôi |
| `sfx_altar_seal.wav` | Phong ấn bệ thờ thần bí | 898 ms | 279.6 Hz | 986.3 Hz | -0.5 dBFS | Hợp âm ngân u huyền bí (280Hz - 420Hz - 560Hz) với đuôi reverb không gian hư không rộng lớn |
| `sfx_shard.wav` | Thu thập mảnh ngọc | 193 ms | 1,321.3 Hz | 2,878.9 Hz | -0.5 dBFS | Tiếng chuông ngọc lấp lánh (chime bell), dải cao sáng đẹp, hỗ trợ streak pitch progression |
| `sfx_player_hurt.wav` | Hiệp sĩ nhận sát thương | 140 ms | 1,800.6 Hz | 1,811.5 Hz | -0.5 dBFS | Tiếng va đập giáp rách (crunch + high alert punch), dải trung cao xuyên thấu cảnh báo nguy cấp |
| `sfx_combo.wav` | Chuỗi chuông chiến thắng | 209 ms | 441.1 Hz | 1,747.0 Hz | -0.5 dBFS | Hợp âm arpeggio thăng hoa tươi sáng, hỗ trợ scale pitch theo cấp độ combo (1.0x -> 1.6x) |
| `sfx_game_over.wav` | Giai điệu kết thúc trận | 1,450 ms | 523.3 Hz | 785.4 Hz | -0.5 dBFS | Giai điệu trầm buồn 3 nốt điện ảnh (D4 -> Bb3 -> G3) ngân dài chìm dần vào bóng tối |

---

## 4. Hướng dẫn sử dụng CLI

### 4.1 Cài đặt môi trường

Yêu cầu **Python 3.10+** (đã kiểm định tối ưu trên Python 3.12.10):
```bash
pip install -r tools/audio/requirements.txt
```

### 4.2 Sinh âm thanh SFX (`generate_sfx.py`)

Chạy từ thư mục gốc dự án hoặc thư mục `tools/audio/`:

- **Sinh toàn bộ 9 âm thanh vào thư mục game:**
  ```bash
  python tools/audio/generate_sfx.py --all --output-dir assets/audio/sfx --validate --verbose
  ```

- **Chỉ sinh một âm thanh cụ thể để tinh chỉnh:**
  ```bash
  python tools/audio/generate_sfx.py --sound pulse --output-dir assets/audio/sfx --validate
  ```

- **Sử dụng cấu hình thiết kế tùy biến:**
  ```bash
  python tools/audio/generate_sfx.py --all --config tools/audio/sound_design_config.json
  ```

### 4.3 Phân tích cân bằng phổ tần số (`verify_spectral_balance.py`)

Kiểm tra FFT phổ tần số, peak frequency, spectral centroid, RMS energy và ma trận độ tách bạch (anti-masking matrix) khi phát đồng thời:
```bash
python tools/audio/verify_spectral_balance.py --dir assets/audio/sfx --report tools/audio/spectral_analysis_report.json
```

Kết quả sẽ xác nhận:
- Tần số cực đại của từng âm thanh tách biệt hoàn toàn (59 Hz đến 1,800 Hz).
- Tỷ lệ nghe rõ tương đối (Relative Audibility) khi phát đồng thời đều vượt ngưỡng an toàn (> -8 dB), đảm bảo không âm thanh nào bị triệt tiêu/át tiếng.

### 4.4 Chạy bộ kiểm thử tự động Pytest

Toàn bộ **194 unit tests** bao phủ synthesis, envelopes, effects, mixing, config schema và final asset validation:
```bash
python -m pytest tools/audio -q
```
*(Đã cấu hình `pytest.ini` tự động thêm đường dẫn pythonpath).*

### 4.5 Chạy kiểm thử tích hợp Godot SoundManager

Sử dụng công cụ xác minh Godot headless để kiểm tra trực tiếp trên Godot Engine (v4.6.3):
```bash
python scripts/ai/verify_godot.py --godot "D:\InstallProgram\Gotdot\Godot_v4.6.3-stable_win64_console.exe" --smoke-scene res://scenes/tests/test_sound_manager.tscn --allow-runtime
```
Kiểm tra 9 nhóm chức năng (46 assertions) bao gồm:
- Load và kiểm tra độ dài 9 asset WAV.
- Gọi các hàm API công khai `SoundManager.play_*()`.
- Giới hạn Polyphony (Pulse cap 1, Wall slam cap 2, Shard cap 3).
- Hệ thống ưu tiên giọng (Voice Priority & Preemption: Critical preempts Low).
- Dừng toàn bộ combat sound khi phát `game_over`.
- Shard streak pitch progression (0 -> 1 -> 2).
- Combo pitch scale (1.0x -> 1.16x -> 1.6x max).
- Tính cô lập của Audio RNG với Gameplay RNG.
- Kịch bản phát đồng thời 3 và 4 âm thanh cùng lúc.

---

## 5. Quy trình tinh chỉnh âm thanh (Sound Iteration Workflow)

Khi cần điều chỉnh cảm giác hoặc âm hưởng của một hiệu ứng:
1. Mở file `tools/audio/sound_design_config.json`.
2. Định vị block âm thanh cần sửa (ví dụ `"pulse"` hoặc `"dash"`).
3. Tinh chỉnh các thông số trực quan:
   - `duration_ms`: Độ dài tổng thể.
   - `layers`: Điều chỉnh âm lượng (`level`), dải tần số (`frequency_range`), hoặc pitch sweep.
   - `adsr`: Điều chỉnh thời gian bùng phát (`attack_ms`), độ xả (`release_ms`).
   - `reverb`: Tăng/giảm không gian phòng và độ ướt (`wet_level`).
4. Chạy lệnh sinh:
   ```bash
   python tools/audio/generate_sfx.py --sound <sound_name> --output-dir assets/audio/sfx
   ```
5. Mở Godot Engine hoặc chạy test scene để nghe và kiểm tra trực tiếp.

---

## 6. Provenance Record (Hồ sơ xuất xứ & Phiên bản)

- **Ngày phê duyệt hoàn thiện**: 2026-09-08 / 2026-09-09
- **Công cụ sinh âm thanh**: Procedural SFX Synthesis Tool v1.0.0
- **Môi trường Engine**: Godot Engine v4.6.3.stable.official.7d41c59c4 (Windows 64-bit)
- **Môi trường Python**: Python 3.12.10 (AMD64) trên Windows 11
- **Thư viện cốt lõi**: NumPy 2.2.3, SciPy 1.15.2, Pytest 8.3.4
- **Thư mục Reference Baseline**: `tests/audio_references/` (Lưu giữ nguyên mẫu 9 file WAV đã nghiệm thu phục vụ hồi quy)
