"""
Unit tests for waveform generation module.

Tests validate:
- Sine wave frequency accuracy
- Noise filtering spectral characteristics
- Frequency sweep modulation behavior
- Output amplitude range compliance
"""

import numpy as np
import pytest
from scipy import signal, fft
from waveforms import (
    generate_sine_wave,
    generate_square_wave,
    generate_sawtooth_wave,
    generate_filtered_noise,
    generate_pink_noise,
    apply_frequency_sweep
)


class TestSineWaveGeneration:
    """Tests for generate_sine_wave function."""
    
    def test_sine_wave_amplitude_range(self):
        """Verify sine wave stays within [-1.0, 1.0] range."""
        waveform = generate_sine_wave(440.0, 0.1, 44100)
        
        assert np.min(waveform) >= -1.0, "Sine wave should not go below -1.0"
        assert np.max(waveform) >= 0.99, "Sine wave should reach near 1.0"
        assert np.max(waveform) <= 1.0, "Sine wave should not exceed 1.0"
    
    def test_sine_wave_duration(self):
        """Verify generated sine wave has correct duration."""
        duration = 0.5
        sample_rate = 44100
        waveform = generate_sine_wave(440.0, duration, sample_rate)
        
        expected_samples = int(duration * sample_rate)
        assert len(waveform) == expected_samples, \
            f"Expected {expected_samples} samples, got {len(waveform)}"
    
    def test_sine_wave_frequency_accuracy(self):
        """Verify sine wave generates correct frequency."""
        target_freq = 440.0  # A4 note
        duration = 1.0
        sample_rate = 44100
        
        waveform = generate_sine_wave(target_freq, duration, sample_rate)
        
        # Perform FFT to find dominant frequency
        fft_result = np.fft.rfft(waveform)
        fft_freqs = np.fft.rfftfreq(len(waveform), 1.0 / sample_rate)
        
        # Find peak frequency
        peak_idx = np.argmax(np.abs(fft_result))
        peak_freq = fft_freqs[peak_idx]
        
        # Allow 1 Hz tolerance
        assert abs(peak_freq - target_freq) < 1.0, \
            f"Expected {target_freq} Hz, got {peak_freq} Hz"
    
    def test_sine_wave_different_frequencies(self):
        """Verify sine wave works with various frequencies."""
        frequencies = [60.0, 200.0, 1000.0, 4000.0, 8000.0]
        
        for freq in frequencies:
            waveform = generate_sine_wave(freq, 0.1, 44100)
            
            assert len(waveform) > 0, f"Failed to generate {freq} Hz sine wave"
            assert np.max(np.abs(waveform)) <= 1.0, \
                f"{freq} Hz sine wave exceeds amplitude limit"
    
    def test_sine_wave_data_type(self):
        """Verify sine wave returns float32 array."""
        waveform = generate_sine_wave(440.0, 0.1, 44100)
        
        assert waveform.dtype == np.float32, \
            f"Expected float32, got {waveform.dtype}"


class TestSquareWaveGeneration:
    """Tests for generate_square_wave function."""
    
    def test_square_wave_amplitude_range(self):
        """Verify square wave stays within [-1.0, 1.0] range."""
        waveform = generate_square_wave(1200.0, 0.1, 44100)
        assert np.min(waveform) >= -1.0
        assert np.max(waveform) <= 1.0
        assert waveform.dtype == np.float32

    def test_square_wave_duration(self):
        """Verify square wave duration in samples."""
        duration = 0.2
        sr = 44100
        waveform = generate_square_wave(1800.0, duration, sr)
        assert len(waveform) == int(duration * sr)


class TestSawtoothWaveGeneration:
    """Tests for generate_sawtooth_wave function."""

    def test_sawtooth_wave_amplitude_range(self):
        """Verify sawtooth wave stays within [-1.0, 1.0] range."""
        waveform = generate_sawtooth_wave(440.0, 0.1, 44100)
        assert np.min(waveform) >= -1.0
        assert np.max(waveform) <= 1.0
        assert waveform.dtype == np.float32

    def test_sawtooth_wave_duration(self):
        """Verify sawtooth wave duration in samples."""
        duration = 0.2
        sr = 44100
        waveform = generate_sawtooth_wave(440.0, duration, sr)
        assert len(waveform) == int(duration * sr)


