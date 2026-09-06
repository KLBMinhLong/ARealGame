extends RefCounted
## Small, explicit configuration. These are design defaults, not benchmarks.

const VIEW_SIZE: Vector2 = Vector2(1152.0, 648.0)
const PLAYFIELD: Rect2 = Rect2(40.0, 112.0, 1072.0, 480.0)
const RUN_SECONDS: float = 180.0
const PLAYER_SPEED: float = 270.0
const PLAYER_RADIUS: float = 14.0
const MAX_HEALTH: int = 3
const HIT_GRACE_SECONDS: float = 1.2
const ENEMY_RADIUS: float = 12.0
const ENEMY_SPEED_START: float = 72.0
const ENEMY_SPEED_END: float = 118.0
const SPAWN_INTERVAL_START: float = 1.35
const SPAWN_INTERVAL_END: float = 0.48
const MAX_ENEMIES: int = 64
const MIN_SPAWN_DISTANCE: float = 210.0

static func clamp_inside(point: Vector2, radius: float) -> Vector2:
	return Vector2(
		clampf(point.x, PLAYFIELD.position.x + radius, PLAYFIELD.end.x - radius),
		clampf(point.y, PLAYFIELD.position.y + radius, PLAYFIELD.end.y - radius)
	)

static func difficulty_progress(elapsed: float) -> float:
	return clampf(elapsed / RUN_SECONDS, 0.0, 1.0)

static func spawn_interval(elapsed: float) -> float:
	return lerpf(SPAWN_INTERVAL_START, SPAWN_INTERVAL_END, difficulty_progress(elapsed))

static func enemy_speed(elapsed: float) -> float:
	return lerpf(ENEMY_SPEED_START, ENEMY_SPEED_END, difficulty_progress(elapsed))

static func choose_spawn(rng: RandomNumberGenerator, player_position: Vector2) -> Vector2:
	var inner: Rect2 = PLAYFIELD.grow(-ENEMY_RADIUS - 2.0)
	for attempt in range(12):
		var point: Vector2
		match rng.randi_range(0, 3):
			0: point = Vector2(inner.position.x, rng.randf_range(inner.position.y, inner.end.y))
			1: point = Vector2(inner.end.x, rng.randf_range(inner.position.y, inner.end.y))
			2: point = Vector2(rng.randf_range(inner.position.x, inner.end.x), inner.position.y)
			_: point = Vector2(rng.randf_range(inner.position.x, inner.end.x), inner.end.y)
		if point.distance_to(player_position) >= MIN_SPAWN_DISTANCE:
			return point
	# Deterministic fallback: pick the farthest corner, never loop indefinitely.
	var corners: Array[Vector2] = [inner.position, Vector2(inner.end.x, inner.position.y), inner.end, Vector2(inner.position.x, inner.end.y)]
	var farthest: Vector2 = corners[0]
	for point in corners:
		if point.distance_squared_to(player_position) > farthest.distance_squared_to(player_position):
			farthest = point
	return farthest
