"""
Unit tests for envelope generation module.

Tests validate:
- ADSR envelope generation correctness
- Attack phase reaches peak
- Decay phase falls to sustain level
- Sustain phase holds constant
- Release phase decays to silence
- Edge cases (zero-length phases, extreme values)
- Total duration calculation
"""

import numpy as np
import pytest
from envelopes import ADSREnvelope, apply_adsr


class TestADSREnvelopeGeneration:
    """Tests for ADSREnvelope class basic functionality."""
    
    def test_envelope_amplitude_range(self):
        """Verify ADSR envelope stays within [0.0, 1.0] range."""
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=20.0,
            sustain_level=0.5,
            release_ms=30.0,
            sample_rate=44100
        )
        
        waveform = np.ones(4410)  # 100ms at 44.1kHz
        enveloped = adsr.apply(waveform)
        
        assert np.min(enveloped) >= 0.0, "Envelope should not go below 0.0"
        assert np.max(enveloped) <= 1.0, "Envelope should not exceed 1.0"
    
    def test_envelope_preserves_duration(self):
        """Verify ADSR envelope maintains same duration as input."""
        adsr = ADSREnvelope(
            attack_ms=5.0,
            decay_ms=10.0,
            sustain_level=0.3,
            release_ms=15.0,
            sample_rate=44100
        )
        
        original_length = 8820  # 200ms
        waveform = np.ones(original_length)
        enveloped = adsr.apply(waveform)
        
        assert len(enveloped) == original_length, \
            f"Envelope should preserve length: {len(enveloped)} vs {original_length}"
    
    def test_envelope_with_zero_input(self):
        """Verify ADSR envelope on zero signal produces zero output."""
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=20.0,
            sustain_level=0.5,
            release_ms=30.0,
            sample_rate=44100
        )
        
        waveform = np.zeros(4410)
        enveloped = adsr.apply(waveform)
        
        assert np.allclose(enveloped, 0.0), "Zero input should produce zero output"
    
    def test_envelope_data_type(self):
        """Verify ADSR envelope returns float array."""
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=20.0,
            sustain_level=0.5,
            release_ms=30.0,
            sample_rate=44100
        )
        
        waveform = np.ones(4410, dtype=np.float32)
        enveloped = adsr.apply(waveform)
        
        assert enveloped.dtype in [np.float32, np.float64], \
            f"Expected float type, got {enveloped.dtype}"


class TestAttackPhase:
    """Tests for ADSR attack phase behavior."""
    
    def test_attack_reaches_peak(self):
        """Verify attack phase reaches near maximum amplitude."""
        adsr = ADSREnvelope(
            attack_ms=50.0,    # Long attack for clear analysis
            decay_ms=0.0,      # No decay
            sustain_level=1.0, # Full sustain
            release_ms=0.0,    # No release
            sample_rate=44100
        )
        
        # Duration slightly longer than attack
        waveform = np.ones(int(0.06 * 44100))  # 60ms
        enveloped = adsr.apply(waveform)
        
        # Peak should be near 1.0
        peak = np.max(enveloped)
        assert peak > 0.95, f"Attack should reach near peak: got {peak}"
    
    def test_attack_starts_from_zero(self):
        """Verify attack phase starts from zero amplitude."""
        adsr = ADSREnvelope(
            attack_ms=20.0,
            decay_ms=10.0,
            sustain_level=0.5,
            release_ms=20.0,
            sample_rate=44100
        )
        
        waveform = np.ones(4410)
        enveloped = adsr.apply(waveform)
        
        # First sample should be very close to zero
        assert enveloped[0] < 0.1, f"Attack should start near zero: got {enveloped[0]}"
    
    def test_attack_exponential_curve(self):
        """Verify attack has exponential rise (faster at start)."""
        adsr = ADSREnvelope(
            attack_ms=100.0,   # Long attack for analysis
            decay_ms=0.0,
            sustain_level=1.0,
            release_ms=0.0,
            sample_rate=44100
        )
        
        waveform = np.ones(int(0.11 * 44100))  # 110ms
        envelope = adsr._generate_envelope(len(waveform))
        
        attack_samples = int(0.1 * 44100)  # 100ms attack
        
        # Check that first half of attack rises faster than second half
        quarter_point = attack_samples // 4
        half_point = attack_samples // 2
        three_quarter_point = 3 * attack_samples // 4
        
        first_quarter_rise = envelope[quarter_point] - envelope[0]
        third_quarter_rise = envelope[three_quarter_point] - envelope[half_point]
        
        # Exponential curve rises faster at the beginning
        assert first_quarter_rise > third_quarter_rise * 0.8, \
            "Attack should have exponential characteristic (faster rise at start)"
    
    def test_zero_attack_time(self):
        """Verify zero attack time starts at full amplitude."""
        adsr = ADSREnvelope(
            attack_ms=0.0,     # Instant attack
            decay_ms=20.0,
            sustain_level=0.5,
            release_ms=20.0,
            sample_rate=44100
        )
        
        waveform = np.ones(4410)
        envelope = adsr._generate_envelope(len(waveform))
        
        # Should start at or near 1.0 immediately
        assert envelope[0] > 0.9, f"Zero attack should start at peak: got {envelope[0]}"


