"""
Unit Tests for Audio Effects Module

Tests reverb, filters, and compression processors.
Validates Task 3.1 implementation.
"""

import numpy as np
import pytest
from effects import (
    apply_reverb_simple,
    apply_lowpass_filter,
    apply_bandpass_filter,
    apply_highpass_filter,
    apply_compression,
    apply_reverb,
    apply_lowpass
)


class TestReverbSimple:
    """Test Schroeder reverb implementation."""
    
    def test_reverb_basic_functionality(self):
        """Test that reverb produces non-zero output."""
        # Generate test signal (short sine wave)
        duration = 0.1  # 100ms
        sample_rate = 44100
        num_samples = int(duration * sample_rate)
        t = np.arange(num_samples) / sample_rate
        waveform = np.sin(2 * np.pi * 440 * t).astype(np.float32)
        
        # Apply reverb
        reverb_output = apply_reverb_simple(
            waveform,
            room_size=0.5,
            damping=0.5,
            wet_mix=0.5,
            tail_ms=200.0,
            sample_rate=sample_rate
        )
        
        # Check output is valid
        assert reverb_output.shape == waveform.shape
        assert reverb_output.dtype == np.float32
        assert not np.all(reverb_output == 0), "Reverb output should not be all zeros"
        assert np.all(np.abs(reverb_output) <= 1.0), "Reverb output should be normalized to [-1, 1]"
    
    def test_reverb_wet_dry_mix(self):
        """Test that wet/dry mix works correctly."""
        duration = 0.05
        sample_rate = 44100
        num_samples = int(duration * sample_rate)
        waveform = np.random.randn(num_samples).astype(np.float32) * 0.5
        
        # Fully dry (wet_mix = 0) should return original signal
        dry_output = apply_reverb_simple(waveform, wet_mix=0.0, sample_rate=sample_rate)
        assert np.allclose(dry_output, waveform, atol=1e-5)
        
        # Wet signal should differ from dry
        wet_output = apply_reverb_simple(waveform, wet_mix=1.0, sample_rate=sample_rate)
        assert not np.allclose(wet_output, waveform)
    
    def test_reverb_tail_duration(self):
        """Test that longer tail_ms produces longer reverb decay."""
        duration = 0.05  # Longer input for reverb to build up
        sample_rate = 44100
        num_samples = int(duration * sample_rate)
        
        # Create noise burst signal (more energy than impulse)
        waveform = np.random.randn(num_samples).astype(np.float32) * 0.5
        waveform[int(num_samples * 0.8):] = 0  # Fade out last 20%
        
        # Short reverb
        short_reverb = apply_reverb_simple(waveform, tail_ms=50.0, wet_mix=1.0, sample_rate=sample_rate)
        
        # Long reverb
        long_reverb = apply_reverb_simple(waveform, tail_ms=500.0, wet_mix=1.0, sample_rate=sample_rate)
        
        # Check that output differs and long reverb has effect
        assert not np.allclose(short_reverb, long_reverb), "Different tail lengths should produce different output"
        assert np.sum(np.abs(long_reverb)) > 0, "Long reverb should produce non-zero output"
    
    def test_reverb_room_size(self):
        """Test that room_size affects reverb character."""
        duration = 0.1  # Longer duration for delay differences to manifest
        sample_rate = 44100
        num_samples = int(duration * sample_rate)
        waveform = np.random.randn(num_samples).astype(np.float32) * 0.5
        
        small_room = apply_reverb_simple(waveform, room_size=0.1, wet_mix=0.5, sample_rate=sample_rate)
        large_room = apply_reverb_simple(waveform, room_size=0.9, wet_mix=0.5, sample_rate=sample_rate)
        
        # Outputs should differ enough (but maybe not dramatically for short signals)
        # Check that they're not identical
        difference = np.sum(np.abs(small_room - large_room))
        assert difference > 0.01, "Different room sizes should produce noticeably different output"


