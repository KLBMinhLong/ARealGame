extends CanvasLayer
## HUD nodes are deliberately built here; there are no missing editor signals.

signal start_requested
signal resume_requested
signal menu_requested
signal quit_requested

const Config = preload("res://scripts/core/game_config.gd")
const SaveManager = preload("res://scripts/core/save_manager.gd")
const SettingsManager = preload("res://scripts/core/settings_manager.gd")
const INK: Color = Color("eef5fa")
const MUTED: Color = Color("afc2d0")
var timer_label: Label
var health_label: Label
var pulse_label: Label
var best_label: Label
var drones_label: Label
var shade: ColorRect
var panel: PanelContainer
var main_box: VBoxContainer
var settings_box: VBoxContainer
var kicker_label: Label
var title_label: Label
var body_label: Label
var primary_button: Button
var tutorial_button: Button
var settings_button: Button
var secondary_button: Button
var quit_button: Button
var master_label: Label
var master_slider: HSlider
var sfx_label: Label
var sfx_slider: HSlider
var fullscreen_button: Button
var reduced_effects_button: Button
var reset_defaults_button: Button
var settings_back_button: Button
var credits_button: Button
var credits_box: VBoxContainer
var credits_back_button: Button
var settings_manager: SettingsManager
var panel_mode: String = "menu"
var previous_panel_mode: String = "menu"
var current_best_seconds: float = 0.0
var current_win_count: int = 0
var current_total_runs: int = 0

func _ready() -> void:
	var root: Control = Control.new()
	root.name = "Root"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_label(root, "VONG VAY", Vector2(40, 24), Vector2(420, 34), 27, INK)
	_label(root, "ARENA LAB  /  PLAYABLE STARTER 0.1", Vector2(41, 64), Vector2(500, 24), 14, MUTED)
	health_label = _label(root, "HULL  3 / 3", Vector2(590, 31), Vector2(170, 30), 22, INK)
	pulse_label = _label(root, "PULSE  READY", Vector2(590, 67), Vector2(170, 24), 14, Color("64b7ff"))
	timer_label = _label(root, "00:00 / 03:00", Vector2(852, 29), Vector2(260, 34), 24, INK)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	best_label = _label(root, "BEST  --:--", Vector2(764, 67), Vector2(160, 24), 14, Color("ffe5ad"))
	drones_label = _label(root, "DRONES  00", Vector2(932, 67), Vector2(180, 24), 14, MUTED)
	drones_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label(root, "WASD / ARROWS   Move       SPACE   Pulse (4s CD)       ESC   Pause       R   Retry", Vector2(40, 612), Vector2(930, 26), 16, MUTED)
	shade = ColorRect.new()
	shade.color = Color(0.025, 0.045, 0.065, 0.76)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	panel = PanelContainer.new()
	panel.position = Vector2(266, 54)
	panel.size = Vector2(620, 540)
	panel.add_theme_stylebox_override("panel", _style(Color("182a37"), Color("597789"), 24))
	root.add_child(panel)
	main_box = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 8)
	panel.add_child(main_box)
	kicker_label = Label.new()
	kicker_label.text = "ONE FIELD. ONE MORE TRY."
	kicker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kicker_label.add_theme_font_size_override("font_size", 14)
	kicker_label.add_theme_color_override("font_color", MUTED)
	main_box.add_child(kicker_label)
	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", INK)
	main_box.add_child(title_label)
	body_label = Label.new()
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.custom_minimum_size = Vector2(500, 95)
	body_label.add_theme_font_size_override("font_size", 15)
	body_label.add_theme_color_override("font_color", MUTED)
	main_box.add_child(body_label)
	primary_button = _button("START RUN", true)
	primary_button.pressed.connect(_on_primary)
	main_box.add_child(primary_button)
	tutorial_button = _button("HOW TO PLAY", false)
	tutorial_button.pressed.connect(_on_tutorial)
	main_box.add_child(tutorial_button)
	settings_button = _button("SETTINGS", false)
	settings_button.pressed.connect(_on_settings)
	main_box.add_child(settings_button)
	credits_button = _button("CREDITS & LICENSES", false)
	credits_button.pressed.connect(_on_credits)
	main_box.add_child(credits_button)
	secondary_button = _button("BACK TO MENU", false)
	secondary_button.pressed.connect(_on_secondary)
	main_box.add_child(secondary_button)
	quit_button = _button("QUIT", false)
	quit_button.pressed.connect(func() -> void: quit_requested.emit())
	main_box.add_child(quit_button)
	_build_settings_ui()
	_build_credits_ui()
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
	button.custom_minimum_size = Vector2(0, 40)
	button.add_theme_font_size_override("font_size", 16)
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

