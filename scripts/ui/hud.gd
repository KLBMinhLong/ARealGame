## hud.gd — Stone Knight M0
## HUD hiển thị HP, Pulse CD, Shards, Chain.
## Quản lý các overlay: Menu, Pause, Death.
extends CanvasLayer

@onready var label: Label = $Label

enum HUDState { MENU, HUD, PAUSE, DEATH }
var hud_state: HUDState = HUDState.MENU


func _ready() -> void:
	_setup_label()
	show_menu()


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
	label.text = "\n\n⚔  STONE KNIGHT  ⚔\n\nPress SPACE to start\n"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func show_hud() -> void:
	hud_state = HUDState.HUD
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP


func show_pause() -> void:
	hud_state = HUDState.PAUSE
	label.text = "\n\n⏸  PAUSED  ⏸\n\nESC to resume\nR to restart\n"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func show_death(shards: int, best_chain: int) -> void:
	hud_state = HUDState.DEATH
	label.text = "\n\n💀  YOU DIED  💀\n\nShards: %d\nBest Chain: x%d\n\nPress R to restart\n" % [shards, best_chain]
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
