extends CanvasLayer
## HUD nodes are deliberately built here; there are no missing editor signals.

signal start_requested
signal resume_requested
signal menu_requested
signal quit_requested

const Config = preload("res://scripts/core/game_config.gd")
const INK: Color = Color("eef5fa")
const MUTED: Color = Color("afc2d0")
var timer_label: Label
var health_label: Label
var pulse_label: Label
var drones_label: Label
var shade: ColorRect
var panel: PanelContainer
var title_label: Label
var body_label: Label
var primary_button: Button
var secondary_button: Button
var quit_button: Button
var panel_mode: String = "menu"

func _ready() -> void:
	var root: Control = Control.new()
	root.name = "Root"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_label(root, "VONG VAY", Vector2(40, 24), Vector2(420, 34), 27, INK)
	_label(root, "ARENA LAB  /  PLAYABLE STARTER 0.1", Vector2(41, 64), Vector2(500, 24), 14, MUTED)
	health_label = _label(root, "HULL  3 / 3", Vector2(620, 31), Vector2(190, 30), 22, INK)
	pulse_label = _label(root, "PULSE  READY", Vector2(620, 67), Vector2(220, 24), 14, Color("64b7ff"))
	timer_label = _label(root, "00:00 / 03:00", Vector2(852, 29), Vector2(260, 34), 24, INK)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	drones_label = _label(root, "DRONES  00", Vector2(906, 67), Vector2(206, 24), 14, MUTED)
	drones_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label(root, "WASD / ARROWS   Move       SPACE   Pulse (4s CD)       ESC   Pause       R   Retry", Vector2(40, 612), Vector2(930, 26), 16, MUTED)
	shade = ColorRect.new()
	shade.color = Color(0.025, 0.045, 0.065, 0.76)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	panel = PanelContainer.new()
	panel.position = Vector2(304, 140)
	panel.size = Vector2(544, 370)
	panel.add_theme_stylebox_override("panel", _style(Color("182a37"), Color("597789"), 24))
	root.add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var kicker: Label = Label.new()
	kicker.text = "ONE FIELD. ONE MORE TRY."
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kicker.add_theme_font_size_override("font_size", 14)
	kicker.add_theme_color_override("font_color", MUTED)
	box.add_child(kicker)
	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.add_theme_color_override("font_color", INK)
	box.add_child(title_label)
	body_label = Label.new()
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.custom_minimum_size = Vector2(460, 70)
	body_label.add_theme_font_size_override("font_size", 17)
	body_label.add_theme_color_override("font_color", MUTED)
	box.add_child(body_label)
	primary_button = _button("START RUN", true)
	primary_button.pressed.connect(_on_primary)
	box.add_child(primary_button)
	secondary_button = _button("BACK TO MENU", false)
	secondary_button.pressed.connect(func() -> void: menu_requested.emit())
	box.add_child(secondary_button)
	quit_button = _button("QUIT", false)
	quit_button.pressed.connect(func() -> void: quit_requested.emit())
	box.add_child(quit_button)
	show_panel("menu")

func _label(parent: Control, text: String, at: Vector2, dimensions: Vector2, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.position = at
	label.size = dimensions
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _style(background: Color, border: Color, padding: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style

func _button(text: String, primary: bool) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 44)
	button.add_theme_font_size_override("font_size", 17)
	var background: Color = Color("327fba") if primary else Color("203946")
	button.add_theme_stylebox_override("normal", _style(background, Color("6e98b3"), 8))
	button.add_theme_stylebox_override("hover", _style(background.lightened(0.12), Color("b7dcff"), 8))
	button.add_theme_stylebox_override("pressed", _style(background.darkened(0.14), Color("b7dcff"), 8))
	button.add_theme_stylebox_override("focus", _style(Color(0, 0, 0, 0), Color("ffe5ad"), 8))
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", INK)
	return button

func set_health(value: int) -> void:
	health_label.text = "HULL  %d / %d" % [value, Config.MAX_HEALTH]

func update_run(elapsed: float, enemy_count: int, pulse_cooldown: float = 0.0) -> void:
	var seconds: int = int(minf(elapsed, Config.RUN_SECONDS))
	timer_label.text = "%02d:%02d / 03:00" % [int(seconds / 60.0), seconds % 60]
	drones_label.text = "DRONES  %02d" % enemy_count
	if pulse_label != null:
		if pulse_cooldown <= 0.001:
			pulse_label.text = "PULSE  READY"
			pulse_label.add_theme_color_override("font_color", Color("64b7ff"))
		else:
			pulse_label.text = "PULSE  %.1fs" % pulse_cooldown
			pulse_label.add_theme_color_override("font_color", MUTED)

func hide_panel() -> void:
	panel.hide()
	shade.hide()
	primary_button.release_focus()
	secondary_button.release_focus()
	quit_button.release_focus()

func show_panel(mode: String, elapsed: float = 0.0) -> void:
	panel_mode = mode
	shade.show()
	panel.show()
	secondary_button.visible = mode != "menu"
	quit_button.visible = mode == "menu"
	match mode:
		"menu":
			title_label.text = "Dodge. Survive. Repeat."
			body_label.text = "Move with WASD or arrow keys.
Avoid the orange drones for 3 minutes.
Press SPACE to pulse and push drones away."
			primary_button.text = "START RUN"
		"paused":
			title_label.text = "Take a breath."
			body_label.text = "The timer and drones are frozen.
Continue when you are ready."
			primary_button.text = "CONTINUE"
		"won":
			title_label.text = "Field cleared."
			body_label.text = "You survived the full 3-minute run.
This is a prototype, not the final game."
			primary_button.text = "PLAY AGAIN"
		_:
			title_label.text = "One more try?"
			body_label.text = "You survived %.1f seconds.
Keep moving and watch the edges." % elapsed
			primary_button.text = "TRY AGAIN"
	primary_button.grab_focus()

func _on_primary() -> void:
	if panel_mode == "paused":
		resume_requested.emit()
	else:
		start_requested.emit()
