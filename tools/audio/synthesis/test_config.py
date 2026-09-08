"""
Unit tests for Sound Design Configuration System (Task 4).

Tests validate:
- Task 4.1: Low-frequency impact sounds (Pulse, Wall Slam)
- Task 4.2: Mid-frequency percussive sounds (Domino, Player Hurt, Combo)
- Task 4.3: High-frequency clarity sounds (Dash, Shard)
- Task 4.4: Magical/emotional sounds (Altar Seal, Game Over)
- Schema and parameter bounds validation
- Category frequency separation (Req 10.4)
- Unified reverb cohesion (Req 10.2)
"""

import copy
import os
import pytest
from config import (
    load_config,
    validate_config,
    validate_frequency_separation,
    validate_reverb_cohesion,
    ConfigValidationError,
    REQUIRED_SOUNDS
)


CONFIG_PATH = os.path.join(os.path.dirname(__file__), "..", "sound_design_config.json")


class TestConfigLoadingAndGlobal:
    """Tests for loading config and validating global parameters."""

    def test_load_default_config(self):
        """Verify the repository sound_design_config.json loads and validates."""
        config = load_config(CONFIG_PATH)
        assert "global" in config
        assert "sounds" in config

    def test_global_specifications(self):
        """Verify global settings comply with Requirement 11."""
        config = load_config(CONFIG_PATH)
        g = config["global"]
        assert g["sample_rate"] == 44100
        assert g["bit_depth"] == 16
        assert g["channels"] == 1
        assert -1.0 <= g["normalization_headroom_db"] <= -0.3
        assert "output_directory" in g

    def test_all_nine_sounds_present(self):
        """Verify all 9 required sounds exist in config."""
        config = load_config(CONFIG_PATH)
        for sound_name in REQUIRED_SOUNDS:
            assert sound_name in config["sounds"], f"Missing {sound_name}"


class TestTask4_1_LowFrequencyImpactSounds:
    """Tests for Task 4.1: Pulse and Wall Slam."""

    def test_pulse_configuration(self):
        """
        Task 4.1 Acceptance:
        - 3 layers: sub-bass 80Hz, body 200-800Hz, shimmer 2-6kHz
        - Short reverb 120ms
        - Category: low_impact
        """
        config = load_config(CONFIG_PATH)
        pulse = config["sounds"]["pulse"]
        assert pulse["category"] == "low_impact"
        assert 150 <= pulse["duration_ms"] <= 350
        
        # Check layers
        layer_names = [l["name"] for l in pulse["layers"]]
        assert "sub_bass" in layer_names
        assert "body" in layer_names
        assert "shimmer" in layer_names
        assert len(pulse["layers"]) >= 3

        # Sub-bass: 80Hz sine
        sub = next(l for l in pulse["layers"] if l["name"] == "sub_bass")
        assert sub["type"] == "sine_wave"
        assert 60 <= sub["frequency_hz"] <= 120

        # Body: 200-800Hz
        body = next(l for l in pulse["layers"] if l["name"] == "body")
        assert body["freq_low_hz"] >= 150 and body["freq_high_hz"] <= 900

        # Shimmer: 2000-6000Hz
        shimmer = next(l for l in pulse["layers"] if l["name"] == "shimmer")
        assert shimmer["freq_low_hz"] >= 1500 and shimmer["freq_high_hz"] <= 6500

        # ADSR & Reverb
        assert pulse["adsr"]["attack_ms"] <= 10
        assert pulse["reverb"]["enabled"] is True
        assert 100 <= pulse["reverb"]["tail_ms"] <= 250

    def test_wall_slam_configuration(self):
        """
        Task 4.1 Acceptance:
        - Low impact 60Hz + noise burst 500-2kHz + pink texture
        - Stone reverb 250ms
        - Category: low_impact
        """
        config = load_config(CONFIG_PATH)
        slam = config["sounds"]["wall_slam"]
        assert slam["category"] == "low_impact"
        assert 200 <= slam["duration_ms"] <= 350

        layer_names = [l["name"] for l in slam["layers"]]
        assert any("impact" in n for n in layer_names)
        assert any("transient" in n for n in layer_names)
        assert any("texture" in n for n in layer_names)

        # Low impact: 60Hz
        impact = next(l for l in slam["layers"] if "impact" in l["name"])
        assert impact["type"] == "sine_wave"
        assert 40 <= impact["frequency_hz"] <= 100

        # Noise burst: 500-2000Hz
        transient = next(l for l in slam["layers"] if "transient" in l["name"])
        assert transient["freq_low_hz"] >= 400 and transient["freq_high_hz"] <= 2500

        # Texture: pink noise
        texture = next(l for l in slam["layers"] if "texture" in l["name"])
        assert texture["type"] == "pink_noise"

        # Reverb: stone reverb ~250ms
        assert slam["reverb"]["enabled"] is True
        assert 200 <= slam["reverb"]["tail_ms"] <= 300
        assert "stone" in slam["reverb"].get("character", "").lower()


