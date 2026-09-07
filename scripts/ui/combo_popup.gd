## combo_popup.gd — F003 Combo Counter Popup (v4)
## Popup nhẹ nhàng như bóng bay — mờ, bay chậm lên top màn hình.
## Chỉ nổi bật khi chain số lớn (x5+).
extends Node

const MAX_POPUPS := 5
const CHAIN_MILESTONES := [2, 3, 5, 7, 10, 15, 20]

var _active_popups: Array[Label] = []

# ─── Per-frame aggregation ───────────────────────────────
var _pending_count: int = 0
var _pending_position: Vector2 = Vector2.ZERO
var _has_pending: bool = false

# ─── Milestone tracking ─────────────────────────────────
var _fired_milestones: Dictionary = {}
var _last_chain_count: int = 0


func _process(_delta: float) -> void:
	if _has_pending:
		_spawn_popup(_pending_count, _pending_position)
		_has_pending = false
		_pending_count = 0


func on_chain_hit_visual(at_position: Vector2, chain_count: int) -> void:
	if chain_count < _last_chain_count:
		_reset_milestones()
	_last_chain_count = chain_count

	var milestone_hit := 0
	for m: int in CHAIN_MILESTONES:
		if chain_count >= m and not _fired_milestones.has(m):
			milestone_hit = m
			_fired_milestones[m] = true

	if milestone_hit == 0:
		return

	if chain_count > _pending_count:
		_pending_count = chain_count
		_pending_position = at_position
		_has_pending = true


func _spawn_popup(chain_count: int, world_pos: Vector2) -> void:
	if _active_popups.size() >= MAX_POPUPS:
		var oldest := _active_popups[0]
		_active_popups.remove_at(0)
		if is_instance_valid(oldest):
			oldest.queue_free()

	var popup := Label.new()
	popup.text = "x%d!" % chain_count

	# Chain nhỏ = nhỏ + mờ. Chain lớn = lớn + rõ hơn.
	var is_big := chain_count >= 5
	var font_size := 10 if not is_big else 12 + mini(chain_count - 5, 8)
	var start_alpha := 0.35 if not is_big else minf(0.5 + (chain_count - 5) * 0.05, 0.9)
	var text_color := Color(1.0, 1.0, 1.0, start_alpha) if not is_big else Color(1.0, 0.9, 0.3, start_alpha)

	popup.add_theme_font_size_override("font_size", font_size)
	popup.add_theme_color_override("font_color", text_color)
	popup.add_theme_color_override("font_outline_color", Color(0, 0, 0, start_alpha * 0.5))
	popup.add_theme_constant_override("outline_size", 1 if not is_big else 2)

	# Vị trí tại va chạm
	popup.position = world_pos + Vector2(randf_range(-4, 4), 0)
	popup.pivot_offset = Vector2(15, 6)

	get_parent().add_child(popup)
	_active_popups.append(popup)

	# Animation: bóng bay — nhẹ nhàng bay lên top, mờ dần
	var drift_duration := 2.5 if not is_big else 3.0
	var target_y := 10.0  # Gần top màn hình mới biến mất

	var tween := create_tween()

	# Drift lên top — linear, nhẹ nhàng
	tween.set_parallel(true)
	tween.tween_property(popup, "position:y", target_y, drift_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	# Mờ dần trong nửa sau
	tween.tween_property(popup, "modulate:a", 0.0, drift_duration * 0.5).set_delay(drift_duration * 0.5)
	# Nhẹ lắc ngang như bóng bay
	tween.tween_property(popup, "position:x", popup.position.x + randf_range(-8, 8), drift_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_parallel(false)

	tween.tween_callback(func() -> void:
		if _active_popups.has(popup):
			_active_popups.erase(popup)
		if is_instance_valid(popup):
			popup.queue_free()
	)


func _reset_milestones() -> void:
	_fired_milestones.clear()


func clear() -> void:
	for popup in _active_popups:
		if is_instance_valid(popup):
			popup.queue_free()
	_active_popups.clear()
	_has_pending = false
	_pending_count = 0
	_last_chain_count = 0
	_reset_milestones()