class TestDecayPhase:
    """Tests for ADSR decay phase behavior."""
    
    def test_decay_falls_to_sustain_level(self):
        """Verify decay phase reaches sustain level."""
        sustain_level = 0.4
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=50.0,     # Long decay for clear analysis
            sustain_level=sustain_level,
            release_ms=0.0,
            sample_rate=44100
        )
        
        # Duration long enough to include attack + decay + some sustain
        waveform = np.ones(int(0.1 * 44100))  # 100ms
        envelope = adsr._generate_envelope(len(waveform))
        
        # Find samples after attack+decay period
        attack_decay_samples = int((10.0 + 50.0) * 44100 / 1000)
        sustain_start_idx = min(attack_decay_samples + 100, len(envelope) - 1)
        
        # Check value near start of sustain phase
        sustain_value = envelope[sustain_start_idx]
        assert abs(sustain_value - sustain_level) < 0.1, \
            f"Decay should reach sustain level {sustain_level}, got {sustain_value}"
    
    def test_decay_logarithmic_curve(self):
        """Verify decay has logarithmic fall (natural decay characteristic)."""
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=100.0,    # Long decay for analysis
            sustain_level=0.2,
            release_ms=0.0,
            sample_rate=44100
        )
        
        waveform = np.ones(int(0.15 * 44100))  # 150ms
        envelope = adsr._generate_envelope(len(waveform))
        
        attack_samples = int(0.01 * 44100)
        decay_samples = int(0.1 * 44100)
        
        # Sample decay at different points
        decay_start = attack_samples
        decay_quarter = decay_start + decay_samples // 4
        decay_half = decay_start + decay_samples // 2
        decay_three_quarter = decay_start + 3 * decay_samples // 4
        
        # Logarithmic decay falls faster at the beginning
        first_quarter_fall = envelope[decay_start] - envelope[decay_quarter]
        third_quarter_fall = envelope[decay_half] - envelope[decay_three_quarter]
        
        assert first_quarter_fall > third_quarter_fall, \
            "Decay should have logarithmic characteristic (faster fall at start)"
    
    def test_zero_decay_time(self):
        """Verify zero decay time immediately reaches sustain level."""
        sustain_level = 0.6
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=0.0,      # Instant decay
            sustain_level=sustain_level,
            release_ms=20.0,
            sample_rate=44100
        )
        
        waveform = np.ones(4410)
        envelope = adsr._generate_envelope(len(waveform))
        
        # After attack, should be at sustain level
        attack_samples = int(0.01 * 44100)
        post_attack_value = envelope[attack_samples + 10]
        
        assert abs(post_attack_value - sustain_level) < 0.15, \
            f"Zero decay should reach sustain immediately: got {post_attack_value}"
    
    def test_sustain_level_clamping(self):
        """Verify sustain level is clamped to [0.0, 1.0] range."""
        # Test sustain > 1.0
        adsr_high = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=10.0,
            sustain_level=1.5,  # Invalid, should clamp to 1.0
            release_ms=10.0,
            sample_rate=44100
        )
        assert adsr_high.sustain_level <= 1.0, "Sustain should be clamped to max 1.0"
        
        # Test sustain < 0.0
        adsr_low = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=10.0,
            sustain_level=-0.5,  # Invalid, should clamp to 0.0
            release_ms=10.0,
            sample_rate=44100
        )
        assert adsr_low.sustain_level >= 0.0, "Sustain should be clamped to min 0.0"


