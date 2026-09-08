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
var run_time: float = 0.0  # F010: difficulty scaling

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
@onready var hitstop: Node = $HitstopSystem  # F002
@onready var combo_popup: Node = $HUD/ComboPopup  # F003


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Main nhận input khi tree paused
	# Gameplay nodes phải dừng khi pause (không kế thừa ALWAYS từ Main)
	$World.process_mode = Node.PROCESS_MODE_PAUSABLE
	$PushSystem.process_mode = Node.PROCESS_MODE_PAUSABLE
	$SpawnTimer.process_mode = Node.PROCESS_MODE_PAUSABLE
	_setup_spawn_timer()
	push_system.setup(player, enemies_container)
	push_system.chain_updated.connect(on_chain_updated)
	player.player_died.connect(on_player_died)
	# F001: Camera shake wiring
	player.pulse_fired.connect(_on_pulse_for_shake)
	push_system.chain_updated.connect(camera.on_chain_updated)
	# F002: Hit-stop wiring
	push_system.pulse_hit.connect(hitstop.on_pulse_hit)
	push_system.chain_updated.connect(hitstop.on_chain_hit)
	# F003: Combo popup wiring (dùng chain_hit_visual có vị trí)
	push_system.chain_hit_visual.connect(combo_popup.on_chain_hit_visual)
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
			camera.clear()  # F001
			hitstop.clear()  # F002: restore time_scale
			hud.show_pause()

		GameState.DEAD:
			get_tree().paused = false
			spawn_timer.stop()
			camera.clear()  # F001
			hitstop.clear()  # F002: restore time_scale
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
	camera.clear()  # F001
	hitstop.clear()  # F002
	combo_popup.clear()  # F003
	vfx.clear()  # F004
	_enter_state(GameState.RUNNING)


func _restart_run() -> void:
	_start_run()


func _reset_run_stats() -> void:
	shard_count = 0
	best_chain = 0
	current_chain = 0
	run_time = 0.0  # F010


func _clear_entities() -> void:
	for child in enemies_container.get_children():
		child.queue_free()
	for child in loot_container.get_children():
		child.queue_free()


# ═══════════════════════════════════════════════════════════
# PROCESS PER STATE
# ═══════════════════════════════════════════════════════════

func _process_running(delta: float) -> void:
	run_time += delta  # F010: difficulty scaling
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
	camera.clear()  # F001
	hitstop.clear()  # F002
	combo_popup.clear()  # F003
	vfx.clear()  # F004


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
	# F010: dynamic max concurrent
	var scale_t := clampf(run_time / Config.SCALE_DURATION, 0.0, 1.0)
	var max_enemies := int(lerpf(Config.SPAWN_MAX_CONCURRENT, Config.SPAWN_MAX_CAP, scale_t))
	if enemies_container.get_child_count() >= max_enemies:
		return
	_spawn_enemy()
	# F010: update interval for next tick
	var new_interval := lerpf(Config.SPAWN_INTERVAL, Config.SPAWN_INTERVAL_MIN, scale_t)
	spawn_timer.wait_time = new_interval


func _spawn_enemy() -> void:
	var enemy: Node2D
	# F012: Phased enemy pacing based on run_time
	var speeder_chance: float = 0.0
	var brute_chance: float = 0.0

	if run_time < Config.PHASE_SPEEDER_START:
		# Giai đoạn 1 (0 – 60s): 100% Slime
		speeder_chance = 0.0
		brute_chance = 0.0
	elif run_time < Config.PHASE_BRUTE_START:
		# Giai đoạn 2 (60s – 150s): Speeder xuất hiện 0% -> 40%
		var t2 := (run_time - Config.PHASE_SPEEDER_START) / (Config.PHASE_BRUTE_START - Config.PHASE_SPEEDER_START)
		speeder_chance = lerpf(0.0, Config.PHASE2_SPEEDER_MAX, t2)
		brute_chance = 0.0
	else:
		# Giai đoạn 3 (150s+): Brute xuất hiện 0% -> 25%, Speeder 40% -> 45%
		var t3 := clampf((run_time - Config.PHASE_BRUTE_START) / (Config.PHASE_RAMP_END - Config.PHASE_BRUTE_START), 0.0, 1.0)
		speeder_chance = lerpf(Config.PHASE2_SPEEDER_MAX, Config.PHASE3_SPEEDER_FINAL, t3)
		brute_chance = lerpf(0.0, Config.PHASE3_BRUTE_FINAL, t3)

	var roll := randf()
	if roll < brute_chance:
		enemy = preload("res://scenes/enemies/brute.tscn").instantiate()
	elif roll < brute_chance + speeder_chance:
		enemy = preload("res://scenes/enemies/speeder.tscn").instantiate()
	else:
		enemy = preload("res://scenes/enemies/slime.tscn").instantiate()

	enemy.position = _get_spawn_position()
	enemy.target = player
	enemy.died.connect(_on_enemy_died)
	enemy.wall_slammed.connect(_on_wall_slam)
	enemies_container.add_child(enemy)


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

func _on_enemy_died(enemy_position: Vector2, shard_amount: int, _is_altar_seal: bool, color: Color) -> void:
	for i in shard_amount:
		_spawn_shard(enemy_position)
	vfx.spawn_death_burst(enemy_position, color)  # F006 + F009: dùng enemy color


func _spawn_shard(at_position: Vector2) -> void:
	var shard := preload("res://scenes/shard.tscn").instantiate()
	shard.position = at_position + Vector2(randf_range(-5, 5), randf_range(-5, 5))
	shard.player_ref = player
	shard.collected.connect(_on_shard_collected)
	loot_container.add_child(shard)


func _on_shard_collected(at_position: Vector2) -> void:
	shard_count += 1
	vfx.spawn_pickup_burst(at_position)  # F007


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


func _on_wall_slam(at_position: Vector2) -> void:
	camera.request_shake(Config.SHAKE_WALL_SLAM)  # F001
	vfx.spawn_dust(at_position)  # F004
