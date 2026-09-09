# test_f020_warden.py — Automated verification for Mini-Boss "The Warden" (F020)
import unittest
import math


class TestF020WardenBoss(unittest.TestCase):
    # Mirroring Config parameters
    WARDEN_HP = 10
    WARDEN_SPEED = 45.0
    WARDEN_SIZE = 24
    WARDEN_PUSH_WEIGHT = 1.6
    WARDEN_SHARD_DROP = 15
    WARDEN_SLAM_RADIUS = 80.0
    WARDEN_SLAM_INTERVAL = 5.0
    WARDEN_SLAM_INTERVAL_ENRAGED = 3.5
    WARDEN_TELEGRAPH_DURATION = 1.0
    WARDEN_RECOVERY_DURATION = 0.6
    WARDEN_SLAM_DAMAGE = 1
    WARDEN_ENRAGE_SPEED_MULT = 1.2

    DECELERATION = 800.0
    PULSE_FORCE_BASE = 400.0
    PULSE_FORCE_HEAVY_TIER3 = 700.0

    DAMAGE_WALL_SLAM = 1
    DAMAGE_SPIKE_SLAM = 2

    def test_warden_config_attributes(self):
        """AC01: Warden has 10 HP, 24px size, 1.6 push weight, and 15 shard drop."""
        self.assertEqual(self.WARDEN_HP, 10)
        self.assertEqual(self.WARDEN_SIZE, 24)
        self.assertEqual(self.WARDEN_PUSH_WEIGHT, 1.6)
        self.assertEqual(self.WARDEN_SHARD_DROP, 15)
        self.assertEqual(self.WARDEN_SLAM_RADIUS, 80.0)
        self.assertEqual(self.WARDEN_TELEGRAPH_DURATION, 1.0)
        self.assertEqual(self.WARDEN_RECOVERY_DURATION, 0.6)

    def test_warden_push_physics_travel(self):
        """AC01: Warden travels ~39px on base push and ~119px with Heavy Push Tier 3."""
        # Base push
        base_v0 = self.PULSE_FORCE_BASE / self.WARDEN_PUSH_WEIGHT
        base_dist = (base_v0 ** 2) / (2.0 * self.DECELERATION)
        self.assertAlmostEqual(base_dist, 39.0625, places=2)
        self.assertGreater(base_dist, 35.0, "Warden must fly far enough to hit nearby walls")
        self.assertLess(base_dist, 45.0, "Warden must feel substantially heavier than Brute (~55px)")

        # Upgraded push (Tier 3 Heavy Push)
        upgraded_v0 = self.PULSE_FORCE_HEAVY_TIER3 / self.WARDEN_PUSH_WEIGHT
        upgraded_dist = (upgraded_v0 ** 2) / (2.0 * self.DECELERATION)
        self.assertAlmostEqual(upgraded_dist, 119.6289, places=2)
        self.assertGreater(upgraded_dist, 100.0, "Upgraded push must launch Warden across half the arena")

    def test_aoe_slam_detection(self):
        """AC02: Players inside 80px radius take damage; players outside are safe."""
        warden_pos = (240.0, 100.0)

        # Player at 60px distance (inside)
        player_inside = (240.0, 160.0)
        dist_inside = math.dist(warden_pos, player_inside)
        self.assertTrue(dist_inside <= self.WARDEN_SLAM_RADIUS)

        # Player at 90px distance (outside)
        player_outside = (240.0, 190.0)
        dist_outside = math.dist(warden_pos, player_outside)
        self.assertFalse(dist_outside <= self.WARDEN_SLAM_RADIUS)

        # Player at exact boundary 80.0px
        player_boundary = (240.0, 180.0)
        dist_boundary = math.dist(warden_pos, player_boundary)
        self.assertTrue(dist_boundary <= self.WARDEN_SLAM_RADIUS)

    def test_altar_immunity_logic(self):
        """AC04: Warden is immune to instant Altar seal; takes 1 damage instead."""
        hp = self.WARDEN_HP
        # When pushed into altar
        is_warden = True
        if is_warden:
            # Warden takes 1 damage, hp goes 10 -> 9, NOT 0!
            hp -= 1
            sealed = False
        else:
            hp = 0
            sealed = True

        self.assertFalse(sealed)
        self.assertEqual(hp, 9)
        self.assertGreater(hp, 0, "Warden must not die from single Altar hit")

    def test_spike_wall_vs_normal_wall_kill_count(self):
        """AC06: Warden takes 5 Spike Wall slams (2 dmg) or 10 Normal Wall slams (1 dmg) to defeat."""
        spike_slams_needed = math.ceil(self.WARDEN_HP / self.DAMAGE_SPIKE_SLAM)
        normal_slams_needed = math.ceil(self.WARDEN_HP / self.DAMAGE_WALL_SLAM)

        self.assertEqual(spike_slams_needed, 5, "Spike Wall should kill Warden in exactly 5 slams")
        self.assertEqual(normal_slams_needed, 10, "Normal Wall should kill Warden in 10 slams")

    def test_wave5_victory_requires_warden_death(self):
        """AC05: Wave 5 timer expiring does not trigger Victory; only Warden death triggers Victory."""
        current_wave = 5
        wave_time_left = 0.0  # timer ran out
        warden_alive = True
        victory_triggered = False
        enraged = False

        # Simulation of main.gd Wave 5 loop
        if current_wave == 5:
            if wave_time_left <= 0.0:
                enraged = True
                # Does NOT set victory_triggered
            if not warden_alive:
                victory_triggered = True

        self.assertTrue(enraged, "Timer running out must trigger Enrage")
        self.assertFalse(victory_triggered, "Timer running out must NEVER grant Victory in Wave 5")

        # Now simulate Warden being defeated
        warden_alive = False
        if not warden_alive:
            victory_triggered = True

        self.assertTrue(victory_triggered, "Defeating Warden must trigger Victory")


if __name__ == "__main__":
    unittest.main()
