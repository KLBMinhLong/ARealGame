extends SceneTree
## Run only after --import. A green smoke test does NOT certify playability.

const Config = preload("res://scripts/core/game_config.gd")
const Game = preload("res://scripts/main.gd")
const GameScene = preload("res://scenes/main.tscn")
var failures: int = 0
var checks: int = 0

func _initialize() -> void:
	call_deferred("_run")

func expect(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("TEST_PASS: " + message)
	else:
		failures += 1
		push_error("TEST_FAIL: " + message)

func _run() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down", "pause_game", "restart_game", "pulse"]:
		expect(InputMap.has_action(action), "Input action exists: " + action)
	var arrow_bindings: Dictionary = {"move_left": KEY_LEFT, "move_right": KEY_RIGHT, "move_up": KEY_UP, "move_down": KEY_DOWN}
	for action: String in arrow_bindings:
		var arrow_found: bool = false
		for input_event in InputMap.action_get_events(action):
			if input_event is InputEventKey:
				arrow_found = arrow_found or input_event.physical_keycode == arrow_bindings[action]
		expect(arrow_found, "Correct arrow key mapped: " + action)
	var space_found: bool = false
	for input_event in InputMap.action_get_events("pulse"):
		if input_event is InputEventKey:
			space_found = space_found or input_event.physical_keycode == KEY_SPACE
	expect(space_found, "Correct Space key mapped: pulse")
	var game: Game = GameScene.instantiate() as Game
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	expect(game.state == Game.State.MENU, "Main scene starts at menu")
	expect(game.hud.start_requested.is_connected(game.start_run), "HUD start signal is wired")
	game.hud.start_requested.emit()
	expect(game.state == Game.State.RUNNING, "Start signal starts a run")
	expect(game.player.health == Config.MAX_HEALTH, "Start resets health")
	var center: Vector2 = Config.PLAYFIELD.get_center()
	game.player.position = center
	game.player.move_by(Vector2.RIGHT, 0.1)
	var straight_distance: float = game.player.position.distance_to(center)
	game.player.position = center
	game.player.move_by(Vector2.ONE, 0.1)
	var diagonal_distance: float = game.player.position.distance_to(center)
	expect(is_equal_approx(straight_distance, diagonal_distance), "Diagonal speed is normalized")
	game.player.move_by(Vector2(-1.0, -1.0), 100.0)
	expect(game.player.position.x >= Config.PLAYFIELD.position.x + Config.PLAYER_RADIUS, "Left boundary contains player")
	expect(game.player.position.y >= Config.PLAYFIELD.position.y + Config.PLAYER_RADIUS, "Top boundary contains player")
	game.player.move_by(Vector2.ONE, 100.0)
	expect(game.player.position.x <= Config.PLAYFIELD.end.x - Config.PLAYER_RADIUS, "Right boundary contains player")
	expect(game.player.position.y <= Config.PLAYFIELD.end.y - Config.PLAYER_RADIUS, "Bottom boundary contains player")
	game.player.reset()
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = 20260905
	var spawn_ok: bool = true
	for trial in range(100):
		var point: Vector2 = Config.choose_spawn(random, center)
		spawn_ok = spawn_ok and Config.PLAYFIELD.has_point(point) and point.distance_to(center) >= Config.MIN_SPAWN_DISTANCE
	expect(spawn_ok, "Seeded spawn samples are inside field and away from player")
	for trial in range(Config.MAX_ENEMIES + 4):
		game.spawn_one()
	expect(game.enemies.get_child_count() == Config.MAX_ENEMIES, "Enemy cap is enforced")
	game.start_run()
	expect(game.enemies.get_child_count() == 0, "Restart removes previous enemies")
	var EnemyScene: PackedScene = preload("res://scenes/enemy.tscn")
	var enemy_near = EnemyScene.instantiate()
	var enemy_far = EnemyScene.instantiate()
	game.enemies.add_child(enemy_near)
	game.enemies.add_child(enemy_far)
	enemy_near.position = center + Vector2(60.0, 0.0)
	enemy_far.position = center + Vector2(200.0, 0.0)
	expect(game.player.pulse_cooldown_remaining == 0.0, "Pulse is ready at start of run")
	game.hud.update_run(game.elapsed, 0, game.player.pulse_cooldown_remaining)
	expect(game.hud.pulse_label.text.contains("READY"), "HUD shows pulse is READY")
	var pulse_triggered_ok: bool = game.player.trigger_pulse()
	expect(pulse_triggered_ok, "Trigger pulse succeeds when ready")
	expect(is_equal_approx(game.player.pulse_cooldown_remaining, Config.PULSE_COOLDOWN_SECONDS), "Pulse sets cooldown")
	game.hud.update_run(game.elapsed, 0, game.player.pulse_cooldown_remaining)
	expect(game.hud.pulse_label.text.contains("s"), "HUD shows pulse cooldown time remaining")
	expect(not game.player.trigger_pulse(), "Trigger pulse fails while cooldown is active")
	expect(enemy_near.position.x > center.x + 60.0, "Enemy in radius is pushed away")
	expect(enemy_near.stun_remaining > 0.0, "Enemy in radius is stunned")
	expect(is_equal_approx(enemy_far.position.x, center.x + 200.0), "Enemy outside radius is unaffected")
	expect(enemy_far.stun_remaining == 0.0, "Enemy outside radius is not stunned")
	game.start_run()
	game.register_hit()
	game.register_hit()
	expect(game.player.health == Config.MAX_HEALTH - 1, "Invulnerability prevents same-frame repeat damage")
	var prior_elapsed: float = game.elapsed
	var prior_grace: float = game.player.grace_remaining
	game.player.pulse_cooldown_remaining = 3.0
	var prior_cooldown: float = game.player.pulse_cooldown_remaining
	game.pause_run()
	game._physics_process(0.5)
	expect(is_equal_approx(game.elapsed, prior_elapsed), "Pause freezes run timer")
	expect(is_equal_approx(game.player.grace_remaining, prior_grace), "Pause freezes invulnerability timer")
	expect(is_equal_approx(game.player.pulse_cooldown_remaining, prior_cooldown), "Pause freezes pulse cooldown")
	game.hud.resume_requested.emit()
	expect(game.state == Game.State.RUNNING, "Resume signal resumes run")
	game.player.grace_remaining = 0.0
	game.register_hit()
	game.player.grace_remaining = 0.0
	game.register_hit()
	expect(game.player.health == 0 and game.state == Game.State.LOST, "Zero health ends run as lost")
	game.start_run()
	game.elapsed = Config.RUN_SECONDS - 0.01
	game._physics_process(0.02)
	expect(game.state == Game.State.WON, "Run duration ends run as won")
	game.return_to_menu()
	expect(game.state == Game.State.MENU and game.enemies.get_child_count() == 0, "Return to menu resets state")
	game.queue_free()
	await process_frame
	if failures == 0:
		print("ALL_TESTS_PASSED: %d checks" % checks)
		quit(0)
	else:
		print("TEST_SUITE_FAILED: %d/%d" % [failures, checks])
		quit(1)
