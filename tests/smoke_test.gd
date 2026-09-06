extends SceneTree
## Run only after --import. A green smoke test does NOT certify playability.

const Config = preload("res://scripts/core/game_config.gd")
const Game = preload("res://scripts/main.gd")
const GameScene = preload("res://scenes/main.tscn")
const SaveManager = preload("res://scripts/core/save_manager.gd")
const SettingsManager = preload("res://scripts/core/settings_manager.gd")
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

	# Sprinter enemy state machine test
	var sprinter = EnemyScene.instantiate()
	game.enemies.add_child(sprinter)
	sprinter.configure(center + Vector2(100.0, 0.0), 100.0, sprinter.Type.SPRINTER)
	expect(sprinter.sprinter_phase == sprinter.SprinterPhase.STALK, "Sprinter starts in STALK phase")
	sprinter.tick(Config.SPRINTER_STALK_SECONDS + 0.05, center)
	expect(sprinter.sprinter_phase == sprinter.SprinterPhase.TELEGRAPH, "Sprinter transitions to TELEGRAPH phase")
	var telegraph_pos: Vector2 = sprinter.position
	sprinter.tick(0.2, center + Vector2(0.0, 50.0))
	expect(sprinter.position == telegraph_pos, "Sprinter stays in place during telegraph")
	sprinter.tick(Config.SPRINTER_TELEGRAPH_SECONDS, center)
	expect(sprinter.sprinter_phase == sprinter.SprinterPhase.DASH, "Sprinter transitions to DASH phase")
	# Advance dash until hitting boundary
	sprinter.tick(2.0, center)
	expect(sprinter.sprinter_phase == sprinter.SprinterPhase.REST, "Sprinter enters REST after reaching arena boundary")
	# Test pulse push interrupts dash into REST
	sprinter.sprinter_phase = sprinter.SprinterPhase.DASH
	sprinter.push_back(center, 50.0, 0.5)
	expect(sprinter.sprinter_phase == sprinter.SprinterPhase.REST, "Pulse push interrupts Sprinter into REST phase")
	expect(sprinter.stun_remaining > 0.0, "Interrupted Sprinter is stunned")

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
	expect(game.hud.title_label.text == "Run Terminated", "Lost screen title is Run Terminated")
	expect(game.hud.body_label.text.contains("Survived"), "Lost screen body contains survival stats")
	game.start_run()
	game.elapsed = Config.RUN_SECONDS - 0.01
	game._physics_process(0.02)
	expect(game.state == Game.State.WON, "Run duration ends run as won")
	expect(game.hud.title_label.text == "Victory!", "Won screen title is Victory!")
	expect(game.hud.body_label.text.contains("03:00"), "Won screen body contains 03:00 stats")
	game.return_to_menu()
	expect(game.state == Game.State.MENU and game.enemies.get_child_count() == 0, "Return to menu resets state")
	game.hud._on_tutorial()
	expect(game.hud.panel_mode == "tutorial", "Tutorial button switches HUD to tutorial mode")
	expect(game.hud.title_label.text == "How to Play", "Tutorial title is correct")
	game.hud._on_secondary()
	expect(game.hud.panel_mode == "menu", "Secondary button returns from tutorial to menu")
	# SaveManager test suite (T310)
	var test_save_path: String = "user://test_save_data.json"
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(test_save_path)
	var test_sm = SaveManager.new(test_save_path)
	expect(not test_sm.load_data(), "SaveManager returns false when file does not exist")
	expect(test_sm.best_survival_seconds == 0.0, "Initial best survival is 0.0")
	expect(test_sm.win_count == 0, "Initial win count is 0")
	expect(test_sm.total_runs == 0, "Initial total runs is 0")

	var res1 = test_sm.record_run(45.5, false)
	expect(res1.is_new_best == true, "First run is recorded as new best")
	expect(is_equal_approx(test_sm.best_survival_seconds, 45.5), "Best survival is 45.5s")
	expect(test_sm.total_runs == 1, "Total runs is 1")
	expect(test_sm.win_count == 0, "Win count is 0")

	var reload_sm = SaveManager.new(test_save_path)
	expect(reload_sm.load_data() == true, "SaveManager successfully loads saved file")
	expect(is_equal_approx(reload_sm.best_survival_seconds, 45.5), "Reloaded best survival matches")
	expect(reload_sm.total_runs == 1, "Reloaded total runs matches")

	var res2 = reload_sm.record_run(30.0, false)
	expect(res2.is_new_best == false, "Lower time is not a new best")
	expect(is_equal_approx(reload_sm.best_survival_seconds, 45.5), "Best survival remains 45.5s")
	expect(reload_sm.total_runs == 2, "Total runs increased to 2")

	var res3 = reload_sm.record_run(180.0, true)
	expect(res3.is_new_best == true, "Max time is new best")
	expect(reload_sm.win_count == 1, "Win count increased to 1")

	var corrupt_file = FileAccess.open(test_save_path, FileAccess.WRITE)
	corrupt_file.store_string("{corrupted_json_syntax_without_quotes: true,")
	corrupt_file.close()
	var fallback_sm = SaveManager.new(test_save_path)
	expect(not fallback_sm.load_data(), "Corrupted save data fails safely to defaults")
	expect(fallback_sm.best_survival_seconds == 0.0, "Corrupted fallback resets best survival")
	expect(fallback_sm.win_count == 0, "Corrupted fallback resets win count")

	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(test_save_path)

	game.hud.set_best_record(95.0, 2, 5)
	expect(game.hud.best_label.text.contains("01:35"), "HUD best label shows formatted time 01:35")

	# Test R restart key input
	game.state = Game.State.LOST
	var r_event: InputEventKey = InputEventKey.new()
	r_event.physical_keycode = KEY_R
	r_event.pressed = true
	game._input(r_event)
	expect(game.state == Game.State.RUNNING, "Pressing R restarts run into RUNNING state")

	# SettingsManager test suite (T320)
	var test_settings_path: String = "user://test_settings.cfg"
	if FileAccess.file_exists(test_settings_path):
		DirAccess.remove_absolute(test_settings_path)
	var test_set: SettingsManager = SettingsManager.new(test_settings_path)
	expect(not test_set.load_settings(), "SettingsManager loads defaults when file missing")
	expect(is_equal_approx(test_set.master_volume, 0.8), "Default master volume is 0.8")
	expect(is_equal_approx(test_set.sfx_volume, 0.8), "Default sfx volume is 0.8")
	expect(test_set.fullscreen == false, "Default fullscreen is false")
	expect(test_set.reduced_effects == false, "Default reduced_effects is false")

	test_set.set_master_volume(0.5)
	test_set.set_sfx_volume(0.6)
	test_set.set_fullscreen(true)
	test_set.set_reduced_effects(true)

	var reload_set: SettingsManager = SettingsManager.new(test_settings_path)
	expect(reload_set.load_settings() == true, "SettingsManager loads saved config")
	expect(is_equal_approx(reload_set.master_volume, 0.5), "Reloaded master volume is 0.5")
	expect(is_equal_approx(reload_set.sfx_volume, 0.6), "Reloaded sfx volume is 0.6")
	expect(reload_set.fullscreen == true, "Reloaded fullscreen is true")
	expect(reload_set.reduced_effects == true, "Reloaded reduced_effects is true")

	reload_set.reset_to_defaults()
	expect(is_equal_approx(reload_set.master_volume, 0.8), "Reset restored default master volume")
	expect(reload_set.fullscreen == false, "Reset restored default fullscreen")

	if FileAccess.file_exists(test_settings_path):
		DirAccess.remove_absolute(test_settings_path)

	# Test Settings panel navigation in HUD
	game.hud._on_settings()
	expect(game.hud.panel_mode == "settings", "HUD switches to settings panel mode")
	expect(game.hud.settings_box.visible == true, "Settings box is visible")
	expect(game.hud.main_box.visible == false, "Main box is hidden while settings open")
	game.hud._on_settings_back()
	expect(game.hud.panel_mode == "menu", "Settings back returns to previous menu mode")
	expect(game.hud.settings_box.visible == false, "Settings box is hidden after returning")
	expect(game.hud.main_box.visible == true, "Main box is restored")

	game.queue_free()
	await process_frame
	if failures == 0:
		print("ALL_TESTS_PASSED: %d checks" % checks)
		quit(0)
	else:
		print("TEST_SUITE_FAILED: %d/%d" % [failures, checks])
		quit(1)
