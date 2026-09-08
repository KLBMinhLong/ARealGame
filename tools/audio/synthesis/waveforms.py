"""
Waveform Generation Module

Provides basic waveform synthesis functions for sound generation.
Implements Task 2.1 - Basic waveform generators for professional SFX.
"""

import numpy as np
from scipy import signal


def generate_sine_wave(frequency: float, duration: float, sample_rate: int) -> np.ndarray:
    """
    Generate a pure sine wave.
    
    Used for: pulse sub-bass, altar seal harmonics, shard bell tones, combo musical notes
    
    Args:
        frequency: Frequency in Hz (20-20000)
        duration: Duration in seconds
        sample_rate: Sample rate in Hz (typically 44100)
    
    Returns:
        numpy array of audio samples (float32, range -1.0 to 1.0)
    """
    num_samples = int(duration * sample_rate)
    t = np.arange(num_samples) / sample_rate
    waveform = np.sin(2 * np.pi * frequency * t).astype(np.float32)
    return waveform


def generate_square_wave(frequency: float, duration: float, sample_rate: int) -> np.ndarray:
    """
    Generate a square wave.
    
    Used for: player hurt alert tone (sharp synthetic harmonic character)
    
    Args:
        frequency: Frequency in Hz (20-20000)
        duration: Duration in seconds
        sample_rate: Sample rate in Hz (typically 44100)
    
    Returns:
        numpy array of audio samples (float32, range -1.0 to 1.0)
    """
    num_samples = int(duration * sample_rate)
    t = np.arange(num_samples) / sample_rate
    waveform = signal.square(2 * np.pi * frequency * t).astype(np.float32)
    return waveform


def generate_sawtooth_wave(frequency: float, duration: float, sample_rate: int) -> np.ndarray:
    """
    Generate a sawtooth wave.
    
    Used for: harmonic-rich tonal layers
    
    Args:
        frequency: Frequency in Hz (20-20000)
        duration: Duration in seconds
        sample_rate: Sample rate in Hz (typically 44100)
    
    Returns:
        numpy array of audio samples (float32, range -1.0 to 1.0)
    """
    num_samples = int(duration * sample_rate)
    t = np.arange(num_samples) / sample_rate
    waveform = signal.sawtooth(2 * np.pi * frequency * t).astype(np.float32)
    return waveform


def generate_filtered_noise(
    freq_low: float,
    freq_high: float,
    duration: float,
    filter_type: str,
    sample_rate: int
) -> np.ndarray:
    """
    Generate bandpass/lowpass/highpass filtered white noise.
    
    Used for: pulse shimmer, dash whoosh, wall slam texture, domino tap
    
    Args:
        freq_low: Low frequency cutoff in Hz
        freq_high: High frequency cutoff in Hz
        duration: Duration in seconds
        filter_type: Filter type - 'bandpass', 'lowpass', or 'highpass'
        sample_rate: Sample rate in Hz (typically 44100)
    
    Returns:
        numpy array of audio samples (float32, range -1.0 to 1.0)
    """
    num_samples = int(duration * sample_rate)
    
    # Generate white noise
    noise = np.random.randn(num_samples).astype(np.float32)
    
    # Normalize frequencies to Nyquist frequency
    nyquist = sample_rate / 2.0
    
    # Design and apply Butterworth filter
    if filter_type == 'bandpass':
        # Bandpass: use both freq_low and freq_high
        low_norm = max(freq_low / nyquist, 0.001)  # Avoid 0
        high_norm = min(freq_high / nyquist, 0.999)  # Avoid 1
        sos = signal.butter(4, [low_norm, high_norm], btype='band', output='sos')
    elif filter_type == 'lowpass':
        # Lowpass: use freq_high as cutoff
        high_norm = min(freq_high / nyquist, 0.999)
        sos = signal.butter(4, high_norm, btype='low', output='sos')
    elif filter_type == 'highpass':
        # Highpass: use freq_low as cutoff
        low_norm = max(freq_low / nyquist, 0.001)
        sos = signal.butter(4, low_norm, btype='high', output='sos')
    else:
        raise ValueError(f"Invalid filter_type: {filter_type}. Must be 'bandpass', 'lowpass', or 'highpass'")
    
    # Apply filter using second-order sections for stability
    filtered = signal.sosfilt(sos, noise)
    
    # Normalize to -1.0 to 1.0 range
    peak = np.max(np.abs(filtered))
    if peak > 0:
        filtered = filtered / peak
    
    return filtered.astype(np.float32)


