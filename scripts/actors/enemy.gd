extends Node2D

const Config = preload("res://scripts/core/game_config.gd")
var speed: float = Config.ENEMY_SPEED_START

func configure(spawn_position: Vector2, move_speed: float) -> void:
	position = spawn_position
	speed = move_speed

func tick(delta: float, target_position: Vector2) -> void:
	var offset: Vector2 = target_position - position
	position = position.move_toward(target_position, speed * delta)
	if offset.length_squared() > 0.001:
		rotation = offset.angle()

func _draw() -> void:
	var radius: float = Config.ENEMY_RADIUS
	# A diamond rather than a circle: readable without color alone.
	var shape: PackedVector2Array = PackedVector2Array([Vector2(radius, 0.0), Vector2(0.0, radius), Vector2(-radius, 0.0), Vector2(0.0, -radius)])
	draw_colored_polygon(shape, Color("f19a69"))
	draw_polyline(PackedVector2Array([shape[0], shape[1], shape[2], shape[3], shape[0]]), Color("ffd5b7"), 1.2, true)
	draw_circle(Vector2(3.0, 0.0), 2.2, Color("542e20"))