func set_best_record(best_seconds: float, wins: int = 0, runs: int = 0) -> void:
	current_best_seconds = best_seconds
	current_win_count = wins
	current_total_runs = runs
	if best_label != null:
		if best_seconds > 0.0:
			best_label.text = "BEST  " + SaveManager.format_seconds(best_seconds)
		else:
			best_label.text = "BEST  --:--"

func hide_panel() -> void:
	panel.hide()
	shade.hide()
	primary_button.release_focus()
	tutorial_button.release_focus()
	settings_button.release_focus()
	if credits_button != null:
		credits_button.release_focus()
	secondary_button.release_focus()
	quit_button.release_focus()
	if settings_back_button != null:
		settings_back_button.release_focus()
	if fullscreen_button != null:
		fullscreen_button.release_focus()
	if reduced_effects_button != null:
		reduced_effects_button.release_focus()
	if reset_defaults_button != null:
		reset_defaults_button.release_focus()
	if credits_back_button != null:
		credits_back_button.release_focus()

func show_panel(mode: String, elapsed: float = 0.0, enemy_count: int = 0, run_stats: Dictionary = {}) -> void:
	panel_mode = mode
	shade.show()
	panel.show()
	if mode == "settings":
		main_box.hide()
		if credits_box != null:
			credits_box.hide()
		settings_box.show()
		refresh_settings_ui()
		settings_back_button.grab_focus()
		return
	if mode == "credits":
		main_box.hide()
		settings_box.hide()
		if credits_box != null:
			credits_box.show()
		if credits_back_button != null:
			credits_back_button.grab_focus()
		return

	main_box.show()
	settings_box.hide()
	if credits_box != null:
		credits_box.hide()
	primary_button.visible = mode != "tutorial"
	tutorial_button.visible = mode != "tutorial"
	settings_button.visible = mode == "menu" or mode == "paused"
	if credits_button != null:
		credits_button.visible = mode == "menu"
	secondary_button.visible = mode != "menu"
	quit_button.visible = mode == "menu"
	match mode:
		"menu":
			kicker_label.text = "ONE FIELD. ONE MORE TRY."
			title_label.text = "Vong Vay"
			if current_best_seconds > 0.0:
				body_label.text = "Dodge the drones. Survive the 3-minute gauntlet.\nWASD / Arrows to Move • SPACE to Shockwave Pulse.\n\nPersonal Best: %s  •  Wins: %d  •  Runs: %d" % [SaveManager.format_seconds(current_best_seconds), current_win_count, current_total_runs]
			else:
				body_label.text = "Dodge the drones. Survive the 3-minute gauntlet.\nWASD / Arrows to Move • SPACE to Shockwave Pulse.\n\nNo recorded runs yet. Step into the arena!"
			primary_button.text = "START RUN"
			secondary_button.text = "MENU"
		"tutorial":
			kicker_label.text = "TACTICAL FIELD GUIDE"
			title_label.text = "How to Play"
			body_label.text = "• WASD / ARROWS: Move & steer your drone in arena.\n• SPACE: Shockwave Pulse (4s CD) pushes drones 80px.\n• ORANGE CHASER: Pursues your position relentlessly.\n• RED SPRINTER (after 00:30): Warns with red laser, then dashes across the field to the wall. Step aside to dodge!\n• SURVIVE 03:00 to win."
			secondary_button.text = "BACK"
			secondary_button.grab_focus()
			return
		"paused":
			kicker_label.text = "GAME PAUSED"
			title_label.text = "Take a breath."
			body_label.text = "The timer, drones, and cooldowns are frozen.\nResume when you are ready."
			primary_button.text = "CONTINUE"
			secondary_button.text = "ABANDON RUN"
		"won":
			kicker_label.text = "ARENA CLEARED"
			title_label.text = "Victory!"
			var is_new: bool = run_stats.get("is_new_best", false)
			var wins: int = int(run_stats.get("win_count", current_win_count))
			var best_sec: float = float(run_stats.get("best_survival_seconds", current_best_seconds))
			var new_badge: String = "★ NEW RECORD! ★\n" if is_new else ""
			body_label.text = "%sYou survived the full 03:00 run (100%%)!\nFinal Drones Evaded: %02d  •  Total Wins: %d\nBest Record: %s\n\nOutstanding evasion and pulse mastery." % [new_badge, enemy_count, wins, SaveManager.format_seconds(best_sec)]
			primary_button.text = "PLAY AGAIN (R)"
			secondary_button.text = "BACK TO MENU"
		_:
			kicker_label.text = "HULL BREACHED"
			title_label.text = "Run Terminated"
			var mins: int = int(elapsed / 60.0)
			var secs: int = int(elapsed) % 60
			var pct: float = clampf((elapsed / Config.RUN_SECONDS) * 100.0, 0.0, 100.0)
			var tip: String = "Tip: Circle around arena edges to herd Chasers." if elapsed < 30.0 else "Tip: Watch for red laser lines — step aside before Sprinters dash!"
			var is_new: bool = run_stats.get("is_new_best", false)
			var best_sec: float = float(run_stats.get("best_survival_seconds", current_best_seconds))
			var runs: int = int(run_stats.get("total_runs", current_total_runs))
			var record_header: String = "★ NEW BEST SURVIVAL RECORD! ★\n" if is_new else ""
			var best_display: String = "Best Record: %s" % SaveManager.format_seconds(best_sec)
			body_label.text = "%sSurvived: %02d:%02d / 03:00 (%.0f%%)\nDrones Active: %02d  •  Runs: %d  •  %s\n\n%s" % [record_header, mins, secs, pct, enemy_count, runs, best_display, tip]
			primary_button.text = "TRY AGAIN (R)"
			secondary_button.text = "BACK TO MENU"
	primary_button.grab_focus()

