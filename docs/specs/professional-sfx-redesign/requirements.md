# Requirements Document: Professional SFX Redesign

## Introduction

Hệ thống âm thanh hiện tại của Stone Knight (F016_SFX_FEEDBACK) đã có đầy đủ chức năng kỹ thuật (voice priority, polyphony limiting, throttling, independent RNG), nhưng âm thanh thực tế cần được thiết kế lại từ đầu để đạt chất lượng chuyên nghiệp, dễ nghe và phù hợp với thẩm mỹ action fantasy của game. Mục tiêu là tạo ra bộ âm thanh hay hơn, dịu nhẹ hơn nhưng vẫn rõ ràng, giúp người chơi phân biệt được các hành động trong gameplay nhanh.

Feature này tập trung vào **thiết kế âm thanh** (sound design) chứ không phải kiến trúc hệ thống. Hệ thống kỹ thuật (SoundManager, audio bus, priority system) đã hoạt động tốt và sẽ được giữ nguyên. Chúng ta chỉ thay thế 9 file WAV hiện tại bằng phiên bản mới được thiết kế cẩn thận với synthesis techniques, layering, spatial characteristics và audio effects chuyên nghiệp.

## Glossary

- **SFX_System**: Hệ thống quản lý âm thanh hiện có (SoundManager) đã được implement trong F016, bao gồm audio pool, priority system, polyphony limiting và throttling
- **Sound_Designer**: Module hoặc script offline sinh âm thanh chuyên nghiệp từ các thông số thiết kế
- **Audio_Layer**: Một lớp âm thanh riêng biệt được tổng hợp (synthesis) hoặc tạo ra, sau đó được mix với các layer khác để tạo thành âm thanh cuối cùng
- **ADSR_Envelope**: Attack-Decay-Sustain-Release envelope kiểm soát biên độ âm thanh theo thời gian
- **Frequency_Spectrum**: Phổ tần số của âm thanh, xác định độ sáng (brightness), ấm áp (warmth) và character của âm
- **Spatial_Character**: Đặc tính không gian của âm thanh (reverb, echo, stereo width) tạo cảm giác chiều sâu và vị trí
- **Harmonic_Content**: Thành phần harmonics quyết định tính chất âm sắc (timbre) và độ phong phú của âm thanh
- **Transient**: Phần tấn công ban đầu của âm thanh, rất quan trọng cho perception và clarity
- **Tail**: Phần đuôi âm thanh (reverb tail, decay tail), ảnh hưởng đến cảm giác không gian và kết thúc tự nhiên
- **Dynamic_Range**: Khoảng cách giữa phần im nhất và to nhất của âm thanh
- **Spectral_Balance**: Cân bằng năng lượng giữa các dải tần số (bass, mid, treble)

## Requirements

### Requirement 1: Professional Pulse Sound Design

**User Story:** Là người chơi, tôi muốn nghe âm thanh Pulse (xung kích) có cảm giác mạnh mẽ, sóng năng lượng lan tỏa nhưng dịu nhẹ và professional, để cảm nhận sức mạnh của kỹ năng mà không bị harsh hay chói tai.

#### Acceptance Criteria

1. THE Sound_Designer SHALL generate a pulse sound with clear attack transient (0-10ms) followed by a smooth energy wave decay (150-250ms total duration)
2. THE Sound_Designer SHALL layer at least three Audio_Layers: low-frequency sub-bass (60-120Hz) for impact, mid-frequency body (200-800Hz) for presence, and high-frequency shimmer (2-6kHz) for clarity
3. THE Sound_Designer SHALL apply ADSR_Envelope with fast attack (5-8ms), medium decay (40-60ms), low sustain (20-30% amplitude), and smooth release (80-120ms)
4. THE Sound_Designer SHALL apply subtle reverb with short tail (100-150ms) to create spatial depth without muddiness
5. THE generated pulse sound SHALL have Spectral_Balance with dominant energy in 100-800Hz range for warmth, and gentle high-frequency roll-off above 8kHz to avoid harshness
6. THE Sound_Designer SHALL ensure Dynamic_Range compression with gentle ratio (2:1 to 3:1) for consistent perceived loudness without clipping
7. THE generated pulse sound SHALL integrate smoothly when played through SFX_System with existing -2.0dB base volume and ±5% pitch variation

