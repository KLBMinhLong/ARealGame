"""generate_sfx.py — Stone Knight SFX Offline Synthesizer
Generates 9 tuned, high-quality, balanced 16-bit 44.1kHz mono WAV files into assets/audio/sfx/.
Standard library only (math, struct, wave, os, random).
"""

import math
import os
import random
import struct
import wave

SAMPLE_RATE = 44100
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "audio", "sfx")


def clamp(val: float, low: float = -1.0, high: float = 1.0) -> float:
    return max(low, min(high, val))


def write_wav(filename: str, samples: list[float], peak_db: float = 0.0) -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    filepath = os.path.join(OUT_DIR, filename)

    # Normalize samples to target peak dB
    max_amp = max(abs(s) for s in samples) if samples else 1.0
    if max_amp < 1e-6:
        max_amp = 1.0
    target_scale = (10.0 ** (peak_db / 20.0)) / max_amp

    with wave.open(filepath, "w") as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit PCM
        wav_file.setframerate(SAMPLE_RATE)

        raw_bytes = bytearray()
        for s in samples:
            val = clamp(s * target_scale)
            int_val = int(val * 32767.0)
            raw_bytes.extend(struct.pack("<h", int_val))

        wav_file.writeframes(raw_bytes)

    size_kb = os.path.getsize(filepath) / 1024.0
    print(f"Generated {filename}: {len(samples)} samples ({len(samples)/SAMPLE_RATE:.2f}s), {size_kb:.1f} KB, peak {peak_db} dB")


# ─── 1. SFX PULSE (~0.30s) ──────────────────────────────────
# Warm, deep bass energy bloom: subtle accumulation swell then deep, smooth bass release
def gen_pulse() -> None:
    duration = 0.30
    total_samples = int(duration * SAMPLE_RATE)
    samples = []

    phase = 0.0
    brown_noise = 0.0

    for i in range(total_samples):
        t = i / SAMPLE_RATE

        # Accumulation swell (0 to 0.06s), then deep bass release (0.06 to 0.30s)
        if t < 0.06:
            # Swell pitch: 65 Hz -> 95 Hz
            freq = 65.0 + 30.0 * (t / 0.06)
            env = math.sin((t / 0.06) * (math.pi * 0.5)) * 0.75
        else:
            rel_t = t - 0.06
            # Deep release pitch: drops from 95 Hz down to 42 Hz smoothly
            freq = 42.0 + 53.0 * math.exp(-12.0 * rel_t)
            env = math.exp(-9.0 * rel_t)

        phase += 2.0 * math.pi * freq / SAMPLE_RATE

        # Pure warm sine + subtle sub-octave & 2nd harmonic (warmth, no harshness)
        tone = 0.80 * math.sin(phase) + 0.15 * math.sin(phase * 0.5) + 0.05 * math.sin(phase * 2.0)

        # Very soft low-passed air puff (brownian-style filtered noise, cutoff ~180Hz)
        white = (random.random() * 2.0 - 1.0)
        brown_noise += (white - brown_noise) * 0.035
        noise_env = env * 0.16

        sample = (tone * 0.88 + brown_noise * noise_env) * env
        samples.append(sample)

    write_wav("sfx_pulse.wav", samples, peak_db=-1.5)


# ─── 2. SFX DASH (~0.12s) ───────────────────────────────────
# Gentle, soft wind puff / breeze. Pure soft air displacement, no harsh tones.
def gen_dash() -> None:
    duration = 0.12
    total_samples = int(duration * SAMPLE_RATE)
    samples = []

    lp_state = 0.0
    hp_state = 0.0

    for i in range(total_samples):
        t = i / SAMPLE_RATE

        white = (random.random() * 2.0 - 1.0)
        # Low-pass filter around ~600 Hz
        lp_state += (white - lp_state) * 0.08
        # High-pass filter around ~160 Hz
        hp_state += (lp_state - hp_state) * 0.02
        wind = lp_state - hp_state

        # Smooth bell-shaped envelope: gentle attack, soft breeze decay
        attack = math.sin(min(1.0, t / 0.03) * math.pi * 0.5)
        decay = math.exp(-22.0 * max(0.0, t - 0.02))
        env = attack * decay

        samples.append(wind * env)

    write_wav("sfx_dash.wav", samples, peak_db=-5.0)