func _on_primary() -> void:
	if panel_mode == "paused":
		resume_requested.emit()
	else:
		start_requested.emit()

func _on_tutorial() -> void:
	previous_panel_mode = panel_mode
	show_panel("tutorial")

func _on_settings() -> void:
	previous_panel_mode = panel_mode
	show_panel("settings")

func _on_secondary() -> void:
	if panel_mode == "tutorial" or panel_mode == "settings" or panel_mode == "credits":
		show_panel(previous_panel_mode)
	else:
		menu_requested.emit()

func _build_settings_ui() -> void:
	settings_box = VBoxContainer.new()
	settings_box.add_theme_constant_override("separation", 8)
	panel.add_child(settings_box)
	settings_box.hide()

	_container_label(settings_box, "AUDIO & DISPLAY PREFERENCES", 14, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_container_label(settings_box, "Settings", 28, INK, HORIZONTAL_ALIGNMENT_CENTER)

	var spacer1: Control = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 4)
	settings_box.add_child(spacer1)

	var master_row: HBoxContainer = HBoxContainer.new()
	master_row.add_theme_constant_override("separation", 12)
	settings_box.add_child(master_row)
	master_label = _container_label(master_row, "Master Volume: 80%", 15, INK)
	master_label.custom_minimum_size = Vector2(210, 26)
	master_slider = HSlider.new()
	master_slider.min_value = 0.0
	master_slider.max_value = 100.0
	master_slider.step = 5.0
	master_slider.value = 80.0
	master_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	master_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	master_slider.value_changed.connect(_on_master_slider_changed)
	master_row.add_child(master_slider)

	var sfx_row: HBoxContainer = HBoxContainer.new()
	sfx_row.add_theme_constant_override("separation", 12)
	settings_box.add_child(sfx_row)
	sfx_label = _container_label(sfx_row, "SFX Volume: 80%", 15, INK)
	sfx_label.custom_minimum_size = Vector2(210, 26)
	sfx_slider = HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 100.0
	sfx_slider.step = 5.0
	sfx_slider.value = 80.0
	sfx_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	sfx_row.add_child(sfx_slider)

	var spacer2: Control = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 4)
	settings_box.add_child(spacer2)

	fullscreen_button = _button("FULLSCREEN: OFF", false)
	fullscreen_button.pressed.connect(_on_toggle_fullscreen)
	settings_box.add_child(fullscreen_button)

	reduced_effects_button = _button("REDUCED FLASH: OFF", false)
	reduced_effects_button.pressed.connect(_on_toggle_reduced_effects)
	settings_box.add_child(reduced_effects_button)

	reset_defaults_button = _button("RESET TO DEFAULTS", false)
	reset_defaults_button.pressed.connect(_on_reset_defaults)
	settings_box.add_child(reset_defaults_button)

	settings_back_button = _button("BACK", true)
	settings_back_button.pressed.connect(_on_settings_back)
	settings_box.add_child(settings_back_button)

