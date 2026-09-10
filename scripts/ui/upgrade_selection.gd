## upgrade_selection.gd — Stone Knight M0 + F018 + F021.6
## UI độc lập quản lý màn hình chọn 1 trong 3 thẻ nâng cấp.
## An toàn tuyệt đối: cờ selection_committed chống chọn đúp, hỗ trợ phím 1/2/3 & click chuột.
## F021.6: Hỗ trợ Rune Foresight (Reroll 1 lần/run với phím R hoặc click).
extends CanvasLayer

signal upgrade_selected(upgrade_id: String)
signal reroll_requested

var is_open: bool = false
var selection_committed: bool = false
var displayed_cards: Array[Dictionary] = []
var can_reroll: bool = false

var dim_overlay: ColorRect
var center_container: Control
var title_label: Label
var subtitle_label: Label
var cards_box: HBoxContainer
var card_buttons: Array[Button] = []
var reroll_button: Button = null
var just_opened: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Nhận input ngay cả khi game pause
	layer = 10  # Hiển thị trên HUD
	_setup_ui()
	hide_selection()


func _setup_ui() -> void:
	# 1. Dim overlay
	dim_overlay = ColorRect.new()
	dim_overlay.name = "DimOverlay"
	dim_overlay.color = Color(0.02, 0.03, 0.06, 0.85)
	dim_overlay.anchor_left = 0
	dim_overlay.anchor_top = 0
	dim_overlay.anchor_right = 1
	dim_overlay.anchor_bottom = 1
	add_child(dim_overlay)

	# 2. Main layout container
	center_container = Control.new()
	center_container.name = "CenterContainer"
	center_container.anchor_left = 0
	center_container.anchor_top = 0
	center_container.anchor_right = 1
	center_container.anchor_bottom = 1
	add_child(center_container)

	# 3. Title label
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "★  SOUL EVOLUTION  ★"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.anchor_left = 0
	title_label.anchor_right = 1
	title_label.offset_top = 22
	title_label.offset_bottom = 40
	title_label.add_theme_font_size_override("font_size", 12)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))  # Gold
	center_container.add_child(title_label)

	# 4. Subtitle label
	subtitle_label = Label.new()
	subtitle_label.name = "SubtitleLabel"
	subtitle_label.text = "Press 1, 2, 3 or Click a card to evolve"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.anchor_left = 0
	subtitle_label.anchor_right = 1
	subtitle_label.offset_top = 40
	subtitle_label.offset_bottom = 54
	subtitle_label.add_theme_font_size_override("font_size", 8)
	subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	center_container.add_child(subtitle_label)

	# 5. Cards horizontal container (480x270 viewport)
	cards_box = HBoxContainer.new()
	cards_box.name = "CardsBox"
	cards_box.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_box.offset_left = 30
	cards_box.offset_right = 450
	cards_box.offset_top = 62
	cards_box.offset_bottom = 232
	cards_box.add_theme_constant_override("separation", 16)
	center_container.add_child(cards_box)

	# 6. Reroll button (F021.6: Rune Foresight)
	reroll_button = Button.new()
	reroll_button.name = "RerollButton"
	reroll_button.custom_minimum_size = Vector2(140, 22)
	reroll_button.offset_left = 170
	reroll_button.offset_right = 310
	reroll_button.offset_top = 236
	reroll_button.offset_bottom = 258
	reroll_button.focus_mode = Control.FOCUS_ALL
	reroll_button.text = "⟳ Reroll [R] (1 left)"
	reroll_button.add_theme_font_size_override("font_size", 8)

	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.1, 0.12, 0.2, 0.9)
	btn_normal.border_color = Color(0.0, 0.8, 0.95, 0.8)
	btn_normal.set_border_width_all(1)
	btn_normal.set_corner_radius_all(3)

	var btn_hover := StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.15, 0.18, 0.3, 0.95)
	btn_hover.border_color = Color(0.2, 1.0, 1.0, 1.0)
	btn_hover.set_border_width_all(1)
	btn_hover.set_corner_radius_all(3)

	var btn_disabled := StyleBoxFlat.new()
	btn_disabled.bg_color = Color(0.07, 0.07, 0.1, 0.6)
	btn_disabled.border_color = Color(0.3, 0.3, 0.35, 0.4)
	btn_disabled.set_border_width_all(1)
	btn_disabled.set_corner_radius_all(3)

	reroll_button.add_theme_stylebox_override("normal", btn_normal)
	reroll_button.add_theme_stylebox_override("hover", btn_hover)
	reroll_button.add_theme_stylebox_override("focus", btn_hover)
	reroll_button.add_theme_stylebox_override("disabled", btn_disabled)

	reroll_button.pressed.connect(_on_reroll_pressed)
	center_container.add_child(reroll_button)


