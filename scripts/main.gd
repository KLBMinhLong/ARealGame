extends Node2D
## Main owns state and tick order. No global autoloads, plugins, or network calls.

const Config = preload("res://scripts/core/game_config.gd")
const PlayerActor = preload("res://scripts/actors/player.gd")
const EnemyActor = preload("res://scripts/actors/enemy.gd")
const HudView = preload("res://scripts/ui/hud.gd")
const EnemyScene = preload("res://scenes/enemy.tscn")
const ScrapActor = preload("res://scripts/actors/scrap.gd")
const SaveManager = preload("res://scripts/core/save_manager.gd")
const SettingsManager = preload("res://scripts/core/settings_manager.gd")
const AudioManager = preload("res://scripts/core/audio_manager.gd")
enum State { MENU, RUNNING, PAUSED, WON, LOST }

@onready var player: PlayerActor = $World/Player
@onready var enemies: Node2D = $World/Enemies
@onready var hud: HudView = $HUD
var scraps: Node2D
var save_manager: SaveManager
var settings_manager: SettingsManager
var custom_save_path: String = ""
var custom_settings_path: String = ""
var audio_manager: AudioManager = AudioManager.new()
var state: State = State.MENU
var elapsed: float = 0.0
var spawn_remaining: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var current_scraps: int = 0
var total_scraps: int = 0
var upgrade_level: int = 0
var next_upgrade_threshold: int = 15
var upgrade_tiers: Dictionary = {
	"kinetic": 0,
	"overclock": 0,
	"siphon": 0,
	"tesla": 0,
	"aegis": 0
}
var camera_trauma: float = 0.0

func _ready() -> void:
	Engine.max_fps = 60
	rng.randomize()
	if save_manager == null:
		save_manager = SaveManager.new(custom_save_path)
	if settings_manager == null:
		settings_manager = SettingsManager.new(custom_settings_path)
	add_child(audio_manager)
	if has_node("World/Scraps"):
		scraps = $World/Scraps
	else:
		scraps = Node2D.new()
		scraps.name = "Scraps"
		$World.add_child(scraps)
	save_manager.load_data()
	settings_manager.load_settings()
	settings_manager.settings_changed.connect(_on_settings_changed)
	hud.configure_settings(settings_manager)
	_on_settings_changed()
	hud.set_best_record(save_manager.best_survival_seconds, save_manager.win_count, save_manager.total_runs)
	hud.start_requested.connect(start_run)
	hud.resume_requested.connect(resume_run)
	hud.menu_requested.connect(return_to_menu)
	hud.upgrade_selected.connect(apply_upgrade)
	hud.quit_requested.connect(func() -> void: get_tree().quit())
	player.health_changed.connect(hud.set_health)
	player.pulse_triggered.connect(_on_player_pulse)
	return_to_menu()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and state == State.RUNNING:
		pause_run()

func _process(delta: float) -> void:
	if camera_trauma > 0.0:
		camera_trauma = maxf(0.0, camera_trauma - delta * 1.8)
		var shake: float = camera_trauma * camera_trauma
		$World.position = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) * shake * 10.0
	else:
		$World.position = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if hud.panel_mode == "upgrade":
		if event is InputEventKey and event.pressed and not event.echo:
			if event.physical_keycode == KEY_1 or event.keycode == KEY_1:
				hud.select_upgrade_by_index(0)
				get_viewport().set_input_as_handled()
				return
			elif event.physical_keycode == KEY_2 or event.keycode == KEY_2:
				hud.select_upgrade_by_index(1)
				get_viewport().set_input_as_handled()
				return
			elif event.physical_keycode == KEY_3 or event.keycode == KEY_3:
				hud.select_upgrade_by_index(2)
				get_viewport().set_input_as_handled()
				return

	if event.is_action_pressed("pause_game") or (event is InputEventKey and event.pressed and not event.echo and (event.physical_keycode == KEY_ESCAPE or event.keycode == KEY_ESCAPE)):
		if hud.panel_mode == "tutorial" or hud.panel_mode == "settings" or hud.panel_mode == "credits":
			hud.show_panel(hud.previous_panel_mode)
			get_viewport().set_input_as_handled()
			return
		if state == State.RUNNING:
			pause_run()
			get_viewport().set_input_as_handled()
		elif state == State.PAUSED and hud.panel_mode != "upgrade":
			resume_run()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart_game") or (event is InputEventKey and event.pressed and not event.echo and (event.physical_keycode == KEY_R or event.keycode == KEY_R)):
		if hud.panel_mode == "tutorial" or hud.panel_mode == "settings" or hud.panel_mode == "credits" or hud.panel_mode == "upgrade":
			return
		start_run()
		get_viewport().set_input_as_handled()