def generate_pink_noise(duration: float, sample_rate: int) -> np.ndarray:
    """
    Generate 1/f pink noise for natural texture.
    
    Used for: wall slam stone texture layer
    
    Pink noise has equal energy per octave (unlike white noise which has equal energy per Hz).
    This creates a more natural, less harsh sound suitable for texture layers.
    
    Args:
        duration: Duration in seconds
        sample_rate: Sample rate in Hz (typically 44100)
    
    Returns:
        numpy array of audio samples (float32, range -1.0 to 1.0)
    """
    num_samples = int(duration * sample_rate)
    
    # Voss-McCartney algorithm for pink noise generation
    # Uses multiple octave generators with random walks
    num_rows = 16
    array = np.random.randn(num_rows, num_samples)
    
    # Apply cumulative sum to create 1/f characteristic
    pink = np.zeros(num_samples)
    for i in range(num_rows):
        # Each row is updated at different rates (powers of 2)
        # This creates the 1/f spectral characteristic
        downsample_factor = 2 ** i
        if downsample_factor < num_samples:
            updates = num_samples // downsample_factor
            # Create repeated signal and ensure it matches num_samples exactly
            row_signal = np.repeat(array[i, :updates], downsample_factor)
            # Pad or trim to exact length
            if len(row_signal) < num_samples:
                row_signal = np.pad(row_signal, (0, num_samples - len(row_signal)), mode='edge')
            elif len(row_signal) > num_samples:
                row_signal = row_signal[:num_samples]
            pink += row_signal
    
    # Normalize to -1.0 to 1.0 range
    peak = np.max(np.abs(pink))
    if peak > 0:
        pink = pink / peak
    
    return pink.astype(np.float32)


def apply_frequency_sweep(
    waveform: np.ndarray,
    start_pitch: float,
    end_pitch: float,
    sample_rate: int
) -> np.ndarray:
    """
    Apply pitch modulation over time (doppler-like effects).
    
    Used for: dash movement perception
    
    Args:
        waveform: Input waveform to modulate
        start_pitch: Starting pitch multiplier (e.g., 1.1 for 10% higher)
        end_pitch: Ending pitch multiplier (e.g., 0.95 for 5% lower)
        sample_rate: Sample rate in Hz (typically 44100)
    
    Returns:
        numpy array of pitch-modulated audio samples (float32, range -1.0 to 1.0)
    """
    num_samples = len(waveform)
    
    # Create pitch envelope from start to end
    pitch_curve = np.linspace(start_pitch, end_pitch, num_samples)
    
    # Create time-varying sample position for resampling
    # Integration of pitch curve gives the phase accumulation
    sample_positions = np.cumsum(pitch_curve)
    
    # Normalize to original length range
    sample_positions = sample_positions * (num_samples - 1) / sample_positions[-1]
    
    # Interpolate waveform at new sample positions
    original_positions = np.arange(num_samples)
    swept_waveform = np.interp(sample_positions, original_positions, waveform)
    
    return swept_waveform.astype(np.float32)


def generate_pitch_drop_sine(
    start_freq: float,
    end_freq: float,
    duration: float,
    sample_rate: int,
    drop_rate: float = 8.0
) -> np.ndarray:
    """
    Generate a sine wave with exponential pitch drop for powerful, warm bass impact.
    Phase integral formulation ensures smooth continuous phase without click or artifact.
    
    Args:
        start_freq: Initial frequency in Hz
        end_freq: Settled frequency in Hz
        duration: Duration in seconds
        sample_rate: Sample rate in Hz
        drop_rate: Exponential rate of pitch falloff
        
    Returns:
        Float32 audio array
    """
    num_samples = int(duration * sample_rate)
    t = np.arange(num_samples) / sample_rate
    if drop_rate <= 0.0:
        phase = 2.0 * np.pi * start_freq * t
    else:
        phase = 2.0 * np.pi * (end_freq * t - ((start_freq - end_freq) / drop_rate) * (np.exp(-drop_rate * t) - 1.0))
    waveform = np.sin(phase).astype(np.float32)
    return waveform


