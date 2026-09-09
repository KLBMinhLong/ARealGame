## main.gd — Stone Knight M0
## Game state machine + orchestrator.
## States: MENU → RUNNING → PAUSED → DEAD
extends Node2D

enum GameState { MENU, RUNNING, PAUSED, DEAD, VICTORY }

var state: GameState = GameState.MENU

# ─── Stats (reset mỗi run) ──────────────────────────────
var shard_count: int = 0
var best_chain: int = 0
var current_chain: int = 0
var run_time: float = 0.0  # F010: difficulty scaling
var enemies_killed: int = 0  # F013: run summary

# ─── Wave System (F017) & Upgrades (F018) ───────────────
enum WavePhase { PRE_WAVE, SPAWNING, CLEAR_REMAINING, UPGRADE_SELECTION, INTERMISSION, COMPLETE }

var current_wave: int = 1
var wave_phase: WavePhase = WavePhase.PRE_WAVE
var wave_time_left: float = 0.0
var phase_timer: float = 0.0
var wave_spawned_count: int = 0
var guaranteed_spawns_queue: Array[String] = []
var active_warden: Node2D = null
var warden_enraged_announced: bool = false


var upgrade_manager: UpgradeManager = UpgradeManager.new()
var upgrade_selection_ui: CanvasLayer = null

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
@onready var sound_manager: Node = $SoundManager  # F016


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Main nhận input khi tree paused
	# Gameplay nodes phải dừng khi pause (không kế thừa ALWAYS từ Main)
	$World.process_mode = Node.PROCESS_MODE_PAUSABLE
	$PushSystem.process_mode = Node.PROCESS_MODE_PAUSABLE
	$SpawnTimer.process_mode = Node.PROCESS_MODE_PAUSABLE
	_setup_spawn_timer()
	_setup_upgrade_ui()
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
	# F016: Sound wiring
	player.pulse_fired.connect(_on_pulse_for_sound)
	player.dash_started.connect(sound_manager.play_dash)
	player.player_hit.connect(_on_player_hit_for_sound)
	push_system.chain_hit_visual.connect(_on_domino_for_sound)
	_enter_state(GameState.MENU)


func _setup_upgrade_ui() -> void:
	var ui_scene = preload("res://scenes/ui/upgrade_selection.tscn")
	upgrade_selection_ui = ui_scene.instantiate()
	upgrade_selection_ui.upgrade_selected.connect(_on_upgrade_card_selected)
	add_child(upgrade_selection_ui)


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
		if wave_phase == WavePhase.UPGRADE_SELECTION:
			return
		match state:
			GameState.RUNNING:
				_enter_state(GameState.PAUSED)
			GameState.PAUSED:
				_enter_state(GameState.RUNNING)

	if event.is_action_pressed("restart_game"):
		if state == GameState.DEAD or state == GameState.PAUSED or state == GameState.VICTORY or state == GameState.RUNNING:
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
			if upgrade_selection_ui != null:
				upgrade_selection_ui.hide_selection()
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
			sound_manager.stop_combat_sounds()  # F016
			hud.show_pause()

		GameState.DEAD:
			get_tree().paused = false
			if upgrade_selection_ui != null:
				upgrade_selection_ui.hide_selection()
			spawn_timer.stop()
			player.is_invulnerable = true
			camera.clear()  # F001
			hitstop.clear()  # F002: restore time_scale
			sound_manager.play_game_over()  # F016: stops combat & plays game over
			hud.show_death(run_time, enemies_killed, shard_count, best_chain, current_wave)

		GameState.VICTORY:
			get_tree().paused = false
			if upgrade_selection_ui != null:
				upgrade_selection_ui.hide_selection()
			spawn_timer.stop()
			player.is_invulnerable = true
			camera.clear()
			hitstop.clear()
			sound_manager.stop_combat_sounds()
			sound_manager.play_altar_seal()
			hud.show_victory(run_time, enemies_killed, shard_count, best_chain)


# ═══════════════════════════════════════════════════════════
# GAME FLOW
# ═══════════════════════════════════════════════════════════