class TestFilteredNoiseGeneration:
    """Tests for generate_filtered_noise function."""
    
    def test_filtered_noise_amplitude_range(self):
        """Verify filtered noise stays within [-1.0, 1.0] range."""
        waveform = generate_filtered_noise(200.0, 800.0, 0.1, 'bandpass', 44100)
        
        assert np.min(waveform) >= -1.0, "Filtered noise should not go below -1.0"
        assert np.max(waveform) <= 1.0, "Filtered noise should not exceed 1.0"
    
    def test_filtered_noise_duration(self):
        """Verify generated filtered noise has correct duration."""
        duration = 0.3
        sample_rate = 44100
        waveform = generate_filtered_noise(500.0, 2000.0, duration, 'bandpass', sample_rate)
        
        expected_samples = int(duration * sample_rate)
        assert len(waveform) == expected_samples, \
            f"Expected {expected_samples} samples, got {len(waveform)}"
    
    def test_bandpass_filter_spectral_characteristics(self):
        """Verify bandpass filter attenuates frequencies outside passband."""
        freq_low = 500.0
        freq_high = 2000.0
        duration = 1.0
        sample_rate = 44100
        
        waveform = generate_filtered_noise(freq_low, freq_high, duration, 'bandpass', sample_rate)
        
        # Perform FFT
        fft_result = np.fft.rfft(waveform)
        fft_freqs = np.fft.rfftfreq(len(waveform), 1.0 / sample_rate)
        power = np.abs(fft_result) ** 2
        
        # Find energy in passband vs outside
        passband_mask = (fft_freqs >= freq_low) & (fft_freqs <= freq_high)
        outside_low_mask = fft_freqs < freq_low * 0.5  # Well below passband
        outside_high_mask = fft_freqs > freq_high * 1.5  # Well above passband
        
        passband_energy = np.sum(power[passband_mask])
        outside_low_energy = np.sum(power[outside_low_mask])
        outside_high_energy = np.sum(power[outside_high_mask])
        
        # Passband should have significantly more energy than outside bands
        assert passband_energy > outside_low_energy * 10, \
            "Bandpass filter should attenuate low frequencies"
        assert passband_energy > outside_high_energy * 10, \
            "Bandpass filter should attenuate high frequencies"
    
    def test_lowpass_filter_type(self):
        """Verify lowpass filter works correctly."""
        waveform = generate_filtered_noise(0.0, 1000.0, 0.2, 'lowpass', 44100)
        
        assert len(waveform) > 0, "Lowpass filter should produce output"
        assert np.max(np.abs(waveform)) <= 1.0, "Lowpass output should be normalized"
    
    def test_highpass_filter_type(self):
        """Verify highpass filter works correctly."""
        waveform = generate_filtered_noise(2000.0, 0.0, 0.2, 'highpass', 44100)
        
        assert len(waveform) > 0, "Highpass filter should produce output"
        assert np.max(np.abs(waveform)) <= 1.0, "Highpass output should be normalized"
    
    def test_invalid_filter_type_raises_error(self):
        """Verify invalid filter type raises ValueError."""
        with pytest.raises(ValueError, match="Invalid filter_type"):
            generate_filtered_noise(500.0, 2000.0, 0.1, 'invalid', 44100)
    
    def test_filtered_noise_randomness(self):
        """Verify filtered noise generates different outputs each time."""
        waveform1 = generate_filtered_noise(500.0, 2000.0, 0.1, 'bandpass', 44100)
        waveform2 = generate_filtered_noise(500.0, 2000.0, 0.1, 'bandpass', 44100)
        
        # Should not be identical (different random noise)
        assert not np.allclose(waveform1, waveform2), \
            "Filtered noise should generate different outputs"
    
    def test_filtered_noise_data_type(self):
        """Verify filtered noise returns float32 array."""
        waveform = generate_filtered_noise(500.0, 2000.0, 0.1, 'bandpass', 44100)
        
        assert waveform.dtype == np.float32, \
            f"Expected float32, got {waveform.dtype}"