func _container_label(parent: Control, text: String, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func configure_settings(manager: SettingsManager) -> void:
	settings_manager = manager
	settings_manager.settings_changed.connect(refresh_settings_ui)
	refresh_settings_ui()

func refresh_settings_ui() -> void:
	if settings_manager == null:
		return
	var m_pct: int = int(roundf(settings_manager.master_volume * 100.0))
	var s_pct: int = int(roundf(settings_manager.sfx_volume * 100.0))
	if master_slider != null:
		master_slider.set_value_no_signal(m_pct)
	if master_label != null:
		master_label.text = "Master Volume: %d%%" % m_pct
	if sfx_slider != null:
		sfx_slider.set_value_no_signal(s_pct)
	if sfx_label != null:
		sfx_label.text = "SFX Volume: %d%%" % s_pct
	if fullscreen_button != null:
		fullscreen_button.text = "FULLSCREEN: ON" if settings_manager.fullscreen else "FULLSCREEN: OFF"
	if reduced_effects_button != null:
		reduced_effects_button.text = "REDUCED FLASH: ON" if settings_manager.reduced_effects else "REDUCED FLASH: OFF"

func _on_master_slider_changed(value: float) -> void:
	if settings_manager != null:
		settings_manager.set_master_volume(value / 100.0)
	if master_label != null:
		master_label.text = "Master Volume: %d%%" % int(value)

func _on_sfx_slider_changed(value: float) -> void:
	if settings_manager != null:
		settings_manager.set_sfx_volume(value / 100.0)
	if sfx_label != null:
		sfx_label.text = "SFX Volume: %d%%" % int(value)

func _on_toggle_fullscreen() -> void:
	if settings_manager != null:
		settings_manager.set_fullscreen(not settings_manager.fullscreen)

func _on_toggle_reduced_effects() -> void:
	if settings_manager != null:
		settings_manager.set_reduced_effects(not settings_manager.reduced_effects)

func _on_reset_defaults() -> void:
	if settings_manager != null:
		settings_manager.reset_to_defaults()

func _on_settings_back() -> void:
	show_panel(previous_panel_mode)

func _on_credits() -> void:
	previous_panel_mode = panel_mode
	show_panel("credits")

func _on_credits_back() -> void:
	show_panel(previous_panel_mode)

func _build_credits_ui() -> void:
	credits_box = VBoxContainer.new()
	credits_box.add_theme_constant_override("separation", 8)
	panel.add_child(credits_box)
	credits_box.hide()

	_container_label(credits_box, "ATTRIBUTION & LICENSING", 14, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_container_label(credits_box, "Credits & Licenses", 26, INK, HORIZONTAL_ALIGNMENT_CENTER)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	credits_box.add_child(scroll)

	var content_box: VBoxContainer = VBoxContainer.new()
	content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_box.add_theme_constant_override("separation", 8)
	scroll.add_child(content_box)

	_credit_section(content_box, "PROJECT & GAME DESIGN", "VÒNG VÂY (AI Starter Arena Survival) — v0.1.0\nCreated & Designed by Project Owner\nPair Programming: Antigravity AI Pair Programmer\nLicense: MIT License")
	_credit_section(content_box, "GAME ENGINE ATTRIBUTION", "Godot Engine (v4.6.3)\nCopyright (c) 2014-present Godot Engine contributors\nCopyright (c) 2007-2014 Juan Linietsky, Ariel Manzur\nLicense: MIT License (https://godotengine.org/license)")
	_credit_section(content_box, "GRAPHICS & AUDIO ASSETS", "• Visuals: Procedural 2D Vector Geometry via GDScript Draw API\n• Audio: Procedural 16-bit PCM AudioStreamWAV Synthesizer\nStatus: 0 external proprietary assets, 100% royalty-free MIT / CC0.")
	_credit_section(content_box, "THIRD-PARTY OPEN SOURCE LIBRARIES", "Godot Engine incorporates code and libraries from third parties:\nFreeType, MbedTLS, Libpng, Zlib, ENet, WebP.\nFull license texts preserved in engine binary and repository.")

	credits_back_button = _button("BACK", true)
	credits_back_button.pressed.connect(_on_credits_back)
	credits_box.add_child(credits_back_button)

func _credit_section(parent: Control, section_title: String, section_body: String) -> void:
	var title: Label = Label.new()
	title.text = section_title
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color("64b7ff"))
	parent.add_child(title)

	var body: Label = Label.new()
	body.text = section_body
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 13)
	body.add_theme_color_override("font_color", MUTED)
	parent.add_child(body)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 4)
	parent.add_child(spacer)
