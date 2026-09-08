"""
Audio Effects Module

Provides audio processing effects like reverb, filters, and compression.
Implements Task 3.1 - Reverb and filter processors for professional SFX.
"""

import numpy as np
from scipy import signal
from typing import Optional


def apply_reverb_simple(
    waveform: np.ndarray,
    room_size: float = 0.5,
    damping: float = 0.5,
    wet_mix: float = 0.3,
    tail_ms: float = 200.0,
    sample_rate: int = 44100
) -> np.ndarray:
    """
    Apply Schroeder reverb using comb and allpass filters.
    
    Implements a classic algorithmic reverb based on Schroeder's 1962 design.
    Uses parallel comb filters for echo density and series allpass filters
    for diffusion, creating natural-sounding room reverberation.
    
    Used for: All sounds requiring spatial depth and character
    - Pulse: Short reverb (120ms) for subtle spatial depth
    - Wall Slam: Medium reverb (250ms) for stone room character  
    - Domino: Minimal reverb (60ms) for tight percussive
    - Altar Seal: Deep reverb (750ms) for void/cosmic character
    - Shard: Short reverb (70ms) for gentle sparkle
    - Combo: Subtle reverb (100ms) for melodic presence
    - Game Over: Long reverb (1000ms) for spacious, contemplative feel
    
    Args:
        waveform: Input audio array (float32, range -1.0 to 1.0)
        room_size: Room size parameter (0.0-1.0) - affects delay times
        damping: High-frequency damping (0.0-1.0) - 0=bright, 1=dark
        wet_mix: Wet/dry mix ratio (0.0-1.0) - 0=dry, 1=fully wet
        tail_ms: Reverb tail duration in milliseconds
        sample_rate: Sample rate in Hz (default: 44100)
    
    Returns:
        Audio with reverb applied (float32, range -1.0 to 1.0)
    """
    # Early exit for fully dry signal
    if wet_mix <= 0.0:
        return waveform.astype(np.float32)
    
    # Base delay times in milliseconds (Schroeder's original ratios)
    # These are prime-number related to avoid resonances
    base_comb_delays_ms = [29.7, 37.1, 41.1, 43.7]
    base_allpass_delays_ms = [5.0, 1.7]
    
    # Scale delays by room size (0.5 + 0.5*room_size gives range 0.5 to 1.0)
    room_scale = 0.5 + 0.5 * room_size
    comb_delays_ms = [d * room_scale for d in base_comb_delays_ms]
    allpass_delays_ms = [d * room_scale for d in base_allpass_delays_ms]
    
    # Calculate feedback coefficients based on tail_ms
    # RT60 formula: g = 10^(-3 * delay_time / RT60)
    rt60_seconds = tail_ms / 1000.0
    
    # Convert to sample delays
    comb_delays_samples = [int(d * sample_rate / 1000) for d in comb_delays_ms]
    allpass_delays_samples = [int(d * sample_rate / 1000) for d in allpass_delays_ms]
    
    # Initialize output
    reverb_output = np.zeros_like(waveform, dtype=np.float32)
    
    # Apply parallel comb filters
    for delay_samples in comb_delays_samples:
        if delay_samples < 1:
            continue
            
        # Calculate feedback gain for this delay time
        delay_time_sec = delay_samples / sample_rate
        feedback_gain = 10 ** (-3 * delay_time_sec / rt60_seconds)
        
        # Clamp feedback gain to stable range
        feedback_gain = min(feedback_gain, 0.95)
        
        # Damping coefficient (affects high frequencies in feedback)
        damping_coeff = 0.2 + damping * 0.6  # Range 0.2 to 0.8
        
        # Comb filter with circular buffer (more efficient)
        comb_output = np.zeros(len(waveform), dtype=np.float32)
        buffer = np.zeros(delay_samples, dtype=np.float32)
        buffer_idx = 0
        lowpass_state = 0.0
        
        for i in range(len(waveform)):
            # Read from circular buffer
            delayed_sample = buffer[buffer_idx]
            
            # Apply one-pole lowpass for damping
            lowpass_state = damping_coeff * lowpass_state + (1.0 - damping_coeff) * delayed_sample
            
            # Compute feedback
            feedback_sample = lowpass_state * feedback_gain
            
            # Write new sample to buffer (input + feedback)
            buffer[buffer_idx] = waveform[i] + feedback_sample
            
            # Output is delayed sample
            comb_output[i] = delayed_sample
            
            # Advance circular buffer index
            buffer_idx = (buffer_idx + 1) % delay_samples
        
        # Sum parallel comb outputs
        reverb_output += comb_output / len(comb_delays_samples)
    
    # Apply series allpass filters for diffusion
    allpass_input = reverb_output.copy()
    for delay_samples in allpass_delays_samples:
        if delay_samples < 1:
            continue
            
        # Allpass gain (typically 0.5 to 0.7)
        allpass_gain = 0.7
        
        # Allpass filter with circular buffer
        allpass_output = np.zeros(len(allpass_input), dtype=np.float32)
        buffer = np.zeros(delay_samples, dtype=np.float32)
        buffer_idx = 0
        
        for i in range(len(allpass_input)):
            # Read from circular buffer
            delayed_sample = buffer[buffer_idx]
            
            # Allpass formula: y[n] = -g*x[n] + x[n-D] + g*y[n-D]
            output_sample = -allpass_gain * allpass_input[i] + delayed_sample
            
            # Write to buffer
            buffer[buffer_idx] = allpass_input[i] + allpass_gain * output_sample
            
            allpass_output[i] = output_sample
            
            # Advance circular buffer index
            buffer_idx = (buffer_idx + 1) % delay_samples
        
        allpass_input = allpass_output
    
    reverb_output = allpass_input
    
    # Mix dry and wet signals
    output = (1.0 - wet_mix) * waveform + wet_mix * reverb_output
    
    # Normalize to prevent clipping
    peak = np.max(np.abs(output))
    if peak > 1.0:
        output = output / peak
    
    return output.astype(np.float32)