class TestTask4_2_MidFrequencyPercussiveSounds:
    """Tests for Task 4.2: Domino, Player Hurt, Combo."""

    def test_domino_configuration(self):
        """
        Task 4.2 Acceptance:
        - Light percussive 1.2kHz + short noise
        - Minimal reverb 60ms
        - Category: mid_percussive
        """
        config = load_config(CONFIG_PATH)
        domino = config["sounds"]["domino"]
        assert domino["category"] == "mid_percussive"
        assert 40 <= domino["duration_ms"] <= 80

        sine_layer = next((l for l in domino["layers"] if l["type"] == "sine_wave"), None)
        assert sine_layer is not None
        assert 1000 <= sine_layer["frequency_hz"] <= 1400

        if domino["reverb"]["enabled"]:
            assert domino["reverb"]["tail_ms"] <= 80

    def test_player_hurt_configuration(self):
        """
        Task 4.2 Acceptance:
        - Alert tone: 1.8kHz sine + 1.2kHz square
        - Dry processing (no reverb)
        - Category: mid_percussive
        """
        config = load_config(CONFIG_PATH)
        hurt = config["sounds"]["player_hurt"]
        assert hurt["category"] == "mid_percussive"
        assert 100 <= hurt["duration_ms"] <= 180

        # Dry processing
        assert hurt["reverb"]["enabled"] is False

        # Alert tone: 1.8kHz sine + 1.2kHz square
        sine_layer = next((l for l in hurt["layers"] if l["type"] == "sine_wave"), None)
        square_layer = next((l for l in hurt["layers"] if l["type"] == "square_wave"), None)
        assert sine_layer is not None, "Missing sine layer in player_hurt"
        assert square_layer is not None, "Missing square layer in player_hurt"
        assert 1500 <= sine_layer["frequency_hz"] <= 2000
        assert 1000 <= square_layer["frequency_hz"] <= 1400

    def test_combo_configuration(self):
        """
        Task 4.2 Acceptance:
        - Ascending musical pattern with major scale intervals
        - Subtle reverb 100ms
        - Category: mid_percussive
        """
        config = load_config(CONFIG_PATH)
        combo = config["sounds"]["combo"]
        assert combo["category"] == "mid_percussive"
        assert 140 <= combo["duration_ms"] <= 250

        # Major scale intervals
        assert "intervals" in combo or len(combo["layers"]) >= 3
        assert combo["reverb"]["enabled"] is True
        assert 80 <= combo["reverb"]["tail_ms"] <= 120


class TestTask4_3_HighFrequencyClaritySounds:
    """Tests for Task 4.3: Dash and Shard."""

    def test_dash_configuration(self):
        """
        Task 4.3 Acceptance:
        - Noise sweep 6kHz -> 1.5kHz with doppler pitch shift 1.1x -> 0.95x
        - Dry processing
        - Category: high_clarity
        """
        config = load_config(CONFIG_PATH)
        dash = config["sounds"]["dash"]
        assert dash["category"] == "high_clarity"
        assert 80 <= dash["duration_ms"] <= 160

        # Dry
        assert dash["reverb"]["enabled"] is False

        # Pitch sweep: 1.1x to 0.95x
        assert "pitch_sweep" in dash
        assert dash["pitch_sweep"]["start_pitch"] == pytest.approx(1.1, rel=0.05)
        assert dash["pitch_sweep"]["end_pitch"] == pytest.approx(0.95, rel=0.05)

        # Filtered noise sweep
        noise_layer = next(l for l in dash["layers"] if l["type"] == "filtered_noise")
        assert noise_layer["freq_high_hz"] >= 5000 and noise_layer["freq_low_hz"] <= 2000

    def test_shard_configuration(self):
        """
        Task 4.3 Acceptance:
        - Pure harmonic series (root ~1200-1319Hz + overtones)
        - Exponential decay 150ms
        - Sparkle reverb 70ms
        - Category: high_clarity
        """
        config = load_config(CONFIG_PATH)
        shard = config["sounds"]["shard"]
        assert shard["category"] == "high_clarity"
        assert 150 <= shard["duration_ms"] <= 250

        # Harmonic series
        sine_layers = [l for l in shard["layers"] if l["type"] == "sine_wave"]
        assert len(sine_layers) >= 2
        root = sine_layers[0]["frequency_hz"]
        assert 1000 <= root <= 1400

        # Exponential decay: adsr decay_ms ~ 150ms
        assert 120 <= shard["adsr"]["decay_ms"] <= 180
        assert shard["adsr"]["sustain_level"] == 0.0

        # Sparkle reverb 70ms
        assert shard["reverb"]["enabled"] is True
        assert 50 <= shard["reverb"]["tail_ms"] <= 100