class TestSustainPhase:
    """Tests for ADSR sustain phase behavior."""
    
    def test_sustain_holds_constant(self):
        """Verify sustain phase maintains constant amplitude."""
        sustain_level = 0.5
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=10.0,
            sustain_level=sustain_level,
            release_ms=10.0,
            sample_rate=44100
        )
        
        # Long duration to ensure sustain phase exists
        waveform = np.ones(int(0.2 * 44100))  # 200ms
        envelope = adsr._generate_envelope(len(waveform))
        
        # Extract sustain region (after attack+decay, before release)
        attack_decay_samples = int(0.02 * 44100)  # 20ms
        release_start = len(envelope) - int(0.01 * 44100)  # Last 10ms
        
        sustain_region = envelope[attack_decay_samples:release_start]
        
        if len(sustain_region) > 0:
            # Sustain should be relatively constant
            sustain_std = np.std(sustain_region)
            assert sustain_std < 0.1, \
                f"Sustain should be constant: std={sustain_std}"
            
            # Mean should be near sustain level
            sustain_mean = np.mean(sustain_region)
            assert abs(sustain_mean - sustain_level) < 0.15, \
                f"Sustain mean should be near {sustain_level}, got {sustain_mean}"
    
    def test_short_duration_no_sustain(self):
        """Verify envelope works even when duration is too short for sustain phase."""
        adsr = ADSREnvelope(
            attack_ms=20.0,
            decay_ms=20.0,
            sustain_level=0.5,
            release_ms=20.0,  # Total 60ms needed
            sample_rate=44100
        )
        
        # Duration shorter than A+D+R
        short_waveform = np.ones(int(0.03 * 44100))  # 30ms (less than 60ms)
        enveloped = adsr.apply(short_waveform)
        
        # Should still produce valid output without crashing
        assert len(enveloped) == len(short_waveform)
        assert np.max(enveloped) > 0.0, "Should still have some amplitude"


class TestReleasePhase:
    """Tests for ADSR release phase behavior."""
    
    def test_release_decays_to_silence(self):
        """Verify release phase decays to near-zero amplitude."""
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=10.0,
            sustain_level=0.5,
            release_ms=50.0,   # Long release for clear analysis
            sample_rate=44100
        )
        
        # Duration ensures full release
        waveform = np.ones(int(0.1 * 44100))  # 100ms
        enveloped = adsr.apply(waveform)
        
        # Last samples should be near zero
        tail_samples = enveloped[-100:]  # Last 100 samples
        assert np.max(tail_samples) < 0.1, \
            f"Release should decay to near zero: tail max = {np.max(tail_samples)}"
    
    def test_release_exponential_decay(self):
        """Verify release has exponential decay (smooth tail)."""
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=10.0,
            sustain_level=0.6,
            release_ms=100.0,  # Long release for analysis
            sample_rate=44100
        )
        
        waveform = np.ones(int(0.15 * 44100))  # 150ms
        envelope = adsr._generate_envelope(len(waveform))
        
        # Find release phase (last 100ms)
        release_samples = int(0.1 * 44100)
        release_start = len(envelope) - release_samples
        
        if release_start > 0:
            # Sample at different points in release
            release_quarter = release_start + release_samples // 4
            release_half = release_start + release_samples // 2
            release_three_quarter = release_start + 3 * release_samples // 4
            
            # Exponential decay falls faster at the beginning
            first_quarter_fall = envelope[release_start] - envelope[release_quarter]
            third_quarter_fall = envelope[release_half] - envelope[release_three_quarter]
            
            assert first_quarter_fall > third_quarter_fall * 0.5, \
                "Release should have exponential characteristic (faster fall at start)"
    
    def test_zero_release_time(self):
        """Verify zero release time ends abruptly (but still valid)."""
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=10.0,
            sustain_level=0.5,
            release_ms=0.0,    # Instant release
            sample_rate=44100
        )
        
        waveform = np.ones(4410)
        enveloped = adsr.apply(waveform)
        
        # Should still produce valid output
        assert len(enveloped) == len(waveform)
        # With zero release, might end at sustain level (no smooth fade)


