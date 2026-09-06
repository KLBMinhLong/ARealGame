extends Node2D
## Main owns state and tick order. No global autoloads, plugins, or network calls.

const Config = preload("res://scripts/core/game_config.gd")
const PlayerActor = preload("res://scripts/actors/player.gd")
const EnemyActor = preload("res://scripts/actors/enemy.gd")
const HudView = preload("res://scripts/ui/hud.gd")
const EnemyScene = preload("res://scenes/enemy.tscn")
enum State { MENU, RUNNING, PAUSED, WON, LOST }

@onready var player: PlayerActor = $World/Player
@onready var enemies: Node2D = $World/Enemies
@onready var hud: HudView = $HUD
var state: State = State.MENU
var elapsed: float = 0.0
var spawn_remaining: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	Engine.max_fps = 60
	rng.randomize()
	hud.start_requested.connect(start_run)
	hud.resume_requested.connect(resume_run)
	hud.menu_requested.connect(return_to_menu)
	hud.quit_requested.connect(func() -> void: get_tree().quit())
	player.health_changed.connect(hud.set_health)
	player.pulse_triggered.connect(_on_player_pulse)
	return_to_menu()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and state == State.RUNNING:
		pause_run()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		if state == State.RUNNING:
			pause_run()
		elif state == State.PAUSED:
			resume_run()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart_game") and (state == State.WON or state == State.LOST):
		start_run()
		get_viewport().set_input_as_handled()

func start_run() -> void:
	_clear_enemies()
	elapsed = 0.0
	spawn_remaining = 0.8
	player.reset()
	state = State.RUNNING
	hud.hide_panel()
	hud.update_run(elapsed, 0, player.pulse_cooldown_remaining)

func return_to_menu() -> void:
	state = State.MENU
	_clear_enemies()
	elapsed = 0.0
	player.reset()
	hud.update_run(0.0, 0, 0.0)
	hud.show_panel("menu")

func pause_run() -> void:
	if state != State.RUNNING:
		return
	state = State.PAUSED
	hud.show_panel("paused")

func resume_run() -> void:
	if state != State.PAUSED:
		return
	state = State.RUNNING
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
	for child in enemies.get_children():
		var enemy: EnemyActor = child as EnemyActor
		enemy.tick(delta, player.position)
		var hit_radius: float = Config.PLAYER_RADIUS + Config.ENEMY_RADIUS
		if enemy.position.distance_squared_to(player.position) <= hit_radius * hit_radius:
			register_hit()
			if state != State.RUNNING:
				break
	hud.update_run(elapsed, enemies.get_child_count(), player.pulse_cooldown_remaining)

func _on_player_pulse() -> void:
	if state != State.RUNNING:
		return
	for child in enemies.get_children():
		var enemy: EnemyActor = child as EnemyActor
		if enemy == null:
			continue
		if enemy.position.distance_to(player.position) <= Config.PULSE_RADIUS:
			enemy.push_back(player.position, Config.PULSE_PUSH_DISTANCE, Config.PULSE_STUN_SECONDS)

func spawn_one() -> void:
	if enemies.get_child_count() >= Config.MAX_ENEMIES:
		return
	var enemy: EnemyActor = EnemyScene.instantiate() as EnemyActor
	enemy.configure(Config.choose_spawn(rng, player.position), Config.enemy_speed(elapsed))
	enemies.add_child(enemy)

func register_hit() -> void:
	if state != State.RUNNING:
		return
	if player.take_hit() and player.health <= 0:
		finish_run(false)

func finish_run(won: bool) -> void:
	if state != State.RUNNING:
		return
	state = State.WON if won else State.LOST
	hud.update_run(elapsed, enemies.get_child_count(), player.pulse_cooldown_remaining)
	hud.show_panel("won" if won else "lost", elapsed)

func _clear_enemies() -> void:
	for enemy in enemies.get_children():
		enemies.remove_child(enemy)
		enemy.queue_free()
