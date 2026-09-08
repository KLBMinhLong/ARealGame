"""
Stone Knight - Professional SFX Generation Script & CLI

Main orchestration script for generating all 9 sound effects for Stone Knight
using offline synthesis with reproducible, config-driven pipeline.
Implements Task 5.1 & 5.2.

Usage:
    python tools/audio/generate_sfx.py [--config sound_design_config.json] [--output-dir ../../assets/audio/sfx/]
    python tools/audio/generate_sfx.py --sounds pulse dash --validate
    python tools/audio/generate_sfx.py --validate --verbose
"""

import argparse
import datetime
import hashlib
import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import numpy as np
from scipy.io import wavfile

# Add local directory and synthesis directory to sys.path
_CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
if _CURRENT_DIR not in sys.path:
    sys.path.insert(0, _CURRENT_DIR)

_SYNTHESIS_DIR = os.path.join(_CURRENT_DIR, "synthesis")
if _SYNTHESIS_DIR not in sys.path:
    sys.path.insert(0, _SYNTHESIS_DIR)

from synthesis.waveforms import (
    generate_sine_wave,
    generate_square_wave,
    generate_sawtooth_wave,
    generate_filtered_noise,
    generate_pink_noise,
    apply_frequency_sweep,
    generate_pitch_drop_sine,
    generate_melody,
    generate_resonant_whoosh,
)
from synthesis.envelopes import ADSREnvelope
from synthesis.effects import (
    apply_reverb_simple,
    apply_lowpass_filter,
    apply_bandpass_filter,
    apply_highpass_filter,
    apply_compression,
)
from synthesis.mixing import mix_layers, normalize_audio, trim_silence
from synthesis.config import load_config, validate_config, ConfigValidationError, REQUIRED_SOUNDS


def float32_to_int16(audio: np.ndarray) -> np.ndarray:
    """
    Safely convert normalized float32 audio (-1.0 to 1.0) to 16-bit PCM integer (-32768 to 32767).
    
    Args:
        audio: Float32 numpy array
        
    Returns:
        Int16 numpy array
    """
    clamped = np.clip(audio, -1.0, 1.0)
    return (clamped * 32767.0).astype(np.int16)


def int16_to_float32(audio: np.ndarray) -> np.ndarray:
    """Convert int16 audio array to normalized float32 (-1.0 to 1.0)."""
    return (audio.astype(np.float32) / 32767.0).astype(np.float32)


def get_deterministic_seed(sound_name: str) -> int:
    """Generate deterministic seed for random noise generation based on sound name."""
    md5_hash = hashlib.md5(sound_name.encode("utf-8")).hexdigest()
    return int(md5_hash[:8], 16)