### Requirement 2: Professional Dash Sound Design

**User Story:** Như người chơi, tôi muốn nghe âm thanh Dash (lướt) ngắn gọn, nhanh nhẹn và smooth, thể hiện chuyển động tức thời nhưng không harsh hay lấn át các âm thanh khác.

#### Acceptance Criteria

1. THE Sound_Designer SHALL generate a dash sound with ultra-fast attack transient (3-5ms) and short total duration (80-120ms)
2. THE Sound_Designer SHALL create whoosh character using filtered noise sweep from high to low frequency (starting 4-8kHz, sweeping down to 800-2kHz over 60-80ms)
3. THE Sound_Designer SHALL layer subtle doppler-like pitch shift (starting pitch 1.1x, ending 0.95x) to enhance movement perception
4. THE Sound_Designer SHALL apply stereo width processing with subtle L-R channel differences (5-10ms delay) to create spatial movement impression
5. THE generated dash sound SHALL have clean high-frequency content with smooth roll-off, avoiding harsh sibilance above 10kHz
6. THE Sound_Designer SHALL ensure the dash sound remains clear and distinct when played through SFX_System with existing -4.0dB base volume
7. THE generated dash sound SHALL not mask or interfere with simultaneous pulse or combat sounds due to complementary frequency ranges

### Requirement 3: Professional Wall Slam Sound Design

**User Story:** Là người chơi, tôi muốn nghe âm thanh Wall Slam (đập tường) nặng nề, có substance và impact nhưng vẫn musical và không quá aggressive, để phân biệt rõ với Domino hit.

#### Acceptance Criteria

1. THE Sound_Designer SHALL generate a wall slam sound with powerful low-frequency impact (40-150Hz) as primary Audio_Layer for weight perception
2. THE Sound_Designer SHALL layer impact transient using short noise burst (5-15ms) in mid-frequency range (500-2kHz) for initial attack clarity
3. THE Sound_Designer SHALL add stone/rock texture layer using filtered noise or sample-based material (200-600Hz) for character and realism
4. THE Sound_Designer SHALL apply ADSR_Envelope with instant attack (0-3ms), quick decay (30-50ms), medium sustain (40-50% amplitude for 80-100ms), and natural release (100-150ms)
5. THE Sound_Designer SHALL apply medium reverb with stone room character (reverb time 200-350ms) to enhance impact heaviness without excessive tail
6. THE generated wall slam sound SHALL have Spectral_Balance dominated by low-mid frequencies (60-800Hz contains 70%+ energy) to differentiate from lighter domino sound
7. THE generated wall slam sound SHALL maintain clarity when played through SFX_System with existing -1.0dB base volume and maximum 2 concurrent instances

### Requirement 4: Professional Domino Hit Sound Design

**User Story:** Là người chơi, tôi muốn nghe âm thanh Domino (quái va quái) nhẹ nhàng, súc tích như "clack" hoặc "tap" nhưng pleasant và không irritating khi nhiều va chạm xảy ra liên tiếp.

#### Acceptance Criteria

