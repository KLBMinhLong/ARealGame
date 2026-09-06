extends Node2D
class_name ScrapItem

signal collected(value: int)

const Config = preload("res://scripts/core/game_config.gd")

var value: int = 1
var magnet_radius: float = 120.0
var magnet_speed: float = 280.0
var pickup_radius: float = 22.0
var rotation_angle: float = 0.0
var lifetime: float = 60.0
var is_attracted: bool = false
var velocity: Vector2 = Vector2.ZERO

func configure(pos: Vector2, scrap_val: int = 1, initial_scatter_velocity: Vector2 = Vector2.ZERO) -> void:
	position = pos
	value = scrap_val
	velocity = initial_scatter_velocity
	rotation_angle = randf() * TAU
	queue_redraw()

func tick(delta: float, player_pos: Vector2, custom_magnet_radius: float = 120.0, custom_magnet_speed: float = 280.0) -> bool:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return false

	rotation_angle += delta * 3.5
	if velocity.length_squared() > 1.0:
		velocity = velocity.move_toward(Vector2.ZERO, delta * 300.0)
		position = Config.clamp_inside(position + velocity * delta, 6.0)

	var dist_to_player: float = position.distance_to(player_pos)
	if dist_to_player <= custom_magnet_radius:
		is_attracted = true
		var dir: Vector2 = (player_pos - position).normalized()
		var pull_accel: float = custom_magnet_speed * (1.0 + (1.0 - dist_to_player / custom_magnet_radius) * 1.5)
		position += dir * pull_accel * delta

	if dist_to_player <= pickup_radius:
		collected.emit(value)
		queue_free()
		return true

	queue_redraw()
	return false

func _draw() -> void:
	var pulse_glow: float = 0.8 + 0.2 * sin(rotation_angle * 2.0)
	var core_color: Color = Color("facc15") # Neon Gold
	var glow_color: Color = Color(0.98, 0.80, 0.08, 0.25 * pulse_glow)
	var rim_color: Color = Color("a3e635") # Neon Lime

	draw_circle(Vector2.ZERO, 7.0, glow_color)
	draw_circle(Vector2.ZERO, 3.5, core_color)

	# 4-point magnetic gear teeth
	for i in range(4):
		var angle: float = rotation_angle + (i * PI / 2.0)
		var tooth_dir: Vector2 = Vector2(cos(angle), sin(angle))
		draw_line(tooth_dir * 3.0, tooth_dir * 5.5, rim_color, 1.5)
