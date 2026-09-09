## test_upgrades.gd — Unit verification for UpgradeManager logic and additive formulas
@tool
extends SceneTree

func _init() -> void:
	print("[TEST] Running UpgradeManager logic verification...")
	var mgr := UpgradeManager.new()

	# 1. Baseline checks (Tier 0)
	assert(is_equal_approx(mgr.get_effective_pulse_force(), 400.0), "Force Tier 0 must be 400.0")
	assert(is_equal_approx(mgr.get_effective_pulse_radius(), 50.0), "Radius Tier 0 must be 50.0")
	assert(is_equal_approx(mgr.get_effective_pulse_cooldown(), 3.5), "CD Tier 0 must be 3.5")
	assert(is_equal_approx(mgr.get_effective_player_speed(), 120.0), "Speed Tier 0 must be 120.0")
	assert(is_equal_approx(mgr.get_effective_magnet_radius(), 40.0), "Magnet Tier 0 must be 40.0")
	assert(mgr.get_effective_max_hp() == 3, "HP Tier 0 must be 3")
	print("  [PASS] Baseline values verified.")

	# 2. Additive formulas for Heavy Push (400 -> 500 -> 600 -> 700)
	mgr.apply_upgrade("UPG_FORCE")
	assert(is_equal_approx(mgr.get_effective_pulse_force(), 500.0), "Force Tier 1 must be 500.0")
	mgr.apply_upgrade("UPG_FORCE")
	assert(is_equal_approx(mgr.get_effective_pulse_force(), 600.0), "Force Tier 2 must be 600.0")
	mgr.apply_upgrade("UPG_FORCE")
	assert(is_equal_approx(mgr.get_effective_pulse_force(), 700.0), "Force Tier 3 must be 700.0")
	assert(not mgr.apply_upgrade("UPG_FORCE"), "Cannot exceed Tier 3")
	assert(is_equal_approx(mgr.get_effective_pulse_force(), 700.0), "Force remains 700.0 after cap")
	print("  [PASS] Heavy Push additive tiers verified (500, 600, 700).")

	# 3. Additive formulas for Wider Reach (50 -> 60 -> 70 -> 80)
	mgr.apply_upgrade("UPG_RADIUS")
	assert(is_equal_approx(mgr.get_effective_pulse_radius(), 60.0), "Radius Tier 1 must be 60.0")
	mgr.apply_upgrade("UPG_RADIUS")
	assert(is_equal_approx(mgr.get_effective_pulse_radius(), 70.0), "Radius Tier 2 must be 70.0")
	mgr.apply_upgrade("UPG_RADIUS")
	assert(is_equal_approx(mgr.get_effective_pulse_radius(), 80.0), "Radius Tier 3 must be 80.0")
	print("  [PASS] Wider Reach additive tiers verified (60, 70, 80).")

	# 4. Quick Charge (3.5 -> 3.1 -> 2.7 -> 2.3)
	mgr.apply_upgrade("UPG_CD")
	assert(is_equal_approx(mgr.get_effective_pulse_cooldown(), 3.1), "CD Tier 1 must be 3.1")
	mgr.apply_upgrade("UPG_CD")
	assert(is_equal_approx(mgr.get_effective_pulse_cooldown(), 2.7), "CD Tier 2 must be 2.7")
	mgr.apply_upgrade("UPG_CD")
	assert(is_equal_approx(mgr.get_effective_pulse_cooldown(), 2.3), "CD Tier 3 must be 2.3")
	print("  [PASS] Quick Charge additive tiers verified (3.1, 2.7, 2.3).")

	# 5. Swift Stone (120 -> 138 -> 156 -> 174)
	mgr.apply_upgrade("UPG_SPEED")
	assert(is_equal_approx(mgr.get_effective_player_speed(), 138.0), "Speed Tier 1 must be 138.0")
	mgr.apply_upgrade("UPG_SPEED")
	assert(is_equal_approx(mgr.get_effective_player_speed(), 156.0), "Speed Tier 2 must be 156.0")
	mgr.apply_upgrade("UPG_SPEED")
	assert(is_equal_approx(mgr.get_effective_player_speed(), 174.0), "Speed Tier 3 must be 174.0")
	print("  [PASS] Swift Stone additive tiers verified (138, 156, 174).")

	# 6. Stone Heart (3 -> 4 -> 5 -> 6)
	mgr.apply_upgrade("UPG_HP")
	assert(mgr.get_effective_max_hp() == 4, "HP Tier 1 must be 4")
	mgr.apply_upgrade("UPG_HP")
	assert(mgr.get_effective_max_hp() == 5, "HP Tier 2 must be 5")
	mgr.apply_upgrade("UPG_HP")
	assert(mgr.get_effective_max_hp() == 6, "HP Tier 3 must be 6")
	print("  [PASS] Stone Heart additive tiers verified (4, 5, 6).")

	# 7. Card drawing uniqueness and max-tier exclusion
	mgr.reset()
	for trial in 100:
		var cards := mgr.draw_cards(3)
		assert(cards.size() == 3, "Must draw 3 cards")
		assert(cards[0]["id"] != cards[1]["id"], "Card 0 and 1 must not be identical")
		assert(cards[1]["id"] != cards[2]["id"], "Card 1 and 2 must not be identical")
		assert(cards[0]["id"] != cards[2]["id"], "Card 0 and 2 must not be identical")
	print("  [PASS] 100 draws verified with 0 duplicate cards.")

	# Cap UPG_FORCE to Tier 3 and verify it never appears in draw
	mgr.apply_upgrade("UPG_FORCE")
	mgr.apply_upgrade("UPG_FORCE")
	mgr.apply_upgrade("UPG_FORCE")
	for trial in 50:
		var cards := mgr.draw_cards(3)
		for c in cards:
			assert(c["id"] != "UPG_FORCE", "Capped card must never be drawn")
	print("  [PASS] Max-tier card properly excluded from draw.")

	# 8. Reset clean
	mgr.reset()
	assert(mgr.get_tier("UPG_FORCE") == 0, "Force tier must reset to 0")
	assert(is_equal_approx(mgr.get_effective_pulse_force(), 400.0), "Force must reset to 400.0")
	print("  [PASS] Clean reset verified.")

	print("[TEST COMPLETED] All F018.1 logic assertions passed successfully!")
	quit(0)