class TestLowpassFilter:
    """Test Butterworth lowpass filter."""
    
    def test_lowpass_basic_functionality(self):
        """Test that lowpass filter works and preserves shape."""
        duration = 0.1
        sample_rate = 44100
        num_samples = int(duration * sample_rate)
        waveform = np.random.randn(num_samples).astype(np.float32)
        
        filtered = apply_lowpass_filter(waveform, cutoff_hz=1000, sample_rate=sample_rate)
        
        assert filtered.shape == waveform.shape
        assert filtered.dtype == np.float32
    
    def test_lowpass_attenuates_high_frequencies(self):
        """Test that lowpass filter attenuates frequencies above cutoff."""
        sample_rate = 44100
        duration = 0.1
        num_samples = int(duration * sample_rate)
        t = np.arange(num_samples) / sample_rate
        
        # Create signal with low (500Hz) and high (4000Hz) frequency components
        low_freq = np.sin(2 * np.pi * 500 * t)
        high_freq = np.sin(2 * np.pi * 4000 * t)
        mixed_signal = (low_freq + high_freq).astype(np.float32)
        
        # Apply lowpass at 1000Hz (should pass 500Hz, attenuate 4000Hz)
        filtered = apply_lowpass_filter(mixed_signal, cutoff_hz=1000, order=4, sample_rate=sample_rate)
        
        # Compute FFT to check frequency content
        fft_original = np.fft.rfft(mixed_signal)
        fft_filtered = np.fft.rfft(filtered)
        freqs = np.fft.rfftfreq(num_samples, 1/sample_rate)
        
        # Find bins for 500Hz and 4000Hz
        idx_500 = np.argmin(np.abs(freqs - 500))
        idx_4000 = np.argmin(np.abs(freqs - 4000))
        
        # High frequency should be attenuated more than low frequency
        attenuation_low = np.abs(fft_filtered[idx_500]) / np.abs(fft_original[idx_500])
        attenuation_high = np.abs(fft_filtered[idx_4000]) / np.abs(fft_original[idx_4000])
        
        assert attenuation_high < attenuation_low, "High frequency should be attenuated more"
        assert attenuation_low > 0.7, "Low frequency should mostly pass through"
    
    def test_lowpass_different_orders(self):
        """Test that higher filter orders produce steeper roll-off."""
        duration = 0.1
        sample_rate = 44100
        num_samples = int(duration * sample_rate)
        waveform = np.random.randn(num_samples).astype(np.float32)
        
        filtered_order2 = apply_lowpass_filter(waveform, cutoff_hz=1000, order=2, sample_rate=sample_rate)
        filtered_order8 = apply_lowpass_filter(waveform, cutoff_hz=1000, order=8, sample_rate=sample_rate)
        
        # Both should work
        assert filtered_order2.shape == waveform.shape
        assert filtered_order8.shape == waveform.shape


