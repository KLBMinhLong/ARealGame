## main.gd — Stone Knight M0
## Game state machine + orchestrator.
## States: MENU → RUNNING → PAUSED → DEAD
extends Node2D

enum GameState { MENU, RUNNING, PAUSED, DEAD }

var state: GameState = GameState.MENU

# ─── Stats (reset mỗi run) ──────────────────────────────
var shard_count: int = 0
var best_chain: int = 0
var current_chain: int = 0

# ─── Node references ────────────────────────────────────
@onready var arena: Node2D = $Arena
@onready var player: Node2D = $World/Player
@onready var enemies_container: Node2D = $World/Enemies
@onready var loot_container: Node2D = $World/Loot
@onready var vfx: Node2D = $VFX
@onready var camera: Camera2D = $Camera  # Has camera_shake.gd script
@onready var hud: CanvasLayer = $HUD
@onready var spawn_timer: Timer = $SpawnTimer
@onready var push_system: Node = $PushSystem


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Nhận input khi tree paused
	_setup_spawn_timer()
	push_system.setup(player, enemies_container)
	push_system.chain_updated.connect(on_chain_updated)
	player.player_died.connect(on_player_died)
	# F001: Camera shake wiring
	player.pulse_fired.connect(_on_pulse_for_shake)
	push_system.chain_updated.connect(camera.on_chain_updated)
	_enter_state(GameState.MENU)


func _process(delta: float) -> void:
	match state:
		GameState.RUNNING:
			_process_running(delta)
		GameState.MENU:
			_process_menu()
		GameState.DEAD:
			_process_dead()
		# PAUSED: nothing to process (tree paused)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		match state:
			GameState.RUNNING:
				_enter_state(GameState.PAUSED)
			GameState.PAUSED:
				_enter_state(GameState.RUNNING)

	if event.is_action_pressed("restart_game"):
		if state == GameState.DEAD or state == GameState.PAUSED:
			_restart_run()

	if event.is_action_pressed("pulse"):
		if state == GameState.MENU:
			_start_run()


# ═══════════════════════════════════════════════════════════
# STATE TRANSITIONS
# ═══════════════════════════════════════════════════════════

func _enter_state(new_state: GameState) -> void:
	var old_state := state
	state = new_state

	match new_state:
		GameState.MENU:
			get_tree().paused = false
			_show_menu()

		GameState.RUNNING:
			get_tree().paused = false
			if old_state == GameState.PAUSED:
				hud.show_hud()
			# Hide pause overlay if coming back from pause

		GameState.PAUSED:
			get_tree().paused = true
			camera.clear()  # F001: no residual shake offset during pause
			hud.show_pause()

		GameState.DEAD:
			get_tree().paused = false
			spawn_timer.stop()
			camera.clear()  # F001: clear shake on death
			hud.show_death(shard_count, best_chain)


# ═══════════════════════════════════════════════════════════
# GAME FLOW
# ═══════════════════════════════════════════════════════════

func _start_run() -> void:
	_reset_run_stats()
	_clear_entities()
	player.reset()
	player.visible = true
	spawn_timer.start()
	hud.show_hud()
	camera.clear()  # F001: reset shake on restart
	_enter_state(GameState.RUNNING)


func _restart_run() -> void:
	_start_run()


func _reset_run_stats() -> void:
	shard_count = 0
	best_chain = 0
	current_chain = 0


func _clear_entities() -> void:
	for child in enemies_container.get_children():
		child.queue_free()
	for child in loot_container.get_children():
		child.queue_free()


# ═══════════════════════════════════════════════════════════
# PROCESS PER STATE
# ═══════════════════════════════════════════════════════════

func _process_running(_delta: float) -> void:
	# Update HUD
	hud.update_hud(player.hp, player.max_hp, player.pulse_cooldown_left, 
					Config.PULSE_COOLDOWN, shard_count, best_chain)