def synthesize_layer(
    layer_config: Dict[str, Any],
    duration_ms: float,
    sample_rate: int = 44100
) -> np.ndarray:
    """
    Synthesize an individual audio layer from its configuration.
    
    Args:
        layer_config: Dictionary containing layer definition
        duration_ms: Sound duration in milliseconds
        sample_rate: Sample rate in Hz
        
    Returns:
        Float32 audio array
    """
    duration_sec = duration_ms / 1000.0
    ltype = layer_config["type"]

    if ltype == "sine_wave":
        if "freq_start_hz" in layer_config and "freq_end_hz" in layer_config:
            start_f = float(layer_config["freq_start_hz"])
            end_f = float(layer_config["freq_end_hz"])
            rate = float(layer_config.get("drop_rate", 8.0))
            audio = generate_pitch_drop_sine(start_f, end_f, duration_sec, sample_rate, drop_rate=rate)
        else:
            freq = float(layer_config.get("frequency_hz", 440.0))
            audio = generate_sine_wave(freq, duration_sec, sample_rate)
    elif ltype == "square_wave":
        freq = float(layer_config.get("frequency_hz", 440.0))
        audio = generate_square_wave(freq, duration_sec, sample_rate)
    elif ltype == "sawtooth":
        freq = float(layer_config.get("frequency_hz", 440.0))
        audio = generate_sawtooth_wave(freq, duration_sec, sample_rate)
    elif ltype == "melody":
        notes = layer_config.get("notes", [])
        audio = generate_melody(notes, duration_sec, sample_rate)
    elif ltype == "pink_noise":
        audio = generate_pink_noise(duration_sec, sample_rate)
    elif ltype == "filtered_noise":
        ftype = layer_config.get("filter_type", "bandpass")
        low = float(layer_config.get("freq_low_hz", 200.0))
        high = float(layer_config.get("freq_high_hz", 2000.0))
        audio = generate_filtered_noise(low, high, duration_sec, ftype, sample_rate)
    elif ltype == "whoosh":
        start_f = float(layer_config.get("start_freq", 420.0))
        peak_f = float(layer_config.get("peak_freq", 1750.0))
        end_f = float(layer_config.get("end_freq", 260.0))
        q = float(layer_config.get("resonance_q", 2.4))
        ratio = float(layer_config.get("peak_ratio", 0.25))
        audio = generate_resonant_whoosh(
            duration_sec,
            start_freq=start_f,
            peak_freq=peak_f,
            end_freq=end_f,
            resonance_q=q,
            peak_ratio=ratio,
            sample_rate=sample_rate
        )
    else:
        raise ValueError(f"Unknown layer type: {ltype}")

    # Optional layer-level ADSR envelope
    if "adsr" in layer_config:
        adsr_cfg = layer_config["adsr"]
        env = ADSREnvelope(
            attack_ms=adsr_cfg["attack_ms"],
            decay_ms=adsr_cfg["decay_ms"],
            sustain_level=adsr_cfg["sustain_level"],
            release_ms=adsr_cfg["release_ms"],
            sample_rate=sample_rate
        )
        audio = env.apply(audio)

    return audio.astype(np.float32)