# ─── 3. SFX WALL SLAM (~0.22s) ──────────────────────────────
# Heavy stone impact: deep thump + gritty crunch. Distinct from domino.
def gen_wall_slam() -> None:
    duration = 0.22
    total_samples = int(duration * SAMPLE_RATE)
    samples = []

    phase_low = 0.0
    phase_crunch = 0.0
    noise_state = 0.0

    for i in range(total_samples):
        t = i / SAMPLE_RATE

        # Deep sub punch (130 Hz -> 42 Hz)
        freq_low = 42.0 + 88.0 * math.exp(-25.0 * t)
        phase_low += 2.0 * math.pi * freq_low / SAMPLE_RATE
        sub = math.sin(phase_low) * math.exp(-12.0 * t)

        # Mid crunch transient (380 Hz crackle)
        freq_crunch = 160.0 + 220.0 * math.exp(-40.0 * t)
        phase_crunch += 2.0 * math.pi * freq_crunch / SAMPLE_RATE
        crunch = math.sin(phase_crunch) * math.exp(-28.0 * t)

        # Stone grit noise burst
        white = (random.random() * 2.0 - 1.0)
        noise_state += (white - noise_state) * 0.3
        noise_burst = noise_state * math.exp(-35.0 * t)

        attack = min(1.0, t / 0.004)
        sample = attack * (sub * 0.65 + crunch * 0.25 + noise_burst * 0.30)
        samples.append(sample)

    write_wav("sfx_wall_slam.wav", samples, peak_db=-1.0)


# ─── 4. SFX DOMINO (~0.07s) ─────────────────────────────────
# Light resonant clack / tap: distinct and softer than stone wall slam.
def gen_domino() -> None:
    duration = 0.07
    total_samples = int(duration * SAMPLE_RATE)
    samples = []

    phase = 0.0

    for i in range(total_samples):
        t = i / SAMPLE_RATE
        freq = 240.0 + 220.0 * math.exp(-45.0 * t)
        phase += 2.0 * math.pi * freq / SAMPLE_RATE

        # Pure hollow tone + slight click
        tone = math.sin(phase) + 0.2 * math.sin(phase * 3.0)
        attack = min(1.0, t / 0.003)
        decay = math.exp(-42.0 * t)

        samples.append(attack * decay * tone)

    write_wav("sfx_domino.wav", samples, peak_db=-6.0)


# ─── 5. SFX ALTAR SEAL (~0.50s) ─────────────────────────────
# Mystical void shimmer & resonance: ethereal, sacred harmonic chord.
def gen_altar_seal() -> None:
    duration = 0.50
    total_samples = int(duration * SAMPLE_RATE)
    samples = []

    phase1 = 0.0  # F#3 (185 Hz)
    phase2 = 0.0  # C#4 (277 Hz)
    phase3 = 0.0  # F#4 (370 Hz)
    phase_detune = 0.0  # 187 Hz (shimmer beat)

    for i in range(total_samples):
        t = i / SAMPLE_RATE
        phase1 += 2.0 * math.pi * 185.0 / SAMPLE_RATE
        phase2 += 2.0 * math.pi * 277.18 / SAMPLE_RATE
        phase3 += 2.0 * math.pi * 369.99 / SAMPLE_RATE
        phase_detune += 2.0 * math.pi * 187.5 / SAMPLE_RATE

        # Harmonics chord with subtle tremolo
        tremolo = 1.0 + 0.20 * math.sin(2.0 * math.pi * 7.5 * t)
        tone = (
            0.45 * math.sin(phase1)
            + 0.25 * math.sin(phase_detune)
            + 0.20 * math.sin(phase2)
            + 0.15 * math.sin(phase3)
        ) * tremolo

        # Swell attack and resonant decay
        attack = min(1.0, t / 0.035)
        decay = math.exp(-5.5 * t)

        samples.append(attack * decay * tone)

    write_wav("sfx_altar_seal.wav", samples, peak_db=-1.5)


# ─── 6. SFX SHARD PICKUP (~0.12s) ───────────────────────────
# Warm crystalline ping: rewarding, gentle, not harsh or ear-piercing.
def gen_shard() -> None:
    duration = 0.12
    total_samples = int(duration * SAMPLE_RATE)
    samples = []

    phase1 = 0.0  # B5 (987.77 Hz)
    phase2 = 0.0  # F#6 (1479.98 Hz)

    for i in range(total_samples):
        t = i / SAMPLE_RATE
        phase1 += 2.0 * math.pi * 987.77 / SAMPLE_RATE
        phase2 += 2.0 * math.pi * 1479.98 / SAMPLE_RATE

        # Warm harmonic bell
        bell = 0.70 * math.sin(phase1) + 0.30 * math.sin(phase2)

        attack = min(1.0, t / 0.005)
        decay = math.exp(-22.0 * t)

        samples.append(attack * decay * bell)

    write_wav("sfx_shard.wav", samples, peak_db=-7.0)


# ─── 7. SFX PLAYER HURT (~0.24s) ────────────────────────────
# Sharp warning alert: dissonant buzz (minor 2nd 220Hz + 233Hz),
# immediately recognizable and cuts through combat without sounding like wall slam.
def gen_player_hurt() -> None:
    duration = 0.24
    total_samples = int(duration * SAMPLE_RATE)
    samples = []

    phase1 = 0.0  # 220 Hz
    phase2 = 0.0  # 233 Hz (dissonant semitone)

    for i in range(total_samples):
        t = i / SAMPLE_RATE
        phase1 += 2.0 * math.pi * 220.0 / SAMPLE_RATE
        phase2 += 2.0 * math.pi * 233.08 / SAMPLE_RATE

        # Dissonant buzz with double stutter pulse
        pulse = 1.0 if (t < 0.07 or (0.10 < t < 0.22)) else 0.2
        # Soft-clipped square/saw wave
        buzz1 = math.copysign(1.0, math.sin(phase1)) * 0.5
        buzz2 = math.sin(phase2) * 0.5
        wave_sum = (buzz1 + buzz2) * pulse

        attack = min(1.0, t / 0.006)
        decay = math.exp(-8.0 * t)

        samples.append(attack * decay * wave_sum)

    write_wav("sfx_player_hurt.wav", samples, peak_db=0.0)


