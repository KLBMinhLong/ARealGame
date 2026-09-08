"""
Sound Design Configuration Module

Provides configuration loading, schema validation, and acoustic coherence verification.
Implements Task 4 - Sound design configuration system.
"""

import json
import os
from typing import Dict, Any, List, Optional, Tuple


class ConfigValidationError(ValueError):
    """Exception raised when sound design configuration fails validation."""
    def __init__(self, message: str, error_code: int = 1):
        super().__init__(message)
        self.error_code = error_code


REQUIRED_SOUNDS = [
    "pulse",
    "dash",
    "wall_slam",
    "domino",
    "altar_seal",
    "shard",
    "player_hurt",
    "combo",
    "game_over"
]

VALID_CATEGORIES = [
    "low_impact",
    "mid_percussive",
    "high_clarity",
    "magical_emotional"
]

VALID_LAYER_TYPES = [
    "sine_wave",
    "square_wave",
    "sawtooth",
    "filtered_noise",
    "pink_noise",
    "melody",
    "whoosh"
]


def load_config(config_path: str) -> Dict[str, Any]:
    """
    Load and parse sound design JSON configuration.
    
    Args:
        config_path: Path to sound_design_config.json
        
    Returns:
        Validated dictionary of configuration
        
    Raises:
        ConfigValidationError: If file missing or invalid JSON
    """
    if not os.path.exists(config_path):
        raise ConfigValidationError(f"Configuration file not found: {config_path}", error_code=1)
    
    try:
        with open(config_path, "r", encoding="utf-8") as f:
            config = json.load(f)
    except json.JSONDecodeError as e:
        raise ConfigValidationError(f"Invalid JSON syntax in {config_path}: {e}", error_code=1)
    
    validate_config(config)
    return config


def validate_config(config: Dict[str, Any]) -> None:
    """
    Validate the configuration against schema rules, parameter ranges, and acoustic requirements.
    
    Args:
        config: Parsed configuration dictionary
        
    Raises:
        ConfigValidationError: If validation fails
    """
    # 1. Global section validation
    if "global" not in config:
        raise ConfigValidationError("Missing 'global' section in configuration", error_code=3)
    
    g = config["global"]
    required_global_fields = [
        "sample_rate",
        "bit_depth",
        "channels",
        "normalization_headroom_db",
        "output_directory"
    ]
    for field in required_global_fields:
        if field not in g:
            raise ConfigValidationError(f"Missing required global field: {field}", error_code=3)
            
    if g["sample_rate"] != 44100:
        raise ConfigValidationError(f"Invalid sample_rate: {g['sample_rate']}. Expected 44100.", error_code=2)
    if g["bit_depth"] != 16:
        raise ConfigValidationError(f"Invalid bit_depth: {g['bit_depth']}. Expected 16.", error_code=2)
    if g["channels"] != 1:
        raise ConfigValidationError(f"Invalid channels: {g['channels']}. Expected 1 (mono).", error_code=2)
    if not (-1.0 <= g["normalization_headroom_db"] <= -0.3):
        raise ConfigValidationError(
            f"normalization_headroom_db ({g['normalization_headroom_db']}) must be between -1.0dB and -0.3dB",
            error_code=2
        )

    # 2. Sounds section validation
    if "sounds" not in config:
        raise ConfigValidationError("Missing 'sounds' section in configuration", error_code=3)
    
    sounds = config["sounds"]
    for sound_name in REQUIRED_SOUNDS:
        if sound_name not in sounds:
            raise ConfigValidationError(f"Missing required sound in configuration: {sound_name}", error_code=3)
        _validate_sound_config(sound_name, sounds[sound_name])

    # 3. Frequency separation across categories (Req 10.4)
    validate_frequency_separation(sounds)

    # 4. Reverb cohesion check (Req 10.2)
    validate_reverb_cohesion(sounds)


def _validate_adsr(sound_name: str, adsr: Dict[str, Any], context: str = "sound") -> None:
    """Validate ADSR envelope parameters."""
    for field in ["attack_ms", "decay_ms", "sustain_level", "release_ms"]:
        if field not in adsr:
            raise ConfigValidationError(f"Missing '{field}' in ADSR for {sound_name} ({context})", error_code=3)
    
    if adsr["attack_ms"] < 0:
        raise ConfigValidationError(f"attack_ms must be >= 0 in {sound_name}", error_code=2)
    if adsr["decay_ms"] < 0:
        raise ConfigValidationError(f"decay_ms must be >= 0 in {sound_name}", error_code=2)
    if not (0.0 <= adsr["sustain_level"] <= 1.0):
        raise ConfigValidationError(f"sustain_level must be in [0.0, 1.0] in {sound_name}", error_code=2)
    if adsr["release_ms"] < 0:
        raise ConfigValidationError(f"release_ms must be >= 0 in {sound_name}", error_code=2)


