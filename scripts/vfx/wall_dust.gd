## wall_dust.gd — F004 Wall Dust Particles
## Spawn CPUParticles2D one-shot tại vị trí wall slam.
## Hướng bắn ngược tường, tự queue_free sau lifetime.
## Attach vào $VFX (world space).
extends Node2D

const PARTICLE_LIFETIME := 0.4  # s
const PARTICLE_COUNT := 6


## Spawn dust tại world position. Suy hướng tường từ vị trí vs arena bounds.
func spawn_dust(at_position: Vector2) -> void:
	var particles := CPUParticles2D.new()
	particles.position = at_position
	particles.emitting = false  # Set params trước, emit sau

	# One-shot
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.amount = PARTICLE_COUNT
	particles.lifetime = PARTICLE_LIFETIME

	# Hướng bắn: ngược tường
	var direction := _get_wall_direction(at_position)
	particles.direction = direction
	particles.spread = 30.0  # ±30°

	# Velocity
	particles.initial_velocity_min = 15.0
	particles.initial_velocity_max = 35.0

	# Gravity nhẹ
	particles.gravity = Vector2(0, 40)

	# Size nhỏ (pixel art)
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.5

	# Màu: trắng/xám, mờ
	var color_ramp := Gradient.new()
	color_ramp.set_color(0, Color(0.8, 0.8, 0.8, 0.5))
	color_ramp.set_color(1, Color(0.6, 0.6, 0.6, 0.0))
	particles.color_ramp = color_ramp

	add_child(particles)
	particles.emitting = true

	# Auto cleanup sau lifetime + buffer
	var timer := get_tree().create_timer(PARTICLE_LIFETIME + 0.2)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(particles):
			particles.queue_free()
	)


## Suy hướng tường từ vị trí — gần bound nào nhất = tường đó.
func _get_wall_direction(pos: Vector2) -> Vector2:
	var to_left := pos.x - Config.ARENA_ORIGIN.x
	var to_right := Config.ARENA_END.x - pos.x
	var to_top := pos.y - Config.ARENA_ORIGIN.y
	var to_bottom := Config.ARENA_END.y - pos.y

	var min_dist := minf(minf(to_left, to_right), minf(to_top, to_bottom))

	# Bắn ngược tường (ra khỏi tường)
	if min_dist == to_left:
		return Vector2(1, 0)  # Đập left → bắn phải
	elif min_dist == to_right:
		return Vector2(-1, 0)  # Đập right → bắn trái
	elif min_dist == to_top:
		return Vector2(0, 1)  # Đập top → bắn xuống
	else:
		return Vector2(0, -1)  # Đập bottom → bắn lên


## F006: Burst particles khi quái chết.
func spawn_death_burst(at_position: Vector2, enemy_color: Color) -> void:
	var particles := CPUParticles2D.new()
	particles.position = at_position
	particles.emitting = false

	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 10
	particles.lifetime = 0.3

	# 360° burst
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0

	particles.initial_velocity_min = 25.0
	particles.initial_velocity_max = 60.0

	particles.gravity = Vector2(0, 30)

	particles.scale_amount_min = 0.8
	particles.scale_amount_max = 2.0

	# Màu quái → fade
	var color_ramp := Gradient.new()
	color_ramp.set_color(0, Color(1.0, 1.0, 1.0, 0.9))  # Flash trắng ban đầu
	color_ramp.set_color(1, Color(enemy_color.r, enemy_color.g, enemy_color.b, 0.0))
	particles.color_ramp = color_ramp

	add_child(particles)
	particles.emitting = true

	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(particles):
			particles.queue_free()
	)


## Clear tất cả particles — restart/menu.
func clear() -> void:
	for child in get_children():
		child.queue_free()
