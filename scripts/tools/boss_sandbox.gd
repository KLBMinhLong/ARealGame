## boss_sandbox.gd — Stone Knight F020 Debug & Playtest Sandbox
## Môi trường cô lập để test riêng Boss Warden:
## - 1 Player
## - 1 Warden (HP: 6)
## - 4 Tường biên + 1 đoạn Tường Gai 120px (thành phải) + 1 Altar
## - 0–2 Quái đệ Slime
## - Đo quãng đường đẩy thực tế (travel distance measurement)
## - Debug controls: R (Reset), M (Minions), E (Enrage), C (Reset CD), T (Heavy Push Tier), K (-1 HP), ESC (Exit)
extends Node2D

@onready var arena: Node2D = $Arena
@onready var player: Node2D = $World/Player
@onready var enemies_container: Node2D = $World/Enemies
@onready var loot_container: Node2D = $World/Loot
@onready var vfx: Node2D = $VFX
@onready var camera: Camera2D = $Camera
@onready var push_system: Node = $PushSystem
@onready var hitstop: Node = $HitstopSystem
@onready var sound_manager: Node = $SoundManager
@onready var debug_label: Label = $HUD/DebugLabel

var warden: EnemyBase = null
var upgrade_manager: UpgradeManager = UpgradeManager.new()
var heavy_push_tier: int = 0
var enable_minions: bool = false
var is_enraged: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$World.process_mode = Node.PROCESS_MODE_PAUSABLE
	$PushSystem.process_mode = Node.PROCESS_MODE_PAUSABLE

	push_system.setup(player, enemies_container)
	push_system.pulse_hit.connect(hitstop.on_pulse_hit)
	player.player_died.connect(_on_player_died)
	player.pulse_fired.connect(_on_pulse_fired)

	# Cấu hình sân đấu: Layout có 1 đoạn Spike Wall ở thành phải (Wave 3 style)
	arena.active_spikes.clear()
	arena.active_spikes.append(Rect2(442, 75, 8, 120))  # Thành phải dài 120px
	arena.queue_redraw()

	_spawn_entities()


func _spawn_entities() -> void:
	# Dọn dẹp quái cũ
	for child in enemies_container.get_children():
		child.queue_free()
	for child in loot_container.get_children():
		child.queue_free()

	# Đặt lại Player
	player.position = Vector2(240, 180)
	player.reset()
	_apply_heavy_push_tier()

	# Spawn Warden
	warden = preload("res://scenes/enemies/warden.tscn").instantiate()
	warden.position = Vector2(240, 60)
	warden.target = player
	warden.arena_ref = arena
	warden.died.connect(_on_warden_died)
	warden.wall_slammed.connect(_on_wall_slam)
	if warden.has_signal("slam_triggered"):
		warden.slam_triggered.connect(_on_warden_slam)
	enemies_container.add_child(warden)

	if is_enraged and warden.has_method("set_enraged"):
		warden.set_enraged(true)

	# Spawn quái đệ nếu bật
	if enable_minions:
		_spawn_minion(Vector2(100, 100))
		_spawn_minion(Vector2(380, 100))


func _spawn_minion(at_pos: Vector2) -> void:
	var minion := preload("res://scenes/enemies/slime.tscn").instantiate()
	minion.position = at_pos
	minion.target = player
	minion.arena_ref = arena
	minion.wall_slammed.connect(_on_wall_slam)
	minion.died.connect(_on_minion_died)
	enemies_container.add_child(minion)


func _apply_heavy_push_tier() -> void:
	upgrade_manager.reset()
	for i in heavy_push_tier:
		upgrade_manager.apply_upgrade("UPG_FORCE")
	player.sync_upgrades(upgrade_manager)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	match event.keycode:
		KEY_R:
			_spawn_entities()
		KEY_M:
			enable_minions = not enable_minions
			_spawn_entities()
		KEY_E:
			is_enraged = not is_enraged
			if warden != null and is_instance_valid(warden) and warden.has_method("set_enraged"):
				warden.set_enraged(is_enraged)
		KEY_C:
			player.pulse_cooldown_left = 0.0
			player.dash_cooldown_left = 0.0
		KEY_T:
			heavy_push_tier = (heavy_push_tier + 1) % 4
			_apply_heavy_push_tier()
		KEY_K:
			if warden != null and is_instance_valid(warden):
				warden.take_damage(1)
		KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/main.tscn")


