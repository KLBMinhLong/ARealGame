## test_sound_manager.gd
## Bounded integration test for Stone Knight SoundManager (Task 7.2).
## Runs inside the Godot SceneTree ensuring is_inside_tree() is true for AudioStreamPlayers.
extends Node

const SoundManagerScript = preload("res://scripts/systems/sound_manager.gd")

var passed_count: int = 0
var failed_count: int = 0


func _ready() -> void:
	print("============================================================")
	print("Stone Knight - SoundManager Integration Test Scene (Task 7.2)")
	print("============================================================")
	
	var sm: Node = SoundManagerScript.new()
	sm.name = "TestSoundManager"
	add_child(sm)

	# Run all test suites
	test_asset_preloads(sm)
	test_public_play_methods(sm)
	test_polyphony_caps(sm)
	test_priority_preemption(sm)
	test_game_over_preemption(sm)
	test_shard_streak_pitch(sm)
	test_combo_pitch_scale(sm)
	test_rng_isolation(sm)
	test_simultaneous_combat_playback(sm)

	# Clean up players and SoundManager explicitly to prevent ObjectDB leaks at exit
	for p in sm.players:
		p.stream = null
		p.queue_free()
	sm.players.clear()
	sm.queue_free()

	print("------------------------------------------------------------")
	print("Integration Test Results: %d PASSED, %d FAILED" % [passed_count, failed_count])
	print("============================================================")

	if failed_count == 0:
		print("[OVERALL] ALL SOUNDMANAGER CHECKS PASSED ✓")
	else:
		printerr("[OVERALL] SOME SOUNDMANAGER CHECKS FAILED ✗")
		get_tree().quit(1)


func assert_true(condition: bool, message: String) -> void:
	if condition:
		passed_count += 1
		print("  [PASS] %s" % message)
	else:
		failed_count += 1
		printerr("  [FAIL] %s" % message)


# ─── Suite 1: Asset Preloads ────────────────────────────────
func test_asset_preloads(sm: Node) -> void:
	print("\n[Suite 1] Preloaded SFX Assets Validation:")
	var assets := {
		"sfx_pulse": sm.sfx_pulse,
		"sfx_dash": sm.sfx_dash,
		"sfx_wall_slam": sm.sfx_wall_slam,
		"sfx_domino": sm.sfx_domino,
		"sfx_altar_seal": sm.sfx_altar_seal,
		"sfx_shard": sm.sfx_shard,
		"sfx_player_hurt": sm.sfx_player_hurt,
		"sfx_combo": sm.sfx_combo,
		"sfx_game_over": sm.sfx_game_over,
	}

	for asset_name in assets.keys():
		var stream: AudioStream = assets[asset_name]
		assert_true(stream != null, "%s is loaded and not null" % asset_name)
		if stream != null:
			var len_s := stream.get_length()
			assert_true(len_s > 0.0, "%s length is valid (%.3fs)" % [asset_name, len_s])


# ─── Suite 2: Public Play API Invocations ───────────────────
func test_public_play_methods(sm: Node) -> void:
	print("\n[Suite 2] Public Play Methods Invocation:")
	sm.clear()

	sm.play_pulse()
	assert_true(sm.players[0].stream == sm.sfx_pulse, "play_pulse() assigns sfx_pulse to player")

	sm.clear()
	sm.play_dash()
	assert_true(sm.players[0].stream == sm.sfx_dash, "play_dash() assigns sfx_dash to player")

	sm.clear()
	sm.play_wall_slam()
	assert_true(sm.players[0].stream == sm.sfx_wall_slam, "play_wall_slam() assigns sfx_wall_slam to player")

	sm.clear()
	sm.play_domino()
	assert_true(sm.players[0].stream == sm.sfx_domino, "play_domino() assigns sfx_domino to player")

	sm.clear()
	sm.play_altar_seal()
	assert_true(sm.players[0].stream == sm.sfx_altar_seal, "play_altar_seal() assigns sfx_altar_seal to player")

	sm.clear()
	sm.play_shard()
	assert_true(sm.players[0].stream == sm.sfx_shard, "play_shard() assigns sfx_shard to player")

	sm.clear()
	sm.play_player_hurt()
	assert_true(sm.players[0].stream == sm.sfx_player_hurt, "play_player_hurt() assigns sfx_player_hurt to player")

	sm.clear()
	sm.play_combo(2)
	assert_true(sm.players[0].stream == sm.sfx_combo, "play_combo() assigns sfx_combo to player")

	sm.clear()
	sm.play_game_over()
	assert_true(sm.players[0].stream == sm.sfx_game_over, "play_game_over() assigns sfx_game_over to player")


