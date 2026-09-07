## combo_popup.gd — F003 Combo Counter Popup (v3)
## Popup "x2!", "x3!" tại vị trí va chạm khi chain đạt mốc.
## CHỈ hiển thị tại mốc cố định (x2, x3, x5, x10...), mỗi mốc 1 lần/chain.
## Aggregate per-frame. Attach dưới HUD (CanvasLayer).
extends Node

const MAX_POPUPS := 5
const ANIM_DURATION := 1.2

## Mốc hiển thị popup. Mỗi mốc chỉ fire 1 lần per chain.
const CHAIN_MILESTONES := [2, 3, 5, 7, 10, 15, 20]

var _active_popups: Array[Label] = []

# ─── Per-frame aggregation ───────────────────────────────
var _pending_count: int = 0
var _pending_position: Vector2 = Vector2.ZERO
var _has_pending: bool = false

# ─── Milestone tracking (reset khi chain kết thúc) ──────
var _fired_milestones: Dictionary = {}  # {milestone: true}
var _last_chain_count: int = 0


func _process(_delta: float) -> void:
	if _has_pending:
		_spawn_popup(_pending_count, _pending_position)
		_has_pending = false
		_pending_count = 0


## Nhận chain_hit_visual signal. Chỉ queue popup khi đạt mốc mới.
func on_chain_hit_visual(at_position: Vector2, chain_count: int) -> void:
	# Chain reset detection
	if chain_count < _last_chain_count:
		_reset_milestones()
	_last_chain_count = chain_count

	# Tìm mốc cao nhất mà chain_count đạt được và chưa fired
	var milestone_hit := 0
	for m: int in CHAIN_MILESTONES:
		if chain_count >= m and not _fired_milestones.has(m):
			milestone_hit = m
			_fired_milestones[m] = true

	if milestone_hit == 0:
		return  # Chưa đạt mốc mới nào

	# Aggregate: giữ count lớn nhất trong frame
	if chain_count > _pending_count:
		_pending_count = chain_count
		_pending_position = at_position
		_has_pending = true


func _spawn_popup(chain_count: int, world_pos: Vector2) -> void:
	# Cap
	if _active_popups.size() >= MAX_POPUPS:
		var oldest := _active_popups[0]
		_active_popups.remove_at(0)
		if is_instance_valid(oldest):
			oldest.queue_free()

	var popup := Label.new()
	popup.text = "x%d!" % chain_count

	# Style
	var base_size := 12
	var bonus := mini(chain_count - 2, 6)
	popup.add_theme_font_size_override("font_size", base_size + bonus)
	popup.add_theme_color_override("font_color", Color(1.0, 0.95, 0.4))
	popup.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	popup.add_theme_constant_override("outline_size", 2)

	# Vị trí tại va chạm
	popup.position = world_pos + Vector2(randf_range(-5, 5), randf_range(-3, 3))
	popup.scale = Vector2.ZERO
	popup.pivot_offset = Vector2(20, 8)

	get_parent().add_child(popup)
	_active_popups.append(popup)

	# Tween
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	# Scale pop-in
	tween.tween_property(popup, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(popup, "scale", Vector2(1.0, 1.0), 0.05)

	# Drift up + fade
	var drift_distance := maxf(world_pos.y - 20.0, 60.0)
	tween.set_parallel(true)
	tween.tween_property(popup, "position:y", world_pos.y - drift_distance, ANIM_DURATION - 0.15).set_delay(0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(popup, "modulate:a", 0.0, ANIM_DURATION * 0.6).set_delay(0.15)
	tween.set_parallel(false)

	# Cleanup — dùng lambda thay .bind() để tránh type conversion error
	tween.tween_callback(func() -> void:
		if _active_popups.has(popup):
			_active_popups.erase(popup)
		if is_instance_valid(popup):
			popup.queue_free()
	)


func _reset_milestones() -> void:
	_fired_milestones.clear()


## Clear — restart/menu.
func clear() -> void:
	for popup in _active_popups:
		if is_instance_valid(popup):
			popup.queue_free()
	_active_popups.clear()
	_has_pending = false
	_pending_count = 0
	_last_chain_count = 0
	_reset_milestones()
