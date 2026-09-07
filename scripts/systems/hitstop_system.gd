## hitstop_system.gd — F002 Hit-stop
## Freeze game ngắn khi Pulse trúng quái hoặc chain domino.
##
## Mechanism: Engine.time_scale = 0 → unfreeze sau real-time duration.
## Dùng Time.get_ticks_usec() vì _process(delta) trả delta=0 khi time_scale=0.
## process_mode = ALWAYS để _process vẫn được gọi khi frozen.
##
## Contract (F002_HITSTOP.md):
##   R01: pulse hit ≥1 quái → freeze HITSTOP_PULSE.
##        chain x2+ → freeze scaled, cap HITSTOP_MAX.
##   R02: freeze = time_scale=0, unfreeze = time_scale=1. Không slow-motion.
##   R03: đang freeze + request mới → kéo dài nếu duration > remaining. Không cộng dồn.
##   R04: pause/death/restart/menu → clear() restore time_scale=1.
##   R05: không đụng damage/force/cooldown/collision/chain/spawn/camera shake.
extends Node

var _is_frozen: bool = false
var _freeze_start_usec: int = 0
var _freeze_duration: float = 0.0  # seconds


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if not _is_frozen:
		return

	# Dùng real time vì delta=0 khi time_scale=0
	var elapsed := float(Time.get_ticks_usec() - _freeze_start_usec) / 1_000_000.0

	if elapsed >= _freeze_duration:
		_unfreeze()


## Freeze game trong duration giây (real time).
## Đang freeze + request mới → kéo dài nếu mới > remaining (R03).
func freeze(duration: float) -> void:
	if duration <= 0.0:
		return

	if _is_frozen:
		var elapsed := float(Time.get_ticks_usec() - _freeze_start_usec) / 1_000_000.0
		var remaining := _freeze_duration - elapsed
		if duration > remaining:
			# Kéo dài: reset start, dùng duration mới
			_freeze_start_usec = Time.get_ticks_usec()
			_freeze_duration = duration
		return

	_is_frozen = true
	_freeze_start_usec = Time.get_ticks_usec()
	_freeze_duration = duration
	Engine.time_scale = Config.HITSTOP_TIMESCALE  # Slow-motion, không full freeze


func _unfreeze() -> void:
	_is_frozen = false
	_freeze_duration = 0.0
	Engine.time_scale = 1.0


## Signal handler: pulse trúng quái (R01).
func on_pulse_hit(enemy_count: int) -> void:
	if enemy_count <= 0:
		return
	freeze(Config.HITSTOP_PULSE)


## Signal handler: chain tăng (R01).
## chain x1 = pulse hit đã xử lý. x2+ thêm theo CHAIN_ADD, cap MAX.
func on_chain_hit(chain_count: int) -> void:
	if chain_count < 2:
		return
	var duration := minf(
		Config.HITSTOP_PULSE + Config.HITSTOP_CHAIN_ADD * (chain_count - 1),
		Config.HITSTOP_MAX,
	)
	freeze(duration)


## Clear — gọi khi pause/restart/menu/death (R04).
func clear() -> void:
	if _is_frozen:
		_unfreeze()