func _on_settings_changed() -> void:
	if player != null:
		player.reduced_effects = settings_manager.reduced_effects

func start_run() -> void:
	_clear_enemies()
	_clear_scraps()
	elapsed = 0.0
	current_scraps = 0
	total_scraps = 0
	upgrade_level = 0
	next_upgrade_threshold = 15
	upgrade_tiers = {"kinetic": 0, "overclock": 0, "siphon": 0, "tesla": 0, "aegis": 0}
	spawn_remaining = 0.8
	camera_trauma = 0.0
	player.reset()
	state = State.RUNNING
	hud.hide_panel()
	hud.update_run(elapsed, 0, player.pulse_cooldown_remaining, current_scraps, next_upgrade_threshold)
	audio_manager.start_music()

func return_to_menu() -> void:
	state = State.MENU
	_clear_enemies()
	_clear_scraps()
	elapsed = 0.0
	camera_trauma = 0.0
	player.reset()
	audio_manager.stop_music()
	hud.set_best_record(save_manager.best_survival_seconds, save_manager.win_count, save_manager.total_runs)
	hud.update_run(0.0, 0, 0.0, 0, 15)
	hud.show_panel("menu")

func pause_run() -> void:
	if state != State.RUNNING:
		return
	state = State.PAUSED
	audio_manager.pause_music(true)
	hud.show_panel("paused")

func resume_run() -> void:
	if state != State.PAUSED:
		return
	state = State.RUNNING
	audio_manager.pause_music(false)
	hud.hide_panel()

func _physics_process(delta: float) -> void:
	if state != State.RUNNING:
		return
	player.tick(delta)
	elapsed = minf(elapsed + delta, Config.RUN_SECONDS)
	if elapsed >= Config.RUN_SECONDS:
		finish_run(true)
		return
	spawn_remaining -= delta
	if spawn_remaining <= 0.0:
		spawn_one()
		spawn_remaining = Config.spawn_interval(elapsed)

	# Flocking separation among chasers:
	var enemy_list: Array = enemies.get_children()
	for i in range(enemy_list.size()):
		var enemy_a: EnemyActor = enemy_list[i] as EnemyActor
		if enemy_a == null or not is_instance_valid(enemy_a):
			continue
		var separation: Vector2 = Vector2.ZERO
		if enemy_a.enemy_type == EnemyActor.Type.CHASER:
			for j in range(enemy_list.size()):
				if i == j:
					continue
				var enemy_b: EnemyActor = enemy_list[j] as EnemyActor
				if enemy_b != null and is_instance_valid(enemy_b) and enemy_b.enemy_type == EnemyActor.Type.CHASER:
					var dist_sq: float = enemy_a.position.distance_squared_to(enemy_b.position)
					if dist_sq < 3600.0 and dist_sq > 0.001:
						var diff: Vector2 = enemy_a.position - enemy_b.position
						separation += diff.normalized() * (1.0 - sqrt(dist_sq) / 60.0)
		enemy_a.tick(delta, player.position, separation)
		var hit_radius: float = Config.PLAYER_RADIUS + Config.ENEMY_RADIUS
		if enemy_a.position.distance_squared_to(player.position) <= hit_radius * hit_radius:
			register_hit()
			if state != State.RUNNING:
				break

	# Process scraps:
	if scraps != null:
		for scrap_child in scraps.get_children():
			var scrap: ScrapItem = scrap_child as ScrapItem
			if scrap != null and is_instance_valid(scrap):
				scrap.tick(delta, player.position, player.magnet_radius, player.magnet_speed)

	hud.update_run(elapsed, enemies.get_child_count(), player.pulse_cooldown_remaining, current_scraps, next_upgrade_threshold)

