## camera_shake.gd — F001 Screen Shake
## Trauma-based camera shake controller.
## Attach vào Camera2D node. Không thay đổi gameplay.
##
## Contract:
##   - trauma ∈ [0, 1]. Requests là trauma bổ sung, không phải pixel.
##   - amplitude = trauma² × max_offset × strength × noise(time)
##   - Nhiều requests cùng frame → lấy MAX, cộng 1 lần.
##   - Decay theo unscaled delta (không bị hit-stop kéo dài).
##   - Hết rung → offset trả về baseline_offset.
##   - strength = 0 → không rung, clear pending, restore baseline.
extends Camera2D

# ─── State ───────────────────────────────────────────────
var trauma: float = 0.0
var baseline_offset: Vector2 = Vector2.ZERO  # Offset gốc của camera owner

# ─── Aggregation ─────────────────────────────────────────
## Mỗi frame thu requests, lấy MAX, cộng 1 lần vào trauma.
var _pending_max: float = 0.0
var _has_pending: bool = false

# ─── Noise (visual RNG riêng, không dùng gameplay RNG) ──
var _noise_x: FastNoiseLite
var _noise_y: FastNoiseLite
var _noise_time: float = 0.0

# ─── Chain dedupe ────────────────────────────────────────
## Mỗi mốc chỉ fire 1 lần per chain. Reset khi chain kết thúc.
var _chain_thresholds := {3: false, 5: false, 10: false}
var _last_chain_count: int = 0


func _ready() -> void:
	baseline_offset = offset
	_setup_noise()
	# Luôn xử lý, kể cả khi tree paused (để clear đúng khi pause)
	process_mode = Node.PROCESS_MODE_ALWAYS


func _setup_noise() -> void:
	# Hai noise instance riêng cho X và Y → chuyển động 2D tự nhiên
	_noise_x = FastNoiseLite.new()
	_noise_x.seed = 1001  # Seed cố định, visual only, không ảnh hưởng gameplay RNG
	_noise_x.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise_x.frequency = 0.5

	_noise_y = FastNoiseLite.new()
	_noise_y.seed = 2002
	_noise_y.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise_y.frequency = 0.5


func _process(_delta: float) -> void:
	# Dùng unscaled delta → shake decay không bị hit-stop/time_scale kéo dài
	var real_delta := _get_unscaled_delta()

	# 1. Aggregation: cộng MAX pending vào trauma
	if _has_pending:
		trauma = clampf(trauma + _pending_max, 0.0, 1.0)
		_pending_max = 0.0
		_has_pending = false

	# 2. Tính offset nếu có trauma và shake enabled
	if trauma > 0.0 and Config.SHAKE_STRENGTH > 0.0:
		_noise_time += real_delta * Config.SHAKE_NOISE_SPEED
		var intensity := trauma * trauma * Config.SHAKE_MAX_OFFSET * Config.SHAKE_STRENGTH
		var shake_offset := Vector2(
			_noise_x.get_noise_1d(_noise_time) * intensity,
			_noise_y.get_noise_1d(_noise_time) * intensity,
		)
		offset = baseline_offset + shake_offset

		# 3. Decay trauma
		trauma = maxf(trauma - Config.SHAKE_DECAY * real_delta, 0.0)
	else:
		# Không rung → restore baseline, clear state
		if offset != baseline_offset:
			offset = baseline_offset
		trauma = 0.0


# ═══════════════════════════════════════════════════════════
# PUBLIC API
# ═══════════════════════════════════════════════════════════

## Request shake. Nhiều request cùng frame → chỉ dùng giá trị lớn nhất.
func request_shake(amount: float) -> void:
	if Config.SHAKE_STRENGTH <= 0.0:
		return
	if amount <= 0.0:
		return
	_has_pending = true
	_pending_max = maxf(_pending_max, amount)


## Xử lý chain_updated signal. Chỉ request shake khi vượt mốc mới.
func on_chain_updated(chain_count: int) -> void:
	# Chain reset detection: count nhỏ hơn last = chain mới
	if chain_count < _last_chain_count:
		_reset_chain_tracking()
	_last_chain_count = chain_count

	# Kiểm tra từng mốc, fire 1 lần
	if chain_count >= 10 and not _chain_thresholds[10]:
		_chain_thresholds[10] = true
		request_shake(Config.SHAKE_CHAIN_10)
	elif chain_count >= 5 and not _chain_thresholds[5]:
		_chain_thresholds[5] = true
		request_shake(Config.SHAKE_CHAIN_5)
	elif chain_count >= 3 and not _chain_thresholds[3]:
		_chain_thresholds[3] = true
		request_shake(Config.SHAKE_CHAIN_3)


## Reset chain tracking (gọi khi chain kết thúc hoặc run restart).
func _reset_chain_tracking() -> void:
	_chain_thresholds = {3: false, 5: false, 10: false}


## Clear toàn bộ state. Gọi khi pause/restart/menu.
func clear() -> void:
	trauma = 0.0
	_pending_max = 0.0
	_has_pending = false
	_last_chain_count = 0
	_reset_chain_tracking()
	offset = baseline_offset


# ═══════════════════════════════════════════════════════════
# HELPERS
# ═══════════════════════════════════════════════════════════

## Unscaled delta: không bị Engine.time_scale hoặc pause ảnh hưởng.
func _get_unscaled_delta() -> float:
	# Khi tree paused, delta vẫn đến vì process_mode = ALWAYS
	# Nhưng giá trị delta lúc này vẫn hợp lệ cho real time
	return get_process_delta_time()
