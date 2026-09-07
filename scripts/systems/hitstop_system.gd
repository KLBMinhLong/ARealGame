## hitstop_system.gd — F002 Hit-stop
## Freeze game ngắn khi Pulse trúng hoặc chain xảy ra.
## Dùng Engine.time_scale = 0 + real-time timer.
## Không thay đổi gameplay logic.
extends Node

var _is_frozen: bool = false
var _freeze_remaining: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Chạy kể cả khi time_scale = 0


func _process(delta: float) -> void:
	if not _is_frozen:
		return

	# delta ở đây vẫn là real delta vì process_mode = ALWAYS
	# Nhưng khi time_scale = 0, delta từ _process vẫn dựa trên frame time
	# Dùng real delta thủ công
	var real_delta := delta / maxf(Engine.time_scale, 0.001) if Engine.time_scale > 0 else delta
	_freeze_remaining -= real_delta

	if _freeze_remaining <= 0.0:
		_unfreeze()


## Freeze game trong duration giây (real time).
## Nếu đang freeze, kéo dài nếu duration mới lớn hơn thời gian còn lại.
func freeze(duration: float) -> void:
	if duration <= 0.0:
		return

	if _is_frozen:
		# Kéo dài nếu request mới dài hơn
		_freeze_remaining = maxf(_freeze_remaining, duration)
		return

	_is_frozen = true
	_freeze_remaining = duration
	Engine.time_scale = 0.0


func _unfreeze() -> void:
	_is_frozen = false
	_freeze_remaining = 0.0
	Engine.time_scale = 1.0


## Gọi khi pulse trúng quái.
func on_pulse_hit(enemy_count: int) -> void:
	if enemy_count <= 0:
		return
	freeze(Config.HITSTOP_PULSE)


## Gọi khi chain tăng. Thời gian freeze tăng theo chain level, cap tại MAX.
func on_chain_hit(chain_count: int) -> void:
	if chain_count < 2:
		return  # Chain x1 = pulse hit đã xử lý
	var duration := minf(
		Config.HITSTOP_PULSE + Config.HITSTOP_CHAIN_ADD * (chain_count - 1),
		Config.HITSTOP_MAX,
	)
	freeze(duration)


## Clear state — gọi khi pause/restart/menu.
func clear() -> void:
	if _is_frozen:
		_unfreeze()
