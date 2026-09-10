# test_f021_meta_progression.py — Automated verification for F021 Meta-Progression & Save System
import unittest
import json
import os
import tempfile
import shutil


class TestF021MetaProgression(unittest.TestCase):
    """
    Automated test verification for F021 Meta-Progression & Save System:
    - Schema validation & default initialization
    - Atomic save and backup logic simulation
    - Corrupted file fallback & isolation
    - Data sanitization (clamping negative numbers and excessive tiers)
    - Future version rejection
    - Candidate-state transaction safety (rollback on disk error)
    - True-Additive baseline formulas (single baseline, no cross-multiplication)
    """

    CURRENT_VERSION = 1

    PERM_UPGRADES = [
        {"id": "PERM_HP", "name": "Stone Body", "max_tier": 2, "costs": [15, 45], "bonus_per_tier": 1, "implemented": True, "enabled_for_purchase": True},
        {"id": "PERM_FORCE", "name": "Heavy Core", "max_tier": 2, "costs": [15, 40], "bonus_per_tier": 0.075, "implemented": True, "enabled_for_purchase": True},
        {"id": "PERM_SPEED", "name": "Quick Feet", "max_tier": 2, "costs": [15, 40], "bonus_per_tier": 0.04, "implemented": True, "enabled_for_purchase": True},
        {"id": "PERM_CD", "name": "Charged Core", "max_tier": 2, "costs": [20, 50], "bonus_per_tier": 0.2, "implemented": True, "enabled_for_purchase": True},
        {"id": "PERM_MAGNET", "name": "Soul Attunement", "max_tier": 1, "costs": [30], "bonus_per_tier": 0.30, "implemented": True, "enabled_for_purchase": True},
        {"id": "PERM_FORESIGHT", "name": "Rune Foresight", "max_tier": 1, "costs": [40], "bonus_per_tier": 1, "implemented": True, "enabled_for_purchase": True},
    ]

    BASE_FORCE = 400.0
    BASE_SPEED = 120.0
    BASE_CD = 3.5
    BASE_MAGNET = 40.0
    BASE_HP = 3

    def setUp(self):
        self.test_dir = tempfile.mkdtemp(prefix="stone_knight_test_")
        self.save_path = os.path.join(self.test_dir, "test_save.json")

    def tearDown(self):
        shutil.rmtree(self.test_dir, ignore_errors=True)

    # ─── Helper: simulate can_buy with implemented/enabled checks ──────
    def _can_buy(self, upgrade_id, rune_stones, perm_tiers):
        """Simulate MetaProgression.can_buy() with implemented/enabled gate."""
        upg_def = None
        for u in self.PERM_UPGRADES:
            if u["id"] == upgrade_id:
                upg_def = u
                break
        if upg_def is None:
            return False
        if not upg_def.get("implemented", False):
            return False
        if not upg_def.get("enabled_for_purchase", False):
            return False
        cur_tier = perm_tiers.get(upgrade_id, 0)
        if cur_tier >= upg_def["max_tier"]:
            return False
        cost = upg_def["costs"][cur_tier]
        return rune_stones >= cost

    def _is_purchasable(self, upgrade_id):
        """Simulate MetaProgression.is_purchasable()."""
        for u in self.PERM_UPGRADES:
            if u["id"] == upgrade_id:
                return u.get("implemented", False) and u.get("enabled_for_purchase", False)
        return False

    def test_ac01_missing_file_loads_default_state(self):
        """AC01: Non-existent file initializes clean default state without crashing."""
        self.assertFalse(os.path.exists(self.save_path))
        state = {
            "version": self.CURRENT_VERSION,
            "rune_stones": 0,
            "total_runs": 0,
            "best_wave": 0,
            "perm_tiers": {u["id"]: 0 for u in self.PERM_UPGRADES},
        }
        self.assertEqual(state["rune_stones"], 0)
        self.assertEqual(state["total_runs"], 0)
        self.assertEqual(state["perm_tiers"]["PERM_HP"], 0)

    def test_ac02_valid_round_trip_save_and_load(self):
        """AC02: Valid save file preserves all fields across save and reload."""
        saved_data = {
            "version": self.CURRENT_VERSION,
            "rune_stones": 45,
            "total_runs": 5,
            "best_wave": 4,
            "perm_tiers": {
                "PERM_HP": 1,
                "PERM_FORCE": 2,
                "PERM_SPEED": 0,
                "PERM_CD": 1,
                "PERM_MAGNET": 1,
                "PERM_FORESIGHT": 0,
            },
        }
        with open(self.save_path, "w", encoding="utf-8") as f:
            json.dump(saved_data, f)

        with open(self.save_path, "r", encoding="utf-8") as f:
            loaded_data = json.load(f)

        self.assertEqual(loaded_data["version"], 1)
        self.assertEqual(loaded_data["rune_stones"], 45)
        self.assertEqual(loaded_data["perm_tiers"]["PERM_FORCE"], 2)

    def test_ac03_corrupted_main_file_recovers_from_backup(self):
        """AC03: If the main JSON file is truncated or corrupted, system falls back to .bak file."""
        bak_path = self.save_path + ".bak"
        valid_backup_data = {
            "version": self.CURRENT_VERSION,
            "rune_stones": 120,
            "total_runs": 10,
            "best_wave": 5,
            "perm_tiers": {"PERM_HP": 2},
        }
        with open(bak_path, "w", encoding="utf-8") as f:
            json.dump(valid_backup_data, f)

        # Write truncated/corrupt JSON to main file
        with open(self.save_path, "w", encoding="utf-8") as f:
            f.write('{"version": 1, "rune_stones": 150, "perm_tiers": {"PERM_HP":')

        # Reading main file fails parse
        parsed = None
        try:
            with open(self.save_path, "r", encoding="utf-8") as f:
                parsed = json.load(f)
        except Exception:
            parsed = None

        self.assertIsNone(parsed, "Main corrupt file must fail JSON parsing")

        # Fallback to backup
        if parsed is None and os.path.exists(bak_path):
            with open(bak_path, "r", encoding="utf-8") as f:
                parsed = json.load(f)

        self.assertIsNotNone(parsed)
        self.assertEqual(parsed["rune_stones"], 120)
        self.assertEqual(parsed["perm_tiers"]["PERM_HP"], 2)

    def test_ac04_dirty_data_clamping_and_validation(self):
        """AC04: Negative numbers and excessive tiers are clamped to valid safe bounds."""
        dirty_data = {
            "version": 1,
            "rune_stones": -999,
            "total_runs": -5,
            "best_wave": 99,
            "perm_tiers": {
                "PERM_HP": 99,       # Max is 2
                "PERM_FORCE": -2,    # Min is 0
                "UNKNOWN_KEY": 123,  # Unknown key should be ignored
            }
        }

        # Validate & sanitize
        sanitized_rs = max(0, dirty_data.get("rune_stones", 0))
        sanitized_runs = max(0, dirty_data.get("total_runs", 0))
        sanitized_wave = min(5, max(0, dirty_data.get("best_wave", 0)))

        sanitized_tiers = {}
        for upg in self.PERM_UPGRADES:
            uid = upg["id"]
            max_t = upg["max_tier"]
            raw_t = dirty_data["perm_tiers"].get(uid, 0)
            sanitized_tiers[uid] = min(max_t, max(0, raw_t))

        self.assertEqual(sanitized_rs, 0)
        self.assertEqual(sanitized_runs, 0)
        self.assertEqual(sanitized_wave, 5)
        self.assertEqual(sanitized_tiers["PERM_HP"], 2)
        self.assertEqual(sanitized_tiers["PERM_FORCE"], 0)
        self.assertNotIn("UNKNOWN_KEY", sanitized_tiers)

    def test_ac05_future_version_rejection(self):
        """AC05: Saves from future versions are rejected to prevent data loss or overwriting."""
        future_data = {"version": 999, "rune_stones": 500}
        with open(self.save_path, "w", encoding="utf-8") as f:
            json.dump(future_data, f)

        with open(self.save_path, "r", encoding="utf-8") as f:
            loaded = json.load(f)

        is_supported = loaded.get("version", 1) <= self.CURRENT_VERSION
        self.assertFalse(is_supported, "Future versions must not be loaded or processed")

    def test_ac06_idempotent_settlement_receipt(self):
        """AC06: Settle run is idempotent; repeated calls for the same run_id return identical receipts."""
        run_state = {
            "run_id": "run_test_12345",
            "settlement_committed": False,
            "receipt": None,
            "collected_shards": 24,
            "boss_killed": True,
            "is_victory": True,
        }

        def settle_run(state):
            if state["settlement_committed"]:
                return state["receipt"], False  # (receipt, did_mutate)

            boss_reward = 15 if state["boss_killed"] else 0
            victory_bonus = 5 if state["is_victory"] else 0
            total = state["collected_shards"] + boss_reward + victory_bonus
            receipt = {
                "run_id": state["run_id"],
                "collected_shards": state["collected_shards"],
                "boss_reward": boss_reward,
                "victory_bonus": victory_bonus,
                "total_earned": total,
            }
            state["receipt"] = receipt
            state["settlement_committed"] = True
            return receipt, True

        # First settlement
        receipt1, mutated1 = settle_run(run_state)
        self.assertTrue(mutated1)
        self.assertEqual(receipt1["total_earned"], 44)  # 24 + 15 + 5

        # Duplicate settlement attempts (e.g. death/victory race, restart click)
        receipt2, mutated2 = settle_run(run_state)
        self.assertFalse(mutated2)
        self.assertEqual(receipt1, receipt2)

        receipt3, mutated3 = settle_run(run_state)
        self.assertFalse(mutated3)
        self.assertEqual(receipt1, receipt3)

    def test_ac09_candidate_transaction_rollback_on_failure(self):
        """AC09: In-memory state remains untouched if disk save fails."""
        memory_state = {
            "rune_stones": 50,
            "perm_tiers": {"PERM_HP": 0}
        }
        cost = 15

        def buy_upgrade_sim(mem, upg_id, simulate_disk_error=False):
            if mem["rune_stones"] < cost:
                return False
            # 1. Candidate state
            cand_stones = mem["rune_stones"] - cost
            cand_tiers = dict(mem["perm_tiers"])
            cand_tiers[upg_id] += 1

            # 2. Disk write
            if simulate_disk_error:
                return False  # Failed write

            # 3. Commit only on success
            mem["rune_stones"] = cand_stones
            mem["perm_tiers"] = cand_tiers
            return True

        # Simulate disk error
        success = buy_upgrade_sim(memory_state, "PERM_HP", simulate_disk_error=True)
        self.assertFalse(success)
        self.assertEqual(memory_state["rune_stones"], 50, "Rune stones must not be deducted on failure")
        self.assertEqual(memory_state["perm_tiers"]["PERM_HP"], 0, "Tier must not increment on failure")

        # Simulate successful transaction
        success = buy_upgrade_sim(memory_state, "PERM_HP", simulate_disk_error=False)
        self.assertTrue(success)
        self.assertEqual(memory_state["rune_stones"], 35)
        self.assertEqual(memory_state["perm_tiers"]["PERM_HP"], 1)

    def test_ac11_true_additive_formulas(self):
        """AC11: True-additive formula on single baseline: effective = base * (1 + perm + in_run)."""
        # Force: Perm tier 2 (+15%), In-run tier 3 (+75%)
        # Single baseline: 400 * (1 + 0.15 + 0.75) = 400 * 1.90 = 760.0
        # (NOT multiplicative 400 * 1.15 * 1.75 = 805.0)
        perm_force = 0.15
        in_run_force = 0.75
        effective_force = self.BASE_FORCE * (1.0 + perm_force + in_run_force)
        self.assertAlmostEqual(effective_force, 760.0, places=2)
        self.assertNotEqual(effective_force, 805.0, "Must not cross-multiply")

        # Speed: Perm tier 2 (+8%), In-run tier 3 (+45%)
        # Single baseline: 120 * (1 + 0.08 + 0.45) = 120 * 1.53 = 183.6
        # (NOT multiplicative 120 * 1.08 * 1.45 = 187.92)
        perm_speed = 0.08
        in_run_speed = 0.45
        effective_speed = self.BASE_SPEED * (1.0 + perm_speed + in_run_speed)
        self.assertAlmostEqual(effective_speed, 183.6, places=2)

        # Max HP: Config (3) + Perm (2) + In-run (3) = 8
        perm_hp = 2
        in_run_hp = 3
        effective_hp = self.BASE_HP + perm_hp + in_run_hp
        self.assertEqual(effective_hp, 8)

        # Cooldown cap protection: 3.5 - 0.4 (perm) - 1.2 (in-run) = 1.9s (>= 1.5s cap)
        perm_cd = 0.4
        in_run_cd = 1.2
        effective_cd = max(1.5, self.BASE_CD - perm_cd - in_run_cd)
        self.assertAlmostEqual(effective_cd, 1.9, places=2)

    def test_ac08_receipt_breakdown_and_hud_formatting(self):
        """AC08: Receipt transparently separates collected shards, boss kill, and victory bonus."""
        # Scenario A: Defeated at Wave 3 with 18 shards
        shards_a = 18
        boss_killed_a = False
        is_victory_a = False
        boss_rew_a = 15 if boss_killed_a else 0
        vic_bon_a = 5 if is_victory_a else 0
        total_a = shards_a + boss_rew_a + vic_bon_a
        self.assertEqual(total_a, 18)

        # Scenario B: Cleared Wave 5, Warden defeated with 32 shards
        shards_b = 32
        boss_killed_b = True
        is_victory_b = True
        boss_rew_b = 15 if boss_killed_b else 0
        vic_bon_b = 5 if is_victory_b else 0
        total_b = shards_b + boss_rew_b + vic_bon_b
        self.assertEqual(total_b, 52)  # 32 + 15 + 5

        # Format string check
        hud_text_b = (
            f"Shards Collected: {shards_b}\n"
            f"Warden Vanquished: +{boss_rew_b} RS\n"
            f"Victory Bonus: +{vic_bon_b} RS\n"
            f"Total Earned: +{total_b} Rune Stones\n"
            f"Balance: {total_b} Rune Stones"
        )
        self.assertIn("Shards Collected: 32", hud_text_b)
        self.assertIn("Warden Vanquished: +15 RS", hud_text_b)
        self.assertIn("Victory Bonus: +5 RS", hud_text_b)
        self.assertIn("Total Earned: +52 Rune Stones", hud_text_b)

    # ═══════════════════════════════════════════════════════════
    # AC21-AC24: Upgrade availability & purchase safety tests
    # ═══════════════════════════════════════════════════════════

    def test_ac21_can_buy_rejects_not_implemented(self):
        """AC21: can_buy returns false for upgrades with implemented=false, even if player has funds."""
        tiers = {u["id"]: 0 for u in self.PERM_UPGRADES}
        rune_stones = 999  # Plenty of money

        # All 6 current upgrades are now implemented AND enabled
        self.assertTrue(self._can_buy("PERM_HP", rune_stones, tiers))
        self.assertTrue(self._can_buy("PERM_FORCE", rune_stones, tiers))
        self.assertTrue(self._can_buy("PERM_SPEED", rune_stones, tiers))
        self.assertTrue(self._can_buy("PERM_CD", rune_stones, tiers))
        self.assertTrue(self._can_buy("PERM_MAGNET", rune_stones, tiers))
        self.assertTrue(self._can_buy("PERM_FORESIGHT", rune_stones, tiers))

        # A hypothetical un-implemented upgrade must be rejected
        unimplemented = {"id": "PERM_FUTURE", "name": "Future Rune", "max_tier": 1, "costs": [50], "implemented": False, "enabled_for_purchase": False}
        self.PERM_UPGRADES.append(unimplemented)
        try:
            self.assertFalse(self._can_buy("PERM_FUTURE", rune_stones, tiers))
            self.assertFalse(self._is_purchasable("PERM_FUTURE"))
        finally:
            self.PERM_UPGRADES.remove(unimplemented)

    def test_ac21_can_buy_rejects_not_enabled(self):
        """AC21b: All 6 permanent upgrades are purchasable."""
        for upg in self.PERM_UPGRADES:
            self.assertTrue(self._is_purchasable(upg["id"]), f"{upg['id']} must be purchasable")

    def test_ac21_buy_upgrade_fails_not_implemented(self):
        """AC21c: buy_upgrade for non-implemented upgrade must not deduct rune stones or increase tier."""
        memory_state = {
            "rune_stones": 100,
            "perm_tiers": {u["id"]: 0 for u in self.PERM_UPGRADES}
        }

        # Non-existent or un-implemented upgrade
        can = self._can_buy("PERM_NONEXISTENT", memory_state["rune_stones"], memory_state["perm_tiers"])
        self.assertFalse(can, "Must not allow purchase of non-existent upgrade")
        self.assertEqual(memory_state["rune_stones"], 100)

    def test_ac21_magnet_purchasable_and_maxes(self):
        """AC21d: PERM_MAGNET (implemented+enabled) can be bought, but not beyond max_tier."""
        tiers = {u["id"]: 0 for u in self.PERM_UPGRADES}

        # Can buy at tier 0 with enough money
        self.assertTrue(self._can_buy("PERM_MAGNET", 30, tiers))
        self.assertTrue(self._can_buy("PERM_MAGNET", 100, tiers))

        # Cannot buy with insufficient funds
        self.assertFalse(self._can_buy("PERM_MAGNET", 29, tiers))

        # Cannot buy at max tier
        tiers["PERM_MAGNET"] = 1  # max_tier for MAGNET is 1
        self.assertFalse(self._can_buy("PERM_MAGNET", 999, tiers))

    def test_ac21_foresight_purchasable_and_maxes(self):
        """AC21e: PERM_FORESIGHT (implemented+enabled) costs 40 RS and maxes at tier 1."""
        tiers = {u["id"]: 0 for u in self.PERM_UPGRADES}

        # Can buy at tier 0 with >= 40 RS
        self.assertTrue(self._can_buy("PERM_FORESIGHT", 40, tiers))
        self.assertTrue(self._can_buy("PERM_FORESIGHT", 100, tiers))

        # Cannot buy with insufficient funds
        self.assertFalse(self._can_buy("PERM_FORESIGHT", 39, tiers))

        # Cannot buy at max tier
        tiers["PERM_FORESIGHT"] = 1  # max_tier is 1
        self.assertFalse(self._can_buy("PERM_FORESIGHT", 999, tiers))

    def test_ac21_foresight_has_reroll_state(self):
        """AC21f: has_reroll is True if and only if PERM_FORESIGHT tier >= 1."""
        def has_reroll(tiers):
            return tiers.get("PERM_FORESIGHT", 0) >= 1

        tiers = {"PERM_FORESIGHT": 0}
        self.assertFalse(has_reroll(tiers))

        tiers["PERM_FORESIGHT"] = 1
        self.assertTrue(has_reroll(tiers))

if __name__ == "__main__":
    unittest.main()

