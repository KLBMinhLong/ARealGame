## combo_popup.gd — F003 Combo Counter Popup
## Quản lý popup "x2!", "x3!" khi chain domino xảy ra.
## Spawn Label động → Tween (scale up → drift up → fade) → queue_free.
## Attach vào CanvasLayer (HUD) → không bị camera shake.
##
## Contract (F003_COMBO_POPUP.md):
##   R01: chain_count ≥ 2 → popup. x1 → không.
##   R02: Scale 0→1.5→1.0, drift up 20px, fade out. ~0.6s.
##   R03: Cap 5 popup cùng lúc.
##   R04: clear() khi restart/menu. Pause → Tween pause theo tree.
##   R05: Không đụng chain logic/damage/scoring/camera.
extends Node

const MAX_POPUPS := 5
const ANIM_DURATION := 0.6  # s tổng

var _active_popups: Array[Label] = []


## Gọi khi chain_updated. Chỉ spawn khi count ≥ 2 (R01).
func on_chain_updated(chain_count: int) -> void:
	if chain_count < 2:
		return
	_spawn_popup(chain_count)


func _spawn_popup(chain_count: int) -> void:
	# Cap: kill popup cũ nhất nếu vượt MAX (R03)
	if _active_popups.size() >= MAX_POPUPS:
		var oldest := _active_popups[0]
		_active_popups.remove_at(0)
		if is_instance_valid(oldest):
			oldest.queue_free()

	# Tạo Label
	var popup := Label.new()
	popup.text = "x%d!" % chain_count
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Style: text trắng, đậm, cỡ tùy chain
	var base_size := 12
	var bonus := mini(chain_count - 2, 6)  # x2=12, x8+=18
	popup.add_theme_font_size_override("font_size", base_size + bonus)
	popup.add_theme_color_override("font_color", Color(1.0, 0.95, 0.4))  # Vàng nhạt
	popup.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	popup.add_theme_constant_override("outline_size", 2)

	# Vị trí: trung tâm viewport, lệch random nhẹ tránh chồng
	var vp_size := Vector2(480, 270)  # Logical viewport
	popup.position = Vector2(
		vp_size.x / 2.0 - 20 + randf_range(-15, 15),
		vp_size.y / 2.0 - 10 + randf_range(-10, 10),
	)
	popup.scale = Vector2.ZERO
	popup.pivot_offset = Vector2(20, 8)  # Gần center text

	# Thêm vào parent (HUD CanvasLayer)
	get_parent().add_child(popup)
	_active_popups.append(popup)

	# Tween animation (R02)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	# Scale: 0 → 1.5 (pop in)
	tween.tween_property(popup, "scale", Vector2(1.5, 1.5), 0.1)
	# Scale: 1.5 → 1.0 (settle)
	tween.tween_property(popup, "scale", Vector2(1.0, 1.0), 0.05)

	# Parallel: drift up + fade out
	tween.set_parallel(true)
	tween.tween_property(popup, "position:y", popup.position.y - 20, ANIM_DURATION - 0.15).set_delay(0.15)
	tween.tween_property(popup, "modulate:a", 0.0, 0.4).set_delay(ANIM_DURATION - 0.4)
	tween.set_parallel(false)

	# Cleanup
	tween.tween_callback(_remove_popup.bind(popup))


func _remove_popup(popup: Label) -> void:
	if _active_popups.has(popup):
		_active_popups.erase(popup)
	if is_instance_valid(popup):
		popup.queue_free()


## Clear tất cả popup — gọi khi restart/menu (R04).
func clear() -> void:
	for popup in _active_popups:
		if is_instance_valid(popup):
			popup.queue_free()
	_active_popups.clear()
