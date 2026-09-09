## hud.gd — Stone Knight M0 + F017
## HUD hiển thị HP, Pulse CD, Dash CD, Wave info & countdown, Shards, Chain.
## Quản lý các overlay: Menu, Pause, Death, Victory và Wave Banners.
extends CanvasLayer

@onready var label: Label = $Label

enum HUDState { MENU, HUD, PAUSE, DEATH, VICTORY }
var hud_state: HUDState = HUDState.MENU

var dim_overlay: ColorRect
var banner_label: Label
var banner_tween: Tween


func _ready() -> void:
	_setup_dim_overlay()
	_setup_label()
	_setup_banner_label()
	show_menu()


func _setup_dim_overlay() -> void:
	dim_overlay = ColorRect.new()
	dim_overlay.name = "DimOverlay"
	dim_overlay.color = Color(0.02, 0.03, 0.05, 0.7)
	dim_overlay.anchor_left = 0
	dim_overlay.anchor_top = 0
	dim_overlay.anchor_right = 1
	dim_overlay.anchor_bottom = 1
	dim_overlay.visible = false
	add_child(dim_overlay)
	if label != null:
		move_child(dim_overlay, 0)


func _setup_label() -> void:
	if label == null:
		label = Label.new()
		label.name = "Label"
		add_child(label)
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_left = 0
	label.anchor_top = 0
	label.anchor_right = 1
	label.anchor_bottom = 1
	label.offset_left = 0
	label.offset_top = 0
	label.offset_right = 0
	label.offset_bottom = 0


func _setup_banner_label() -> void:
	banner_label = Label.new()
	banner_label.name = "BannerLabel"
	banner_label.anchor_left = 0
	banner_label.anchor_top = 0
	banner_label.anchor_right = 1
	banner_label.anchor_bottom = 1
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner_label.add_theme_font_size_override("font_size", 11)
	banner_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))  # Gold
	banner_label.modulate.a = 0.0
	add_child(banner_label)


# ═══════════════════════════════════════════════════════════
# BANNER SYSTEM (F017)
# ═══════════════════════════════════════════════════════════

func show_banner(text: String, duration: float = 1.8, text_color: Color = Color(1.0, 0.88, 0.35)) -> void:
	if banner_label == null:
		return
	banner_label.text = text
	banner_label.add_theme_color_override("font_color", text_color)
	if banner_tween != null and banner_tween.is_valid():
		banner_tween.kill()
	banner_label.modulate.a = 1.0
	banner_tween = create_tween()
	banner_tween.tween_interval(duration * 0.45)
	banner_tween.tween_property(banner_label, "modulate:a", 0.0, duration * 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func hide_banner() -> void:
	if banner_tween != null and banner_tween.is_valid():
		banner_tween.kill()
	if banner_label != null:
		banner_label.modulate.a = 0.0


# ═══════════════════════════════════════════════════════════
# STATES
# ═══════════════════════════════════════════════════════════

func show_menu() -> void:
	hud_state = HUDState.MENU
	hide_banner()
	if dim_overlay != null:
		dim_overlay.visible = false
	label.text = "\n\n⚔  STONE KNIGHT  ⚔\n\nPress SPACE or CLICK to start\n"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func show_hud() -> void:
	hud_state = HUDState.HUD
	if dim_overlay != null:
		dim_overlay.visible = false
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP


func show_pause() -> void:
	hud_state = HUDState.PAUSE
	hide_banner()
	if dim_overlay != null:
		dim_overlay.visible = true
	label.text = "\n\n⏸  PAUSED  ⏸\n\nESC to resume\nR to restart\n"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func show_death(time_survived: float, enemies_killed: int, shards: int, best_chain: int, wave_reached: int = 1) -> void:
	hud_state = HUDState.DEATH
	hide_banner()
	if dim_overlay != null:
		dim_overlay.visible = true
	var minutes: int = int(time_survived / 60.0)
	var seconds: int = int(time_survived) % 60
	label.text = "\n💀  RUN OVER  💀\n\nWave Reached: %d/%d\nSurvival Time: %02d:%02d\nEnemies Slain: %d\nBest Combo: x%d\nShards Collected: %d\n\nPress R to restart\n" % [
		wave_reached, Config.TOTAL_WAVES, minutes, seconds, enemies_killed, best_chain, shards
	]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func show_victory(time_survived: float, enemies_killed: int, shards: int, best_chain: int) -> void:
	hud_state = HUDState.VICTORY
	hide_banner()
	if dim_overlay != null:
		dim_overlay.visible = true
	var minutes: int = int(time_survived / 60.0)
	var seconds: int = int(time_survived) % 60
	label.text = "\n🏆  VICTORY — THE SEAL HOLDS!  🏆\n\nAll %d Waves Conquered!\nTotal Time: %02d:%02d\nEnemies Slain: %d\nBest Combo: x%d\nShards Collected: %d\n\nPress R to play again\n" % [
		Config.TOTAL_WAVES, minutes, seconds, enemies_killed, best_chain, shards
	]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


# ═══════════════════════════════════════════════════════════
# HUD UPDATE (called every frame during RUNNING)
# ═══════════════════════════════════════════════════════════

func update_hud(
	hp: int, max_hp: int, cd_left: float, _cd_max: float, shards: int, best_chain: int,
	dash_cd: float = 0.0, current_wave: int = 1, total_waves: int = 5,
	wave_time_left: float = 0.0, is_intermission: bool = false, intermission_time_left: float = 0.0,
	is_clearing_remaining: bool = false, remaining_count: int = 0, is_pre_wave: bool = false,
	is_upgrading: bool = false
) -> void:
	if hud_state != HUDState.HUD:
		return
	
	# HP hearts
	var hearts := ""
	for i in max_hp:
		if i < hp:
			hearts += "♥"
		else:
			hearts += "♡"
	
	# Pulse Cooldown
	var pulse_text := "Pulse: READY" if cd_left <= 0 else "Pulse: %.1fs" % cd_left
	
	# Dash Cooldown
	var dash_text := "Dash: READY" if dash_cd <= 0 else "Dash: %.1fs" % dash_cd

	# Wave & Timer info (F017 + F018)
	var wave_text := ""
	if is_intermission:
		var wait_s := maxi(1, int(ceilf(intermission_time_left)))
		wave_text = "Wave %d Cleared! (Next in %ds)" % [current_wave, wait_s]
	elif is_upgrading:
		wave_text = "Wave %d/%d (Evolving...)" % [current_wave, total_waves]
	elif is_clearing_remaining:
		wave_text = "Wave %d/%d [CLEAR: %d]" % [current_wave, total_waves, remaining_count]
	elif is_pre_wave:
		wave_text = "Wave %d/%d (Get Ready!)" % [current_wave, total_waves]
	else:
		var wave_sec := maxi(0, int(ceilf(wave_time_left)))
		var w_min := int(float(wave_sec) / 60.0)
		var w_s := wave_sec % 60
		wave_text = "Wave %d/%d [%02d:%02d]" % [current_wave, total_waves, w_min, w_s]

	label.text = "%s     %s   %s     %s\n\nShards: %d   Chain Best: x%d" % [
		hearts, pulse_text, dash_text, wave_text, shards, best_chain
	]