func _on_player_pulse() -> void:
	if state != State.RUNNING:
		return
	audio_manager.play_pulse()
	camera_trauma = minf(1.0, camera_trauma + 0.3)
	var pushed_enemies: Array[EnemyActor] = []
	for child in enemies.get_children():
		var enemy: EnemyActor = child as EnemyActor
		if enemy == null or not is_instance_valid(enemy):
			continue
		if enemy.position.distance_to(player.position) <= player.pulse_radius:
			var push_res: Dictionary = enemy.push_back(player.position, Config.PULSE_PUSH_DISTANCE, Config.PULSE_STUN_SECONDS, player.pulse_push_force)
			pushed_enemies.append(enemy)
			if push_res.get("hit_wall", false):
				camera_trauma = minf(1.0, camera_trauma + 0.45)
				audio_manager.play_wall_slam()
				enemy.take_damage(1, true)

	# Domino collision check:
	for pushed in pushed_enemies:
		if not is_instance_valid(pushed) or pushed.health <= 0:
			continue
		for other in enemies.get_children():
			var other_enemy: EnemyActor = other as EnemyActor
			if other_enemy == null or other_enemy == pushed or not is_instance_valid(other_enemy):
				continue
			if pushed.position.distance_squared_to(other_enemy.position) <= (Config.ENEMY_RADIUS * 2.2) * (Config.ENEMY_RADIUS * 2.2):
				audio_manager.play_wall_slam()
				camera_trauma = minf(1.0, camera_trauma + 0.3)
				pushed.take_damage(1, false)
				other_enemy.take_damage(1, false)
				break

	# Tesla arc if unlocked:
	if player.tesla_arc_level > 0:
		_apply_tesla_arc(pushed_enemies)

func _apply_tesla_arc(sources: Array[EnemyActor]) -> void:
	var zap_count: int = player.tesla_arc_level * 2
	var targets_hit: int = 0
	for child in enemies.get_children():
		var enemy: EnemyActor = child as EnemyActor
		if enemy == null or not is_instance_valid(enemy) or enemy in sources:
			continue
		for source in sources:
			if is_instance_valid(source) and source.position.distance_to(enemy.position) <= 120.0:
				enemy.take_damage(1, false)
				audio_manager.play_wall_slam()
				targets_hit += 1
				break
		if targets_hit >= zap_count:
			break

func spawn_one() -> void:
	if enemies.get_child_count() >= Config.MAX_ENEMIES:
		return
	var enemy: EnemyActor = EnemyScene.instantiate() as EnemyActor
	var spawn_pos: Vector2 = Config.choose_spawn(rng, player.position)
	var enemy_type: EnemyActor.Type = EnemyActor.Type.CHASER
	if elapsed >= Config.SPRINTER_SPAWN_START_TIME and rng.randf() < Config.SPRINTER_SPAWN_CHANCE:
		enemy_type = EnemyActor.Type.SPRINTER
	enemy.configure(spawn_pos, Config.enemy_speed(elapsed), enemy_type)
	enemy.telegraph_started.connect(func() -> void: if state == State.RUNNING: audio_manager.play_telegraph())
	enemy.dash_started.connect(func() -> void: if state == State.RUNNING: audio_manager.play_dash())
	enemy.died.connect(_on_enemy_died)
	enemies.add_child(enemy)

func _on_enemy_died(pos: Vector2, enemy_type: EnemyActor.Type, _hit_wall: bool) -> void:
	var scrap_count: int = 3 if enemy_type == EnemyActor.Type.SPRINTER else 1
	for s in range(scrap_count):
		var scatter_dir: Vector2 = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)).normalized()
		var scatter_vel: Vector2 = scatter_dir * rng.randf_range(40.0, 140.0)
		spawn_scrap(pos, 1, scatter_vel)

func spawn_scrap(pos: Vector2, scrap_val: int, scatter_vel: Vector2) -> void:
	if scraps == null:
		return
	var scrap: ScrapItem = ScrapActor.new()
	scrap.configure(pos, scrap_val, scatter_vel)
	scrap.collected.connect(_on_scrap_collected)
	scraps.add_child(scrap)