# ─── 8. SFX COMBO (~0.20s) ──────────────────────────────────
# Upbeat musical triad chime: C5 -> E5 -> G5
def gen_combo() -> None:
    duration = 0.20
    total_samples = int(duration * SAMPLE_RATE)
    samples = []

    phase = 0.0

    for i in range(total_samples):
        t = i / SAMPLE_RATE

        # Arpeggio steps: C5 (523.25), E5 (659.25), G5 (783.99)
        if t < 0.06:
            freq = 523.25
            local_t = t
        elif t < 0.12:
            freq = 659.25
            local_t = t - 0.06
        else:
            freq = 783.99
            local_t = t - 0.12

        phase += 2.0 * math.pi * freq / SAMPLE_RATE
        tone = math.sin(phase) + 0.15 * math.sin(phase * 2.0)

        attack = min(1.0, local_t / 0.006)
        decay = math.exp(-12.0 * local_t) if t < 0.12 else math.exp(-8.0 * local_t)

        samples.append(attack * decay * tone)

    write_wav("sfx_combo.wav", samples, peak_db=-3.0)


# ─── 9. SFX GAME OVER (~1.30s) ──────────────────────────────
# Rhythmic 3-phrase defeat motif: High cadence -> Mid cadence -> Low cadence
# Exact same melody repeated in 3 octave tiers (A -> F -> D)
def gen_game_over() -> None:
    duration = 1.35
    total_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * total_samples

    # 3 sequential tiers: High (t=0.0s), Mid (t=0.36s), Low (t=0.72s)
    # Melody: Note 1 (8th note) -> Note 2 (8th note) -> Note 3 (quarter note/sustained)
    tiers = [
        # 1. High tier (A4 -> F4 -> D4)
        {
            "start_t": 0.00,
            "vol": 0.65,
            "notes": [
                (440.00, 0.00, 0.11),   # A4
                (349.23, 0.11, 0.22),   # F4
                (293.66, 0.22, 0.35),   # D4
            ],
        },
        # 2. Mid tier (A3 -> F3 -> D3)
        {
            "start_t": 0.36,
            "vol": 0.85,
            "notes": [
                (220.00, 0.00, 0.11),   # A3
                (174.61, 0.11, 0.22),   # F3
                (146.83, 0.22, 0.35),   # D3
            ],
        },
        # 3. Low tier (A2 -> F2 -> D2 with deep ring-out)
        {
            "start_t": 0.72,
            "vol": 1.00,
            "notes": [
                (110.00, 0.00, 0.14),   # A2
                (87.31,  0.14, 0.28),   # F2
                (73.42,  0.28, 0.62),   # D2 (long tail)
            ],
        },
    ]

    for tier in tiers:
        t_base = tier["start_t"]
        t_vol = tier["vol"]
        for freq, n_start, n_end in tier["notes"]:
            abs_start = t_base + n_start
            abs_end = t_base + n_end
            note_dur = abs_end - abs_start

            start_idx = int(abs_start * SAMPLE_RATE)
            end_idx = min(total_samples, int(abs_end * SAMPLE_RATE))

            phase = 0.0
            phase_sub = 0.0
            for i in range(start_idx, end_idx):
                local_t = (i - start_idx) / SAMPLE_RATE
                phase += 2.0 * math.pi * freq / SAMPLE_RATE
                phase_sub += 2.0 * math.pi * (freq * 0.5) / SAMPLE_RATE

                # Warm mellow Rhodes/organ timbre: fundamental + subtle 2nd & 3rd harmonic
                tone = (
                    0.72 * math.sin(phase)
                    + 0.18 * math.sin(phase * 2.0)
                    + 0.06 * math.sin(phase * 3.0)
                    + 0.12 * math.sin(phase_sub)
                )

                attack = min(1.0, local_t / 0.012)
                # Tail note decays slower
                decay_rate = 3.5 if n_end > 0.5 else 6.5
                decay = math.exp(-decay_rate * (local_t / note_dur))

                samples[i] += tone * attack * decay * t_vol

    write_wav("sfx_game_over.wav", samples, peak_db=0.0)


def main() -> None:
    print("Synthesizing Stone Knight SFX...")
    gen_pulse()
    gen_dash()
    gen_wall_slam()
    gen_domino()
    gen_altar_seal()
    gen_shard()
    gen_player_hurt()
    gen_combo()
    gen_game_over()
    print("All 9 SFX successfully generated in assets/audio/sfx/")


if __name__ == "__main__":
    main()