func _process(_delta: float) -> void:
	_update_debug_hud()


func _update_debug_hud() -> void:
	if debug_label == null:
		return

	var boss_hp_str := "DEAD"
	var boss_action_str := "N/A"
	var boss_slam_timer := 0.0
	var last_dist := 0.0

	if warden != null and is_instance_valid(warden):
		boss_hp_str = "%d/%d" % [warden.hp, warden.max_hp]
		match warden.action_state:
			0: boss_action_str = "CHASE"
			1: boss_action_str = "TELEGRAPH (%.1fs)" % warden.telegraph_timer
			2: boss_action_str = "RECOVERY (%.1fs)" % warden.recovery_timer
		boss_slam_timer = warden.slam_timer
		last_dist = warden.last_push_distance

	# Thanh tim Boss
	var hearts := ""
	if warden != null and is_instance_valid(warden):
		for i in warden.max_hp:
			hearts += "♥" if i < warden.hp else "♡"

	var force_val: float = player.effective_pulse_force
	debug_label.text = """=== BOSS SANDBOX (F020 DEBUG) ===
[R] Reset | [M] Minions: %s | [E] Enraged: %s | [C] Reset CD | [T] Heavy Push: Tier %d | [K] -1 HP | [ESC] Main Menu
BOSS HP: [ %s ] (%s) | STATE: %s | Slam CD: %.1fs
LAST PUSH DIST: %.1f px | FORCE: %.0f px/s | PLAYER HP: %d/%d
""" % [
		"ON (2 Slimes)" if enable_minions else "OFF (0)",
		"ON" if is_enraged else "OFF",
		heavy_push_tier,
		hearts,
		boss_hp_str,
		boss_action_str,
		boss_slam_timer,
		last_dist,
		force_val,
		player.hp,
		player.max_hp
	]


func _on_pulse_fired(_pos: Vector2, _rad: float, _force: float) -> void:
	camera.request_shake(0.12)
	sound_manager.play_pulse()


func _on_warden_slam(at_position: Vector2, _radius: float) -> void:
	camera.request_shake(0.30)
	vfx.spawn_dust(at_position)
	sound_manager.play_wall_slam()


func _on_wall_slam(at_position: Vector2, is_spike: bool) -> void:
	var shake := 0.35 if is_spike else 0.20
	camera.request_shake(shake)
	if is_spike:
		vfx.spawn_floating_text(at_position + Vector2(0, -10), "SPIKE! (2 DMG)", Config.COLOR_SPIKE_WALL)
		vfx.spawn_death_burst(at_position, Config.COLOR_SPIKE_WALL)
	else:
		vfx.spawn_dust(at_position)
		sound_manager.play_wall_slam()


func _on_warden_died(pos: Vector2, _shards: int, _altar: bool, color: Color) -> void:
	camera.request_shake(0.35)
	vfx.spawn_death_burst(pos, color)
	sound_manager.play_altar_seal()
	vfx.spawn_floating_text(pos + Vector2(0, -15), "WARDEN VANQUISHED!", Color(1.0, 0.9, 0.2))


func _on_minion_died(pos: Vector2, _shards: int, _altar: bool, color: Color) -> void:
	vfx.spawn_death_burst(pos, color)


func _on_player_died() -> void:
	camera.request_shake(0.30)
	vfx.spawn_death_burst(player.position, Config.COLOR_PLAYER)
	# Tự động hồi sinh sau 1s trong sandbox
	get_tree().create_timer(1.0).timeout.connect(_spawn_entities)
