extends Node
## Procedural Audio Synthesizer and Manager.
## Generates clean 16-bit PCM retro-sci-fi sound effects via AudioStreamWAV.
## Zero external dependencies, 100% offline, polyphonic playback on "SFX" bus.

const MIX_RATE: int = 22050
const POOL_SIZE: int = 8

var stream_pulse: AudioStreamWAV
var stream_hit: AudioStreamWAV
var stream_telegraph: AudioStreamWAV
var stream_dash: AudioStreamWAV
var stream_win: AudioStreamWAV
var stream_game_over: AudioStreamWAV
var stream_wall_slam: AudioStreamWAV
var stream_scrap_pickup: AudioStreamWAV
var stream_level_up: AudioStreamWAV
var stream_synthwave_loop: AudioStreamWAV

var _players: Array[AudioStreamPlayer] = []
var _next_player_idx: int = 0
var music_player: AudioStreamPlayer

func _init() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	ensure_audio_buses()
	_generate_all_streams()

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.stream = stream_synthwave_loop
	add_child(music_player)
	for i in range(POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_players.append(player)

static func ensure_audio_buses() -> void:
	if AudioServer.get_bus_index("Music") == -1:
		var music_idx: int = AudioServer.bus_count
		AudioServer.add_bus(music_idx)
		AudioServer.set_bus_name(music_idx, "Music")
		AudioServer.set_bus_send(music_idx, "Master")
	if AudioServer.get_bus_index("SFX") == -1:
		var sfx_idx: int = AudioServer.bus_count
		AudioServer.add_bus(sfx_idx)
		AudioServer.set_bus_name(sfx_idx, "SFX")
		AudioServer.set_bus_send(sfx_idx, "Master")

func play_pulse() -> void:
	_play_stream(stream_pulse)

func play_hit() -> void:
	_play_stream(stream_hit)

func play_telegraph() -> void:
	_play_stream(stream_telegraph)

func play_dash() -> void:
	_play_stream(stream_dash)

func play_win() -> void:
	_play_stream(stream_win)

func play_game_over() -> void:
	_play_stream(stream_game_over)

func play_wall_slam() -> void:
	_play_stream(stream_wall_slam)

func play_scrap_pickup() -> void:
	_play_stream(stream_scrap_pickup)

func play_level_up() -> void:
	_play_stream(stream_level_up)

func start_music() -> void:
	if music_player != null and not music_player.playing:
		music_player.play()

func stop_music() -> void:
	if music_player != null:
		music_player.stop()

func pause_music(is_paused: bool) -> void:
	if music_player != null:
		music_player.stream_paused = is_paused

func _play_stream(stream: AudioStreamWAV) -> void:
	if stream == null or _players.is_empty():
		return
	# Find an idle player or round-robin
	var chosen_player: AudioStreamPlayer = _players[_next_player_idx]
	for p in _players:
		if not p.playing:
			chosen_player = p
			break
	_next_player_idx = (_next_player_idx + 1) % _players.size()
	chosen_player.stream = stream
	chosen_player.play()

func _generate_all_streams() -> void:
	stream_pulse = _synth_pulse()
	stream_hit = _synth_hit()
	stream_telegraph = _synth_telegraph()
	stream_dash = _synth_dash()
	stream_win = _synth_win()
	stream_game_over = _synth_game_over()
	stream_wall_slam = _synth_wall_slam()
	stream_scrap_pickup = _synth_scrap_pickup()
	stream_level_up = _synth_level_up()
	stream_synthwave_loop = _synth_synthwave_loop()

func _create_wav(samples: Array[float]) -> AudioStreamWAV:
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(samples.size() * 2)
	for i in range(samples.size()):
		var clamped_sample: float = clampf(samples[i], -1.0, 1.0)
		var int_val: int = clampi(int(clamped_sample * 32767.0), -32768, 32767)
		byte_array.encode_s16(i * 2, int_val)
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = byte_array
	return wav

func _synth_pulse() -> AudioStreamWAV:
	var duration: float = 0.25
	var total_samples: int = int(duration * MIX_RATE)
	var samples: Array[float] = []
	samples.resize(total_samples)
	for i in range(total_samples):
		var t: float = float(i) / MIX_RATE
		var progress: float = t / duration
		var freq: float = lerpf(240.0, 50.0, progress)
		var env: float = (1.0 - progress) * (1.0 - progress)
		samples[i] = sin(t * freq * TAU) * env * 0.85
	return _create_wav(samples)

func _synth_hit() -> AudioStreamWAV:
	var duration: float = 0.18
	var total_samples: int = int(duration * MIX_RATE)
	var samples: Array[float] = []
	samples.resize(total_samples)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(total_samples):
		var t: float = float(i) / MIX_RATE
		var progress: float = t / duration
		var env: float = exp(-16.0 * progress)
		var freq: float = lerpf(180.0, 40.0, progress)
		var tone: float = sin(t * freq * TAU) * 0.6
		var noise: float = rng.randf_range(-1.0, 1.0) * 0.4
		samples[i] = (tone + noise) * env * 0.9
	return _create_wav(samples)

func _synth_telegraph() -> AudioStreamWAV:
	var duration: float = 0.42
	var total_samples: int = int(duration * MIX_RATE)
	var samples: Array[float] = []
	samples.resize(total_samples)
	for i in range(total_samples):
		var t: float = float(i) / MIX_RATE
		var progress: float = t / duration
		var freq: float = lerpf(650.0, 1250.0, progress)
		var tremolo: float = 0.6 + 0.4 * sin(t * 36.0 * TAU)
		var env: float = minf(progress * 8.0, 1.0) * (1.0 - progress * 0.3)
		samples[i] = sin(t * freq * TAU) * tremolo * env * 0.45
	return _create_wav(samples)

func _synth_dash() -> AudioStreamWAV:
	var duration: float = 0.28
	var total_samples: int = int(duration * MIX_RATE)
	var samples: Array[float] = []
	samples.resize(total_samples)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 99
	for i in range(total_samples):
		var t: float = float(i) / MIX_RATE
		var progress: float = t / duration
		var freq: float = lerpf(360.0, 110.0, progress)
		var env: float = sin(progress * PI)
		var tone: float = sin(t * freq * TAU) * 0.4
		var noise: float = rng.randf_range(-1.0, 1.0) * 0.6
		samples[i] = (tone + noise) * env * 0.7
	return _create_wav(samples)

func _synth_win() -> AudioStreamWAV:
	var duration: float = 0.8
	var total_samples: int = int(duration * MIX_RATE)
	var samples: Array[float] = []
	samples.resize(total_samples)
	for i in range(total_samples):
		var t: float = float(i) / MIX_RATE
		var freq: float = 523.25 # C5
		if t >= 0.4:
			freq = 1046.5 # C6
		elif t >= 0.2:
			freq = 659.25 # E5
		var seg_t: float = fmod(t, 0.2) if t < 0.4 else t - 0.4
		var seg_dur: float = 0.2 if t < 0.4 else 0.4
		var env: float = maxf(0.0, 1.0 - (seg_t / seg_dur))
		samples[i] = sin(t * freq * TAU) * env * 0.55
	return _create_wav(samples)

func _synth_game_over() -> AudioStreamWAV:
	var duration: float = 0.6
	var total_samples: int = int(duration * MIX_RATE)
	var samples: Array[float] = []
	samples.resize(total_samples)
	for i in range(total_samples):
		var t: float = float(i) / MIX_RATE
		var progress: float = t / duration
		var freq: float = lerpf(180.0, 35.0, progress)
		var env: float = 1.0 - progress
		samples[i] = sin(t * freq * TAU) * env * 0.75
	return _create_wav(samples)

func _synth_wall_slam() -> AudioStreamWAV:
	var duration: float = 0.32
	var total_samples: int = int(duration * MIX_RATE)
	var samples: Array[float] = []
	samples.resize(total_samples)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 777
	for i in range(total_samples):
		var t: float = float(i) / MIX_RATE
		var progress: float = t / duration
		var freq: float = lerpf(140.0, 35.0, progress)
		var env: float = exp(-12.0 * progress)
		var sub_bass: float = sin(t * freq * TAU) * 0.7
		var crunch: float = rng.randf_range(-1.0, 1.0) * exp(-24.0 * progress) * 0.6
		samples[i] = (sub_bass + crunch) * env * 0.95
	return _create_wav(samples)

func _synth_scrap_pickup() -> AudioStreamWAV:
	var duration: float = 0.14
	var total_samples: int = int(duration * MIX_RATE)
	var samples: Array[float] = []
	samples.resize(total_samples)
	for i in range(total_samples):
		var t: float = float(i) / MIX_RATE
		var progress: float = t / duration
		var freq: float = lerpf(1046.5, 1318.5, progress)
		var env: float = (1.0 - progress) * (1.0 - progress)
		var tone: float = sin(t * freq * TAU) * 0.65 + sin(t * freq * 2.0 * TAU) * 0.25
		samples[i] = tone * env * 0.7
	return _create_wav(samples)

func _synth_level_up() -> AudioStreamWAV:
	var duration: float = 0.52
	var total_samples: int = int(duration * MIX_RATE)
	var samples: Array[float] = []
	samples.resize(total_samples)
	var notes: Array[float] = [523.25, 659.25, 783.99, 1046.5]
	for i in range(total_samples):
		var t: float = float(i) / MIX_RATE
		var note_idx: int = clampi(int(t / 0.12), 0, 3)
		var note_t: float = fmod(t, 0.12) if note_idx < 3 else t - 0.36
		var note_dur: float = 0.12 if note_idx < 3 else 0.16
		var env: float = maxf(0.0, 1.0 - (note_t / note_dur))
		var freq: float = notes[note_idx]
		var tone: float = sin(t * freq * TAU) * 0.6 + sin(t * freq * 1.5 * TAU) * 0.2
		samples[i] = tone * env * 0.75
	return _create_wav(samples)

func _synth_synthwave_loop() -> AudioStreamWAV:
	var duration: float = 3.75
	var total_samples: int = int(duration * MIX_RATE)
	var samples: Array[float] = []
	samples.resize(total_samples)
	var beat_sec: float = 60.0 / 128.0
	var step_sec: float = beat_sec / 4.0
	var bass_freqs: Array[float] = [55.0, 55.0, 65.4, 55.0, 73.4, 55.0, 82.4, 73.4]
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 128
	for i in range(total_samples):
		var t: float = float(i) / MIX_RATE
		var beat_num: int = int(t / beat_sec)
		var beat_pos: float = fmod(t, beat_sec)
		var step_num: int = int(t / step_sec) % 8
		var step_pos: float = fmod(t, step_sec)

		var bass_freq: float = bass_freqs[step_num]
		var bass_env: float = exp(-16.0 * (step_pos / step_sec))
		var bass: float = (sin(t * bass_freq * TAU) * 0.7 + sin(t * bass_freq * 2.0 * TAU) * 0.3) * bass_env * 0.55

		var kick_freq: float = lerpf(120.0, 45.0, clampf(beat_pos / 0.12, 0.0, 1.0))
		var kick_env: float = exp(-18.0 * (beat_pos / beat_sec))
		var kick: float = sin(beat_pos * kick_freq * TAU) * kick_env * 0.75

		var snare: float = 0.0
		if beat_num % 2 == 1:
			var snare_env: float = exp(-22.0 * (beat_pos / beat_sec))
			snare = rng.randf_range(-1.0, 1.0) * snare_env * 0.45

		var arp_freq: float = bass_freq * 8.0
		var arp_env: float = exp(-14.0 * (step_pos / step_sec))
		var arp: float = sin(t * arp_freq * TAU) * arp_env * 0.18

		samples[i] = clampf(bass + kick + snare + arp, -1.0, 1.0) * 0.75

	var wav: AudioStreamWAV = _create_wav(samples)
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total_samples
	return wav

