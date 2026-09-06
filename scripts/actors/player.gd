extends Node2D
## Intentional simple geometry: no physics body and no obstacle collisions.
## Main calls tick(); one owner controls pause, update order, and game state.

signal health_changed(value: int)

const Config = preload("res://scripts/core/game_config.gd")
var health: int = Config.MAX_HEALTH
var grace_remaining: float = 0.0
var facing: Vector2 = Vector2.UP

func reset() -> void:
	position = Config.PLAYFIELD.get_center()
	health = Config.MAX_HEALTH
	grace_remaining = 0.0
	facing = Vector2.UP
	health_changed.emit(health)
	queue_redraw()

func tick(delta: float) -> void:
	grace_remaining = maxf(0.0, grace_remaining - delta)
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_by(direction, delta)
	queue_redraw()

func move_by(direction: Vector2, delta: float) -> void:
	var normalized_input: Vector2 = direction.limit_length(1.0)
	if normalized_input.length_squared() > 0.001:
		facing = normalized_input.normalized()
	position = Config.clamp_inside(position + normalized_input * Config.PLAYER_SPEED * delta, Config.PLAYER_RADIUS)

func take_hit() -> bool:
	if health <= 0 or grace_remaining > 0.0:
		return false
	health = maxi(0, health - 1)
	grace_remaining = Config.HIT_GRACE_SECONDS
	health_changed.emit(health)
	queue_redraw()
	return true

func _draw() -> void:
	var color: Color = Color("64b7ff")
	draw_circle(Vector2.ZERO, Config.PLAYER_RADIUS + 5.0, Color(0.39, 0.72, 1.0, 0.12))
	draw_circle(Vector2.ZERO, Config.PLAYER_RADIUS, color)
	draw_arc(Vector2.ZERO, Config.PLAYER_RADIUS, 0.0, TAU, 32, Color("b7dcff"), 1.5, true)
	var tip: Vector2 = facing * 9.0
	var side: Vector2 = facing.orthogonal() * 4.0
	draw_colored_polygon(PackedVector2Array([tip, -facing * 3.0 + side, -facing * 3.0 - side]), Color("102230"))
	if grace_remaining > 0.0:
		# Steady ring, not flashing. Pause freezes its remaining time.
		draw_arc(Vector2.ZERO, 23.0, -PI / 2.0, -PI / 2.0 + TAU * grace_remaining / Config.HIT_GRACE_SECONDS, 40, Color("f2e5be"), 2.5, true)