func _start_run() -> void:
	get_tree().paused = false
	if upgrade_selection_ui != null:
		upgrade_selection_ui.hide_selection()
	_reset_run_stats()
	_clear_entities()
	player.reset()
	upgrade_manager.reset()
	player.sync_upgrades(upgrade_manager)
	arena.set_layout(1)  # F019: reset layout sạch về Wave 1
	player.visible = true
	hud.show_hud()
	camera.clear()  # F001
	hitstop.clear()  # F002
	combo_popup.clear()  # F003
	vfx.clear()  # F004
	sound_manager.clear()  # F016
	_enter_state(GameState.RUNNING)
	_start_wave(1)


func _restart_run() -> void:
	_start_run()


func _reset_run_stats() -> void:
	shard_count = 0
	best_chain = 0
	current_chain = 0
	run_time = 0.0  # F010
	enemies_killed = 0  # F013
	current_wave = 1
	wave_phase = WavePhase.PRE_WAVE
	wave_time_left = 0.0
	phase_timer = 0.0
	wave_spawned_count = 0
	guaranteed_spawns_queue.clear()


func _clear_entities() -> void:
	active_warden = null
	warden_enraged_announced = false
	_despawn_all_entities("clear_entities")



func _despawn_all_entities(_reason: String = "") -> void:
	for child in enemies_container.get_children():
		if is_instance_valid(child):
			# Disconnect signals to prevent awarding kills, shards, or triggering SFX
			if child.died.is_connected(_on_enemy_died):
				child.died.disconnect(_on_enemy_died)
			if child.wall_slammed.is_connected(_on_wall_slam):
				child.wall_slammed.disconnect(_on_wall_slam)
			child.queue_free()
	for child in loot_container.get_children():
		if is_instance_valid(child):
			if child.collected.is_connected(_on_shard_collected):
				child.collected.disconnect(_on_shard_collected)
			child.queue_free()


# ═══════════════════════════════════════════════════════════
# PROCESS PER STATE
# ═══════════════════════════════════════════════════════════

func _process_running(delta: float) -> void:
	if wave_phase == WavePhase.UPGRADE_SELECTION:
		hud.update_hud(
			player.hp, player.max_hp, player.pulse_cooldown_left,
			player.effective_pulse_cooldown_max, shard_count, best_chain,
			player.dash_cooldown_left, current_wave, Config.TOTAL_WAVES,
			0.0, false, 0.0,
			false, 0, false,
			true
		)
		return

	run_time += delta  # F010: total run timer

	# F017: Wave lifecycle state machine
	match wave_phase:
		WavePhase.PRE_WAVE:
			phase_timer -= delta
			if phase_timer <= 0.0:
				wave_phase = WavePhase.SPAWNING
				var wave_idx := clampi(current_wave - 1, 0, Config.WAVES_DATA.size() - 1)
				var wave_data: Dictionary = Config.WAVES_DATA[wave_idx]
				spawn_timer.wait_time = wave_data.get("interval_start", 2.2)
				spawn_timer.start()
				_try_spawn_enemy()

		WavePhase.SPAWNING:
			var wave_idx := clampi(current_wave - 1, 0, Config.WAVES_DATA.size() - 1)
			var wave_data: Dictionary = Config.WAVES_DATA[wave_idx]
			var budget: int = wave_data.get("spawn_budget", 14)

			if current_wave == 5:
				# F020: Wave 5 Boss Fight Rules
				if wave_time_left > 0.0:
					wave_time_left -= delta
					if wave_time_left <= 0.0:
						wave_time_left = 0.0
						if not warden_enraged_announced:
							warden_enraged_announced = true
							if active_warden != null and is_instance_valid(active_warden):
								if active_warden.has_method("set_enraged"):
									active_warden.set_enraged(true)
							hud.show_banner("🔥  WARDEN ENRAGED!  🔥", 2.2, Color(1.0, 0.4, 0.1))
				# Wave 5 KHÔNG tự động kết thúc hoặc sang CLEAR_REMAINING khi hết giờ.
				# Chỉ hoàn thành khi Warden bị tiêu diệt!
			else:
				wave_time_left -= delta
				if wave_time_left <= 0.0 or wave_spawned_count >= budget:
					wave_time_left = 0.0
					spawn_timer.stop()
					wave_phase = WavePhase.CLEAR_REMAINING
					if _get_active_enemy_count() == 0:
						_on_wave_cleared()


		WavePhase.CLEAR_REMAINING:
			if _get_active_enemy_count() == 0:
				_on_wave_cleared()

		WavePhase.UPGRADE_SELECTION:
			pass

		WavePhase.INTERMISSION:
			phase_timer -= delta
			if phase_timer <= 0.0:
				if current_wave >= Config.TOTAL_WAVES:
					wave_phase = WavePhase.COMPLETE
					_enter_state(GameState.VICTORY)
				else:
					_start_wave(current_wave + 1)

		WavePhase.COMPLETE:
			pass

	var is_interm := (wave_phase == WavePhase.INTERMISSION)
	var is_clearing := (wave_phase == WavePhase.CLEAR_REMAINING)
	var is_pre := (wave_phase == WavePhase.PRE_WAVE)
	var is_upg := (wave_phase == WavePhase.UPGRADE_SELECTION)
	var active_enemies := _get_active_enemy_count()

	hud.update_hud(
		player.hp, player.max_hp, player.pulse_cooldown_left,
		player.effective_pulse_cooldown_max, shard_count, best_chain,
		player.dash_cooldown_left, current_wave, Config.TOTAL_WAVES,
		wave_time_left, is_interm, phase_timer,
		is_clearing, active_enemies, is_pre,
		is_upg
	)


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
# WAVE SYSTEM (F017) & UPGRADES (F018)
# ═══════════════════════════════════════════════════════════

