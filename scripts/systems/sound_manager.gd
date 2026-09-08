## sound_manager.gd — Stone Knight M0 + F016
## Hệ thống âm thanh phản hồi (Asset-based SFX).
## Quản lý pool 10 AudioStreamPlayer, voice priority, polyphony headroom,
## throttling chống chói/rách tiếng và RNG hoàn toàn độc lập với gameplay.
extends Node

enum Priority {
	LOW = 1,
	MEDIUM = 2,
	HIGH = 3,
	CRITICAL = 4,
}

# ─── Preloaded SFX Assets ─────────────────────────────────
var sfx_pulse: AudioStream = preload("res://assets/audio/sfx/sfx_pulse.wav")
var sfx_dash: AudioStream = preload("res://assets/audio/sfx/sfx_dash.wav")
var sfx_wall_slam: AudioStream = preload("res://assets/audio/sfx/sfx_wall_slam.wav")
var sfx_domino: AudioStream = preload("res://assets/audio/sfx/sfx_domino.wav")
var sfx_altar_seal: AudioStream = preload("res://assets/audio/sfx/sfx_altar_seal.wav")
var sfx_shard: AudioStream = preload("res://assets/audio/sfx/sfx_shard.wav")
var sfx_player_hurt: AudioStream = preload("res://assets/audio/sfx/sfx_player_hurt.wav")
var sfx_combo: AudioStream = preload("res://assets/audio/sfx/sfx_combo.wav")
var sfx_game_over: AudioStream = preload("res://assets/audio/sfx/sfx_game_over.wav")

# ─── Voice Pool ───────────────────────────────────────────
const POOL_SIZE := 10
var players: Array[AudioStreamPlayer] = []
var player_priorities: Array[int] = []
var player_types: Array[String] = []

# ─── Independent RNG ──────────────────────────────────────
var audio_rng: RandomNumberGenerator = RandomNumberGenerator.new()

# ─── Throttling & Streak Tracking ─────────────────────────
var last_play_msec: Dictionary = {}
var shard_streak: int = 0
var last_shard_time: int = 0

# ─── Sound Config Specs ───────────────────────────────────
const THROTTLE_GAPS: Dictionary = {
	"pulse": 150,
	"dash": 100,
	"wall_slam": 50,
	"domino": 40,
	"altar_seal": 100,
	"shard": 30,
	"player_hurt": 200,
	"combo": 100,
	"game_over": 1000,
}

const POLYPHONY_CAPS: Dictionary = {
	"pulse": 1,
	"dash": 1,
	"wall_slam": 2,
	"domino": 2,
	"altar_seal": 2,
	"shard": 3,
	"player_hurt": 1,
	"combo": 1,
	"game_over": 1,
}

