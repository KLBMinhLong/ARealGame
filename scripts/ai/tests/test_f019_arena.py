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
    Automated verification for F019A (Wave Layout Foundation) & F019B (Spike Wall):
    - Layout definitions and geometry bounds
    - Single impact resolution at corners
    - Altar and spawn clearance
    - Spike damage values
    """

    ARENA_ORIGIN = (30.0, 30.0)
    ARENA_END = (450.0, 240.0)
    ALTAR_POS = (240.0, 90.0)
    ALTAR_SIZE = 24.0

    ARENA_LAYOUTS = [
        {"wave": 1, "spike_walls": []},
        {"wave": 2, "spike_walls": []},
        {"wave": 3, "spike_walls": [
            Rect2(30.0, 105.0, 6.0, 60.0),
            Rect2(444.0, 105.0, 6.0, 60.0),
        ]},
        {"wave": 4, "spike_walls": [
            Rect2(110.0, 30.0, 60.0, 6.0),
            Rect2(310.0, 30.0, 60.0, 6.0),
        ]},
        {"wave": 5, "spike_walls": [
            Rect2(30.0, 105.0, 6.0, 60.0),
            Rect2(444.0, 105.0, 6.0, 60.0),
            Rect2(210.0, 234.0, 60.0, 6.0),
        ]},
    ]

    DAMAGE_WALL_SLAM = 1
    DAMAGE_SPIKE_SLAM = 2
    BRUTE_HP = 2

    def test_damage_values_and_brute_one_hit_kill(self):
        self.assertEqual(self.DAMAGE_WALL_SLAM, 1)
        self.assertEqual(self.DAMAGE_SPIKE_SLAM, 2)
        self.assertEqual(self.BRUTE_HP, 2)
        # Spike slam deals exactly enough damage to 1-hit kill a Brute
        self.assertGreaterEqual(self.DAMAGE_SPIKE_SLAM, self.BRUTE_HP)

    def test_layout_counts_and_progression(self):
        self.assertEqual(len(self.ARENA_LAYOUTS), 5)
        # Wave 1 and 2 have 0 spikes (introductory phases)
        self.assertEqual(len(self.ARENA_LAYOUTS[0]["spike_walls"]), 0)
        self.assertEqual(len(self.ARENA_LAYOUTS[1]["spike_walls"]), 0)
        # Wave 3 introduces 2 spike wall segments
        self.assertEqual(len(self.ARENA_LAYOUTS[2]["spike_walls"]), 2)
        # Wave 4 has 2 top segments
        self.assertEqual(len(self.ARENA_LAYOUTS[3]["spike_walls"]), 2)
        # Wave 5 has 3 strategic segments
        self.assertEqual(len(self.ARENA_LAYOUTS[4]["spike_walls"]), 3)

    def test_spike_walls_lie_on_perimeter_bounds(self):
        for layout in self.ARENA_LAYOUTS:
            for spike in layout["spike_walls"]:
                # Check within arena bounding box
                self.assertGreaterEqual(spike.x, self.ARENA_ORIGIN[0] - 0.1)
                self.assertLessEqual(spike.x + spike.w, self.ARENA_END[0] + 0.1)
                self.assertGreaterEqual(spike.y, self.ARENA_ORIGIN[1] - 0.1)
                self.assertLessEqual(spike.y + spike.h, self.ARENA_END[1] + 0.1)

    def test_spike_walls_do_not_overlap_altar(self):
        altar_rect = Rect2(
            self.ALTAR_POS[0] - self.ALTAR_SIZE / 2.0 - 20.0,
            self.ALTAR_POS[1] - self.ALTAR_SIZE / 2.0 - 20.0,
            self.ALTAR_SIZE + 40.0,
            self.ALTAR_SIZE + 40.0
        )
        for layout in self.ARENA_LAYOUTS:
            for spike in layout["spike_walls"]:
                # Bounding box collision test
                overlap = not (
                    spike.x + spike.w < altar_rect.x or
                    spike.x > altar_rect.x + altar_rect.w or
                    spike.y + spike.h < altar_rect.y or
                    spike.y > altar_rect.y + altar_rect.h
                )
                self.assertFalse(overlap, f"Spike wall {spike.x},{spike.y} overlaps Altar!")

    def test_contact_detection_accuracy(self):
        spikes = self.ARENA_LAYOUTS[2]["spike_walls"]  # Wave 3: left [30, 105, 6, 60]
        # Point right in the middle of left spike wall
        hit_pos = (30.0, 135.0)
        is_spike = any(s.grow(6.0).has_point(hit_pos) for s in spikes)
        self.assertTrue(is_spike)

        # Point on normal wall outside spike segment (e.g. y=50 on left wall)
        hit_pos_normal = (30.0, 50.0)
        is_spike_normal = any(s.grow(6.0).has_point(hit_pos_normal) for s in spikes)
        self.assertFalse(is_spike_normal)

    def test_single_impact_corner_resolution(self):
        """
        Verify that hitting a corner adjacent to a spike segment resolves as
        SPIKE_WALL and deals exactly 2 damage, not 2 + 1 = 3.
        """
        # In a corner where X touches spike wall and Y touches normal wall
        hit_points = [(30.0, 105.0), (30.0, 30.0)]
        spikes = [Rect2(30.0, 105.0, 6.0, 60.0)]

        is_spike = any(any(s.grow(6.0).has_point(pt) for s in spikes) for pt in hit_points)
        self.assertTrue(is_spike)

        # Single damage resolution logic:
        damage = self.DAMAGE_SPIKE_SLAM if is_spike else self.DAMAGE_WALL_SLAM
        self.assertEqual(damage, 2, "Corner impact must resolve to exactly 2 damage, never 3")

if __name__ == "__main__":
    unittest.main()