func _start_wave(wave_num: int) -> void:
	current_wave = wave_num
	wave_spawned_count = 0
	var wave_idx := clampi(current_wave - 1, 0, Config.WAVES_DATA.size() - 1)
	var wave_data: Dictionary = Config.WAVES_DATA[wave_idx]
	wave_time_left = wave_data.get("duration", 35.0)

	# Guaranteed introductory spawns
	guaranteed_spawns_queue.clear()
	var guaranteed: Array = wave_data.get("guaranteed_spawns", [])
	for item in guaranteed:
		guaranteed_spawns_queue.append(str(item))

	# PRE_WAVE phase: player positions, banner displayed, no spawn
	wave_phase = WavePhase.PRE_WAVE
	phase_timer = Config.WAVE_PRE_DURATION
	spawn_timer.stop()
	arena.set_layout(current_wave)  # F019: áp dụng layout an toàn trong PRE_WAVE
	if current_wave == 5:
		hud.show_banner("⚠  BOSS: THE WARDEN  ⚠", 2.5, Color(1.0, 0.35, 0.35))
	else:
		hud.show_banner("⚔  WAVE %d: %s  ⚔" % [current_wave, str(wave_data.get("name", "")).to_upper()], Config.WAVE_BANNER_DURATION)


func _on_wave_cleared() -> void:
	spawn_timer.stop()
	if current_wave >= Config.TOTAL_WAVES:
		wave_phase = WavePhase.INTERMISSION
		phase_timer = 2.0  # Celebration pause before Victory
		sound_manager.play_altar_seal()  # Audio cue
		hud.show_banner("✨  THE WARDEN VANQUISHED!  ✨", 2.2, Color(1.0, 0.9, 0.2))

	else:
		# F018: Waves 1-4 trigger 3-card upgrade selection
		var cards := upgrade_manager.draw_cards(3)
		if cards.is_empty():
			_start_intermission()
		else:
			wave_phase = WavePhase.UPGRADE_SELECTION
			sound_manager.play_altar_seal()
			get_tree().paused = true
			upgrade_selection_ui.show_selection(cards)


func _on_upgrade_card_selected(upgrade_id: String) -> void:
	get_tree().paused = false
	upgrade_manager.apply_upgrade(upgrade_id)
	player.sync_upgrades(upgrade_manager)
	sound_manager.play_shard()
	_start_intermission()


func _start_intermission() -> void:
	wave_phase = WavePhase.INTERMISSION
	phase_timer = Config.WAVE_INTERMISSION_DURATION
	hud.show_banner("✨  WAVE %d CLEARED!  ✨" % current_wave, Config.WAVE_BANNER_DURATION, Color(0.4, 1.0, 0.6))