def apply_lowpass_filter(
    waveform: np.ndarray,
    cutoff_hz: float,
    order: int = 4,
    sample_rate: int = 44100
) -> np.ndarray:
    """
    Apply Butterworth lowpass filter for high-frequency roll-off.
    
    Used for: Taming harsh high frequencies and creating warmth
    
    Args:
        waveform: Input audio array (float32, range -1.0 to 1.0)
        cutoff_hz: Cutoff frequency in Hz (20-20000)
        order: Filter order (higher = steeper roll-off, default: 4)
        sample_rate: Sample rate in Hz (default: 44100)
    
    Returns:
        Filtered audio (float32, range -1.0 to 1.0)
    """
    # Normalize cutoff frequency to Nyquist frequency
    nyquist = sample_rate / 2.0
    normalized_cutoff = min(cutoff_hz / nyquist, 0.999)  # Prevent >= 1.0
    
    # Design Butterworth lowpass filter
    # Use second-order sections (sos) for numerical stability
    sos = signal.butter(order, normalized_cutoff, btype='low', output='sos')
    
    # Apply filter
    filtered = signal.sosfilt(sos, waveform)
    
    return filtered.astype(np.float32)


def apply_bandpass_filter(
    waveform: np.ndarray,
    freq_low_hz: float,
    freq_high_hz: float,
    order: int = 4,
    sample_rate: int = 44100
) -> np.ndarray:
    """
    Apply Butterworth bandpass filter to isolate frequency range.
    
    Used for: Creating specific tonal characters and filtering noise
    
    Args:
        waveform: Input audio array (float32, range -1.0 to 1.0)
        freq_low_hz: Low cutoff frequency in Hz (20-20000)
        freq_high_hz: High cutoff frequency in Hz (20-20000)
        order: Filter order (higher = steeper roll-off, default: 4)
        sample_rate: Sample rate in Hz (default: 44100)
    
    Returns:
        Filtered audio (float32, range -1.0 to 1.0)
    """
    # Normalize frequencies to Nyquist frequency
    nyquist = sample_rate / 2.0
    normalized_low = max(freq_low_hz / nyquist, 0.001)   # Prevent <= 0.0
    normalized_high = min(freq_high_hz / nyquist, 0.999)  # Prevent >= 1.0
    
    # Ensure low < high
    if normalized_low >= normalized_high:
        raise ValueError(f"freq_low_hz ({freq_low_hz}) must be less than freq_high_hz ({freq_high_hz})")
    
    # Design Butterworth bandpass filter
    # Use second-order sections (sos) for numerical stability
    sos = signal.butter(order, [normalized_low, normalized_high], btype='band', output='sos')
    
    # Apply filter
    filtered = signal.sosfilt(sos, waveform)
    
    return filtered.astype(np.float32)


