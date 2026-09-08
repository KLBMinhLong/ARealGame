# Implementation Plan: Professional SFX Redesign

## Overview

This feature replaces Stone Knight's 9 existing sound effect files with professionally designed audio using an offline Python-based sound generation tool. The implementation focuses on creating a configurable synthesis system that produces high-quality WAV files meeting technical specifications (16-bit, 44.1kHz mono) and aesthetic goals (cohesive, clear, pleasant). No game code or SoundManager changes are required—only asset replacement.

**Key Approach:**
- Offline Python tooling for reproducible sound generation
- Config-driven synthesis with layering, ADSR envelopes, and effects
- Pure asset replacement maintaining existing audio system integration

## Tasks

- [x] 1. Set up Python sound generation environment and project structure
  - Create `tools/audio/` directory with synthesis modules
  - Install required dependencies: numpy, scipy, pydub, librosa
  - Create project structure with subdirectories for synthesis components
  - _Requirements: 12.1, 12.6_

- [x] 2. Implement core waveform synthesis engine
  - [x] 2.1 Implement basic waveform generators
    - Create `synthesis/waveforms.py` with sine, filtered noise, pink noise generation functions
    - Implement frequency sweep modulation for doppler effects
    - Add unit tests validating waveform properties
    - _Requirements: 12.1, 12.5_
  
  - [x] 2.2 Implement ADSR envelope processor
    - Create `synthesis/envelopes.py` with ADSREnvelope class
    - Generate smooth attack/decay/sustain/release curves (exponential/logarithmic)
    - Support configurable timing parameters in milliseconds
    - _Requirements: 1.3, 3.4, 5.3, 7.2, 8.3, 9.3_

- [x] 3. Implement audio effects processing chain
  - [x] 3.1 Implement reverb and filter processors
    - Create `synthesis/effects.py` with Schroeder reverb algorithm
    - Add Butterworth lowpass and bandpass filters using scipy.signal
    - Implement configurable room size, damping, wet/dry mix parameters
    - _Requirements: 1.4, 2.2, 3.5, 5.5, 6.5, 9.5_
  
  - [x] 3.2 Implement compression and mixing utilities
    - Add simple dynamic range compression with threshold/ratio controls
    - Create `synthesis/mixing.py` with layer mixing and peak normalization
    - Implement silence trimming function (threshold -60dB)
    - _Requirements: 1.6, 10.1, 11.3_

- [x] 4. Create sound design configuration system
  - [x] 4.1 Design low-frequency impact sounds (Pulse, Wall Slam)
    - Create `sound_design_config.json` schema with global and per-sound sections
    - Configure Pulse: 3 layers (sub-bass 80Hz, body 200-800Hz, shimmer 2-6kHz), short reverb 120ms
    - Configure Wall Slam: low impact 60Hz + noise burst 500-2kHz + pink texture, stone reverb 250ms
    - _Requirements: 1.1-1.7, 3.1-3.7, 10.4_
  
  - [x] 4.2 Design mid-frequency percussive sounds (Domino, Player Hurt, Combo)
    - Configure Domino: light percussive 1.2kHz + short noise, minimal reverb 60ms
    - Configure Player Hurt: alert tone 1.8kHz sine + 1.2kHz square, dry processing
    - Configure Combo: ascending musical pattern with major scale intervals, subtle reverb 100ms
    - _Requirements: 4.1-4.7, 7.1-7.7, 8.1-8.7_
  
  - [x] 4.3 Design high-frequency clarity sounds (Dash, Shard)
    - Configure Dash: noise sweep 6kHz→1.5kHz with doppler pitch shift 1.1x→0.95x, dry
    - Configure Shard: pure harmonic series 1200Hz + overtones, exponential decay 150ms, sparkle reverb 70ms
    - _Requirements: 2.1-2.7, 6.1-6.7, 10.4_
  
  - [x] 4.4 Design magical/emotional sounds (Altar Seal, Game Over)
    - Configure Altar Seal: detuned harmonics 280/420/560Hz + 4kHz sparkle, deep reverb 750ms
    - Configure Game Over: descending E minor→C major resolution, spacious reverb 1000ms
    - Validate all configs have unified aesthetic approach and frequency separation
    - _Requirements: 5.1-5.7, 9.1-9.7, 10.2, 10.5, 10.7_