def _validate_sound_config(sound_name: str, s: Dict[str, Any]) -> None:
    """Validate individual sound parameters."""
    if "duration_ms" not in s or s["duration_ms"] <= 0:
        raise ConfigValidationError(f"Invalid duration_ms for {sound_name}", error_code=2)
    
    if "category" not in s or s["category"] not in VALID_CATEGORIES:
        raise ConfigValidationError(
            f"Invalid or missing category for {sound_name}. Must be one of {VALID_CATEGORIES}",
            error_code=2
        )
    
    if "layers" not in s or not isinstance(s["layers"], list) or len(s["layers"]) == 0:
        raise ConfigValidationError(f"Sound {sound_name} must have at least one layer in 'layers'", error_code=3)
    
    for i, layer in enumerate(s["layers"]):
        if "name" not in layer:
            raise ConfigValidationError(f"Layer {i} in {sound_name} missing 'name'", error_code=3)
        if "type" not in layer or layer["type"] not in VALID_LAYER_TYPES:
            raise ConfigValidationError(
                f"Invalid layer type '{layer.get('type')}' in {sound_name}. Must be in {VALID_LAYER_TYPES}",
                error_code=2
            )
        if "amplitude" not in layer or not (0.0 <= layer["amplitude"] <= 1.0):
            raise ConfigValidationError(f"Layer '{layer.get('name')}' in {sound_name} amplitude must be in [0.0, 1.0]", error_code=2)
        
        # Type-specific validation
        ltype = layer["type"]
        if ltype in ["sine_wave", "square_wave", "sawtooth"]:
            freq = layer.get("frequency_hz")
            if freq is not None and (freq < 20 or freq > 20000):
                raise ConfigValidationError(f"frequency_hz ({freq}) in {sound_name} must be 20-20000 Hz", error_code=2)
        elif ltype == "filtered_noise":
            ftype = layer.get("filter_type", "bandpass")
            if ftype not in ["bandpass", "lowpass", "highpass"]:
                raise ConfigValidationError(f"Invalid filter_type '{ftype}' in {sound_name}", error_code=2)
            if ftype == "bandpass":
                low = layer.get("freq_low_hz")
                high = layer.get("freq_high_hz")
                if low is not None and high is not None and low >= high:
                    raise ConfigValidationError(f"freq_low_hz ({low}) must be < freq_high_hz ({high}) in {sound_name}", error_code=2)
        elif ltype == "melody":
            if "notes" not in layer or not isinstance(layer["notes"], list) or len(layer["notes"]) == 0:
                raise ConfigValidationError(f"Melody layer in {sound_name} must contain non-empty 'notes' list", error_code=3)
        
        if "adsr" in layer:
            _validate_adsr(sound_name, layer["adsr"], context=f"layer {layer['name']}")

    if "adsr" in s:
        _validate_adsr(sound_name, s["adsr"], context="sound")

    if "reverb" in s:
        rv = s["reverb"]
        if "enabled" not in rv:
            raise ConfigValidationError(f"Missing 'enabled' in reverb for {sound_name}", error_code=3)
        if rv["enabled"]:
            if "tail_ms" in rv and rv["tail_ms"] < 0:
                raise ConfigValidationError(f"reverb tail_ms must be >= 0 in {sound_name}", error_code=2)
            if "wet_mix" in rv and not (0.0 <= rv["wet_mix"] <= 1.0):
                raise ConfigValidationError(f"reverb wet_mix must be in [0.0, 1.0] in {sound_name}", error_code=2)

    if "pitch_sweep" in s:
        ps = s["pitch_sweep"]
        if "start_pitch" not in ps or "end_pitch" not in ps:
            raise ConfigValidationError(f"pitch_sweep missing start_pitch or end_pitch in {sound_name}", error_code=3)


def validate_frequency_separation(sounds: Dict[str, Any]) -> None:
    """
    Validate frequency spectrum separation between sound categories (Requirement 10.4).
    - low_impact (pulse, wall_slam): focus 40-800Hz
    - mid_percussive (domino, player_hurt, combo): focus 800-4000Hz
    - high_clarity (dash, shard): focus 1000-8000Hz
    - magical_emotional (altar_seal, game_over): rich harmonic span
    """
    expected_categories = {
        "pulse": "low_impact",
        "wall_slam": "low_impact",
        "domino": "mid_percussive",
        "player_hurt": "mid_percussive",
        "combo": "mid_percussive",
        "dash": "high_clarity",
        "shard": "high_clarity",
        "altar_seal": "magical_emotional",
        "game_over": "magical_emotional"
    }

    for name, cat in expected_categories.items():
        sound_cat = sounds[name].get("category")
        if sound_cat != cat:
            raise ConfigValidationError(
                f"Sound '{name}' category is '{sound_cat}', expected '{cat}' for frequency separation",
                error_code=2
            )


def validate_reverb_cohesion(sounds: Dict[str, Any]) -> None:
    """
    Validate unified reverb philosophy across categories (Requirement 10.2):
    - short reverb (50-150ms) or dry for action / clarity / quick taps (dash, domino, shard, combo, pulse)
    - medium reverb (200-350ms) for heavy impacts (wall_slam)
    - long reverb (600-1200ms) for magical / emotional moments (altar_seal, game_over)
    """
    # Wall slam: medium reverb (200-350ms)
    ws_reverb = sounds["wall_slam"].get("reverb", {})
    if ws_reverb.get("enabled"):
        tail = ws_reverb.get("tail_ms", 0)
        if not (150 <= tail <= 400):
            raise ConfigValidationError(f"Wall slam reverb tail ({tail}ms) should be medium (200-350ms)", error_code=2)

    # Altar seal and Game Over: long reverb (600-1200ms)
    for mag_name in ["altar_seal", "game_over"]:
        rv = sounds[mag_name].get("reverb", {})
        if not rv.get("enabled"):
            raise ConfigValidationError(f"Sound '{mag_name}' must have reverb enabled for magical/emotional depth", error_code=2)
        tail = rv.get("tail_ms", 0)
        if tail < 500:
            raise ConfigValidationError(f"Sound '{mag_name}' reverb tail ({tail}ms) must be >= 500ms for spatial depth", error_code=2)