def apply_highpass_filter(
    waveform: np.ndarray,
    cutoff_hz: float,
    order: int = 4,
    sample_rate: int = 44100
) -> np.ndarray:
    """
    Apply Butterworth highpass filter to remove low frequencies.
    
    Used for: Removing rumble and low-frequency mud
    
    Args:
        waveform: Input audio array (float32, range -1.0 to 1.0)
        cutoff_hz: Cutoff frequency in Hz (20-20000)
        order: Filter order (higher = steeper roll-off, default: 4)
        sample_rate: Sample rate in Hz (default: 44100)
    
    Returns:
        Filtered audio (float32, range -1.0 to 1.0)
    """
    # Normalize cutoff frequency to Nyquist frequency
    nyquist = sample_rate / 2.0
    normalized_cutoff = max(cutoff_hz / nyquist, 0.001)  # Prevent <= 0.0
    
    # Design Butterworth highpass filter
    # Use second-order sections (sos) for numerical stability
    sos = signal.butter(order, normalized_cutoff, btype='high', output='sos')
    
    # Apply filter
    filtered = signal.sosfilt(sos, waveform)
    
    return filtered.astype(np.float32)


def apply_compression(
    waveform: np.ndarray,
    threshold_db: float = -20.0,
    ratio: float = 3.0,
    attack_ms: float = 5.0,
    release_ms: float = 50.0,
    sample_rate: int = 44100
) -> np.ndarray:
    """
    Apply simple dynamic range compression for consistent loudness.
    
    Reduces the dynamic range by attenuating signals above the threshold.
    Uses gentle ratios (2:1 to 3:1) to preserve dynamics while ensuring
    consistent perceived loudness across all sounds.
    
    Used for: All sounds before final normalization
    
    Args:
        waveform: Input audio array (float32, range -1.0 to 1.0)
        threshold_db: Compression threshold in dB (e.g., -20.0)
        ratio: Compression ratio (e.g., 3.0 for 3:1 compression)
        attack_ms: Attack time in milliseconds (how quickly compression engages)
        release_ms: Release time in milliseconds (how quickly compression releases)
        sample_rate: Sample rate in Hz (default: 44100)
    
    Returns:
        Compressed audio (float32, range -1.0 to 1.0)
    """
    # Convert threshold from dB to linear amplitude
    threshold_linear = 10 ** (threshold_db / 20.0)
    
    # Convert attack/release times to coefficients
    # Lower coefficient = faster response
    attack_coeff = np.exp(-1.0 / (attack_ms * sample_rate / 1000.0))
    release_coeff = np.exp(-1.0 / (release_ms * sample_rate / 1000.0))
    
    # Initialize envelope follower state
    envelope = 0.0
    output = np.zeros_like(waveform, dtype=np.float32)
    
    for i in range(len(waveform)):
        # Get input sample amplitude
        input_amp = abs(waveform[i])
        
        # Envelope follower (peak detector with attack/release)
        if input_amp > envelope:
            # Attack (fast response to peaks)
            envelope = attack_coeff * envelope + (1.0 - attack_coeff) * input_amp
        else:
            # Release (slower decay)
            envelope = release_coeff * envelope + (1.0 - release_coeff) * input_amp
        
        # Calculate gain reduction
        if envelope > threshold_linear:
            # Above threshold: apply compression
            # Formula: output_level = threshold + (input_level - threshold) / ratio
            # In linear domain: gain = threshold / envelope * (envelope / threshold) ^ (1/ratio)
            # Simplified: gain = (threshold / envelope) ^ (1 - 1/ratio)
            gain_reduction = (threshold_linear / envelope) ** (1.0 - 1.0 / ratio)
        else:
            # Below threshold: no compression
            gain_reduction = 1.0
        
        # Apply gain reduction
        output[i] = waveform[i] * gain_reduction
    
    return output.astype(np.float32)


# Legacy compatibility wrappers for existing code
def apply_reverb(audio: np.ndarray, reverb_time_ms: float, sample_rate: int = 44100) -> np.ndarray:
    """
    Legacy wrapper for apply_reverb_simple with default parameters.
    
    Args:
        audio: Input audio array
        reverb_time_ms: Reverb time in milliseconds
        sample_rate: Sample rate in Hz (default: 44100)
    
    Returns:
        Audio with reverb applied
    """
    return apply_reverb_simple(
        audio,
        room_size=0.5,
        damping=0.5,
        wet_mix=0.3,
        tail_ms=reverb_time_ms,
        sample_rate=sample_rate
    )


def apply_lowpass(audio: np.ndarray, cutoff_freq: float, sample_rate: int = 44100) -> np.ndarray:
    """
    Legacy wrapper for apply_lowpass_filter with default order.
    
    Args:
        audio: Input audio array
        cutoff_freq: Cutoff frequency in Hz
        sample_rate: Sample rate in Hz (default: 44100)
    
    Returns:
        Filtered audio
    """
    return apply_lowpass_filter(audio, cutoff_freq, order=4, sample_rate=sample_rate)