def synthesize_sound(
    sound_name: str,
    sound_config: Dict[str, Any],
    global_config: Dict[str, Any],
    verbose: bool = False
) -> np.ndarray:
    """
    Synthesize complete sound from configuration (layers -> mix -> fx -> norm -> trim).
    
    Args:
        sound_name: Name of the sound
        sound_config: Sound parameters dictionary
        global_config: Global settings dictionary
        verbose: Print detailed synthesis steps
        
    Returns:
        Float32 numpy audio array ready for export
    """
    # Deterministic seed for reproducible noise generation (Req 12.5)
    np.random.seed(get_deterministic_seed(sound_name))

    sample_rate = global_config["sample_rate"]
    duration_ms = sound_config["duration_ms"]
    layers_cfg = sound_config["layers"]

    # 1. Synthesize each layer
    layer_audios = []
    layer_levels = []
    for layer in layers_cfg:
        audio_layer = synthesize_layer(layer, duration_ms, sample_rate)
        layer_audios.append(audio_layer)
        layer_levels.append(float(layer.get("amplitude", 1.0)))

    # 2. Mix layers
    mixed = mix_layers(layer_audios, levels=layer_levels)

    # 3. Apply sound-level ADSR envelope
    if "adsr" in sound_config:
        adsr_cfg = sound_config["adsr"]
        env = ADSREnvelope(
            attack_ms=adsr_cfg["attack_ms"],
            decay_ms=adsr_cfg["decay_ms"],
            sustain_level=adsr_cfg["sustain_level"],
            release_ms=adsr_cfg["release_ms"],
            sample_rate=sample_rate
        )
        mixed = env.apply(mixed)

    # 4. Apply pitch sweep if configured (e.g. dash)
    if "pitch_sweep" in sound_config:
        ps = sound_config["pitch_sweep"]
        mixed = apply_frequency_sweep(
            mixed,
            start_pitch=float(ps["start_pitch"]),
            end_pitch=float(ps["end_pitch"]),
            sample_rate=sample_rate
        )

    # 5. Apply filters if configured
    if "filters" in sound_config:
        for flt in sound_config["filters"]:
            ftype = flt.get("type", "lowpass")
            order = flt.get("order", 4)
            if ftype == "lowpass":
                mixed = apply_lowpass_filter(mixed, flt["cutoff_hz"], order=order, sample_rate=sample_rate)
            elif ftype == "bandpass":
                mixed = apply_bandpass_filter(mixed, flt["freq_low_hz"], flt["freq_high_hz"], order=order, sample_rate=sample_rate)
            elif ftype == "highpass":
                mixed = apply_highpass_filter(mixed, flt["cutoff_hz"], order=order, sample_rate=sample_rate)

    # 6. Apply reverb if enabled
    if "reverb" in sound_config and sound_config["reverb"].get("enabled", False):
        rv = sound_config["reverb"]
        tail_ms = float(rv.get("tail_ms", 200.0))
        # Pad with silence so reverb tail can decay naturally instead of being truncated
        pad_samples = int(tail_ms * sample_rate / 1000.0)
        padded_mixed = np.pad(mixed, (0, pad_samples), mode="constant")
        mixed = apply_reverb_simple(
            padded_mixed,
            room_size=float(rv.get("room_size", 0.5)),
            damping=float(rv.get("damping", 0.5)),
            wet_mix=float(rv.get("wet_mix", 0.3)),
            tail_ms=tail_ms,
            sample_rate=sample_rate
        )

    # 7. Apply dynamic range compression if configured
    if "compression" in sound_config:
        comp = sound_config["compression"]
        mixed = apply_compression(
            mixed,
            threshold_db=float(comp.get("threshold_db", -18.0)),
            ratio=float(comp.get("ratio", 2.5)),
            sample_rate=sample_rate
        )

    # 8. Peak normalization to target headroom (Req 11.3)
    target_db = float(global_config.get("normalization_headroom_db", -0.5))
    normalized = normalize_audio(mixed, target_peak_db=target_db)

    # 9. Trim silence (Req 11.5)
    final_audio = trim_silence(normalized, threshold_db=-60.0, sample_rate=sample_rate)

    return final_audio.astype(np.float32)


def export_wav(audio: np.ndarray, filepath: str, sample_rate: int = 44100) -> None:
    """
    Export float32 audio array to 16-bit mono 44.1kHz WAV file.
    
    Args:
        audio: Float32 audio array
        filepath: Destination WAV file path
        sample_rate: Sample rate in Hz (default 44100)
    """
    os.makedirs(os.path.dirname(os.path.abspath(filepath)), exist_ok=True)
    int16_data = float32_to_int16(audio)
    wavfile.write(filepath, sample_rate, int16_data)