class TestPinkNoiseGeneration:
    """Tests for generate_pink_noise function."""
    
    def test_pink_noise_amplitude_range(self):
        """Verify pink noise stays within [-1.0, 1.0] range."""
        waveform = generate_pink_noise(0.2, 44100)
        
        assert np.min(waveform) >= -1.0, "Pink noise should not go below -1.0"
        assert np.max(waveform) <= 1.0, "Pink noise should not exceed 1.0"
    
    def test_pink_noise_duration(self):
        """Verify generated pink noise has correct duration."""
        duration = 0.4
        sample_rate = 44100
        waveform = generate_pink_noise(duration, sample_rate)
        
        expected_samples = int(duration * sample_rate)
        assert len(waveform) == expected_samples, \
            f"Expected {expected_samples} samples, got {len(waveform)}"
    
    def test_pink_noise_spectral_rolloff(self):
        """Verify pink noise has -3dB/octave roll-off (1/f characteristic)."""
        duration = 2.0
        sample_rate = 44100
        waveform = generate_pink_noise(duration, sample_rate)
        
        # Perform FFT
        fft_result = np.fft.rfft(waveform)
        fft_freqs = np.fft.rfftfreq(len(waveform), 1.0 / sample_rate)
        power = np.abs(fft_result) ** 2
        
        # Compare energy in different octave bands
        # Pink noise should have similar energy per octave
        octave_bands = [
            (100, 200),    # Octave 1
            (200, 400),    # Octave 2
            (400, 800),    # Octave 3
            (800, 1600),   # Octave 4
        ]
        
        octave_energies = []
        for low, high in octave_bands:
            mask = (fft_freqs >= low) & (fft_freqs < high)
            energy = np.sum(power[mask])
            octave_energies.append(energy)
        
        # Pink noise should have relatively equal energy per octave
        # Check that energy doesn't drop too drastically
        for i in range(len(octave_energies) - 1):
            ratio = octave_energies[i] / (octave_energies[i + 1] + 1e-10)
            # Allow variation but should be roughly similar (within 10x)
            assert 0.1 < ratio < 10.0, \
                f"Octave energy ratio too extreme: {ratio}"
    
    def test_pink_noise_randomness(self):
        """Verify pink noise generates different outputs each time."""
        waveform1 = generate_pink_noise(0.1, 44100)
        waveform2 = generate_pink_noise(0.1, 44100)
        
        # Should not be identical
        assert not np.allclose(waveform1, waveform2), \
            "Pink noise should generate different outputs"
    
    def test_pink_noise_data_type(self):
        """Verify pink noise returns float32 array."""
        waveform = generate_pink_noise(0.1, 44100)
        
        assert waveform.dtype == np.float32, \
            f"Expected float32, got {waveform.dtype}"