1. THE Sound_Designer SHALL generate a domino sound with light, percussive character focusing on mid-high frequencies (800-4kHz) to contrast with heavy wall slam
2. THE Sound_Designer SHALL create short duration (40-80ms total) with fast attack (2-4ms) and quick decay to prevent overlap and muddiness
3. THE Sound_Designer SHALL layer subtle wood or ceramic resonance character for pleasant texture without harshness
4. THE Sound_Designer SHALL apply minimal reverb (reverb time 50-80ms) or dry processing to keep sound tight and clear
5. THE generated domino sound SHALL have Spectral_Balance with reduced low-frequency content below 200Hz to avoid conflict with wall slam and pulse sounds
6. THE Sound_Designer SHALL ensure Harmonic_Content is simple and clean, avoiding complex overtones that cause fatigue during repeated playback
7. THE generated domino sound SHALL remain intelligible and non-fatiguing when played through SFX_System with existing -6.0dB base volume and up to 2 concurrent instances

### Requirement 5: Professional Altar Seal Sound Design

**User Story:** Như người chơi, tôi muốn nghe âm thanh Altar Seal (phong ấn hư không) sâu thẳm, ma thuật và resonant, tạo cảm giác void magic ngân vang trong khoảng 0.5 giây với character fantasy magical.

#### Acceptance Criteria

1. THE Sound_Designer SHALL generate an altar seal sound with mystical shimmer character using layered harmonic tones or pad-like synthesis (duration 400-600ms)
2. THE Sound_Designer SHALL create void/ethereal quality using detuned harmonic layers (fundamental around 200-400Hz with overtones at musical intervals: perfect fifth, octave)
3. THE Sound_Designer SHALL apply slow attack (20-40ms) and gradual decay to create smooth, resonant quality without harsh transient
4. THE Sound_Designer SHALL layer subtle high-frequency sparkle or bell-like harmonics (3-7kHz) for magical shimmer impression
5. THE Sound_Designer SHALL apply deep spatial reverb (reverb time 600-900ms, early reflections subtle) to enhance void/cosmic character
6. THE generated altar seal sound SHALL have rich Harmonic_Content with sustained tone quality and smooth Frequency_Spectrum without harsh peaks
7. THE generated altar seal sound SHALL integrate smoothly when played through SFX_System with existing -1.5dB base volume and maximum 2 concurrent instances

### Requirement 6: Professional Shard Pickup Sound Design

**User Story:** Là người chơi, tôi muốn nghe âm thanh Shard Pickup (nhặt pha lê) trong trẻo, pleasant như "crystal ting" vừa phải, tạo satisfaction nhưng không chói tai khi nhặt nhiều shard liên tục.

#### Acceptance Criteria

1. THE Sound_Designer SHALL generate a shard sound with bright, crystalline character using pure harmonic tones or bell-like synthesis (duration 150-250ms)
2. THE Sound_Designer SHALL create clear transient attack (3-6ms) in high-frequency range (2-5kHz) for instant recognition and clarity
3. THE Sound_Designer SHALL apply musical pitch content (recommended root note in range C6-E6 ~1047-1319Hz with clear harmonics) for pleasant, non-random character
4. THE Sound_Designer SHALL ensure smooth exponential decay (decay time 120-180ms) to avoid abrupt cutoff or excessive ringing
5. THE Sound_Designer SHALL apply subtle stereo width and short reverb (50-100ms) for gentle sparkle without accumulating reverb tail during rapid successive pickups
6. THE generated shard sound SHALL have Spectral_Balance with dominant energy in 1-6kHz range, minimal low-frequency content below 400Hz to preserve clarity
7. THE generated shard sound SHALL remain pleasant and non-fatiguing when played through SFX_System with existing -7.0dB base volume and up to 3 concurrent instances during rapid collection

### Requirement 7: Professional Player Hurt Sound Design

**User Story:** Như người chơi, tôi muốn nghe âm thanh Player Hurt (mất máu) sắc nét, warning-like và immediately noticeable, đủ mạnh để cảnh báo nguy hiểm nhưng không harsh hay frightening, tách biệt hoàn toàn với các âm va chạm.

#### Acceptance Criteria