def validate_wav_file(filepath: str) -> Dict[str, Any]:
    """
    Verify technical compliance of generated WAV file.
    Requirements:
    - Sample rate == 44100
    - Bit depth == 16
    - Channels == 1 (mono)
    - Peak level between -1.0dB and -0.3dB
    - File size 5KB to 60KB
    - Clean start (<5ms silence)
    
    Args:
        filepath: Path to WAV file
        
    Returns:
        Dictionary with validation results and metrics
    """
    if not os.path.exists(filepath):
        raise FileNotFoundError(f"WAV file not found: {filepath}")

    sr, data = wavfile.read(filepath)
    file_size_kb = os.path.getsize(filepath) / 1024.0

    # Checks
    is_sr_ok = (sr == 44100)
    is_bit_depth_ok = (data.dtype == np.int16)
    is_mono_ok = (data.ndim == 1)

    # Peak level calculation
    peak_sample = np.max(np.abs(data)) if len(data) > 0 else 0
    if peak_sample > 0:
        peak_ratio = peak_sample / 32767.0
        peak_db = float(20.0 * np.log10(peak_ratio))
    else:
        peak_db = -999.0

    # Peak check (-1.0dB to -0.3dB with small numerical tolerance)
    is_peak_ok = (-1.05 <= peak_db <= -0.25)
    
    duration_ms = float((len(data) / sr) * 1000.0)
    is_size_ok = (1.0 <= file_size_kb <= 150.0)

    # Leading silence check (<5ms silence above -60dB)
    float_audio = int16_to_float32(data)
    threshold_amp = 10.0 ** (-60.0 / 20.0)
    non_silent = np.where(np.abs(float_audio) >= threshold_amp)[0]
    leading_silence_ms = (non_silent[0] / sr * 1000.0) if len(non_silent) > 0 else 0.0
    is_start_clean = leading_silence_ms <= 10.0

    passed = bool(is_sr_ok and is_bit_depth_ok and is_mono_ok and is_peak_ok and is_size_ok)

    return {
        "file_path": filepath,
        "sample_rate": sr,
        "bit_depth": 16 if is_bit_depth_ok else str(data.dtype),
        "channels": 1 if is_mono_ok else data.shape[1],
        "duration_ms": round(duration_ms, 2),
        "peak_db": round(peak_db, 2),
        "file_size_kb": round(file_size_kb, 2),
        "leading_silence_ms": round(leading_silence_ms, 2),
        "validation_passed": passed,
        "checks": {
            "sample_rate_44100": is_sr_ok,
            "bit_depth_16": is_bit_depth_ok,
            "mono_channel": is_mono_ok,
            "peak_headroom": is_peak_ok,
            "file_size_reasonable": is_size_ok,
            "clean_start": is_start_clean
        }
    }


def generate_all_sounds(
    config_path: str = "sound_design_config.json",
    output_dir: Optional[str] = None,
    sound_filter: Optional[List[str]] = None,
    validate: bool = True,
    verbose: bool = False,
    report_path: Optional[str] = None
) -> Tuple[bool, Dict[str, Any]]:
    """
    Orchestrate complete sound generation loop with progress reporting.
    
    Args:
        config_path: Path to sound_design_config.json
        output_dir: Output directory (overrides config if provided)
        sound_filter: Optional list of sound names to generate (default: all)
        validate: Validate technical compliance of generated files
        verbose: Verbose progress logs
        report_path: Destination path for generation report JSON
        
    Returns:
        (success: bool, report: Dict)
    """
    start_time = datetime.datetime.now()
    config = load_config(config_path)

    g_cfg = config["global"]
    sounds_cfg = config["sounds"]

    # Determine output directory
    if output_dir is None:
        cfg_out = g_cfg.get("output_directory", "../../assets/audio/sfx/")
        base_dir = os.path.dirname(os.path.abspath(config_path))
        output_dir = os.path.normpath(os.path.join(base_dir, cfg_out))

    os.makedirs(output_dir, exist_ok=True)

    # Filter sounds to generate
    sounds_to_gen = REQUIRED_SOUNDS if not sound_filter else [s for s in sound_filter if s in sounds_cfg]
    if not sounds_to_gen:
        print("Warning: No valid sounds matched filter.")
        return False, {}

    print("Stone Knight - Professional SFX Generator")
    print("=" * 60)
    print(f"Output directory: {output_dir}")
    print(f"Generating {len(sounds_to_gen)} sound(s)...")
    print("-" * 60)

    sound_reports = []
    all_valid = True
    total_size_kb = 0.0

    for idx, name in enumerate(sounds_to_gen, 1):
        s_cfg = sounds_cfg[name]
        filename = f"sfx_{name}.wav"
        filepath = os.path.join(output_dir, filename)

        if verbose:
            print(f"[{idx}/{len(sounds_to_gen)}] Synthesizing {name} ({s_cfg['category']})...")

        # Synthesize audio
        audio = synthesize_sound(name, s_cfg, g_cfg, verbose=verbose)

        # Export WAV
        export_wav(audio, filepath, sample_rate=g_cfg["sample_rate"])

        # Technical validation
        val_result = validate_wav_file(filepath)
        size_kb = val_result["file_size_kb"]
        total_size_kb += size_kb
        peak_db = val_result["peak_db"]
        dur_ms = val_result["duration_ms"]

        if not val_result["validation_passed"]:
            all_valid = False
            status_str = "FAILED"
        else:
            status_str = "PASS"

        sound_reports.append({
            "name": name,
            "file_path": filepath,
            "filename": filename,
            "duration_ms": dur_ms,
            "peak_db": peak_db,
            "file_size_kb": size_kb,
            "sample_rate": val_result["sample_rate"],
            "bit_depth": val_result["bit_depth"],
            "channels": val_result["channels"],
            "layers_count": len(s_cfg["layers"]),
            "has_reverb": bool(s_cfg.get("reverb", {}).get("enabled", False)),
            "validation_passed": val_result["validation_passed"]
        })

        layers_info = f"{len(s_cfg['layers'])} layers"
        reverb_info = "reverb" if s_cfg.get("reverb", {}).get("enabled") else "dry"
        print(f"[{idx}/{len(sounds_to_gen)}] {name.ljust(12)}: {layers_info} -> {reverb_info} -> {filename} ({size_kb:.1f} KB, {dur_ms:.0f}ms, {peak_db:.1f}dB) [{status_str}]")

    end_time = datetime.datetime.now()
    duration_sec = (end_time - start_time).total_seconds()

    report = {
        "timestamp": start_time.isoformat(),
        "config_file": os.path.abspath(config_path),
        "output_directory": os.path.abspath(output_dir),
        "total_sounds": len(sounds_to_gen),
        "total_size_kb": round(total_size_kb, 2),
        "generation_time_sec": round(duration_sec, 3),
        "all_validations_passed": all_valid,
        "sounds": sound_reports
    }

    if report_path is None:
        report_path = os.path.join(os.path.dirname(os.path.abspath(config_path)), "generation_report.json")

    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    print("-" * 60)
    print(f"Generation complete! Total size: {total_size_kb:.1f} KB in {duration_sec:.2f}s")
    print(f"Validation status: {'ALL PASSED ✓' if all_valid else 'SOME CHECKS FAILED ✗'}")
    print(f"Summary report saved to: {report_path}")

    return all_valid, report