class TestFrequencySweep:
    """Tests for apply_frequency_sweep function."""
    
    def test_frequency_sweep_amplitude_range(self):
        """Verify frequency sweep maintains amplitude within [-1.0, 1.0]."""
        original = generate_sine_wave(440.0, 0.1, 44100)
        swept = apply_frequency_sweep(original, 1.1, 0.9, 44100)
        
        assert np.min(swept) >= -1.0, "Swept waveform should not go below -1.0"
        assert np.max(swept) <= 1.0, "Swept waveform should not exceed 1.0"
    
    def test_frequency_sweep_preserves_duration(self):
        """Verify frequency sweep maintains same duration."""
        original = generate_sine_wave(440.0, 0.2, 44100)
        swept = apply_frequency_sweep(original, 1.2, 0.8, 44100)
        
        assert len(swept) == len(original), \
            f"Sweep should preserve duration: {len(swept)} vs {len(original)}"
    
    def test_frequency_sweep_upward_pitch(self):
        """Verify upward pitch sweep increases frequency over time."""
        # Generate swept noise for clearer frequency analysis
        original = generate_filtered_noise(500.0, 1500.0, 0.5, 'bandpass', 44100)
        swept = apply_frequency_sweep(original, 1.0, 1.5, 44100)
        
        # Split into first and second half
        mid_point = len(swept) // 2
        first_half = swept[:mid_point]
        second_half = swept[mid_point:]
        
        # Compute mean spectral centroid for each half
        fft_first = np.fft.rfft(first_half)
        fft_second = np.fft.rfft(second_half)
        freqs_first = np.fft.rfftfreq(len(first_half), 1.0 / 44100)
        freqs_second = np.fft.rfftfreq(len(second_half), 1.0 / 44100)
        
        # Spectral centroid (center of mass)
        power_first = np.abs(fft_first) ** 2
        power_second = np.abs(fft_second) ** 2
        
        centroid_first = np.sum(freqs_first * power_first) / (np.sum(power_first) + 1e-10)
        centroid_second = np.sum(freqs_second * power_second) / (np.sum(power_second) + 1e-10)
        
        # Second half should have higher centroid (upward sweep)
        assert centroid_second > centroid_first * 1.05, \
            f"Upward sweep should increase frequency: {centroid_first} -> {centroid_second}"
    
    def test_frequency_sweep_downward_pitch(self):
        """Verify downward pitch sweep decreases frequency over time."""
        original = generate_filtered_noise(1000.0, 3000.0, 0.5, 'bandpass', 44100)
        swept = apply_frequency_sweep(original, 1.0, 0.5, 44100)
        
        # Split into first and second half
        mid_point = len(swept) // 2
        first_half = swept[:mid_point]
        second_half = swept[mid_point:]
        
        # Compute mean spectral centroid for each half
        fft_first = np.fft.rfft(first_half)
        fft_second = np.fft.rfft(second_half)
        freqs_first = np.fft.rfftfreq(len(first_half), 1.0 / 44100)
        freqs_second = np.fft.rfftfreq(len(second_half), 1.0 / 44100)
        
        power_first = np.abs(fft_first) ** 2
        power_second = np.abs(fft_second) ** 2
        
        centroid_first = np.sum(freqs_first * power_first) / (np.sum(power_first) + 1e-10)
        centroid_second = np.sum(freqs_second * power_second) / (np.sum(power_second) + 1e-10)
        
        # Second half should have lower centroid (downward sweep)
        assert centroid_second < centroid_first * 0.95, \
            f"Downward sweep should decrease frequency: {centroid_first} -> {centroid_second}"
    
    def test_frequency_sweep_no_change(self):
        """Verify sweep with start_pitch == end_pitch preserves signal."""
        original = generate_sine_wave(440.0, 0.1, 44100)
        swept = apply_frequency_sweep(original, 1.0, 1.0, 44100)
        
        # Should be very similar (some numerical error allowed)
        correlation = np.corrcoef(original, swept)[0, 1]
        assert correlation > 0.99, \
            f"No-change sweep should preserve signal: correlation {correlation}"
    
    def test_frequency_sweep_data_type(self):
        """Verify frequency sweep returns float32 array."""
        original = generate_sine_wave(440.0, 0.1, 44100)
        swept = apply_frequency_sweep(original, 1.1, 0.9, 44100)
        
        assert swept.dtype == np.float32, \
            f"Expected float32, got {swept.dtype}"


class TestIntegrationScenarios:
    """Integration tests combining multiple waveform functions."""
    
    def test_pulse_sound_layer_combination(self):
        """Test combining sine wave + filtered noise (pulse sound simulation)."""
        # Sub-bass layer
        sub_bass = generate_sine_wave(80.0, 0.2, 44100) * 0.6
        
        # Shimmer layer
        shimmer = generate_filtered_noise(200.0, 800.0, 0.2, 'bandpass', 44100) * 0.3
        
        # Mix layers
        mixed = sub_bass + shimmer
        
        # Should stay within range after mixing
        assert np.max(np.abs(mixed)) <= 1.5, \
            "Mixed layers should not clip excessively (will be normalized)"
    
    def test_dash_sound_frequency_sweep(self):
        """Test dash sound with frequency sweep (whoosh effect)."""
        # Generate filtered noise
        noise = generate_filtered_noise(4000.0, 8000.0, 0.1, 'bandpass', 44100)
        
        # Apply downward frequency sweep
        whoosh = apply_frequency_sweep(noise, 1.1, 0.95, 44100)
        
        assert len(whoosh) == len(noise), "Sweep should preserve length"
        assert np.max(np.abs(whoosh)) <= 1.0, "Whoosh should stay normalized"
    
    def test_wall_slam_multi_layer(self):
        """Test wall slam with sine + noise burst + pink noise."""
        duration = 0.3
        sample_rate = 44100
        
        # Impact sine
        impact = generate_sine_wave(60.0, duration, sample_rate) * 0.5
        
        # Short noise burst
        burst = generate_filtered_noise(500.0, 2000.0, duration, 'bandpass', sample_rate) * 0.3
        
        # Pink noise texture
        texture = generate_pink_noise(duration, sample_rate) * 0.2
        
        # Mix all layers
        mixed = impact + burst + texture
        
        # Verify mixed output has reasonable amplitude
        assert np.max(np.abs(mixed)) > 0.1, "Mixed layers should have audible amplitude"
        assert len(mixed) == int(duration * sample_rate), "Duration should match"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