1. THE Sound_Designer SHALL generate a player hurt sound with urgent, alert character using distinctive frequency range (1-3kHz) that cuts through combat noise
2. THE Sound_Designer SHALL create sharp transient attack (1-3ms) for instant attention-grabbing without harshness
3. THE Sound_Designer SHALL apply unique timbral character distinct from all other game sounds, using synthetic tone or processed impact that clearly signals danger
4. THE Sound_Designer SHALL ensure moderate duration (100-180ms) long enough to be noticed but short enough to not overlap with gameplay sounds excessively
5. THE Sound_Designer SHALL avoid overly aggressive or frightening character by using controlled Harmonic_Content and avoiding dissonant frequencies
6. THE generated player hurt sound SHALL have Spectral_Balance focused in upper-mid frequencies (800-3kHz) with clean, intelligible transient
7. THE generated player hurt sound SHALL maintain maximum clarity and priority when played through SFX_System with existing 0.0dB base volume and CRITICAL priority level

### Requirement 8: Professional Combo Chain Sound Design

**User Story:** Là người chơi, tôi muốn nghe âm điệu Combo Chain (chuỗi combo) thăng hoa và vui tai, âm thanh nâng dần (ascending musical pattern) khi combo tăng để tạo excitement và positive reinforcement.

#### Acceptance Criteria

1. THE Sound_Designer SHALL generate a combo sound with melodic, ascending pitch progression that creates sense of achievement and escalation
2. THE Sound_Designer SHALL create musical character using harmonic tones in major scale intervals (recommended intervals: major third, perfect fifth, octave) for positive emotional response
3. THE Sound_Designer SHALL apply fast attack (5-10ms) and controlled decay (100-200ms) for clear articulation without excessive sustain
4. THE Sound_Designer SHALL design ascending frequency pattern where higher combo levels trigger proportionally higher pitch variations (e.g., base pitch + combo_level * semitone_offset)
5. THE Sound_Designer SHALL layer subtle harmonic richness or chime-like quality for pleasant, rewarding character
6. THE generated combo sound SHALL have Spectral_Balance with clear fundamental tone and controlled overtones, avoiding muddy low frequencies below 300Hz
7. THE generated combo sound SHALL integrate smoothly when played through SFX_System with existing -3.0dB base volume and single instance playback (non-overlapping)

### Requirement 9: Professional Game Over Sound Design

**User Story:** Như người chơi, tôi muốn nghe âm thanh Game Over (thua) trầm buồn nhưng elegant, một chuỗi âm điệu kết thúc (musical phrase) khoảng 0.9 giây, tạo closure cho hiệp đấu mà không quá negative hay depressing.

#### Acceptance Criteria

1. THE Sound_Designer SHALL generate a game over sound with melancholic but dignified character using musical phrase or chord progression (duration 800-1000ms)
2. THE Sound_Designer SHALL create descending or resolving melodic pattern that provides emotional closure without excessive sadness (recommended: minor to major resolution, or gentle descending sequence)
3. THE Sound_Designer SHALL apply smooth ADSR_Envelope with gentle attack (15-30ms), sustained body (400-600ms), and long natural release (200-300ms) for graceful ending
4. THE Sound_Designer SHALL use rich Harmonic_Content with warm, full-bodied timbre (focus on 200-1200Hz fundamental with gentle upper harmonics)
5. THE Sound_Designer SHALL apply reverb with long tail (800-1200ms) to create spacious, contemplative atmosphere appropriate for end-of-run moment
6. THE generated game over sound SHALL have Spectral_Balance that is warm and enveloping without harsh high frequencies, promoting acceptance rather than frustration
7. THE generated game over sound SHALL integrate smoothly when played through SFX_System with existing 0.0dB base volume and CRITICAL priority, effectively stopping other combat sounds

### Requirement 10: Unified Sound Design Aesthetic

**User Story:** Là người chơi, tôi muốn tất cả âm thanh trong game có aesthetic cohesion (sự gắn kết thẩm mỹ), cảm giác như chúng thuộc về cùng một thế giới âm thanh chuyên nghiệp và hài hòa.