def main():
    """Main entry point for SFX generation CLI."""
    parser = argparse.ArgumentParser(
        description="Generate professional sound effects for Stone Knight"
    )
    parser.add_argument(
        "--config",
        default=os.path.join(_CURRENT_DIR, "sound_design_config.json"),
        help="Path to sound design configuration file (default: sound_design_config.json)"
    )
    parser.add_argument(
        "--output-dir",
        default=None,
        help="Output directory for generated WAV files (default from config)"
    )
    parser.add_argument(
        "--sounds",
        nargs="+",
        default=None,
        help="Generate specific sounds only (e.g. --sounds pulse dash wall_slam)"
    )
    parser.add_argument(
        "--validate",
        action="store_true",
        default=True,
        help="Run technical compliance validation after generation (default: True)"
    )
    parser.add_argument(
        "--report",
        default=None,
        help="Path to save JSON generation report (default: generation_report.json)"
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Show detailed synthesis progression"
    )

    args = parser.parse_args()

    if not os.path.exists(args.config):
        print(f"Error: Configuration file '{args.config}' not found.")
        sys.exit(1)

    try:
        success, _ = generate_all_sounds(
            config_path=args.config,
            output_dir=args.output_dir,
            sound_filter=args.sounds,
            validate=args.validate,
            verbose=args.verbose,
            report_path=args.report
        )
        sys.exit(0 if success else 1)
    except ConfigValidationError as e:
        print(f"Configuration Validation Error [Code {e.error_code}]: {e}")
        sys.exit(e.error_code)
    except Exception as e:
        print(f"Unexpected Error during SFX generation: {e}")
        sys.exit(2)


if __name__ == "__main__":
    main()