- [x] 5. Build generation orchestration script and CLI
  - [x] 5.1 Create main generation script with CLI interface
    - Implement `generate_sfx.py` with argparse for --config, --output-dir, --sounds, --validate flags
    - Add config loading and JSON schema validation
    - Implement per-sound generation loop with progress reporting
    - _Requirements: 12.2, 12.3, 12.6_
  
  - [x] 5.2 Implement WAV export and validation
    - Add WAV export function converting float32 to int16 at 44.1kHz mono
    - Create validation function checking sample rate, bit depth, channels, peak level
    - Generate summary report JSON with file paths, sizes, durations, peak levels
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 12.7_

- [x] 6. Checkpoint - Generate initial sound set and validate technical compliance
  - Run `python tools/audio/generate_sfx.py --validate --verbose`
  - Verify all 9 WAV files created in `assets/audio/sfx/` with correct naming convention
  - Check technical compliance: 16-bit, 44.1kHz, mono, peak levels -0.3 to -1.0dB
  - Ensure all tests pass, ask user if questions arise

- [x] 7. Iteration and aesthetic refinement
  - [x] 7.1 Initial listening review and parameter adjustment
    - Listen to all 9 sounds individually for harsh transients, clipping, or artifacts
    - Check durations match expectations (pulse 150-250ms, dash 80-120ms, etc.)
    - Adjust ADSR envelopes, reverb amounts, and layer amplitudes in config as needed
    - _Requirements: 1.1-9.7 (all aesthetic criteria)_
  
  - [x] 7.2 Integration testing with Godot SoundManager
    - Import generated WAVs into Godot project at `assets/audio/sfx/`
    - Create test scene calling SoundManager.play_* methods for all 9 sounds
    - Test polyphony limits and priority system work correctly with new sounds
    - _Requirements: 1.7, 2.6, 3.7, 4.7, 5.7, 6.7, 7.7, 8.7, 9.7, 11.6, 11.7_
  
  - [x] 7.3 Verify spectral balance and mixing clarity
    - Test simultaneous playback scenarios (pulse + wall_slam + domino)
    - Ensure frequency separation prevents masking (low-heavy vs mid-focused vs high-focused)
    - Adjust layer mix levels if sounds clash or one dominates inappropriately
    - _Requirements: 10.3, 10.4, 10.6_

- [x] 8. Final validation and documentation
  - [x] 8.1 Run comprehensive automated validation suite
    - Verify WAV format compliance (sample rate, bit depth, channels)
    - Check duration ranges and spectral balance metrics
    - Validate dynamic range consistency across all sounds
    - _Requirements: 11.1-11.5_
  
  - [x] 8.2 Complete auditory review checklist
    - Manually verify each sound meets aesthetic goals (pleasant, clear, cohesive)
    - Confirm unified sound design aesthetic across all 9 sounds
    - Test in actual gameplay context for clarity and appropriateness
    - _Requirements: 1.1-10.7 (all aesthetic requirements)_
  
  - [x] 8.3 Document generation process and create handoff
    - Write tool usage guide and config parameter reference
    - Document sound design rationale and iteration changes made
    - Create asset provenance record (tool version, config, timestamp)
    - Save approved sounds to `tests/audio_references/` for regression testing
    - _Requirements: 12.4, 12.6_

- [x] 9. Final checkpoint - Ensure all tests pass and user approval obtained
  - All automated tests passing (194 pytest tests + 46 Godot engine assertions)
  - Auditory checklist approved by user/sound designer
  - Documentation complete in tools/audio/README.md
  - Ask user for final approval before marking feature complete

## Notes

- All tasks involve offline asset generation, not runtime code changes
- SoundManager and audio bus configuration remain unchanged
- Iteration cycles (Task 7) expected—aesthetic quality requires listening feedback
- Python 3.8+ required with numpy, scipy, pydub, librosa libraries
- Easy rollback: `git checkout HEAD -- assets/audio/sfx/sfx_*.wav` restores old sounds
- Config-driven approach allows future sound adjustments without code changes
- No property-based testing tasks—audio quality is subjective and requires manual review

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1"] },
    { "id": 1, "tasks": ["2.1"] },
    { "id": 2, "tasks": ["2.2", "3.1"] },
    { "id": 3, "tasks": ["3.2"] },
    { "id": 4, "tasks": ["4.1", "4.2", "4.3", "4.4"] },
    { "id": 5, "tasks": ["5.1"] },
    { "id": 6, "tasks": ["5.2"] },
    { "id": 7, "tasks": ["7.1"] },
    { "id": 8, "tasks": ["7.2", "7.3"] },
    { "id": 9, "tasks": ["8.1", "8.2", "8.3"] }
  ]
}
```
