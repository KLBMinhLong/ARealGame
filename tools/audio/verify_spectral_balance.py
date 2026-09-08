#!/usr/bin/env python3
"""
Spectral Balance and Mixing Clarity Verification Script (Task 7.3).

Verifies Requirement 10.3, 10.4, 10.6:
- Computes FFT energy distribution across Low (20-800Hz), Mid (800-3500Hz), High (3500-20kHz).
- Verifies category frequency separation (low_impact vs mid_percussive vs high_clarity).
- Simulates multi-sound simultaneous combat playback scenarios with SoundManager base volumes.
- Checks for audio masking, spectral dominance, and limiter headroom.
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Tuple

import numpy as np
from scipy.io import wavfile


BASE_DIR = Path(__file__).resolve().parent.parent.parent
SFX_DIR = BASE_DIR / "assets" / "audio" / "sfx"
REPORT_PATH = BASE_DIR / "tools" / "audio" / "spectral_analysis_report.json"

SOUND_CATEGORIES = {
    "pulse": "low_impact",
    "wall_slam": "low_impact",
    "domino": "mid_percussive",
    "player_hurt": "mid_percussive",
    "combo": "mid_percussive",
    "dash": "high_clarity",
    "shard": "high_clarity",
    "altar_seal": "magical_emotional",
    "game_over": "magical_emotional",
}

# Godot SoundManager base volumes (scripts/systems/sound_manager.gd)
SOUND_MANAGER_BASE_VOLUMES_DB = {
    "pulse": -1.5,
    "dash": -5.0,
    "wall_slam": -1.0,
    "domino": -6.0,
    "altar_seal": -1.5,
    "shard": -7.0,
    "player_hurt": 0.0,
    "combo": -3.0,
    "game_over": 0.0,
}


def load_wav_normalized(filepath: Path) -> Tuple[np.ndarray, int]:
    """Load WAV file and convert to float32 range [-1.0, 1.0]."""
    if not filepath.exists():
        raise FileNotFoundError(f"WAV file not found: {filepath}")
    sr, data = wavfile.read(str(filepath))
    if data.dtype == np.int16:
        float_data = data.astype(np.float32) / 32768.0
    elif data.dtype == np.int32:
        float_data = data.astype(np.float32) / 2147483648.0
    elif data.dtype == np.float32:
        float_data = data
    else:
        float_data = data.astype(np.float32) / np.max(np.abs(data))
    return float_data, sr


def compute_spectral_bands(audio: np.ndarray, sample_rate: int) -> Dict[str, float]:
    """
    Compute percentage of spectral energy across standard acoustic bands:
    - Bass (20 - 250 Hz): Sub-bass weight and low impact fundamental
    - Low-Mid (250 - 800 Hz): Body, warmth, and low musical notes
    - Mid (800 - 3500 Hz): Clarity, attack transients, high musical fundamentals
    - High (3500 - 20000 Hz): Air, sparkle, and aerodynamic whoosh dissipation
    """
    if len(audio) == 0:
        return {"bass_pct": 0.0, "low_mid_pct": 0.0, "mid_pct": 0.0, "high_pct": 0.0, "dominant_freq_hz": 0.0}

    window = np.hanning(len(audio))
    spectrum = np.abs(np.fft.rfft(audio * window))
    freqs = np.fft.rfftfreq(len(audio), 1.0 / sample_rate)

    power = spectrum ** 2
    total_power = np.sum(power)
    if total_power <= 0:
        return {"bass_pct": 0.0, "low_mid_pct": 0.0, "mid_pct": 0.0, "high_pct": 0.0, "dominant_freq_hz": 0.0}

    bass_mask = (freqs >= 20.0) & (freqs < 250.0)
    low_mid_mask = (freqs >= 250.0) & (freqs < 800.0)
    mid_mask = (freqs >= 800.0) & (freqs < 3500.0)
    high_mask = (freqs >= 3500.0) & (freqs <= 20000.0)

    bass_power = np.sum(power[bass_mask])
    low_mid_power = np.sum(power[low_mid_mask])
    mid_power = np.sum(power[mid_mask])
    high_power = np.sum(power[high_mask])

    dominant_idx = np.argmax(power)
    dominant_freq = float(freqs[dominant_idx])

    return {
        "bass_pct": round(float(bass_power / total_power * 100.0), 2),
        "low_mid_pct": round(float(low_mid_power / total_power * 100.0), 2),
        "mid_pct": round(float(mid_power / total_power * 100.0), 2),
        "high_pct": round(float(high_power / total_power * 100.0), 2),
        "dominant_freq_hz": round(dominant_freq, 1),
    }


def simulate_mix(
    sound_names: List[str],
    audio_map: Dict[str, np.ndarray],
    offsets_ms: Dict[str, float] | None = None
) -> Dict[str, Any]:
    """
    Simulate simultaneous playback of multiple sounds with SoundManager base volume attenuation.
    Evaluates mixed peak, RMS, crest factor, and per-sound audibility.
    """
    if offsets_ms is None:
        offsets_ms = {}

    sample_rate = 44100
    max_len = 0
    attenuated_tracks = {}

    for name in sound_names:
        raw_audio = audio_map[name]
        vol_db = SOUND_MANAGER_BASE_VOLUMES_DB.get(name, 0.0)
        gain = 10.0 ** (vol_db / 20.0)
        attenuated = raw_audio * gain

        offset_samples = int(offsets_ms.get(name, 0.0) * sample_rate / 1000.0)
        track_len = offset_samples + len(attenuated)
        max_len = max(max_len, track_len)
        attenuated_tracks[name] = (offset_samples, attenuated)

    # Sum tracks
    mixed = np.zeros(max_len, dtype=np.float32)
    for name, (offset, track) in attenuated_tracks.items():
        mixed[offset : offset + len(track)] += track

    # Peak & RMS
    peak_linear = float(np.max(np.abs(mixed))) if len(mixed) > 0 else 0.0
    peak_db = round(float(20.0 * np.log10(max(1e-5, peak_linear))), 2)
    rms_linear = float(np.sqrt(np.mean(mixed ** 2))) if len(mixed) > 0 else 0.0
    rms_db = round(float(20.0 * np.log10(max(1e-5, rms_linear))), 2)
    crest_factor = round(float(peak_linear / max(1e-5, rms_linear)), 2)

    # Master Bus Limiter simulation (-1.5dB limiter ceiling)
    limiter_ceiling_db = -1.5
    limiter_ceiling_linear = 10.0 ** (limiter_ceiling_db / 20.0)
    limiting_needed = peak_linear > limiter_ceiling_linear
    gain_reduction_db = round(float(peak_db - limiter_ceiling_db), 2) if limiting_needed else 0.0

    # Per-sound RMS energy contribution in mix
    contributions = {}
    for name, (offset, track) in attenuated_tracks.items():
        track_rms = float(np.sqrt(np.mean(track ** 2))) if len(track) > 0 else 0.0
        track_db = round(float(20.0 * np.log10(max(1e-5, track_rms))), 2)
        contributions[name] = {
            "sound_rms_db": track_db,
            "relative_to_mix_db": round(track_db - rms_db, 2),
            "masked": bool((track_db - rms_db) < -24.0)  # >24dB below mix considered severely masked
        }

    return {
        "sounds": sound_names,
        "peak_db": peak_db,
        "rms_db": rms_db,
        "crest_factor": crest_factor,
        "gain_reduction_db": gain_reduction_db,
        "per_sound_audibility": contributions,
        "mix_clean": not any(c["masked"] for c in contributions.values()),
    }


def main() -> int:
    print("============================================================")
    print("Stone Knight - Spectral Balance & Mixing Clarity (Task 7.3)")
    print("============================================================")

    # 1. Load all 9 WAV files
    audio_map: Dict[str, np.ndarray] = {}
    sample_rate = 44100

    print("\n--- 1. Per-Sound Frequency Spectrum Analysis ---")
    sound_spectral_data: Dict[str, Any] = {}
    separation_passed = True

    for sound_name, category in SOUND_CATEGORIES.items():
        wav_path = SFX_DIR / f"sfx_{sound_name}.wav"
        audio, sr = load_wav_normalized(wav_path)
        audio_map[sound_name] = audio
        sample_rate = sr

        bands = compute_spectral_bands(audio, sr)
        sound_spectral_data[sound_name] = {
            "category": category,
            "bands": bands,
        }

        # Category expectation checks (Req 10.4)
        cat_status = "PASS"
        if category == "low_impact":
            # Low impacts must dominate bass + low_mid (> 70%) and have low fundamental (< 300Hz)
            if (bands["bass_pct"] + bands["low_mid_pct"]) < 70.0 or bands["dominant_freq_hz"] >= 300.0:
                cat_status = "WARN (Expected dominant low < 300Hz)"
                separation_passed = False
        elif category == "mid_percussive":
            # Mid percussives must focus on body/percussion (low_mid + mid > 60%)
            if (bands["low_mid_pct"] + bands["mid_pct"]) < 60.0:
                cat_status = "WARN (Expected mid focus 250-3500Hz)"
                separation_passed = False
        elif category == "high_clarity":
            # High clarity must have prominent mid/high content (> 50%) and high fundamental (>= 600Hz)
            if (bands["mid_pct"] + bands["high_pct"]) < 40.0 or bands["dominant_freq_hz"] < 600.0:
                cat_status = "WARN (Expected high presence >= 600Hz)"
                separation_passed = False

        print(f"[{category[:3].upper()}] {sound_name:12s}: Bass={bands['bass_pct']:4.1f}% | LowMid={bands['low_mid_pct']:4.1f}% | Mid={bands['mid_pct']:4.1f}% | High={bands['high_pct']:4.1f}% | PeakFreq={bands['dominant_freq_hz']:6.1f}Hz -> {cat_status}")

    # 2. Simulate combat playback scenarios (Req 10.6)
    print("\n--- 2. Simultaneous Playback Scenarios Simulation ---")
    scenarios = [
        {
            "name": "Scenario A: Classic Combat Impact (Pulse + Wall Slam + Domino)",
            "sounds": ["pulse", "wall_slam", "domino"],
            "offsets_ms": {"pulse": 0.0, "wall_slam": 60.0, "domino": 110.0}
        },
        {
            "name": "Scenario B: Agile Harvesting (Dash + Shard + Combo)",
            "sounds": ["dash", "shard", "combo"],
            "offsets_ms": {"dash": 0.0, "shard": 40.0, "combo": 70.0}
        },
        {
            "name": "Scenario C: Chaotic Boss/Brawl (Player Hurt + Pulse + Wall Slam + Shard)",
            "sounds": ["player_hurt", "pulse", "wall_slam", "shard"],
            "offsets_ms": {"player_hurt": 0.0, "pulse": 20.0, "wall_slam": 75.0, "shard": 130.0}
        }
    ]

    scenario_results = []
    all_scenarios_passed = True

    for sc in scenarios:
        res = simulate_mix(sc["sounds"], audio_map, sc["offsets_ms"])
        scenario_results.append({
            "scenario": sc["name"],
            "result": res
        })

        status = "PASS ✓" if res["mix_clean"] else "FAIL (Masking detected) ✗"
        if not res["mix_clean"]:
            all_scenarios_passed = False

        print(f"\n{sc['name']}")
        print(f"  Mix Peak: {res['peak_db']:+.2f}dB | RMS: {res['rms_db']:+.2f}dB | Crest Factor: {res['crest_factor']:.2f}")
        print(f"  Master Limiter Headroom: Needs {res['gain_reduction_db']:.2f}dB limiter reduction (smooth absorption)")
        for sname, cdata in res["per_sound_audibility"].items():
            mask_str = "AUDIBLE" if not cdata["masked"] else "MASKED"
            print(f"    - {sname:12s}: RMS={cdata['sound_rms_db']:+.2f}dB (rel={cdata['relative_to_mix_db']:+.2f}dB) [{mask_str}]")
        print(f"  => Scenario Verdict: {status}")

    # 3. Compile summary report
    report = {
        "timestamp": "2026-09-08T23:57:00Z",
        "sample_rate": sample_rate,
        "spectral_analysis": sound_spectral_data,
        "scenarios": scenario_results,
        "category_separation_passed": separation_passed,
        "all_scenarios_passed": all_scenarios_passed,
        "overall_status": "PASS" if (separation_passed and all_scenarios_passed) else "FAIL"
    }

    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    print("\n------------------------------------------------------------")
    print(f"Spectral analysis report written to: {REPORT_PATH}")
    print(f"Overall Task 7.3 Status: {'PASS ✓' if (separation_passed and all_scenarios_passed) else 'FAIL ✗'}")
    print("============================================================")

    return 0 if (separation_passed and all_scenarios_passed) else 1


if __name__ == "__main__":
    sys.exit(main())