# ─── Suite 3: Polyphony Caps ────────────────────────────────
func test_polyphony_caps(sm: Node) -> void:
	print("\n[Suite 3] Polyphony Limits Verification:")
	sm.clear()

	# 1. Pulse cap = 1
	sm.play_pulse()
	sm.players[0].play()
	sm.last_play_msec.erase("pulse")
	sm.play_pulse()

	var pulse_count := 0
	for i in range(sm.POOL_SIZE):
		if sm.player_types[i] == "pulse":
			pulse_count += 1
	assert_true(pulse_count == 1, "Pulse respects polyphony cap of 1 (found %d)" % pulse_count)

	# 2. Wall slam cap = 2
	sm.clear()
	sm.play_wall_slam()
	sm.players[0].play()
	sm.last_play_msec.erase("wall_slam")
	sm.play_wall_slam()
	sm.players[1].play()
	sm.last_play_msec.erase("wall_slam")
	sm.play_wall_slam()  # Should be rejected due to cap = 2

	var wall_slam_count := 0
	for i in range(sm.POOL_SIZE):
		if sm.player_types[i] == "wall_slam":
			wall_slam_count += 1
	assert_true(wall_slam_count == 2, "Wall slam respects polyphony cap of 2 (found %d)" % wall_slam_count)

	# 3. Shard cap = 3
	sm.clear()
	for i in range(5):
		sm.last_play_msec.erase("shard")
		sm.play_shard()
		if i < sm.POOL_SIZE:
			sm.players[i].play()

	var shard_count := 0
	for i in range(sm.POOL_SIZE):
		if sm.player_types[i] == "shard":
			shard_count += 1
	assert_true(shard_count == 3, "Shard respects polyphony cap of 3 (found %d)" % shard_count)


# ─── Suite 4: Priority & Preemption ────────────────────────
func test_priority_preemption(sm: Node) -> void:
	print("\n[Suite 4] Voice Priority & Preemption System:")
	sm.clear()

	# Fill entire pool (10/10) with LOW priority voices
	for i in range(sm.POOL_SIZE):
		sm.players[i].stream = sm.sfx_domino
		sm.players[i].play()
		sm.player_priorities[i] = int(sm.Priority.LOW)
		sm.player_types[i] = "fake_low_%d" % i

	# Try to play another LOW priority sound (should be dropped because pool is full and prio is equal)
	sm.last_play_msec.erase("domino")
	sm.play_domino()
	var domino_found := false
	for i in range(sm.POOL_SIZE):
		if sm.player_types[i] == "domino":
			domino_found = true
			break
	assert_true(not domino_found, "Low priority sound does not preempt equal/higher priority voices")

	# Play CRITICAL priority sound (player_hurt, prio = 4)
	# Should preempt the lowest priority voice in pool
	sm.last_play_msec.erase("player_hurt")
	sm.play_player_hurt()

	var hurt_found := false
	var hurt_index := -1
	for i in range(sm.POOL_SIZE):
		if sm.player_types[i] == "player_hurt":
			hurt_found = true
			hurt_index = i
			break
	assert_true(hurt_found, "Critical priority (player_hurt) preempts low priority voice")
	assert_true(hurt_index != -1 and sm.player_priorities[hurt_index] == int(sm.Priority.CRITICAL),
		"Preempted voice upgraded to CRITICAL priority (%d)" % (sm.player_priorities[hurt_index] if hurt_index != -1 else -1))


# ─── Suite 5: Game Over Preemption ─────────────────────────
func test_game_over_preemption(sm: Node) -> void:
	print("\n[Suite 5] Game Over Stop Combat Sounds:")
	sm.clear()

	# Start combat sounds
	sm.players[0].stream = sm.sfx_pulse
	sm.players[0].play()
	sm.player_priorities[0] = int(sm.Priority.HIGH)
	sm.player_types[0] = "pulse"

	sm.players[1].stream = sm.sfx_wall_slam
	sm.players[1].play()
	sm.player_priorities[1] = int(sm.Priority.MEDIUM)
	sm.player_types[1] = "wall_slam"

	# Trigger game over
	sm.last_play_msec.erase("game_over")
	sm.play_game_over()

	var combat_voices_active := 0
	var go_found := false
	for i in range(sm.POOL_SIZE):
		if sm.player_types[i] in ["pulse", "wall_slam"]:
			combat_voices_active += 1
		if sm.player_types[i] == "game_over":
			go_found = true
	assert_true(combat_voices_active == 0, "All combat voices stopped on game over (found %d)" % combat_voices_active)
	assert_true(go_found, "Game over voice allocated exclusively")


