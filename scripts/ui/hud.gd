## hud.gd — Stone Knight M0
## HUD hiển thị HP, Pulse CD, Shards, Chain.
## Quản lý các overlay: Menu, Pause, Death.
extends CanvasLayer

@onready var label: Label = $Label

enum HUDState { MENU, HUD, PAUSE, DEATH }
var hud_state: HUDState = HUDState.MENU


var dim_overlay: ColorRect


func _ready() -> void:
	_setup_dim_overlay()
	_setup_label()
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


# ═══════════════════════════════════════════════════════════
# STATES
# ═══════════════════════════════════════════════════════════

func show_menu() -> void:
	hud_state = HUDState.MENU
	if dim_overlay != null:
		dim_overlay.visible = false
	label.text = "\n\n⚔  STONE KNIGHT  ⚔\n\nPress SPACE to start\n"
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
	if dim_overlay != null:
		dim_overlay.visible = true
	label.text = "\n\n⏸  PAUSED  ⏸\n\nESC to resume\nR to restart\n"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func show_death(time_survived: float, enemies_killed: int, shards: int, best_chain: int) -> void:
	hud_state = HUDState.DEATH
	if dim_overlay != null:
		dim_overlay.visible = true
	var minutes: int = int(time_survived) / 60
	var seconds: int = int(time_survived) % 60
	label.text = "\n💀  RUN OVER  💀\n\nSurvival Time: %02d:%02d\nEnemies Slain: %d\nBest Combo: x%d\nShards Collected: %d\n\nPress R to restart\n" % [
		minutes, seconds, enemies_killed, best_chain, shards
	]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


# ═══════════════════════════════════════════════════════════
# HUD UPDATE (called every frame during RUNNING)
# ═══════════════════════════════════════════════════════════

func update_hud(hp: int, max_hp: int, cd_left: float, _cd_max: float, shards: int, best_chain: int) -> void:
	if hud_state != HUDState.HUD:
		return
	
	# HP hearts
	var hearts := ""
	for i in max_hp:
		if i < hp:
			hearts += "♥"
		else:
			hearts += "♡"
	
	# Cooldown
	var cd_text := ""
	if cd_left > 0:
		cd_text = "CD: %.1fs" % cd_left
	else:
		cd_text = "READY!"
	
	label.text = "%s     %s\n\nShards: %d   Chain Best: x%d" % [hearts, cd_text, shards, best_chain]
