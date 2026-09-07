## combo_popup.gd — F003 Combo Counter Popup (v2)
## Popup "x2!", "x3!" tại vị trí va chạm khi chain domino.
## Aggregate per-frame: chỉ 1 popup/frame (count lớn nhất).
## Attach dưới HUD (CanvasLayer) → không bị camera shake.
extends Node

const MAX_POPUPS := 5
const ANIM_DURATION := 1.2  # s tổng — chậm hơn v1

var _active_popups: Array[Label] = []

# ─── Per-frame aggregation ───────────────────────────────
var _pending_count: int = 0
var _pending_position: Vector2 = Vector2.ZERO
var _has_pending: bool = false


func _process(_delta: float) -> void:
	if _has_pending:
		_spawn_popup(_pending_count, _pending_position)
		_has_pending = false
		_pending_count = 0


## Nhận chain_hit_visual signal. Aggregate: chỉ giữ count lớn nhất/frame.
func on_chain_hit_visual(at_position: Vector2, chain_count: int) -> void:
	if chain_count < 2:
		return
	if chain_count > _pending_count:
		_pending_count = chain_count
		_pending_position = at_position
		_has_pending = true


func _spawn_popup(chain_count: int, world_pos: Vector2) -> void:
	# Cap: kill popup cũ nhất nếu vượt MAX
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

	# Vị trí: world_pos ≈ screen_pos (camera cố định ở viewport center)
	popup.position = world_pos + Vector2(randf_range(-5, 5), randf_range(-3, 3))
	popup.scale = Vector2.ZERO
	popup.pivot_offset = Vector2(20, 8)

	get_parent().add_child(popup)
	_active_popups.append(popup)

	# Tween animation — chậm, bay xa, mờ sớm
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	# Scale: 0 → 1.3 (pop in)
	tween.tween_property(popup, "scale", Vector2(1.3, 1.3), 0.1)
	# Scale: 1.3 → 1.0 (settle)
	tween.tween_property(popup, "scale", Vector2(1.0, 1.0), 0.05)

	# Drift up xa (gần hết màn hình) + fade
	var drift_distance := maxf(world_pos.y - 20.0, 60.0)  # Bay đến gần top
	tween.set_parallel(true)
	tween.tween_property(popup, "position:y", world_pos.y - drift_distance, ANIM_DURATION - 0.15).set_delay(0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(popup, "modulate:a", 0.0, ANIM_DURATION * 0.6).set_delay(0.15)  # Mờ sớm & dần
	tween.set_parallel(false)

	tween.tween_callback(_remove_popup.bind(popup))


func _remove_popup(popup: Label) -> void:
	if _active_popups.has(popup):
		_active_popups.erase(popup)
	if is_instance_valid(popup):
		popup.queue_free()


## Clear tất cả popup — gọi khi restart/menu.
func clear() -> void:
	for popup in _active_popups:
		if is_instance_valid(popup):
			popup.queue_free()
	_active_popups.clear()
	_has_pending = false
	_pending_count = 0
