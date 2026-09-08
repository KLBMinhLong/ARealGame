"""
Unit tests for SFX Generation Orchestration Script and CLI (Task 5.1 & 5.2).

Tests validate:
- Float32 to int16 conversion and WAV export
- WAV validation logic (sample rate, bit depth, channels, peak headroom)
- Per-sound synthesis execution
- Deterministic reproduction (Req 12.5)
- Summary report JSON generation (Req 12.7)
"""

import json
import os
import shutil
import tempfile
import numpy as np
import pytest
from scipy.io import wavfile

import sys
_AUDIO_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if _AUDIO_DIR not in sys.path:
    sys.path.insert(0, _AUDIO_DIR)

from generate_sfx import (
    float32_to_int16,
    int16_to_float32,
    export_wav,
    validate_wav_file,
    synthesize_sound,
    generate_all_sounds,
    get_deterministic_seed
)
from synthesis.config import load_config


CONFIG_PATH = os.path.join(_AUDIO_DIR, "sound_design_config.json")


class TestConversionAndWAVExport:
    """Tests for Task 5.2: Float32 to int16 conversion and WAV exporting."""

    def test_float32_to_int16_range(self):
        """Verify float32 values [-1.0, 1.0] are mapped to int16 range."""
        test_in = np.array([-1.0, -0.5, 0.0, 0.5, 1.0], dtype=np.float32)
        out = float32_to_int16(test_in)
        assert out.dtype == np.int16
        assert out[0] == -32767 or out[0] == -32768
        assert out[2] == 0
        assert out[4] == 32767

    def test_float32_to_int16_clipping(self):
        """Verify values outside [-1.0, 1.0] are safely clamped without overflow."""
        test_in = np.array([-2.5, 3.0], dtype=np.float32)
        out = float32_to_int16(test_in)
        assert out[0] == -32767
        assert out[1] == 32767

    def test_export_and_validate_wav(self):
        """Verify exporting creates compliant 16-bit 44.1kHz mono WAV."""
        temp_dir = tempfile.mkdtemp()
        try:
            filepath = os.path.join(temp_dir, "test_tone.wav")
            sr = 44100
            duration = 0.1
            t = np.arange(int(duration * sr)) / sr
            # Tone at -0.5dB peak
            target_amp = 10.0 ** (-0.5 / 20.0)
            tone = (np.sin(2 * np.pi * 440 * t) * target_amp).astype(np.float32)

            export_wav(tone, filepath, sample_rate=sr)

            assert os.path.exists(filepath)
            report = validate_wav_file(filepath)
            assert report["validation_passed"] is True
            assert report["sample_rate"] == 44100
            assert report["bit_depth"] == 16
            assert report["channels"] == 1
            assert -1.0 <= report["peak_db"] <= -0.3
        finally:
            shutil.rmtree(temp_dir, ignore_errors=True)


class TestWAVValidationEdgeCases:
    """Tests for validate_wav_file error detection."""

    def test_missing_file_raises_error(self):
        with pytest.raises(FileNotFoundError):
            validate_wav_file("non_existent_file.wav")

    def test_invalid_sample_rate_fails_validation(self):
        temp_dir = tempfile.mkdtemp()
        try:
            filepath = os.path.join(temp_dir, "wrong_sr.wav")
            data = np.zeros(2000, dtype=np.int16)
            wavfile.write(filepath, 22050, data)  # Wrong sample rate
            report = validate_wav_file(filepath)
            assert report["validation_passed"] is False
            assert report["checks"]["sample_rate_44100"] is False
        finally:
            shutil.rmtree(temp_dir, ignore_errors=True)


class TestSynthesisPipeline:
    """Tests for Task 5.1: Per-sound synthesis generation."""

    def test_synthesize_pulse_sound(self):
        """Verify pulse synthesis produces valid normalized audio."""
        config = load_config(CONFIG_PATH)
        pulse_cfg = config["sounds"]["pulse"]
        g_cfg = config["global"]

        audio = synthesize_sound("pulse", pulse_cfg, g_cfg)
        assert audio.dtype == np.float32
        assert len(audio) > 0
        peak = np.max(np.abs(audio))
        peak_db = 20 * np.log10(peak)
        assert -1.05 <= peak_db <= -0.25

    def test_deterministic_synthesis(self):
        """Verify requirement 12.5: same sound produces bitwise identical output."""
        config = load_config(CONFIG_PATH)
        dash_cfg = config["sounds"]["dash"]
        g_cfg = config["global"]

        run1 = synthesize_sound("dash", dash_cfg, g_cfg)
        run2 = synthesize_sound("dash", dash_cfg, g_cfg)
        assert np.array_equal(run1, run2), "Synthesis must be deterministic across runs"


class TestFullGenerationLoop:
    """Tests for generation loop and summary reporting (Task 5.1 & 5.2)."""

    def test_generate_filtered_subset(self):
        temp_dir = tempfile.mkdtemp()
        report_file = os.path.join(temp_dir, "test_report.json")
        try:
            success, report = generate_all_sounds(
                config_path=CONFIG_PATH,
                output_dir=temp_dir,
                sound_filter=["pulse", "dash"],
                validate=True,
                report_path=report_file
            )

            assert success is True
            assert report["total_sounds"] == 2
            assert report["all_validations_passed"] is True
            assert os.path.exists(os.path.join(temp_dir, "sfx_pulse.wav"))
            assert os.path.exists(os.path.join(temp_dir, "sfx_dash.wav"))
            assert os.path.exists(report_file)

            # Verify report file JSON contents
            with open(report_file, "r") as f:
                saved_report = json.load(f)
            assert saved_report["total_sounds"] == 2
            assert len(saved_report["sounds"]) == 2
            assert saved_report["sounds"][0]["name"] == "pulse"
            assert saved_report["sounds"][0]["sample_rate"] == 44100
            assert saved_report["sounds"][0]["bit_depth"] == 16
        finally:
            shutil.rmtree(temp_dir, ignore_errors=True)
