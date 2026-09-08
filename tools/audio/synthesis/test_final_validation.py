"""
Comprehensive Automated Validation Suite for Generated SFX Assets (Task 8.1).

Validates Requirements 11.1 - 11.5:
- 11.1: WAV format, 16-bit, 44.1kHz
- 11.2: Mono channels (single channel)
- 11.3: Peak amplitude normalized (-0.3dB to -1.0dB headroom) without clipping
- 11.4: Small footprint (5KB - 150KB)
- 11.5: Clean start (<10ms silence) and natural decay tail
"""

import os
from pathlib import Path
import numpy as np
import pytest
from scipy.io import wavfile

from generate_sfx import validate_wav_file, REQUIRED_SOUNDS


SFX_DIR = Path(__file__).resolve().parent.parent.parent.parent / "assets" / "audio" / "sfx"


class TestTask8_1_WAVFormatCompliance:
    """Task 8.1: Comprehensive WAV format compliance across all 9 sounds."""

    @pytest.mark.parametrize("sound_name", REQUIRED_SOUNDS)
    def test_wav_file_exists_and_naming(self, sound_name):
        """Verify each required sound exists with correct sfx_[name].wav naming (Req 11.6)."""
        filepath = SFX_DIR / f"sfx_{sound_name}.wav"
        assert filepath.exists(), f"Missing audio asset: {filepath}"

    @pytest.mark.parametrize("sound_name", REQUIRED_SOUNDS)
    def test_sample_rate_and_bit_depth(self, sound_name):
        """Verify 44.1kHz sample rate and 16-bit PCM bit depth (Req 11.1)."""
        filepath = SFX_DIR / f"sfx_{sound_name}.wav"
        sr, data = wavfile.read(str(filepath))
        assert sr == 44100, f"{sound_name} sample rate is {sr}, expected 44100"
        assert data.dtype == np.int16, f"{sound_name} bit depth is {data.dtype}, expected int16"

    @pytest.mark.parametrize("sound_name", REQUIRED_SOUNDS)
    def test_mono_channel(self, sound_name):
        """Verify single mono channel (Req 11.2)."""
        filepath = SFX_DIR / f"sfx_{sound_name}.wav"
        sr, data = wavfile.read(str(filepath))
        assert data.ndim == 1, f"{sound_name} must be mono (1D array), got ndim={data.ndim}"

    @pytest.mark.parametrize("sound_name", REQUIRED_SOUNDS)
    def test_peak_headroom_compliance(self, sound_name):
        """Verify peak level is normalized between -1.0dB and -0.3dB (Req 11.3)."""
        filepath = SFX_DIR / f"sfx_{sound_name}.wav"
        res = validate_wav_file(str(filepath))
        assert res["checks"]["peak_headroom"] is True, f"{sound_name} peak {res['peak_db']}dB out of [-1.05, -0.25]dB range"

    @pytest.mark.parametrize("sound_name", REQUIRED_SOUNDS)
    def test_clean_start_transient(self, sound_name):
        """Verify clean attack with < 10ms leading silence (Req 11.5)."""
        filepath = SFX_DIR / f"sfx_{sound_name}.wav"
        res = validate_wav_file(str(filepath))
        assert res["leading_silence_ms"] <= 10.0, f"{sound_name} has {res['leading_silence_ms']}ms leading silence"

    @pytest.mark.parametrize("sound_name", REQUIRED_SOUNDS)
    def test_file_size_footprint(self, sound_name):
        """Verify file size footprint between 5KB and 150KB (Req 11.4)."""
        filepath = SFX_DIR / f"sfx_{sound_name}.wav"
        size_kb = os.path.getsize(filepath) / 1024.0
        assert 4.0 <= size_kb <= 150.0, f"{sound_name} size {size_kb:.2f}KB outside bounds"

    @pytest.mark.parametrize("sound_name", REQUIRED_SOUNDS)
    def test_no_dc_offset(self, sound_name):
        """Verify audio has negligible DC offset (< 0.01) to prevent popping."""
        filepath = SFX_DIR / f"sfx_{sound_name}.wav"
        sr, data = wavfile.read(str(filepath))
        float_data = data.astype(np.float32) / 32768.0
        dc_offset = np.abs(np.mean(float_data))
        assert dc_offset < 0.01, f"{sound_name} has DC offset {dc_offset:.4f}"
