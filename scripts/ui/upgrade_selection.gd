## upgrade_selection.gd — Stone Knight M0 + F018
## UI độc lập quản lý màn hình chọn 1 trong 3 thẻ nâng cấp.
## An toàn tuyệt đối: cờ selection_committed chống chọn đúp, hỗ trợ phím 1/2/3 & click chuột.
extends CanvasLayer

signal upgrade_selected(upgrade_id: String)

var is_open: bool = false
var selection_committed: bool = false
var displayed_cards: Array[Dictionary] = []

var dim_overlay: ColorRect
var center_container: Control
var title_label: Label
var subtitle_label: Label
var cards_box: HBoxContainer
var card_buttons: Array[Button] = []
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


func _unhandled_input(event: InputEvent) -> void:
	if not is_open or selection_committed or just_opened:
		return

	if event.is_action_pressed("select_card_1") or _is_key_pressed(event, KEY_1, KEY_KP_1):
		_commit_choice(0)
	elif event.is_action_pressed("select_card_2") or _is_key_pressed(event, KEY_2, KEY_KP_2):
		_commit_choice(1)
	elif event.is_action_pressed("select_card_3") or _is_key_pressed(event, KEY_3, KEY_KP_3):
		_commit_choice(2)


func _process(_delta: float) -> void:
	# Xóa cờ just_opened sau frame đầu tiên để không nhận phím từ gameplay cũ
	if just_opened:
		just_opened = false


func _is_key_pressed(event: InputEvent, key_a: Key, key_b: Key) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == key_a or event.keycode == key_b
	return false


func show_selection(cards: Array[Dictionary]) -> void:
	displayed_cards = cards.duplicate()
	selection_committed = false
	just_opened = true
	is_open = true
	visible = true

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
	btn.pressed.connect(func() -> void:
		_commit_choice(index)
	)

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

	var chosen_card: Dictionary = displayed_cards[index]
	var card_id: String = chosen_card.get("id", "")
	hide_selection()
	upgrade_selected.emit(card_id)
