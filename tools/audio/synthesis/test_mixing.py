"""
Unit tests for audio mixing module.
Tests layer mixing, peak normalization, and silence trimming.
"""

import numpy as np
import pytest
from mixing import mix_layers, normalize_audio, trim_silence


class TestMixLayers:
    """Test multi-layer audio mixing."""
    
    def test_mix_two_layers_unity_gain(self):
        """Mix two layers at unity gain (default)."""
        layer1 = np.array([0.5, 0.3, 0.1], dtype=np.float32)
        layer2 = np.array([0.2, 0.4, 0.6], dtype=np.float32)
        
        mixed = mix_layers([layer1, layer2])
        
        expected = np.array([0.7, 0.7, 0.7], dtype=np.float32)
        np.testing.assert_array_almost_equal(mixed, expected, decimal=6)
    
    def test_mix_three_layers_with_levels(self):
        """Mix three layers with custom level control."""
        layer1 = np.ones(100, dtype=np.float32) * 0.5
        layer2 = np.ones(100, dtype=np.float32) * 0.3
        layer3 = np.ones(100, dtype=np.float32) * 0.2
        
        # Mix with levels: 100%, 50%, 0%
        mixed = mix_layers([layer1, layer2, layer3], levels=[1.0, 0.5, 0.0])
        
        # Expected: 0.5*1.0 + 0.3*0.5 + 0.2*0.0 = 0.65
        assert np.allclose(mixed, 0.65), f"Expected 0.65, got {mixed[0]}"
    
    def test_mix_single_layer(self):
        """Mix single layer (edge case)."""
        layer = np.array([0.1, 0.2, 0.3], dtype=np.float32)
        
        mixed = mix_layers([layer])
        
        np.testing.assert_array_equal(mixed, layer)
    
    def test_mix_empty_layers_raises_error(self):
        """Empty layer list should raise ValueError."""
        with pytest.raises(ValueError, match="Cannot mix empty layer list"):
            mix_layers([])
    
    def test_mix_different_length_layers_raises_error(self):
        """Layers with different lengths should raise ValueError."""
        layer1 = np.array([0.1, 0.2, 0.3], dtype=np.float32)
        layer2 = np.array([0.4, 0.5], dtype=np.float32)  # Different length
        
        with pytest.raises(ValueError, match="All layers must have same length"):
            mix_layers([layer1, layer2])
    
    def test_mix_levels_count_mismatch_raises_error(self):
        """Mismatched levels count should raise ValueError."""
        layer1 = np.ones(10, dtype=np.float32)
        layer2 = np.ones(10, dtype=np.float32)
        
        with pytest.raises(ValueError, match="Number of levels .* must match number of layers"):
            mix_layers([layer1, layer2], levels=[1.0])  # Only 1 level for 2 layers
    
    def test_mix_preserves_float32_dtype(self):
        """Mixed output should be float32."""
        layer1 = np.array([0.1, 0.2], dtype=np.float64)  # float64 input
        layer2 = np.array([0.3, 0.4], dtype=np.float32)
        
        mixed = mix_layers([layer1, layer2])
        
        assert mixed.dtype == np.float32, f"Expected float32, got {mixed.dtype}"