func _on_scrap_collected(val: int) -> void:
	if state != State.RUNNING:
		return
	audio_manager.play_scrap_pickup()
	current_scraps += val
	total_scraps += val
	if current_scraps >= next_upgrade_threshold:
		current_scraps -= next_upgrade_threshold
		upgrade_level += 1
		next_upgrade_threshold = int(floor(15.0 * pow(1.35, upgrade_level)))
		trigger_upgrade_selection()

func trigger_upgrade_selection() -> void:
	audio_manager.play_level_up()
	state = State.PAUSED
	audio_manager.pause_music(true)
	var options: Array[Dictionary] = _generate_upgrade_options()
	hud.show_upgrade_options(options)

func _generate_upgrade_options() -> Array[Dictionary]:
	var all_mods: Array[Dictionary] = [
		{
			"id": "kinetic",
			"title": "Xung Công Phá (Kinetic Overload)",
			"desc": "Lực đẩy +40%, quái văng nhanh và gây sát thương va đập mạnh",
			"tier": upgrade_tiers["kinetic"] + 1
		},
		{
			"id": "overclock",
			"title": "Tụ Điện Cao Tần (Overclock Capacitor)",
			"desc": "Hồi chiêu Pulse giảm 25% (nạp xung cực nhanh)",
			"tier": upgrade_tiers["overclock"] + 1
		},
		{
			"id": "siphon",
			"title": "Nam Châm Tận Thu (Scrap Siphon)",
			"desc": "Tầm hút linh kiện +60px và phế liệu bay nhanh hơn",
			"tier": upgrade_tiers["siphon"] + 1
		},
		{
			"id": "tesla",
			"title": "Bão Điện Từ (Tesla Arc)",
			"desc": "Phóng tia điện từ giật làm choáng và nổ quái lân cận khi Pulse",
			"tier": upgrade_tiers["tesla"] + 1
		},
		{
			"id": "aegis",
			"title": "Khiên Phản Lực (Aegis Burst)",
			"desc": "Nhận 0.75s bất tử bảo hộ ngay sau mỗi lần kích hoạt xung",
			"tier": upgrade_tiers["aegis"] + 1
		}
	]
	all_mods.shuffle()
	return [all_mods[0], all_mods[1], all_mods[2]]

func apply_upgrade(upgrade_id: String) -> void:
	upgrade_tiers[upgrade_id] = upgrade_tiers.get(upgrade_id, 0) + 1
	match upgrade_id:
		"kinetic":
			player.pulse_push_force += 0.4
			player.pulse_radius = minf(180.0, player.pulse_radius + 15.0)
		"overclock":
			player.pulse_cooldown_max = maxf(1.8, player.pulse_cooldown_max * 0.75)
		"siphon":
			player.magnet_radius += 60.0
			player.magnet_speed += 90.0
		"tesla":
			player.tesla_arc_level += 1
		"aegis":
			player.aegis_shield_duration += 0.75
	state = State.RUNNING
	audio_manager.pause_music(false)
	hud.hide_panel()

func register_hit() -> void:
	if state != State.RUNNING:
		return
	if player.take_hit():
		audio_manager.play_hit()
		camera_trauma = minf(1.0, camera_trauma + 0.5)
		if player.health <= 0:
			finish_run(false)

func finish_run(won: bool) -> void:
	if state != State.RUNNING:
		return
	state = State.WON if won else State.LOST
	audio_manager.stop_music()
	if won:
		audio_manager.play_win()
	else:
		audio_manager.play_game_over()
	var run_stats: Dictionary = save_manager.record_run(elapsed, won)
	hud.set_best_record(save_manager.best_survival_seconds, save_manager.win_count, save_manager.total_runs)
	hud.update_run(elapsed, enemies.get_child_count(), player.pulse_cooldown_remaining, current_scraps, next_upgrade_threshold)
	hud.show_panel("won" if won else "lost", elapsed, enemies.get_child_count(), run_stats)

func _clear_enemies() -> void:
	for enemy in enemies.get_children():
		enemies.remove_child(enemy)
		enemy.queue_free()

func _clear_scraps() -> void:
	if scraps != null:
		for scrap in scraps.get_children():
			scraps.remove_child(scrap)
			scrap.queue_free()
