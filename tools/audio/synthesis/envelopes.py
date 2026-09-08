"""
Envelope Generation Module

Provides ADSR and other envelope functions for amplitude shaping.
Implements Task 2.2 - ADSR envelope processor with smooth transitions.
"""

import numpy as np


class ADSREnvelope:
    """
    ADSR (Attack-Decay-Sustain-Release) envelope generator.
    
    Creates smooth amplitude envelopes for shaping sound over time.
    Used for all 9 sounds with different timing requirements.
    
    Envelope stages:
    - Attack: Exponential rise from 0 to 1 (natural transient)
    - Decay: Logarithmic fall from 1 to sustain_level
    - Sustain: Constant amplitude during body
    - Release: Exponential decay to silence
    """
    
    def __init__(
        self,
        attack_ms: float,
        decay_ms: float,
        sustain_level: float,
        release_ms: float,
        sample_rate: int = 44100
    ):
        """
        Initialize ADSR envelope parameters.
        
        Args:
            attack_ms: Attack time in milliseconds (0-100ms typical)
            decay_ms: Decay time in milliseconds (0-200ms typical)
            sustain_level: Sustain amplitude level (0.0 to 1.0)
            release_ms: Release time in milliseconds (0-300ms typical)
            sample_rate: Sample rate in Hz (default: 44100)
        """
        self.attack_ms = attack_ms
        self.decay_ms = decay_ms
        self.sustain_level = max(0.0, min(1.0, sustain_level))  # Clamp to [0, 1]
        self.release_ms = release_ms
        self.sample_rate = sample_rate
        
        # Convert milliseconds to samples
        self.attack_samples = int(attack_ms * sample_rate / 1000)
        self.decay_samples = int(decay_ms * sample_rate / 1000)
        self.release_samples = int(release_ms * sample_rate / 1000)
    
    def apply(self, waveform: np.ndarray) -> np.ndarray:
        """
        Apply ADSR envelope to waveform.
        
        Args:
            waveform: Input audio waveform (numpy array)
        
        Returns:
            Waveform with ADSR envelope applied (same shape as input)
        """
        envelope = self._generate_envelope(len(waveform))
        return waveform * envelope
    
    def _generate_envelope(self, total_samples: int) -> np.ndarray:
        """
        Create ADSR envelope curve with smooth transitions.
        
        Args:
            total_samples: Total length of envelope in samples
        
        Returns:
            Numpy array containing envelope values (0.0 to 1.0)
        """
        envelope = np.zeros(total_samples, dtype=np.float32)
        
        # Calculate sustain duration (remaining time after A+D+R)
        sustain_samples = max(0, total_samples - self.attack_samples - self.decay_samples - self.release_samples)
        
        current_idx = 0
        
        # Attack phase: Exponential rise from 0 to 1
        if self.attack_samples > 0:
            attack_end = min(current_idx + self.attack_samples, total_samples)
            attack_length = attack_end - current_idx
            
            # Exponential curve: 1 - e^(-x) for natural transient (avoids click)
            t = np.linspace(0, 5, attack_length)  # 5 gives ~99% rise
            envelope[current_idx:attack_end] = 1.0 - np.exp(-t)
            current_idx = attack_end
        
        # Decay phase: Logarithmic fall from 1 to sustain_level
        if self.decay_samples > 0 and current_idx < total_samples:
            decay_end = min(current_idx + self.decay_samples, total_samples)
            decay_length = decay_end - current_idx
            
            if self.sustain_level < 1.0:
                # Logarithmic curve for natural decay
                t = np.linspace(0, 1, decay_length)
                # Interpolate from 1.0 to sustain_level using logarithmic curve
                decay_curve = np.exp(-3 * t)  # e^(-3t) gives smooth decay
                envelope[current_idx:decay_end] = self.sustain_level + (1.0 - self.sustain_level) * decay_curve
            else:
                # If sustain is 1.0, just hold at 1.0
                envelope[current_idx:decay_end] = 1.0
            
            current_idx = decay_end
        
        # Sustain phase: Hold constant amplitude
        if sustain_samples > 0 and current_idx < total_samples:
            sustain_end = min(current_idx + sustain_samples, total_samples)
            envelope[current_idx:sustain_end] = self.sustain_level
            current_idx = sustain_end
        
        # Release phase: Exponential decay to silence
        if self.release_samples > 0 and current_idx < total_samples:
            release_end = total_samples
            release_length = release_end - current_idx
            
            # Get starting amplitude (either sustain_level or current envelope value)
            start_amplitude = self.sustain_level if sustain_samples > 0 else (
                envelope[current_idx - 1] if current_idx > 0 else 1.0
            )
            
            # Exponential decay to zero for smooth tail
            t = np.linspace(0, 5, release_length)  # 5 gives ~99% decay
            envelope[current_idx:release_end] = start_amplitude * np.exp(-t)
        
        return envelope
    
    def get_total_duration_ms(self) -> float:
        """
        Calculate total envelope duration in milliseconds.
        
        Returns:
            Total duration in milliseconds
        """
        return self.attack_ms + self.decay_ms + self.release_ms
    
    def __repr__(self) -> str:
        """String representation for debugging."""
        return (f"ADSREnvelope(attack={self.attack_ms}ms, decay={self.decay_ms}ms, "
                f"sustain={self.sustain_level:.2f}, release={self.release_ms}ms)")


def apply_adsr(
    audio: np.ndarray,
    attack_ms: float,
    decay_ms: float,
    sustain_level: float,
    release_ms: float,
    sample_rate: int = 44100
) -> np.ndarray:
    """
    Convenience function to apply ADSR envelope to audio.
    
    This is a simpler interface that doesn't require creating an ADSREnvelope object.
    
    Args:
        audio: Input audio array
        attack_ms: Attack time in milliseconds
        decay_ms: Decay time in milliseconds
        sustain_level: Sustain amplitude level (0.0 to 1.0)
        release_ms: Release time in milliseconds
        sample_rate: Sample rate in Hz (default: 44100)
    
    Returns:
        Audio with ADSR envelope applied
    """
    envelope = ADSREnvelope(attack_ms, decay_ms, sustain_level, release_ms, sample_rate)
    return envelope.apply(audio)