func _get_active_enemy_count() -> int:
	var count := 0
	for child in enemies_container.get_children():
		if is_instance_valid(child) and not child.is_queued_for_deletion():
			if "hp" in child and child.hp > 0:
				# Safety watchdog: clamp or recover out-of-bounds enemies
				if is_nan(child.position.x) or is_nan(child.position.y) or child.position.x < -50 or child.position.x > Config.VIEWPORT_W + 50 or child.position.y < -50 or child.position.y > Config.VIEWPORT_H + 50:
					push_warning("[WATCHDOG] Enemy out of bounds at %s, repositioning to arena center" % str(child.position))
					child.position = Config.ARENA_CENTER
				count += 1
	return count


func _setup_spawn_timer() -> void:
	spawn_timer.one_shot = false
	spawn_timer.autostart = false
	if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func _on_spawn_timer_timeout() -> void:
	if state != GameState.RUNNING or wave_phase != WavePhase.SPAWNING:
		return
	_try_spawn_enemy()


func _try_spawn_enemy() -> void:
	if state != GameState.RUNNING or wave_phase != WavePhase.SPAWNING:
		return

	var wave_idx := clampi(current_wave - 1, 0, Config.WAVES_DATA.size() - 1)
	var wave_data: Dictionary = Config.WAVES_DATA[wave_idx]
	var budget: int = wave_data.get("spawn_budget", 14)
	if wave_spawned_count >= budget:
		wave_phase = WavePhase.CLEAR_REMAINING
		spawn_timer.stop()
		return

	var max_active: int = wave_data.get("max_active", 8)
	if _get_active_enemy_count() >= max_active:
		return

	_spawn_enemy(wave_data)
	wave_spawned_count += 1

	if wave_spawned_count >= budget:
		wave_phase = WavePhase.CLEAR_REMAINING
		spawn_timer.stop()
		return

	# Dynamic interval scaling as wave progresses
	var wave_dur: float = wave_data.get("duration", 35.0)
	var progress := clampf(1.0 - (wave_time_left / wave_dur), 0.0, 1.0)
	var interval_start: float = wave_data.get("interval_start", 2.2)
	var interval_end: float = wave_data.get("interval_end", 1.5)
	spawn_timer.wait_time = lerpf(interval_start, interval_end, progress)


func _spawn_enemy(wave_data: Dictionary) -> void:
	var enemy_type := ""
	if not guaranteed_spawns_queue.is_empty():
		enemy_type = guaranteed_spawns_queue.pop_front()
	else:
		var speeder_chance: float = wave_data.get("speeder_chance", 0.0)
		var brute_chance: float = wave_data.get("brute_chance", 0.0)
		var roll := randf()
		if roll < brute_chance:
			enemy_type = "brute"
		elif roll < brute_chance + speeder_chance:
			enemy_type = "speeder"
		else:
			enemy_type = "slime"

	var enemy: Node2D
	match enemy_type:
		"warden":
			enemy = preload("res://scenes/enemies/warden.tscn").instantiate()
			active_warden = enemy
			if enemy.has_signal("slam_triggered"):
				enemy.slam_triggered.connect(_on_warden_slam)
		"brute":
			enemy = preload("res://scenes/enemies/brute.tscn").instantiate()
		"speeder":
			enemy = preload("res://scenes/enemies/speeder.tscn").instantiate()
		_:
			enemy = preload("res://scenes/enemies/slime.tscn").instantiate()

	if enemy_type == "warden":
		enemy.position = Vector2(Config.VIEWPORT_W / 2.0, Config.ARENA_ORIGIN.y + 40.0)
	else:
		enemy.position = _get_spawn_position()

	enemy.target = player
	enemy.arena_ref = arena  # F019: reference cho va chạm hazard
	enemy.died.connect(_on_enemy_died)
	enemy.wall_slammed.connect(_on_wall_slam)
	enemies_container.add_child(enemy)


func _on_warden_slam(at_position: Vector2, _radius: float) -> void:
	camera.request_shake(0.30)
	vfx.spawn_dust(at_position)
	sound_manager.play_wall_slam()