class TestNormalizeAudio:
    """Test peak normalization."""
    
    def test_normalize_to_default_target(self):
        """Normalize to default -0.5dB target."""
        audio = np.array([0.5, -0.3, 0.1], dtype=np.float32)
        
        normalized = normalize_audio(audio)
        
        # Peak should be at -0.5dB = 10^(-0.5/20) ≈ 0.944
        target_amplitude = 10 ** (-0.5 / 20.0)
        actual_peak = np.max(np.abs(normalized))
        
        assert np.isclose(actual_peak, target_amplitude, rtol=1e-5), \
            f"Expected peak {target_amplitude:.6f}, got {actual_peak:.6f}"
    
    def test_normalize_to_custom_target(self):
        """Normalize to custom -1.0dB target."""
        audio = np.array([0.2, -0.4, 0.3], dtype=np.float32)
        
        normalized = normalize_audio(audio, target_peak_db=-1.0)
        
        # Peak should be at -1.0dB = 10^(-1.0/20) ≈ 0.891
        target_amplitude = 10 ** (-1.0 / 20.0)
        actual_peak = np.max(np.abs(normalized))
        
        assert np.isclose(actual_peak, target_amplitude, rtol=1e-5), \
            f"Expected peak {target_amplitude:.6f}, got {actual_peak:.6f}"
    
    def test_normalize_already_at_target(self):
        """Audio already at target level should remain unchanged."""
        target_amplitude = 10 ** (-0.5 / 20.0)
        audio = np.array([target_amplitude, -0.5 * target_amplitude, 0.3 * target_amplitude], dtype=np.float32)
        
        normalized = normalize_audio(audio, target_peak_db=-0.5)
        
        # Should be nearly identical (within floating point precision)
        np.testing.assert_array_almost_equal(normalized, audio, decimal=6)
    
    def test_normalize_silent_audio(self):
        """Silent audio (all zeros) should remain silent."""
        audio = np.zeros(100, dtype=np.float32)
        
        normalized = normalize_audio(audio)
        
        assert np.all(normalized == 0), "Silent audio should remain silent"
    
    def test_normalize_negative_peak(self):
        """Normalization should work correctly with negative peak."""
        audio = np.array([0.1, -0.6, 0.2], dtype=np.float32)  # Peak is -0.6
        
        normalized = normalize_audio(audio, target_peak_db=-0.5)
        
        target_amplitude = 10 ** (-0.5 / 20.0)
        actual_peak = np.max(np.abs(normalized))
        
        assert np.isclose(actual_peak, target_amplitude, rtol=1e-5)
    
    def test_normalize_preserves_waveform_shape(self):
        """Normalization should preserve relative amplitude relationships."""
        audio = np.array([0.1, 0.2, 0.3, 0.4], dtype=np.float32)
        
        normalized = normalize_audio(audio)
        
        # Ratios between samples should be preserved
        assert np.isclose(normalized[1] / normalized[0], 2.0, rtol=1e-5)
        assert np.isclose(normalized[2] / normalized[0], 3.0, rtol=1e-5)
        assert np.isclose(normalized[3] / normalized[0], 4.0, rtol=1e-5)
    
    def test_normalize_output_dtype_float32(self):
        """Normalized output should be float32."""
        audio = np.array([0.5, 0.3], dtype=np.float64)  # float64 input
        
        normalized = normalize_audio(audio)
        
        assert normalized.dtype == np.float32, f"Expected float32, got {normalized.dtype}"


class TestTrimSilence:
    """Test silence trimming."""
    
    def test_trim_leading_silence(self):
        """Remove leading silence below threshold."""
        # Silent samples followed by signal
        audio = np.array([0.0, 0.0, 0.0, 0.5, 0.3, 0.1], dtype=np.float32)
        
        trimmed = trim_silence(audio, threshold_db=-60.0)
        
        expected = np.array([0.5, 0.3, 0.1], dtype=np.float32)
        np.testing.assert_array_equal(trimmed, expected)
    
    def test_trim_trailing_silence(self):
        """Remove trailing silence below threshold."""
        # Signal followed by silent samples
        audio = np.array([0.5, 0.3, 0.1, 0.0, 0.0, 0.0], dtype=np.float32)
        
        trimmed = trim_silence(audio, threshold_db=-60.0)
        
        expected = np.array([0.5, 0.3, 0.1], dtype=np.float32)
        np.testing.assert_array_equal(trimmed, expected)
    
    def test_trim_both_ends(self):
        """Remove silence from both leading and trailing."""
        audio = np.array([0.0, 0.0, 0.5, 0.3, 0.1, 0.0, 0.0], dtype=np.float32)
        
        trimmed = trim_silence(audio, threshold_db=-60.0)
        
        expected = np.array([0.5, 0.3, 0.1], dtype=np.float32)
        np.testing.assert_array_equal(trimmed, expected)
    
    def test_trim_no_silence(self):
        """Audio with no silence should remain unchanged."""
        audio = np.array([0.5, 0.3, 0.1, 0.2, 0.4], dtype=np.float32)
        
        trimmed = trim_silence(audio, threshold_db=-60.0)
        
        np.testing.assert_array_equal(trimmed, audio)
    
    def test_trim_custom_threshold(self):
        """Use custom threshold for trimming."""
        # -20dB threshold = 10^(-20/20) = 0.1
        audio = np.array([0.05, 0.08, 0.5, 0.3, 0.09, 0.06], dtype=np.float32)
        
        trimmed = trim_silence(audio, threshold_db=-20.0)
        
        # 0.05, 0.08, 0.09, 0.06 are all below 0.1 threshold
        expected = np.array([0.5, 0.3], dtype=np.float32)
        np.testing.assert_array_equal(trimmed, expected)
    
    def test_trim_entirely_silent_audio(self):
        """Entirely silent audio should return minimal array."""
        audio = np.zeros(100, dtype=np.float32)
        
        trimmed = trim_silence(audio)
        
        # Should return single zero sample (minimal valid audio)
        assert len(trimmed) == 1
        assert trimmed[0] == 0.0
    
    def test_trim_preserves_negative_peaks(self):
        """Trimming should work correctly with negative samples."""
        audio = np.array([0.0, 0.0, -0.5, 0.3, -0.2, 0.0], dtype=np.float32)
        
        trimmed = trim_silence(audio)
        
        expected = np.array([-0.5, 0.3, -0.2], dtype=np.float32)
        np.testing.assert_array_equal(trimmed, expected)
    
    def test_trim_very_low_amplitude_signal(self):
        """Signal just above threshold should be preserved."""
        threshold_db = -60.0
        threshold_amplitude = 10 ** (threshold_db / 20.0)
        
        # Create signal well above threshold (2x to be safe)
        signal_amplitude = threshold_amplitude * 2.0
        audio = np.array([0.0, signal_amplitude, signal_amplitude * 0.8, 0.0], dtype=np.float32)
        
        trimmed = trim_silence(audio, threshold_db=threshold_db)
        
        # Should preserve the signal samples (both above threshold)
        assert len(trimmed) == 2
        assert trimmed[0] > 0
    
    def test_trim_output_dtype_float32(self):
        """Trimmed output should be float32."""
        audio = np.array([0.0, 0.5, 0.3, 0.0], dtype=np.float64)  # float64 input
        
        trimmed = trim_silence(audio)
        
        assert trimmed.dtype == np.float32, f"Expected float32, got {trimmed.dtype}"