func _unhandled_input(event: InputEvent) -> void:
	if not is_open or selection_committed or just_opened:
		return

	if _is_key_pressed(event, KEY_1, KEY_KP_1):
		_commit_choice(0)
	elif _is_key_pressed(event, KEY_2, KEY_KP_2):
		_commit_choice(1)
	elif _is_key_pressed(event, KEY_3, KEY_KP_3):
		_commit_choice(2)
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		_on_reroll_pressed()


func _process(_delta: float) -> void:
	# Xóa cờ just_opened sau frame đầu tiên để không nhận phím từ gameplay cũ
	if just_opened:
		just_opened = false


func _is_key_pressed(event: InputEvent, key_a: Key, key_b: Key) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == key_a or event.keycode == key_b
	return false


func show_selection(cards: Array[Dictionary], p_can_reroll: bool = false, rerolls_left: int = 0, has_foresight: bool = false) -> void:
	displayed_cards = cards.duplicate()
	selection_committed = false
	can_reroll = p_can_reroll
	just_opened = true
	is_open = true
	visible = true

	# Cập nhật trạng thái nút Reroll
	if reroll_button != null:
		if not has_foresight:
			reroll_button.visible = false
			subtitle_label.text = "Press 1, 2, 3 or Click a card to evolve"
		else:
			reroll_button.visible = true
			if p_can_reroll:
				reroll_button.disabled = false
				reroll_button.text = "⟳ REROLL [R] (%d left)" % rerolls_left
				reroll_button.add_theme_color_override("font_color", Color(0.0, 0.9, 1.0))
				subtitle_label.text = "Press 1, 2, 3 or Click a card  |  [R] to Reroll (%d left)" % rerolls_left
			else:
				reroll_button.disabled = true
				reroll_button.text = "⟳ Reroll (0 left)"
				reroll_button.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
				subtitle_label.text = "Press 1, 2, 3 or Click a card to evolve  |  Reroll: 0 left"

	# Clear old card buttons
	for child in cards_box.get_children():
		child.queue_free()
	card_buttons.clear()

	# Create card UI for each option
	for i in displayed_cards.size():
		var card: Dictionary = displayed_cards[i]
		var card_btn := _create_card_button(i, card)
		cards_box.add_child(card_btn)
		card_buttons.append(card_btn)


func hide_selection() -> void:
	is_open = false
	visible = false
	selection_committed = false
	can_reroll = false


func _create_card_button(index: int, card: Dictionary) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(116, 155)
	btn.focus_mode = Control.FOCUS_ALL

	# Container bên trong Button để layout text
	var vbox := VBoxContainer.new()
	vbox.anchor_left = 0
	vbox.anchor_top = 0
	vbox.anchor_right = 1
	vbox.anchor_bottom = 1
	vbox.offset_left = 6
	vbox.offset_right = -6
	vbox.offset_top = 8
	vbox.offset_bottom = -8
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(vbox)

	# Hotkey badge: [1], [2], [3]
	var hotkey_lbl := Label.new()
	hotkey_lbl.text = "[%d]" % (index + 1)
	hotkey_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hotkey_lbl.add_theme_font_size_override("font_size", 9)
	hotkey_lbl.add_theme_color_override("font_color", Color(0.0, 0.9, 1.0))  # Cyan
	vbox.add_child(hotkey_lbl)

	# Icon
	var icon_lbl := Label.new()
	icon_lbl.text = card.get("icon", "[★]")
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 10)
	icon_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(icon_lbl)

	# Name
	var name_lbl := Label.new()
	name_lbl.text = card.get("name", "Upgrade")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_lbl)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(spacer)

	# Description
	var desc_lbl := Label.new()
	desc_lbl.text = card.get("desc", "")
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 8)
	desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	vbox.add_child(desc_lbl)

	# Tier progression: Tier 1/3
	var tier_lbl := Label.new()
	var cur_t: int = card.get("current_tier", 0)
	var nxt_t: int = card.get("next_tier", 1)
	var max_t: int = card.get("max_tier", 3)
	tier_lbl.text = "Tier %d → %d / %d" % [cur_t, nxt_t, max_t]
	tier_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier_lbl.add_theme_font_size_override("font_size", 7)
	tier_lbl.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	vbox.add_child(tier_lbl)

	# Click callback
	btn.pressed.connect(_commit_choice.bind(index))

	return btn



func _commit_choice(index: int) -> void:
	if selection_committed or not is_open:
		return
	if index < 0 or index >= displayed_cards.size():
		return

	# Khóa lập tức toàn bộ lựa chọn để chống double-click hoặc nhấn phím đúp
	selection_committed = true
	for btn in card_buttons:
		if is_instance_valid(btn):
			btn.disabled = true
	if is_instance_valid(reroll_button):
		reroll_button.disabled = true

	var chosen_card: Dictionary = displayed_cards[index]
	var card_id: String = chosen_card.get("id", "")
	hide_selection()
	upgrade_selected.emit(card_id)


func _on_reroll_pressed() -> void:
	if not is_open or selection_committed or not can_reroll:
		return
	can_reroll = false
	if is_instance_valid(reroll_button):
		reroll_button.disabled = true
	reroll_requested.emit()