class TestEdgeCases:
    """Tests for edge cases and extreme parameter values."""
    
    def test_all_zero_times(self):
        """Verify envelope works with all zero timing parameters."""
        adsr = ADSREnvelope(
            attack_ms=0.0,
            decay_ms=0.0,
            sustain_level=0.5,
            release_ms=0.0,
            sample_rate=44100
        )
        
        waveform = np.ones(1000)
        enveloped = adsr.apply(waveform)
        
        # Should produce valid output (likely flat at sustain level)
        assert len(enveloped) == len(waveform)
        assert np.all(np.isfinite(enveloped)), "Output should not contain NaN/Inf"
    
    def test_very_long_envelope_times(self):
        """Verify envelope works with very long timing parameters."""
        adsr = ADSREnvelope(
            attack_ms=500.0,
            decay_ms=500.0,
            sustain_level=0.5,
            release_ms=500.0,
            sample_rate=44100
        )
        
        # Short waveform relative to envelope times
        waveform = np.ones(int(0.1 * 44100))  # 100ms
        enveloped = adsr.apply(waveform)
        
        # Should still work (envelope will be cut off)
        assert len(enveloped) == len(waveform)
        assert np.all(np.isfinite(enveloped)), "Output should not contain NaN/Inf"
    
    def test_very_short_waveform(self):
        """Verify envelope works with very short input waveforms."""
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=10.0,
            sustain_level=0.5,
            release_ms=10.0,
            sample_rate=44100
        )
        
        # Very short waveform (just 100 samples, ~2.3ms)
        short_waveform = np.ones(100)
        enveloped = adsr.apply(short_waveform)
        
        assert len(enveloped) == 100
        assert np.all(np.isfinite(enveloped)), "Output should not contain NaN/Inf"
    
    def test_single_sample_waveform(self):
        """Verify envelope handles single-sample input."""
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=10.0,
            sustain_level=0.5,
            release_ms=10.0,
            sample_rate=44100
        )
        
        single_sample = np.array([1.0])
        enveloped = adsr.apply(single_sample)
        
        assert len(enveloped) == 1
        assert np.isfinite(enveloped[0]), "Single sample should be finite"
    
    def test_different_sample_rates(self):
        """Verify envelope works with different sample rates."""
        sample_rates = [22050, 44100, 48000, 96000]
        
        for sr in sample_rates:
            adsr = ADSREnvelope(
                attack_ms=10.0,
                decay_ms=10.0,
                sustain_level=0.5,
                release_ms=10.0,
                sample_rate=sr
            )
            
            duration_samples = int(0.1 * sr)
            waveform = np.ones(duration_samples)
            enveloped = adsr.apply(waveform)
            
            assert len(enveloped) == duration_samples, \
                f"Envelope should work at {sr}Hz sample rate"
            assert np.all(np.isfinite(enveloped)), \
                f"Output should be finite at {sr}Hz"


class TestTotalDuration:
    """Tests for total duration calculation."""
    
    def test_get_total_duration_ms(self):
        """Verify get_total_duration_ms returns correct sum."""
        attack = 10.0
        decay = 20.0
        release = 30.0
        
        adsr = ADSREnvelope(
            attack_ms=attack,
            decay_ms=decay,
            sustain_level=0.5,
            release_ms=release,
            sample_rate=44100
        )
        
        expected_duration = attack + decay + release  # 60ms
        actual_duration = adsr.get_total_duration_ms()
        
        assert actual_duration == expected_duration, \
            f"Expected {expected_duration}ms, got {actual_duration}ms"
    
    def test_duration_excludes_sustain(self):
        """Verify total duration calculation excludes sustain (which is variable)."""
        adsr = ADSREnvelope(
            attack_ms=5.0,
            decay_ms=10.0,
            sustain_level=0.8,  # Sustain level doesn't affect duration
            release_ms=15.0,
            sample_rate=44100
        )
        
        # Duration should be A+D+R, not including sustain phase
        expected_duration = 5.0 + 10.0 + 15.0  # 30ms
        actual_duration = adsr.get_total_duration_ms()
        
        assert actual_duration == expected_duration, \
            f"Duration should be A+D+R: expected {expected_duration}ms, got {actual_duration}ms"


