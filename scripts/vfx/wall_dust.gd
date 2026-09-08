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

## F007: Burst particles khi nhặt shard.
func spawn_pickup_burst(at_position: Vector2) -> void:
	var particles := CPUParticles2D.new()
	particles.position = at_position
	particles.emitting = false

	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 6
	particles.lifetime = 0.25

	particles.direction = Vector2(0, -1)
	particles.spread = 180.0

	particles.initial_velocity_min = 15.0
	particles.initial_velocity_max = 40.0

	particles.gravity = Vector2(0, 20)

	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.2

	var color_ramp := Gradient.new()
	color_ramp.set_color(0, Color(Config.COLOR_SHARD.r, Config.COLOR_SHARD.g, Config.COLOR_SHARD.b, 0.9))
	color_ramp.set_color(1, Color(1.0, 1.0, 0.8, 0.0))
	particles.color_ramp = color_ramp

	add_child(particles)
	particles.emitting = true

	var timer := get_tree().create_timer(0.45)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(particles):
			particles.queue_free()
	)


## F015: Void vortex particles khi quái bị phong ấn vào Altar.
func spawn_altar_seal_vfx(at_position: Vector2) -> void:
	var particles := CPUParticles2D.new()
	particles.position = at_position
	particles.emitting = false

	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 14
	particles.lifetime = 0.35

	particles.direction = Vector2(0, -1)
	particles.spread = 180.0

	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 50.0
	particles.gravity = Vector2.ZERO

	particles.scale_amount_min = 0.8
	particles.scale_amount_max = 2.0

	var color_ramp := Gradient.new()
	color_ramp.set_color(0, Color(Config.COLOR_ALTAR_FLASH.r, Config.COLOR_ALTAR_FLASH.g, Config.COLOR_ALTAR_FLASH.b, 1.0))
	color_ramp.set_color(1, Color(Config.COLOR_ALTAR.r, Config.COLOR_ALTAR.g, Config.COLOR_ALTAR.b, 0.0))
	particles.color_ramp = color_ramp

	add_child(particles)
	particles.emitting = true

	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(particles):
			particles.queue_free()
	)


## F015: Floating text hiển thị số tiền cộng thẳng (ví dụ +2).
func spawn_floating_text(at_position: Vector2, text: String, text_color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = at_position - Vector2(16, 8)
	label.size = Vector2(32, 16)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_font_size_override("font_size", 9)
	add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 14.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func() -> void:
		if is_instance_valid(label):
			label.queue_free()
	)


## Clear tất cả particles — restart/menu.
func clear() -> void:
	for child in get_children():
		child.queue_free()