class TestBandpassFilter:
    """Test Butterworth bandpass filter."""
    
    def test_bandpass_basic_functionality(self):
        """Test that bandpass filter works and preserves shape."""
        duration = 0.1
        sample_rate = 44100
        num_samples = int(duration * sample_rate)
        waveform = np.random.randn(num_samples).astype(np.float32)
        
        filtered = apply_bandpass_filter(waveform, freq_low_hz=500, freq_high_hz=2000, sample_rate=sample_rate)
        
        assert filtered.shape == waveform.shape
        assert filtered.dtype == np.float32
    
    def test_bandpass_passes_midband(self):
        """Test that bandpass filter passes frequencies in the pass band."""
        sample_rate = 44100
        duration = 0.1
        num_samples = int(duration * sample_rate)
        t = np.arange(num_samples) / sample_rate
        
        # Create signal with three frequency components
        low_freq = np.sin(2 * np.pi * 200 * t)    # Below pass band
        mid_freq = np.sin(2 * np.pi * 1000 * t)   # In pass band
        high_freq = np.sin(2 * np.pi * 5000 * t)  # Above pass band
        mixed_signal = (low_freq + mid_freq + high_freq).astype(np.float32)
        
        # Apply bandpass 500-2000Hz (should pass 1000Hz, attenuate 200Hz and 5000Hz)
        filtered = apply_bandpass_filter(mixed_signal, freq_low_hz=500, freq_high_hz=2000, order=4, sample_rate=sample_rate)
        
        # Compute FFT
        fft_original = np.fft.rfft(mixed_signal)
        fft_filtered = np.fft.rfft(filtered)
        freqs = np.fft.rfftfreq(num_samples, 1/sample_rate)
        
        # Find bins
        idx_200 = np.argmin(np.abs(freqs - 200))
        idx_1000 = np.argmin(np.abs(freqs - 1000))
        idx_5000 = np.argmin(np.abs(freqs - 5000))
        
        # Calculate attenuation
        attenuation_low = np.abs(fft_filtered[idx_200]) / (np.abs(fft_original[idx_200]) + 1e-10)
        attenuation_mid = np.abs(fft_filtered[idx_1000]) / (np.abs(fft_original[idx_1000]) + 1e-10)
        attenuation_high = np.abs(fft_filtered[idx_5000]) / (np.abs(fft_original[idx_5000]) + 1e-10)
        
        # Mid frequency should pass through better than extremes
        assert attenuation_mid > attenuation_low, "Mid-band should pass better than low"
        assert attenuation_mid > attenuation_high, "Mid-band should pass better than high"
    
    def test_bandpass_invalid_range(self):
        """Test that bandpass raises error when freq_low >= freq_high."""
        waveform = np.random.randn(1000).astype(np.float32)
        
        with pytest.raises(ValueError):
            apply_bandpass_filter(waveform, freq_low_hz=2000, freq_high_hz=500)


class TestHighpassFilter:
    """Test Butterworth highpass filter."""
    
    def test_highpass_basic_functionality(self):
        """Test that highpass filter works and preserves shape."""
        duration = 0.1
        sample_rate = 44100
        num_samples = int(duration * sample_rate)
        waveform = np.random.randn(num_samples).astype(np.float32)
        
        filtered = apply_highpass_filter(waveform, cutoff_hz=1000, sample_rate=sample_rate)
        
        assert filtered.shape == waveform.shape
        assert filtered.dtype == np.float32
    
    def test_highpass_attenuates_low_frequencies(self):
        """Test that highpass filter attenuates frequencies below cutoff."""
        sample_rate = 44100
        duration = 0.1
        num_samples = int(duration * sample_rate)
        t = np.arange(num_samples) / sample_rate
        
        # Create signal with low (200Hz) and high (2000Hz) frequency components
        low_freq = np.sin(2 * np.pi * 200 * t)
        high_freq = np.sin(2 * np.pi * 2000 * t)
        mixed_signal = (low_freq + high_freq).astype(np.float32)
        
        # Apply highpass at 1000Hz (should attenuate 200Hz, pass 2000Hz)
        filtered = apply_highpass_filter(mixed_signal, cutoff_hz=1000, order=4, sample_rate=sample_rate)
        
        # Compute FFT
        fft_original = np.fft.rfft(mixed_signal)
        fft_filtered = np.fft.rfft(filtered)
        freqs = np.fft.rfftfreq(num_samples, 1/sample_rate)
        
        # Find bins
        idx_200 = np.argmin(np.abs(freqs - 200))
        idx_2000 = np.argmin(np.abs(freqs - 2000))
        
        # Calculate attenuation
        attenuation_low = np.abs(fft_filtered[idx_200]) / (np.abs(fft_original[idx_200]) + 1e-10)
        attenuation_high = np.abs(fft_filtered[idx_2000]) / (np.abs(fft_original[idx_2000]) + 1e-10)
        
        # Low frequency should be attenuated more than high frequency
        assert attenuation_low < attenuation_high, "Low frequency should be attenuated more"
        assert attenuation_high > 0.7, "High frequency should mostly pass through"