def generate_melody(
    notes: list,
    duration: float,
    sample_rate: int
) -> np.ndarray:
    """
    Generate a sequence of musical notes with warm harmonic tones and smooth envelopes.
    Used for Game Over melodic motifs and ascending/descending musical phrases.
    
    Args:
        notes: List of note dicts with frequency_hz/freq_hz, start_ms, duration_ms, amplitude
        duration: Total duration in seconds
        sample_rate: Sample rate in Hz
        
    Returns:
        Float32 audio array
    """
    total_samples = int(duration * sample_rate)
    output = np.zeros(total_samples, dtype=np.float32)

    for note in notes:
        freq = float(note.get("freq_hz", note.get("frequency_hz", 440.0)))
        start_ms = float(note.get("start_ms", 0.0))
        dur_ms = float(note.get("duration_ms", 200.0))
        amp = float(note.get("amplitude", 0.7))

        start_s = int(start_ms * sample_rate / 1000.0)
        dur_s = int(dur_ms * sample_rate / 1000.0)
        end_s = min(total_samples, start_s + dur_s)
        actual_dur = end_s - start_s
        if actual_dur <= 0:
            continue

        t = np.arange(actual_dur) / sample_rate
        # Warm, musical timbre: fundamental + subtle 2nd harmonic
        tone = 0.78 * np.sin(2 * np.pi * freq * t) + 0.22 * np.sin(2 * np.pi * (2 * freq) * t)

        # Smooth envelope (attack 15ms, exponential decay)
        attack_s = min(int(0.015 * sample_rate), actual_dur)
        env = np.ones(actual_dur, dtype=np.float32)
        if attack_s > 0:
            env[:attack_s] = np.linspace(0.0, 1.0, attack_s)
        decay_samples = actual_dur - attack_s
        if decay_samples > 0:
            env[attack_s:] = np.exp(-3.2 * (np.arange(decay_samples) / decay_samples))

        output[start_s:end_s] += (tone * env * amp).astype(np.float32)

    peak = np.max(np.abs(output))
    if peak > 1.0:
        output = output / peak

    return output.astype(np.float32)


def generate_resonant_whoosh(
    duration: float,
    start_freq: float = 420.0,
    peak_freq: float = 1750.0,
    end_freq: float = 260.0,
    resonance_q: float = 2.4,
    peak_ratio: float = 0.25,
    sample_rate: int = 44100
) -> np.ndarray:
    """
    Generate an authentic 'vù, vụt qua' aerodynamic whoosh using a dynamic
    Doppler resonant state-variable bandpass sweep over pink noise.
    
    Args:
        duration: Duration in seconds
        start_freq: Initial swell center frequency in Hz (typically ~400-500Hz)
        peak_freq: Peak center frequency when whoosh passes (typically ~1600-2000Hz)
        end_freq: Ending center frequency as air dissipates (typically ~250-320Hz)
        resonance_q: Filter resonance quality factor (higher = more distinct whoosh formant)
        peak_ratio: Position in duration where peak frequency and velocity occur (0.0-1.0)
        sample_rate: Sample rate in Hz
        
    Returns:
        Float32 audio array
    """
    num_samples = int(duration * sample_rate)
    if num_samples <= 0:
        return np.zeros(1, dtype=np.float32)

    t = np.arange(num_samples) / sample_rate

    # Generate soft pink noise base for silky, non-harsh wind texture
    white = np.random.randn(num_samples).astype(np.float32)
    b, a = signal.butter(1, 0.06, btype='low')
    pink = signal.lfilter(b, a, white).astype(np.float32)

    # Dynamic Doppler aerodynamic frequency sweep trajectory
    t_peak = max(0.015, duration * peak_ratio)
    freqs = np.zeros(num_samples, dtype=np.float32)
    for i in range(num_samples):
        if t[i] < t_peak:
            # Swell up into the peak velocity
            ratio = t[i] / t_peak
            freqs[i] = start_freq + (peak_freq - start_freq) * ratio
        else:
            # Swoosh down as air turbulence dissipates behind
            rel = (t[i] - t_peak) / max(1e-5, duration - t_peak)
            freqs[i] = end_freq + (peak_freq - end_freq) * np.exp(-3.8 * rel)

    # Chamberlin digital state-variable resonant bandpass filter
    output = np.zeros(num_samples, dtype=np.float32)
    low, band = 0.0, 0.0
    damping = 1.0 / max(0.1, resonance_q)

    for i in range(num_samples):
        f = max(50.0, min(float(freqs[i]), sample_rate * 0.45))
        omega = 2.0 * np.sin(np.pi * f / sample_rate)
        omega = min(0.95, omega)

        high = pink[i] - low - damping * band
        band += omega * high
        low += omega * band
        output[i] = band

    # Smooth aerodynamic envelope: soft swell into peak, natural aerodynamic roll-off
    env = np.zeros(num_samples, dtype=np.float32)
    attack_samples = max(1, int(t_peak * sample_rate))
    env[:attack_samples] = np.sin(np.linspace(0.0, np.pi * 0.5, attack_samples)) ** 2
    decay_samples = num_samples - attack_samples
    if decay_samples > 0:
        env[attack_samples:] = np.cos(np.linspace(0.0, np.pi * 0.5, decay_samples)) ** 1.8

    output = output * env
    peak = np.max(np.abs(output))
    if peak > 0:
        output = output / peak

    return output.astype(np.float32)