class TestConvenienceFunction:
    """Tests for apply_adsr convenience function."""
    
    def test_apply_adsr_function(self):
        """Verify apply_adsr convenience function works correctly."""
        audio = np.ones(4410, dtype=np.float32)
        
        enveloped = apply_adsr(
            audio=audio,
            attack_ms=10.0,
            decay_ms=20.0,
            sustain_level=0.5,
            release_ms=30.0,
            sample_rate=44100
        )
        
        assert len(enveloped) == len(audio)
        assert np.min(enveloped) >= 0.0
        assert np.max(enveloped) <= 1.0
    
    def test_apply_adsr_equivalent_to_class(self):
        """Verify apply_adsr produces same result as ADSREnvelope class."""
        audio = np.random.randn(2205).astype(np.float32) * 0.5
        
        # Using class
        adsr = ADSREnvelope(
            attack_ms=15.0,
            decay_ms=25.0,
            sustain_level=0.4,
            release_ms=35.0,
            sample_rate=44100
        )
        result_class = adsr.apply(audio)
        
        # Using convenience function
        result_function = apply_adsr(
            audio=audio,
            attack_ms=15.0,
            decay_ms=25.0,
            sustain_level=0.4,
            release_ms=35.0,
            sample_rate=44100
        )
        
        assert np.allclose(result_class, result_function), \
            "Convenience function should produce same result as class method"


class TestReprString:
    """Tests for string representation."""
    
    def test_repr_contains_parameters(self):
        """Verify __repr__ contains envelope parameters."""
        adsr = ADSREnvelope(
            attack_ms=10.0,
            decay_ms=20.0,
            sustain_level=0.5,
            release_ms=30.0,
            sample_rate=44100
        )
        
        repr_str = repr(adsr)
        
        assert "ADSREnvelope" in repr_str
        assert "10" in repr_str  # Attack
        assert "20" in repr_str  # Decay
        assert "0.5" in repr_str  # Sustain
        assert "30" in repr_str  # Release


class TestIntegrationWithWaveforms:
    """Integration tests with actual synthesized waveforms."""
    
    def test_pulse_sound_adsr(self):
        """Test ADSR envelope on pulse sound (fast attack, smooth release)."""
        # Simulate pulse sub-bass
        sample_rate = 44100
        duration = 0.2  # 200ms
        num_samples = int(duration * sample_rate)
        
        # Simple sine wave
        t = np.arange(num_samples) / sample_rate
        waveform = np.sin(2 * np.pi * 80.0 * t).astype(np.float32)
        
        # Apply pulse ADSR
        adsr = ADSREnvelope(
            attack_ms=7.0,
            decay_ms=50.0,
            sustain_level=0.25,
            release_ms=100.0,
            sample_rate=sample_rate
        )
        
        enveloped = adsr.apply(waveform)
        
        assert len(enveloped) == num_samples
        assert np.max(enveloped) > 0.2, "Pulse should have audible amplitude"
        assert enveloped[-1] < 0.05, "Pulse should fade to silence"
    
    def test_shard_sound_adsr(self):
        """Test ADSR envelope on shard sound (clear attack, exponential decay)."""
        # Simulate shard crystalline tone
        sample_rate = 44100
        duration = 0.2  # 200ms
        num_samples = int(duration * sample_rate)
        
        t = np.arange(num_samples) / sample_rate
        waveform = np.sin(2 * np.pi * 1200.0 * t).astype(np.float32)
        
        # Apply shard ADSR
        adsr = ADSREnvelope(
            attack_ms=5.0,
            decay_ms=150.0,  # Long decay for bell-like sound
            sustain_level=0.0,  # No sustain (percussive)
            release_ms=0.0,
            sample_rate=sample_rate
        )
        
        enveloped = adsr.apply(waveform)
        
        assert len(enveloped) == num_samples
        assert np.max(enveloped) > 0.8, "Shard should reach near peak"
        assert enveloped[-100] < 0.2, "Shard should decay significantly"
    
    def test_game_over_sound_adsr(self):
        """Test ADSR envelope on game over sound (gentle attack, long release)."""
        # Simulate game over tone
        sample_rate = 44100
        duration = 1.0  # 1000ms
        num_samples = int(duration * sample_rate)
        
        t = np.arange(num_samples) / sample_rate
        waveform = np.sin(2 * np.pi * 400.0 * t).astype(np.float32)
        
        # Apply game over ADSR
        adsr = ADSREnvelope(
            attack_ms=20.0,
            decay_ms=100.0,
            sustain_level=0.7,
            release_ms=250.0,
            sample_rate=sample_rate
        )
        
        enveloped = adsr.apply(waveform)
        
        assert len(enveloped) == num_samples
        assert enveloped[0] < 0.1, "Game over should start gently"
        assert np.max(enveloped) > 0.6, "Game over should have sustained body"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