func _process_menu() -> void:
	pass  # Menu is static, handled by HUD


func _process_dead() -> void:
	pass  # Death screen is static


# ═══════════════════════════════════════════════════════════
# UI HELPERS
# ═══════════════════════════════════════════════════════════

func _show_menu() -> void:
	player.visible = false
	_clear_entities()
	spawn_timer.stop()
	hud.show_menu()
	camera.clear()  # F001: reset shake on menu


# ═══════════════════════════════════════════════════════════
# SPAWN SYSTEM (M0: continuous, no waves)
# ═══════════════════════════════════════════════════════════

func _setup_spawn_timer() -> void:
	spawn_timer.wait_time = Config.SPAWN_INTERVAL
	spawn_timer.one_shot = false
	spawn_timer.autostart = false
	if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func _on_spawn_timer_timeout() -> void:
	if state != GameState.RUNNING:
		return
	if enemies_container.get_child_count() >= Config.SPAWN_MAX_CONCURRENT:
		return
	_spawn_slime()


func _spawn_slime() -> void:
	var slime := preload("res://scenes/enemies/slime.tscn").instantiate()
	slime.position = _get_spawn_position()
	slime.target = player
	slime.died.connect(_on_enemy_died)
	slime.wall_slammed.connect(_on_wall_slam_for_shake)  # F001
	enemies_container.add_child(slime)


func _get_spawn_position() -> Vector2:
	# Random spawn trên 4 rìa playable, cách player >= SPAWN_MIN_DISTANCE
	var pos := Vector2.ZERO
	var safe := false
	var attempts := 0

	while not safe and attempts < 20:
		var edge := randi() % 4
		match edge:
			0:  # Top
				pos = Vector2(randf_range(Config.ARENA_ORIGIN.x, Config.ARENA_END.x), Config.ARENA_ORIGIN.y)
			1:  # Bottom
				pos = Vector2(randf_range(Config.ARENA_ORIGIN.x, Config.ARENA_END.x), Config.ARENA_END.y)
			2:  # Left
				pos = Vector2(Config.ARENA_ORIGIN.x, randf_range(Config.ARENA_ORIGIN.y, Config.ARENA_END.y))
			3:  # Right
				pos = Vector2(Config.ARENA_END.x, randf_range(Config.ARENA_ORIGIN.y, Config.ARENA_END.y))

		if pos.distance_to(player.position) >= Config.SPAWN_MIN_DISTANCE:
			safe = true
		attempts += 1

	return pos


# ═══════════════════════════════════════════════════════════
# SIGNALS FROM GAMEPLAY
# ═══════════════════════════════════════════════════════════

func _on_enemy_died(enemy_position: Vector2, shard_amount: int, _is_altar_seal: bool) -> void:
	# Spawn shards
	for i in shard_amount:
		_spawn_shard(enemy_position)
	# Chain tracking would go here


func _spawn_shard(at_position: Vector2) -> void:
	var shard := preload("res://scenes/shard.tscn").instantiate()
	shard.position = at_position + Vector2(randf_range(-5, 5), randf_range(-5, 5))
	shard.player_ref = player
	shard.collected.connect(_on_shard_collected)
	loot_container.add_child(shard)


func _on_shard_collected() -> void:
	shard_count += 1


func on_player_died() -> void:
	_enter_state(GameState.DEAD)


func on_chain_updated(chain_count: int) -> void:
	current_chain = chain_count
	if chain_count > best_chain:
		best_chain = chain_count


# ═══════════════════════════════════════════════════════════
# F001: CAMERA SHAKE EVENT ADAPTERS
# ═══════════════════════════════════════════════════════════

func _on_pulse_for_shake(_position: Vector2, _radius: float) -> void:
	camera.request_shake(Config.SHAKE_PULSE)


func _on_wall_slam_for_shake(_at_position: Vector2) -> void:
	camera.request_shake(Config.SHAKE_WALL_SLAM)
