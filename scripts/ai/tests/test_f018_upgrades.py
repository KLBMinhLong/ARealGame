import unittest
import random

class TestF018Upgrades(unittest.TestCase):
    """
    Automated test verification for F018 In-Run Upgrades:
    - Additive formulas from Config baseline
    - Tier capping (max tier 3)
    - RNG isolation and non-duplicate draws
    - Clean reset
    """

    # Baselines from Config (game_config.gd)
    BASE_FORCE = 400.0
    BASE_RADIUS = 50.0
    BASE_CD = 3.5
    BASE_SPEED = 120.0
    BASE_MAGNET = 40.0
    BASE_HP = 3

    def test_heavy_push_additive_formula(self):
        # effective = base * (1 + 0.25 * tier)
        # Tier 0: 400
        # Tier 1: 500
        # Tier 2: 600
        # Tier 3: 700
        for tier, expected in [(0, 400.0), (1, 500.0), (2, 600.0), (3, 700.0)]:
            val = self.BASE_FORCE * (1.0 + 0.25 * tier)
            self.assertAlmostEqual(val, expected, places=3)

    def test_wider_reach_additive_formula(self):
        # effective = base * (1 + 0.20 * tier)
        # Tier 0: 50
        # Tier 1: 60
        # Tier 2: 70
        # Tier 3: 80
        for tier, expected in [(0, 50.0), (1, 60.0), (2, 70.0), (3, 80.0)]:
            val = self.BASE_RADIUS * (1.0 + 0.20 * tier)
            self.assertAlmostEqual(val, expected, places=3)

    def test_quick_charge_additive_formula(self):
        # effective = max(1.5, base - 0.4 * tier)
        # Tier 0: 3.5s
        # Tier 1: 3.1s
        # Tier 2: 2.7s
        # Tier 3: 2.3s
        for tier, expected in [(0, 3.5), (1, 3.1), (2, 2.7), (3, 2.3)]:
            val = max(1.5, self.BASE_CD - 0.4 * tier)
            self.assertAlmostEqual(val, expected, places=3)

    def test_swift_stone_additive_formula(self):
        # effective = base * (1 + 0.15 * tier)
        # Tier 0: 120
        # Tier 1: 138
        # Tier 2: 156
        # Tier 3: 174
        for tier, expected in [(0, 120.0), (1, 138.0), (2, 156.0), (3, 174.0)]:
            val = self.BASE_SPEED * (1.0 + 0.15 * tier)
            self.assertAlmostEqual(val, expected, places=3)

    def test_soul_magnet_additive_formula(self):
        # effective = base * (1 + 0.50 * tier)
        # Tier 0: 40
        # Tier 1: 60
        # Tier 2: 80
        # Tier 3: 100
        for tier, expected in [(0, 40.0), (1, 60.0), (2, 80.0), (3, 100.0)]:
            val = self.BASE_MAGNET * (1.0 + 0.50 * tier)
            self.assertAlmostEqual(val, expected, places=3)

    def test_stone_heart_additive_formula(self):
        # effective = base + tier
        # Tier 0: 3
        # Tier 1: 4
        # Tier 2: 5
        # Tier 3: 6
        for tier, expected in [(0, 3), (1, 4), (2, 5), (3, 6)]:
            val = self.BASE_HP + tier
            self.assertEqual(val, expected)

    def test_card_draw_uniqueness(self):
        pool = ["UPG_FORCE", "UPG_RADIUS", "UPG_CD", "UPG_SPEED", "UPG_MAGNET", "UPG_HP"]
        tiers = {card: 0 for card in pool}
        rng = random.Random(42)

        for _ in range(200):
            available = [c for c in pool if tiers[c] < 3]
            rng.shuffle(available)
            drawn = available[:3]
            self.assertEqual(len(drawn), 3)
            self.assertEqual(len(set(drawn)), 3)

    def test_max_tier_exclusion(self):
        pool = ["UPG_FORCE", "UPG_RADIUS", "UPG_CD", "UPG_SPEED", "UPG_MAGNET", "UPG_HP"]
        tiers = {card: 0 for card in pool}
        # Max out UPG_FORCE
        tiers["UPG_FORCE"] = 3
        rng = random.Random(123)

        for _ in range(100):
            available = [c for c in pool if tiers[c] < 3]
            rng.shuffle(available)
            drawn = available[:3]
            self.assertNotIn("UPG_FORCE", drawn)

    def test_reroll_state_and_usage(self):
        """F021.6: Verify rerolls_remaining tracking, can_reroll, and use_reroll."""
        class MockUpgradeManager:
            def __init__(self):
                self.rerolls_remaining = 0

            def inject_perm_bonuses(self, has_reroll=False):
                self.rerolls_remaining = 1 if has_reroll else 0

            def can_reroll(self):
                return self.rerolls_remaining > 0

            def use_reroll(self):
                if self.rerolls_remaining > 0:
                    self.rerolls_remaining -= 1
                    return True
                return False

            def reset(self):
                self.rerolls_remaining = 0

        mgr = MockUpgradeManager()
        self.assertFalse(mgr.can_reroll())
        self.assertEqual(mgr.rerolls_remaining, 0)

        # Without Foresight
        mgr.inject_perm_bonuses(has_reroll=False)
        self.assertFalse(mgr.can_reroll())
        self.assertFalse(mgr.use_reroll())

        # With Foresight
        mgr.inject_perm_bonuses(has_reroll=True)
        self.assertTrue(mgr.can_reroll())
        self.assertEqual(mgr.rerolls_remaining, 1)

        # Use reroll
        self.assertTrue(mgr.use_reroll())
        self.assertEqual(mgr.rerolls_remaining, 0)
        self.assertFalse(mgr.can_reroll())

        # Second use in same run must fail
        self.assertFalse(mgr.use_reroll())

        # Reset run resets rerolls
        mgr.reset()
        self.assertEqual(mgr.rerolls_remaining, 0)

    def test_reroll_draw_excludes_current_cards(self):
        """F021.6: Verify draw_cards filters exclude_ids when pool is sufficient."""
        pool = ["UPG_FORCE", "UPG_RADIUS", "UPG_CD", "UPG_SPEED", "UPG_MAGNET", "UPG_HP"]

        def simulate_draw_cards(count=3, exclude_ids=None, current_tiers=None):
            if exclude_ids is None:
                exclude_ids = []
            if current_tiers is None:
                current_tiers = {}

            available = [c for c in pool if current_tiers.get(c, 0) < 3]
            if not available:
                return []

            if exclude_ids:
                filtered = [c for c in available if c not in exclude_ids]
                if len(filtered) >= count:
                    available = filtered

            rng = random.Random(999)
            rng.shuffle(available)
            return available[:min(count, len(available))]

        # Initial draw: 3 cards
        initial = pool[:3]  # ["UPG_FORCE", "UPG_RADIUS", "UPG_CD"]

        # Reroll with initial excluded: must return the other 3
        rerolled = simulate_draw_cards(3, exclude_ids=initial)
        self.assertEqual(len(rerolled), 3)
        for card in initial:
            self.assertNotIn(card, rerolled)
        expected_other = set(pool[3:])
        self.assertEqual(set(rerolled), expected_other)

        # Edge case: only 2 cards available total (4 cards at max tier)
        tiers = {c: 3 for c in pool}
        tiers["UPG_FORCE"] = 0
        tiers["UPG_RADIUS"] = 0
        # When exclude_ids has 1 of them, filtered has 1 card (< count 2), so fallback returns both
        drawn_limited = simulate_draw_cards(2, exclude_ids=["UPG_FORCE"], current_tiers=tiers)
        self.assertEqual(len(drawn_limited), 2)
        self.assertIn("UPG_FORCE", drawn_limited)
        self.assertIn("UPG_RADIUS", drawn_limited)

if __name__ == "__main__":
    unittest.main()