class TestIntegrationScenarios:
    """Test realistic usage scenarios combining multiple functions."""
    
    def test_pulse_three_layer_workflow(self):
        """Simulate pulse sound: mix 3 layers → normalize → trim."""
        sample_rate = 44100
        duration = 0.2  # 200ms
        num_samples = int(duration * sample_rate)
        
        # Create three layers: sub-bass, body, shimmer
        sub_bass = np.sin(2 * np.pi * 80 * np.arange(num_samples) / sample_rate) * 0.6
        body = np.sin(2 * np.pi * 400 * np.arange(num_samples) / sample_rate) * 0.3
        shimmer = np.random.randn(num_samples) * 0.1  # Noise layer
        
        # Apply decay envelope to all
        decay = np.exp(-5 * np.arange(num_samples) / num_samples)
        sub_bass *= decay
        body *= decay
        shimmer *= decay
        
        # Mix layers
        mixed = mix_layers([sub_bass, body, shimmer], levels=[1.0, 0.8, 0.5])
        
        # Normalize to -0.5dB
        normalized = normalize_audio(mixed, target_peak_db=-0.5)
        
        # Trim silence (should trim trailing decay)
        final = trim_silence(normalized, threshold_db=-60.0)
        
        # Verify workflow succeeded
        assert len(final) > 0
        assert len(final) <= len(normalized)  # Trimmed should be shorter or equal
        target_amplitude = 10 ** (-0.5 / 20.0)
        actual_peak = np.max(np.abs(final))
        assert actual_peak <= target_amplitude * 1.01  # Within 1% tolerance
    
    def test_wall_slam_normalization_prevents_clipping(self):
        """Ensure heavy wall slam doesn't clip after mixing."""
        # Create heavy impact layers that would clip without normalization
        impact = np.ones(1000) * 0.8
        texture = np.ones(1000) * 0.7
        
        # Mix without levels control (would exceed 1.0)
        mixed = mix_layers([impact, texture])
        
        # This would be > 1.0, but normalize brings it to safe range
        normalized = normalize_audio(mixed, target_peak_db=-1.0)
        
        # Verify no clipping
        assert np.max(np.abs(normalized)) <= 1.0
        
        # Verify it's normalized to target
        target_amplitude = 10 ** (-1.0 / 20.0)
        actual_peak = np.max(np.abs(normalized))
        assert np.isclose(actual_peak, target_amplitude, rtol=1e-5)
    
    def test_empty_audio_edge_case(self):
        """Handle edge case of extremely short audio."""
        audio = np.array([0.5], dtype=np.float32)  # Single sample
        
        # Should handle single-sample audio gracefully
        normalized = normalize_audio(audio, target_peak_db=-0.5)
        trimmed = trim_silence(normalized)
        
        assert len(trimmed) == 1
        assert trimmed[0] > 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