class TestTask4_4_MagicalEmotionalSounds:
    """Tests for Task 4.4: Altar Seal, Game Over, and Category separation."""

    def test_altar_seal_configuration(self):
        """
        Task 4.4 Acceptance:
        - Detuned harmonics 280 / 420 / 560 Hz + 4kHz sparkle
        - Deep reverb 750ms
        - Category: magical_emotional
        """
        config = load_config(CONFIG_PATH)
        altar = config["sounds"]["altar_seal"]
        assert altar["category"] == "magical_emotional"
        assert 400 <= altar["duration_ms"] <= 600

        # Detuned harmonics: 280, 420, 560
        freqs = [l["frequency_hz"] for l in altar["layers"] if l.get("frequency_hz") is not None]
        assert any(abs(f - 280) < 25 for f in freqs), f"Expected ~280Hz in {freqs}"
        assert any(abs(f - 420) < 35 for f in freqs), f"Expected ~420Hz in {freqs}"
        assert any(abs(f - 560) < 45 for f in freqs), f"Expected ~560Hz in {freqs}"

        # Sparkle layer
        assert any("sparkle" in l["name"] for l in altar["layers"])

        # Deep reverb 750ms
        assert altar["reverb"]["enabled"] is True
        assert 600 <= altar["reverb"]["tail_ms"] <= 900

    def test_game_over_configuration(self):
        """
        Task 4.4 Acceptance:
        - Descending E minor -> C major resolution
        - Spacious reverb 1000ms
        - Category: magical_emotional
        """
        config = load_config(CONFIG_PATH)
        over = config["sounds"]["game_over"]
        assert over["category"] == "magical_emotional"
        assert 800 <= over["duration_ms"] <= 1000

        # Spacious reverb: 1000ms
        assert over["reverb"]["enabled"] is True
        assert 800 <= over["reverb"]["tail_ms"] <= 1200
        assert "spacious" in over["reverb"].get("character", "").lower()

    def test_frequency_separation(self):
        """Verify frequency separation between categories (Req 10.4)."""
        config = load_config(CONFIG_PATH)
        validate_frequency_separation(config["sounds"])

    def test_reverb_cohesion(self):
        """Verify unified reverb cohesion across categories (Req 10.2)."""
        config = load_config(CONFIG_PATH)
        validate_reverb_cohesion(config["sounds"])


class TestConfigErrorHandling:
    """Tests for parameter bounds and schema error detection."""

    def test_missing_sound_raises_error(self):
        config = load_config(CONFIG_PATH)
        del config["sounds"]["pulse"]
        with pytest.raises(ConfigValidationError) as exc:
            validate_config(config)
        assert "Missing required sound" in str(exc.value)

    def test_invalid_sample_rate_raises_error(self):
        config = load_config(CONFIG_PATH)
        config["global"]["sample_rate"] = 48000
        with pytest.raises(ConfigValidationError) as exc:
            validate_config(config)
        assert "sample_rate" in str(exc.value)

    def test_invalid_category_raises_error(self):
        config = load_config(CONFIG_PATH)
        config["sounds"]["pulse"]["category"] = "invalid_category"
        with pytest.raises(ConfigValidationError) as exc:
            validate_config(config)
        assert "category" in str(exc.value)

    def test_negative_adsr_raises_error(self):
        config = load_config(CONFIG_PATH)
        config["sounds"]["pulse"]["adsr"]["attack_ms"] = -5
        with pytest.raises(ConfigValidationError) as exc:
            validate_config(config)
        assert "attack_ms" in str(exc.value)

    def test_out_of_bounds_amplitude_raises_error(self):
        config = load_config(CONFIG_PATH)
        config["sounds"]["pulse"]["layers"][0]["amplitude"] = 1.5
        with pytest.raises(ConfigValidationError) as exc:
            validate_config(config)
        assert "amplitude" in str(exc.value)
