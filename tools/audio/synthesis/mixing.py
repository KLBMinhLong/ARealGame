"""
Audio Mixing Module

Provides multi-layer mixing, normalization, and final output processing.
Implements Task 3.2 - Layer mixing, peak normalization, and silence trimming.
"""

import numpy as np
from typing import List, Optional


def mix_layers(
    layers: List[np.ndarray], 
    levels: Optional[List[float]] = None
) -> np.ndarray:
    """
    Mix multiple audio layers together with optional level control.
    
    Used for: Combining multiple synthesis layers (e.g., pulse has 3 layers: 
    sub-bass, body, shimmer) into final composite sound.
    
    Args:
        layers: List of audio arrays to mix (must all have same length)
        levels: Optional list of level multipliers for each layer (0.0-1.0).
                If None, all layers mixed at unity gain (1.0).
    
    Returns:
        Mixed audio array (float32, range depends on input levels)
    
    Raises:
        ValueError: If layers have different lengths or levels count mismatch
    """
    if not layers:
        raise ValueError("Cannot mix empty layer list")
    
    # Validate all layers have same length
    layer_length = len(layers[0])
    for i, layer in enumerate(layers):
        if len(layer) != layer_length:
            raise ValueError(
                f"Layer {i} has length {len(layer)}, expected {layer_length}. "
                f"All layers must have same length for mixing."
            )
    
    # Default to unity gain if levels not provided
    if levels is None:
        levels = [1.0] * len(layers)
    
    # Validate levels count matches layers count
    if len(levels) != len(layers):
        raise ValueError(
            f"Number of levels ({len(levels)}) must match number of layers ({len(layers)})"
        )
    
    # Initialize output with zeros
    mixed = np.zeros(layer_length, dtype=np.float32)
    
    # Sum all layers with amplitude control
    for layer, level in zip(layers, levels):
        mixed += layer.astype(np.float32) * level
    
    return mixed


def normalize_audio(
    audio: np.ndarray, 
    target_peak_db: float = -0.5
) -> np.ndarray:
    """
    Normalize audio peak amplitude to target dB level.
    
    Used for: Ensuring all sounds reach target levels without clipping.
    Target range: -0.3dB to -1.0dB for maximum quality with safety headroom.
    
    Args:
        audio: Input audio array (float32)
        target_peak_db: Target peak level in dB (default: -0.5dB)
                       Typical range: -1.0 to -0.3 dB
    
    Returns:
        Normalized audio (float32, peak at target_peak_db)
    """
    # Find current peak amplitude
    peak_amplitude = np.max(np.abs(audio))
    
    # Early exit if audio is silent
    if peak_amplitude == 0:
        return audio.astype(np.float32)
    
    # Convert target dB to linear amplitude
    # Formula: amplitude = 10^(dB / 20)
    target_amplitude = 10 ** (target_peak_db / 20.0)
    
    # Calculate gain needed to reach target
    gain = target_amplitude / peak_amplitude
    
    # Apply gain
    normalized = audio * gain
    
    return normalized.astype(np.float32)


def trim_silence(
    audio: np.ndarray,
    threshold_db: float = -60.0,
    sample_rate: int = 44100
) -> np.ndarray:
    """
    Remove leading and trailing silence below threshold.
    
    Used for: Clean sound starts and natural decay ends. Removes silence 
    below -60dB threshold for tight attack transients and natural release tails.
    
    Args:
        audio: Input audio array (float32)
        threshold_db: Silence threshold in dB (default: -60.0dB)
        sample_rate: Sample rate in Hz (default: 44100)
    
    Returns:
        Trimmed audio array with leading/trailing silence removed (float32)
    """
    # Convert threshold from dB to linear amplitude
    # Formula: amplitude = 10^(dB / 20)
    threshold_amplitude = 10 ** (threshold_db / 20.0)
    
    # Find samples above threshold
    above_threshold = np.abs(audio) > threshold_amplitude
    
    # Early exit if entire audio is below threshold (silent)
    if not np.any(above_threshold):
        # Return minimal audio (single zero sample) to avoid empty arrays
        return np.array([0.0], dtype=np.float32)
    
    # Find first and last sample above threshold
    nonsilent_indices = np.where(above_threshold)[0]
    start_idx = nonsilent_indices[0]
    end_idx = nonsilent_indices[-1] + 1  # +1 to include the last sample
    
    # Trim to non-silent region
    trimmed = audio[start_idx:end_idx]
    
    return trimmed.astype(np.float32)