func _on_warden_defeated() -> void:
	camera.request_shake(0.35)
	sound_manager.play_altar_seal()
	# Xóa toàn bộ quái đệ còn lại trên sân
	for child in enemies_container.get_children():
		if child != active_warden and is_instance_valid(child):
			vfx.spawn_death_burst(child.position, child.enemy_color)
			child.queue_free()
	spawn_timer.stop()
	active_warden = null
	_on_wave_cleared()



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

func _on_enemy_died(enemy_position: Vector2, shard_amount: int, is_altar_seal: bool, color: Color) -> void:
	enemies_killed += 1  # F013
	if is_altar_seal:
		# F015: Altar Seal — tiền tự động cộng thẳng vào túi, không rơi ra đất
		shard_count += shard_amount
		vfx.spawn_altar_seal_vfx(Config.ALTAR_POSITION)
		vfx.spawn_floating_text(Config.ALTAR_POSITION + Vector2(0, -14), "+%d" % shard_amount, Config.COLOR_SHARD)
		arena.trigger_altar_flash()
		camera.request_shake(Config.SHAKE_ALTAR_SEAL)
		sound_manager.play_altar_seal()  # F016
	else:
		for i in shard_amount:
			_spawn_shard(enemy_position)
		vfx.spawn_death_burst(enemy_position, color)  # F006 + F009: dùng enemy color

	# F020: Kiểm tra nếu Warden bị tiêu diệt ở Wave 5
	if current_wave == 5 and active_warden != null and (active_warden.hp <= 0 or active_warden.enemy_state == EnemyBase.EnemyState.DYING):
		_on_warden_defeated()
		return

	# If in cleanup phase, check if this was the last remaining enemy
	if wave_phase == WavePhase.CLEAR_REMAINING and _get_active_enemy_count() == 0:
		_on_wave_cleared()



func _spawn_shard(at_position: Vector2) -> void:
	var shard := preload("res://scenes/shard.tscn").instantiate()
	shard.position = at_position + Vector2(randf_range(-5, 5), randf_range(-5, 5))
	shard.player_ref = player
	shard.collected.connect(_on_shard_collected)
	loot_container.add_child(shard)


func _on_shard_collected(at_position: Vector2) -> void:
	shard_count += 1
	vfx.spawn_pickup_burst(at_position)  # F007
	sound_manager.play_shard()  # F016


func on_player_died() -> void:
	_enter_state(GameState.DEAD)


func on_chain_updated(chain_count: int) -> void:
	current_chain = chain_count
	if chain_count > best_chain:
		best_chain = chain_count
	if chain_count >= 2:
		sound_manager.play_combo(chain_count)  # F016


# ═══════════════════════════════════════════════════════════
# F001: CAMERA SHAKE EVENT ADAPTERS
# ═══════════════════════════════════════════════════════════

func _on_pulse_for_shake(_position: Vector2, _radius: float, _force: float = 0.0) -> void:
	camera.request_shake(Config.SHAKE_PULSE)


func _on_wall_slam(at_position: Vector2, is_spike: bool = false) -> void:
	var shake_val: float = clampf(Config.SHAKE_WALL_SLAM * 1.5, 0.0, 0.35) if is_spike else Config.SHAKE_WALL_SLAM
	camera.request_shake(shake_val)  # F001 + F019
	if is_spike:
		vfx.spawn_floating_text(at_position + Vector2(0, -10), "SPIKE! +1 SHARD", Config.COLOR_SPIKE_WALL)
		vfx.spawn_death_burst(at_position, Config.COLOR_SPIKE_WALL)
	else:
		vfx.spawn_dust(at_position)  # F004
	sound_manager.play_wall_slam()  # F016


# ═══════════════════════════════════════════════════════════
# F016: SOUND EVENT ADAPTERS
# ═══════════════════════════════════════════════════════════

func _on_pulse_for_sound(_position: Vector2, _radius: float, _force: float = 0.0) -> void:
	sound_manager.play_pulse()


func _on_player_hit_for_sound(_hp_remaining: int) -> void:
	sound_manager.play_player_hurt()


func _on_domino_for_sound(_at_position: Vector2, _chain_count: int) -> void:
	sound_manager.play_domino()
