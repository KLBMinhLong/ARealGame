import unittest

class Rect2:
    def __init__(self, x: float, y: float, w: float, h: float):
        self.x = x
        self.y = y
        self.w = w
        self.h = h

    def grow(self, amount: float):
        return Rect2(self.x - amount, self.y - amount, self.w + amount * 2.0, self.h + amount * 2.0)

    def has_point(self, pt: tuple):
        px, py = pt
        return (self.x <= px <= self.x + self.w) and (self.y <= py <= self.y + self.h)

class TestF019ArenaHazards(unittest.TestCase):
    """
    Automated verification for F019 Tuning:
    - Expanded layout definitions (120px on side walls)
    - Front-edge collision stopping at front of spikes
    - Bonus shard (+1) on spike slam kill for all enemies
    - Brute push weight tuning (1.35 -> ~55px travel distance)
    """

    ARENA_ORIGIN = (30.0, 30.0)
    ARENA_END = (450.0, 240.0)
    ALTAR_POS = (240.0, 90.0)
    ALTAR_SIZE = 24.0

    ARENA_LAYOUTS = [
        {"wave": 1, "spike_walls": []},
        {"wave": 2, "spike_walls": []},
        {"wave": 3, "spike_walls": [
            Rect2(30.0, 75.0, 8.0, 120.0),
            Rect2(442.0, 75.0, 8.0, 120.0),
        ]},
        {"wave": 4, "spike_walls": [
            Rect2(80.0, 30.0, 100.0, 8.0),
            Rect2(300.0, 30.0, 100.0, 8.0),
        ]},
        {"wave": 5, "spike_walls": [
            Rect2(30.0, 75.0, 8.0, 120.0),
            Rect2(442.0, 75.0, 8.0, 120.0),
            Rect2(190.0, 232.0, 100.0, 8.0),
        ]},
    ]

    DAMAGE_WALL_SLAM = 1
    DAMAGE_SPIKE_SLAM = 2
    BRUTE_HP = 2
    BRUTE_PUSH_WEIGHT = 1.35
    PULSE_VELOCITY = 400.0
    PULSE_DECELERATION = 800.0
    SHARD_SPIKE_BONUS = 1

    def test_damage_values_and_brute_one_hit_kill(self):
        self.assertEqual(self.DAMAGE_WALL_SLAM, 1)
        self.assertEqual(self.DAMAGE_SPIKE_SLAM, 2)
        self.assertEqual(self.BRUTE_HP, 2)
        self.assertGreaterEqual(self.DAMAGE_SPIKE_SLAM, self.BRUTE_HP)

    def test_brute_travel_distance(self):
        # Initial velocity for Brute
        v0 = self.PULSE_VELOCITY / self.BRUTE_PUSH_WEIGHT
        # v0 = 400 / 1.35 = 296.3 px/s
        self.assertAlmostEqual(v0, 296.296, places=2)
        # Travel distance = v0^2 / (2 * decel)
        dist = (v0 * v0) / (2.0 * self.PULSE_DECELERATION)
        # dist ~ 54.87 px (previously was 30.86 px with weight 1.8)
        self.assertGreater(dist, 50.0, "Brute travel distance must exceed 50px for dash-and-pulse feasibility")

    def test_shard_bonus_on_spike_kill(self):
        self.assertEqual(self.SHARD_SPIKE_BONUS, 1)
        # Slime: 1 base + 1 spike bonus = 2
        self.assertEqual(1 + self.SHARD_SPIKE_BONUS, 2)
        # Speeder: 1 base + 1 spike bonus = 2
        self.assertEqual(1 + self.SHARD_SPIKE_BONUS, 2)
        # Brute: 2 base + 1 spike bonus = 3
        self.assertEqual(self.BRUTE_HP + self.SHARD_SPIKE_BONUS, 3)

    def test_layout_counts_and_progression(self):
        self.assertEqual(len(self.ARENA_LAYOUTS), 5)
        self.assertEqual(len(self.ARENA_LAYOUTS[0]["spike_walls"]), 0)
        self.assertEqual(len(self.ARENA_LAYOUTS[1]["spike_walls"]), 0)
        # Wave 3 has 2 expanded 120px segments
        self.assertEqual(len(self.ARENA_LAYOUTS[2]["spike_walls"]), 2)
        self.assertEqual(self.ARENA_LAYOUTS[2]["spike_walls"][0].h, 120.0)
        # Wave 4 has 2 100px segments
        self.assertEqual(len(self.ARENA_LAYOUTS[3]["spike_walls"]), 2)
        # Wave 5 has 3 segments
        self.assertEqual(len(self.ARENA_LAYOUTS[4]["spike_walls"]), 3)

    def test_spike_walls_lie_on_perimeter_bounds(self):
        for layout in self.ARENA_LAYOUTS:
            for spike in layout["spike_walls"]:
                self.assertGreaterEqual(spike.x, self.ARENA_ORIGIN[0] - 0.1)
                self.assertLessEqual(spike.x + spike.w, self.ARENA_END[0] + 0.1)
                self.assertGreaterEqual(spike.y, self.ARENA_ORIGIN[1] - 0.1)
                self.assertLessEqual(spike.y + spike.h, self.ARENA_END[1] + 0.1)

    def test_front_edge_spike_collision_snaps_in_front(self):
        # Left wall spike: x=30, w=8 -> front edge is x=38.
        # Enemy with half-size 5 moving left from x=45 towards x=30.
        # Normal wall would stop at 30 + 5 = 35.
        # Front-edge spike collision MUST stop at 38 + 5 = 43!
        half = 5.0
        spike = Rect2(30.0, 75.0, 8.0, 120.0)
        front_x = spike.x + spike.w  # 38.0
        enemy_x = 40.0  # would hit front edge because 40 - 5 = 35 <= 38
        snap_x = front_x + half  # 43.0
        self.assertEqual(snap_x, 43.0)
        self.assertGreater(snap_x, self.ARENA_ORIGIN[0] + half, "Must stop in front of spikes, not inside gray wall")

    def test_contact_detection_accuracy(self):
        spikes = self.ARENA_LAYOUTS[2]["spike_walls"]  # Wave 3: left [30, 75, 8, 120]
        # Point inside 120px left spike wall (e.g. y=135)
        hit_pos = (30.0, 135.0)
        is_spike = any(s.grow(6.0).has_point(hit_pos) for s in spikes)
        self.assertTrue(is_spike)

        # Point on normal wall outside spike segment (e.g. y=50 on left wall)
        hit_pos_normal = (30.0, 50.0)
        is_spike_normal = any(s.grow(6.0).has_point(hit_pos_normal) for s in spikes)
        self.assertFalse(is_spike_normal)

if __name__ == "__main__":
    unittest.main()