#### Acceptance Criteria

1. THE Sound_Designer SHALL ensure all generated sounds share consistent production quality with similar Dynamic_Range, spectral clarity, and professional mixing standards
2. THE Sound_Designer SHALL apply unified reverb character across appropriate sounds (short reverb for action sounds, medium for impacts, long for magical/emotional sounds) using consistent virtual space simulation
3. THE Sound_Designer SHALL maintain Spectral_Balance across all sounds so no individual sound has excessive energy in any frequency band that causes masking or fatigue
4. THE Sound_Designer SHALL ensure Frequency_Spectrum separation between sound categories: low-heavy (pulse, wall slam), mid-focused (domino, player hurt), high-focused (dash, shard) for clarity in complex mix
5. THE Sound_Designer SHALL apply consistent synthesis or processing philosophy (e.g., all sounds use similar synthesis methods, filter types, or audio effects chain) for aesthetic coherence
6. THE generated sound set SHALL work harmoniously when multiple sounds play simultaneously through SFX_System without frequency masking, phase cancellation, or perceived loudness imbalance
7. THE Sound_Designer SHALL document the unified design approach including synthesis methods, core frequency ranges, reverb settings, and processing chain for future sound additions or modifications

### Requirement 11: Technical Audio Specification Compliance

**User Story:** Như developer, tôi muốn các file âm thanh mới tuân thủ chính xác technical specifications của hệ thống hiện có để tích hợp seamlessly mà không cần thay đổi SFX_System code.

#### Acceptance Criteria

1. THE Sound_Designer SHALL generate all audio files in WAV format with 16-bit bit depth and 44.1kHz sample rate
2. THE Sound_Designer SHALL generate all audio files as mono (single channel) to match existing SFX_System architecture
3. THE Sound_Designer SHALL ensure all generated audio files have normalized peak amplitude without clipping (peak level between -0.3dB and -1.0dB) for maximum quality with safety headroom
4. THE Sound_Designer SHALL optimize file sizes to maintain small footprint (target 5-50KB per file depending on duration) through appropriate encoding and trimming
5. THE Sound_Designer SHALL ensure all generated audio files have clean start (no leading silence >5ms) and natural decay end (no abrupt cutoff, allow natural tail to fade below -60dB)
6. THE generated audio files SHALL integrate with existing audio asset structure by placing files in `assets/audio/sfx/` directory with naming convention `sfx_[sound_name].wav`
7. THE generated audio files SHALL work correctly when preloaded through SFX_System and played through existing SFX audio bus with Limiter at -1.5dB on Master bus

### Requirement 12: Offline Sound Generation Tooling

**User Story:** Như developer, tôi muốn có offline tool hoặc script để tạo và regenerate các file âm thanh một cách controllable và repeatable, cho phép iteration và refinement dễ dàng.

#### Acceptance Criteria

1. THE Sound_Designer SHALL be implemented as offline Python script or tool (may use libraries like scipy, numpy, pydub, or similar) that generates audio files without requiring runtime Godot execution
2. THE Sound_Designer SHALL accept configuration parameters (frequencies, durations, envelope settings, reverb amounts) through clear interface (config file, command-line arguments, or code constants)
3. THE Sound_Designer SHALL generate all 9 sound files in single execution run with clear console output indicating progress and success/failure for each file
4. THE Sound_Designer SHALL provide preview functionality allowing developer to audition generated sounds (either through system audio playback or by opening generated files)
5. THE Sound_Designer SHALL implement deterministic generation where same input parameters always produce identical output files for version control and reproducibility
6. THE Sound_Designer tool SHALL include clear documentation explaining sound design parameters, synthesis methods, and how to adjust settings to achieve desired aesthetic results
7. WHEN generation is complete, THE Sound_Designer SHALL output summary report showing file paths, file sizes, duration, peak amplitude, and spectral characteristics of each generated sound