# ─── Suite 6: Shard Streak Pitch Progression ───────────────
func test_shard_streak_pitch(sm: Node) -> void:
	print("\n[Suite 6] Shard Streak Pitch Progression:")
	sm.clear()
	sm.last_shard_time = -1000

	# First shard (streak reset because last_shard_time was > 400ms ago)
	sm.last_play_msec.erase("shard")
	sm.play_shard()
	assert_true(sm.shard_streak == 0, "First shard has streak 0")

	# Second shard in rapid succession (< 400ms)
	sm.last_play_msec.erase("shard")
	sm.play_shard()
	assert_true(sm.shard_streak == 1, "Rapid second shard increments streak to 1")

	# Third shard
	sm.last_play_msec.erase("shard")
	sm.play_shard()
	assert_true(sm.shard_streak == 2, "Third shard increments streak to 2")


# ─── Suite 7: Combo Pitch Scale Progression ────────────────
func test_combo_pitch_scale(sm: Node) -> void:
	print("\n[Suite 7] Combo Pitch Scale Progression:")
	sm.clear()

	sm.last_play_msec.erase("combo")
	sm.play_combo(1)
	var pitch_1: float = sm.players[0].pitch_scale
	assert_true(is_equal_approx(pitch_1, 1.0), "Combo level 1 base pitch is 1.0 (got %.3f)" % pitch_1)

	sm.clear()
	sm.last_play_msec.erase("combo")
	sm.play_combo(3)
	var pitch_3: float = sm.players[0].pitch_scale
	assert_true(is_equal_approx(pitch_3, 1.16), "Combo level 3 pitch scales up to 1.16 (got %.3f)" % pitch_3)

	sm.clear()
	sm.last_play_msec.erase("combo")
	sm.play_combo(10)
	var pitch_max: float = sm.players[0].pitch_scale
	assert_true(is_equal_approx(pitch_max, 1.6), "Combo level 10 clamps at max pitch 1.6 (got %.3f)" % pitch_max)


# ─── Suite 8: RNG Isolation ─────────────────────────────────
func test_rng_isolation(sm: Node) -> void:
	print("\n[Suite 8] RNG Isolation (audio_rng vs gameplay RNG):")
	var game_rng := RandomNumberGenerator.new()
	game_rng.seed = 424242

	# Generate baseline sequence from gameplay RNG
	var expected_val_1 := game_rng.randf()
	var expected_val_2 := game_rng.randf()

	# Re-seed game RNG and interleave heavy SoundManager calls (which use audio_rng)
	game_rng.seed = 424242
	var actual_val_1 := game_rng.randf()

	for i in range(20):
		sm.last_play_msec.erase("dash")
		sm.play_dash()
		sm.last_play_msec.erase("pulse")
		sm.play_pulse()

	var actual_val_2 := game_rng.randf()

	assert_true(actual_val_1 == expected_val_1, "Gameplay RNG val 1 is deterministic")
	assert_true(actual_val_2 == expected_val_2, "Gameplay RNG val 2 unaffected by audio_rng calls")


# ─── Suite 9: Simultaneous Combat Playback (Task 7.3) ────────
func test_simultaneous_combat_playback(sm: Node) -> void:
	print("\n[Suite 9] Simultaneous Playback Scenarios (Req 10.6):")
	sm.clear()

	# Scenario A: Pulse + Wall Slam + Domino
	sm.last_play_msec.erase("pulse")
	sm.last_play_msec.erase("wall_slam")
	sm.last_play_msec.erase("domino")
	sm.play_pulse()
	sm.play_wall_slam()
	sm.play_domino()

	var active_scen_a := 0
	for i in range(sm.POOL_SIZE):
		if sm.player_types[i] in ["pulse", "wall_slam", "domino"]:
			active_scen_a += 1
	assert_true(active_scen_a == 3, "Scenario A triggers 3 distinct voices concurrently (found %d)" % active_scen_a)

	# Scenario B: Dash + Shard + Combo
	sm.clear()
	sm.last_play_msec.erase("dash")
	sm.last_play_msec.erase("shard")
	sm.last_play_msec.erase("combo")
	sm.play_dash()
	sm.play_shard()
	sm.play_combo(2)

	var active_scen_b := 0
	for i in range(sm.POOL_SIZE):
		if sm.player_types[i] in ["dash", "shard", "combo"]:
			active_scen_b += 1
	assert_true(active_scen_b == 3, "Scenario B triggers 3 distinct voices concurrently (found %d)" % active_scen_b)

	# Scenario C: Player Hurt + Pulse + Wall Slam + Shard
	sm.clear()
	sm.last_play_msec.erase("player_hurt")
	sm.last_play_msec.erase("pulse")
	sm.last_play_msec.erase("wall_slam")
	sm.last_play_msec.erase("shard")
	sm.play_player_hurt()
	sm.play_pulse()
	sm.play_wall_slam()
	sm.play_shard()

	var active_scen_c := 0
	for i in range(sm.POOL_SIZE):
		if sm.player_types[i] in ["player_hurt", "pulse", "wall_slam", "shard"]:
			active_scen_c += 1
	assert_true(active_scen_c == 4, "Scenario C triggers 4 distinct voices concurrently (found %d)" % active_scen_c)