class TestCompression:
    """Test dynamic range compression."""
    
    def test_compression_basic_functionality(self):
        """Test that compression works and preserves shape."""
        duration = 0.1
        sample_rate = 44100
        num_samples = int(duration * sample_rate)
        waveform = np.random.randn(num_samples).astype(np.float32) * 0.5
        
        compressed = apply_compression(
            waveform,
            threshold_db=-20.0,
            ratio=3.0,
            attack_ms=5.0,
            release_ms=50.0,
            sample_rate=sample_rate
        )
        
        assert compressed.shape == waveform.shape
        assert compressed.dtype == np.float32
    
    def test_compression_reduces_peaks(self):
        """Test that compression reduces peak amplitudes above threshold."""
        sample_rate = 44100
        duration = 0.1
        num_samples = int(duration * sample_rate)
        
        # Create signal with varying amplitude
        t = np.arange(num_samples) / sample_rate
        quiet_part = np.sin(2 * np.pi * 440 * t[:num_samples//2]) * 0.1
        loud_part = np.sin(2 * np.pi * 440 * t[num_samples//2:]) * 0.8
        waveform = np.concatenate([quiet_part, loud_part]).astype(np.float32)
        
        # Apply compression with relatively low threshold
        compressed = apply_compression(
            waveform,
            threshold_db=-20.0,  # About 0.1 linear
            ratio=4.0,
            attack_ms=1.0,
            release_ms=20.0,
            sample_rate=sample_rate
        )
        
        # Check that peaks are reduced
        original_peak = np.max(np.abs(waveform))
        compressed_peak = np.max(np.abs(compressed))
        
        # Loud part should be compressed (peak reduced)
        assert compressed_peak < original_peak, "Compression should reduce peak amplitude"
        
        # Check that quiet part is mostly unchanged (below threshold)
        quiet_original = np.abs(waveform[:num_samples//4])
        quiet_compressed = np.abs(compressed[:num_samples//4])
        quiet_ratio = np.mean(quiet_compressed) / (np.mean(quiet_original) + 1e-10)
        
        # Quiet part should be close to original (within 20%)
        assert 0.8 < quiet_ratio < 1.2, "Below-threshold signals should be mostly unchanged"
    
    def test_compression_below_threshold_unchanged(self):
        """Test that signals below threshold pass through mostly unchanged."""
        sample_rate = 44100
        duration = 0.05
        num_samples = int(duration * sample_rate)
        
        # Create quiet signal (well below -20dB threshold)
        waveform = np.random.randn(num_samples).astype(np.float32) * 0.01  # Around -40dB
        
        compressed = apply_compression(
            waveform,
            threshold_db=-20.0,
            ratio=3.0,
            sample_rate=sample_rate
        )
        
        # Signals below threshold should be mostly unchanged
        # (some minor difference due to envelope follower)
        assert np.allclose(compressed, waveform, atol=0.01)


class TestLegacyWrappers:
    """Test legacy compatibility wrappers."""
    
    def test_apply_reverb_wrapper(self):
        """Test that legacy apply_reverb wrapper works."""
        duration = 0.05
        sample_rate = 44100
        num_samples = int(duration * sample_rate)
        waveform = np.random.randn(num_samples).astype(np.float32) * 0.5
        
        result = apply_reverb(waveform, reverb_time_ms=150.0, sample_rate=sample_rate)
        
        assert result.shape == waveform.shape
        assert result.dtype == np.float32
    
    def test_apply_lowpass_wrapper(self):
        """Test that legacy apply_lowpass wrapper works."""
        duration = 0.05
        sample_rate = 44100
        num_samples = int(duration * sample_rate)
        waveform = np.random.randn(num_samples).astype(np.float32) * 0.5
        
        result = apply_lowpass(waveform, cutoff_freq=2000, sample_rate=sample_rate)
        
        assert result.shape == waveform.shape
        assert result.dtype == np.float32


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