const BASE_VOLUMES: Dictionary = {
	"pulse": -1.5,
	"dash": -5.0,
	"wall_slam": -1.0,
	"domino": -6.0,
	"altar_seal": -1.5,
	"shard": -7.0,
	"player_hurt": 0.0,
	"combo": -3.0,
	"game_over": 0.0,
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	audio_rng.randomize()
	_init_pool()


func _init_pool() -> void:
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.name = "SFXPlayer_%d" % i
		p.bus = &"SFX"
		p.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(p)
		players.append(p)
		player_priorities.append(0)
		player_types.append("")


# ═══════════════════════════════════════════════════════════
# CORE PLAYBACK ENGINE (Priority, Headroom & Preemption)
# ═══════════════════════════════════════════════════════════

func _play_sfx(sound_type: String, stream: AudioStream, priority: Priority, pitch: float = 1.0) -> void:
	if not Config.SFX_ENABLED:
		return

	var now := Time.get_ticks_msec()

	# 1. Throttling: kiểm tra khoảng cách tối thiểu giữa 2 âm cùng loại
	var throttle_gap: int = THROTTLE_GAPS.get(sound_type, 40)
	if last_play_msec.has(sound_type):
		if (now - int(last_play_msec[sound_type])) < throttle_gap:
			return  # Throttled

	# 2. Polyphony Cap: đếm số kênh đang phát cùng sound_type
	var cap: int = POLYPHONY_CAPS.get(sound_type, 1)
	var active_count := 0
	for i in range(POOL_SIZE):
		if players[i].playing and player_types[i] == sound_type:
			active_count += 1
	if active_count >= cap:
		return  # Polyphony limit reached for this sound type

	# 3. Tìm player rảnh rỗi hoặc cướp lượt (preemption)
	var target_index := -1

	# Ưu tiên tìm player đang rảnh
	for i in range(POOL_SIZE):
		if not players[i].playing:
			target_index = i
			break

	# Nếu pool đầy: tìm player có priority thấp nhất để cướp lượt
	if target_index == -1:
		var lowest_prio := 999
		var lowest_index := -1
		for i in range(POOL_SIZE):
			if player_priorities[i] < lowest_prio:
				lowest_prio = player_priorities[i]
				lowest_index = i

		# Chỉ cướp lượt nếu âm thanh mới có độ ưu tiên cao hơn
		if lowest_index != -1 and int(priority) > lowest_prio:
			target_index = lowest_index
			players[target_index].stop()
		else:
			return  # Bỏ qua âm thanh mới do độ ưu tiên không đủ cao

	# 4. Thiết lập tham số và phát
	var base_vol: float = BASE_VOLUMES.get(sound_type, 0.0)
	var p := players[target_index]
	p.stream = stream
	p.volume_db = base_vol + Config.SFX_MASTER_VOLUME_DB
	p.pitch_scale = pitch
	p.play()

	player_priorities[target_index] = int(priority)
	player_types[target_index] = sound_type
	last_play_msec[sound_type] = now


# ═══════════════════════════════════════════════════════════
# PUBLIC SFX API
# ═══════════════════════════════════════════════════════════

func play_pulse() -> void:
	var jitter := audio_rng.randf_range(0.97, 1.03)
	_play_sfx("pulse", sfx_pulse, Priority.HIGH, jitter)


func play_dash() -> void:
	var jitter := audio_rng.randf_range(0.96, 1.04)
	_play_sfx("dash", sfx_dash, Priority.MEDIUM, jitter)


func play_wall_slam() -> void:
	var jitter := audio_rng.randf_range(0.94, 1.06)
	_play_sfx("wall_slam", sfx_wall_slam, Priority.MEDIUM, jitter)


func play_domino() -> void:
	var jitter := audio_rng.randf_range(0.95, 1.05)
	_play_sfx("domino", sfx_domino, Priority.LOW, jitter)


func play_altar_seal() -> void:
	var jitter := audio_rng.randf_range(0.98, 1.02)
	_play_sfx("altar_seal", sfx_altar_seal, Priority.HIGH, jitter)


func play_shard() -> void:
	var now := Time.get_ticks_msec()
	if (now - last_shard_time) < 400:
		shard_streak = mini(shard_streak + 1, 8)
	else:
		shard_streak = 0
	last_shard_time = now

	# Tăng pitch nhẹ khi nhặt liên tục trong 0.4s
	var streak_pitch := 1.0 + float(shard_streak) * 0.03
	var jitter := audio_rng.randf_range(0.98, 1.02)
	_play_sfx("shard", sfx_shard, Priority.LOW, streak_pitch * jitter)


func play_player_hurt() -> void:
	# Priority CRITICAL: luôn cắt qua âm khác
	var jitter := audio_rng.randf_range(0.97, 1.03)
	_play_sfx("player_hurt", sfx_player_hurt, Priority.CRITICAL, jitter)


func play_combo(combo_level: int) -> void:
	# Pitch tăng theo chuỗi combo (x2, x3, x5...)
	var combo_pitch := clampf(1.0 + float(combo_level - 1) * 0.08, 1.0, 1.6)
	_play_sfx("combo", sfx_combo, Priority.MEDIUM, combo_pitch)


func play_game_over() -> void:
	# Dừng các âm thanh chiến đấu đang phát, ưu tiên tuyệt đối cho Game Over
	stop_combat_sounds()
	_play_sfx("game_over", sfx_game_over, Priority.CRITICAL, 1.0)


# ═══════════════════════════════════════════════════════════
# LIFECYCLE & CLEANUP
# ═══════════════════════════════════════════════════════════

## Dừng toàn bộ âm thanh chiến đấu thông thường (dùng khi chết)
func stop_combat_sounds() -> void:
	for i in range(POOL_SIZE):
		if player_types[i] != "game_over":
			players[i].stop()
			player_priorities[i] = 0
			player_types[i] = ""


## Xóa và dừng tất cả âm thanh (dùng khi restart/menu)
func clear() -> void:
	for i in range(POOL_SIZE):
		players[i].stop()
		player_priorities[i] = 0
		player_types[i] = ""
	last_play_msec.clear()
	shard_streak = 0
