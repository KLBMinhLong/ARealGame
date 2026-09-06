extends Node2D

signal telegraph_started
signal dash_started
signal died(pos: Vector2, enemy_type: Type, hit_wall: bool)

const Config = preload("res://scripts/core/game_config.gd")

enum Type { CHASER, SPRINTER }
enum SprinterPhase { STALK, TELEGRAPH, DASH, REST }

var enemy_type: Type = Type.CHASER
var speed: float = Config.ENEMY_SPEED_START
var stun_remaining: float = 0.0
var health: int = 1

var sprinter_phase: SprinterPhase = SprinterPhase.STALK
var phase_timer: float = 0.0
var locked_direction: Vector2 = Vector2.RIGHT

func configure(spawn_position: Vector2, move_speed: float, type: Type = Type.CHASER) -> void:
	position = spawn_position
	speed = move_speed
	enemy_type = type
	stun_remaining = 0.0
	health = 2 if enemy_type == Type.SPRINTER else 1
	if enemy_type == Type.SPRINTER:
		sprinter_phase = SprinterPhase.STALK
		phase_timer = Config.SPRINTER_STALK_SECONDS
	queue_redraw()

func take_damage(amount: int, from_wall: bool = false) -> bool:
	health -= amount
	if health <= 0:
		died.emit(position, enemy_type, from_wall)
		queue_free()
		return true
	return false

func push_back(from_position: Vector2, distance: float, stun_duration: float, force_multiplier: float = 1.0) -> Dictionary:
	var diff: Vector2 = position - from_position
	var push_dir: Vector2 = diff.normalized() if diff.length_squared() > 0.001 else Vector2.UP
	var total_distance: float = distance * force_multiplier
	var target_pos: Vector2 = position + push_dir * total_distance
	var clamped_pos: Vector2 = Config.clamp_inside(target_pos, Config.ENEMY_RADIUS)
	var hit_wall: bool = not is_equal_approx(target_pos.x, clamped_pos.x) or not is_equal_approx(target_pos.y, clamped_pos.y)
	position = clamped_pos
	stun_remaining = maxf(stun_remaining, stun_duration)
	if enemy_type == Type.SPRINTER:
		if sprinter_phase == SprinterPhase.TELEGRAPH or sprinter_phase == SprinterPhase.DASH:
			sprinter_phase = SprinterPhase.REST
			phase_timer = Config.SPRINTER_REST_SECONDS
	queue_redraw()
	return {
		"hit_wall": hit_wall,
		"push_dir": push_dir,
		"position": position
	}

func tick(delta: float, target_position: Vector2, separation: Vector2 = Vector2.ZERO) -> void:
	if stun_remaining > 0.0:
		stun_remaining = maxf(0.0, stun_remaining - delta)
		if stun_remaining <= 0.0:
			queue_redraw()
		return

	if enemy_type == Type.CHASER:
		_tick_chaser(delta, target_position, separation)
	else:
		_tick_sprinter(delta, target_position)

func _tick_chaser(delta: float, target_position: Vector2, separation: Vector2 = Vector2.ZERO) -> void:
	var offset: Vector2 = target_position - position
	var move_dir: Vector2 = offset.normalized() if offset.length_squared() > 0.001 else Vector2.ZERO
	if separation.length_squared() > 0.001:
		move_dir = (move_dir * 0.75 + separation.normalized() * 0.25).normalized()
	position = Config.clamp_inside(position + move_dir * speed * delta, Config.ENEMY_RADIUS)
	if offset.length_squared() > 0.001:
		rotation = offset.angle()

func _tick_sprinter(delta: float, target_position: Vector2) -> void:
	phase_timer -= delta
	match sprinter_phase:
		SprinterPhase.STALK:
			var offset: Vector2 = target_position - position
			position = position.move_toward(target_position, Config.SPRINTER_STALK_SPEED * delta)
			if offset.length_squared() > 0.001:
				rotation = offset.angle()
			if phase_timer <= 0.0:
				sprinter_phase = SprinterPhase.TELEGRAPH
				phase_timer = Config.SPRINTER_TELEGRAPH_SECONDS
				locked_direction = (target_position - position).normalized() if offset.length_squared() > 0.001 else Vector2.RIGHT
				rotation = locked_direction.angle()
				telegraph_started.emit()
				queue_redraw()

		SprinterPhase.TELEGRAPH:
			queue_redraw()
			if phase_timer <= 0.0:
				sprinter_phase = SprinterPhase.DASH
				phase_timer = Config.SPRINTER_DASH_MAX_SECONDS
				dash_started.emit()
				queue_redraw()

		SprinterPhase.DASH:
			var next_pos: Vector2 = position + locked_direction * Config.SPRINTER_DASH_SPEED * delta
			var clamped_pos: Vector2 = Config.clamp_inside(next_pos, Config.ENEMY_RADIUS)
			var hit_wall: bool = not is_equal_approx(next_pos.x, clamped_pos.x) or not is_equal_approx(next_pos.y, clamped_pos.y)
			position = clamped_pos
			if hit_wall or phase_timer <= 0.0:
				sprinter_phase = SprinterPhase.REST
				phase_timer = Config.SPRINTER_REST_SECONDS
				queue_redraw()

		SprinterPhase.REST:
			if phase_timer <= 0.0:
				sprinter_phase = SprinterPhase.STALK
				phase_timer = Config.SPRINTER_STALK_SECONDS
				queue_redraw()

func _draw() -> void:
	var radius: float = Config.ENEMY_RADIUS
	if enemy_type == Type.CHASER:
		# 1. Industrial Treads / Claws on the sides
		var tread_color: Color = Color("141923")
		draw_rect(Rect2(-radius + 2.0, -radius - 2.5, radius * 1.6, 3.0), tread_color)
		draw_rect(Rect2(-radius + 2.0, radius - 0.5, radius * 1.6, 3.0), tread_color)
		# Tread rivets
		draw_circle(Vector2(-radius + 4.0, -radius - 1.0), 1.0, Color("4a5568"))
		draw_circle(Vector2(radius - 2.0, -radius - 1.0), 1.0, Color("4a5568"))
		draw_circle(Vector2(-radius + 4.0, radius + 1.0), 1.0, Color("4a5568"))
		draw_circle(Vector2(radius - 2.0, radius + 1.0), 1.0, Color("4a5568"))

		# 2. Heavy Salvage Claws at Front
		var claw_color: Color = Color("4b5c6d") if stun_remaining <= 0.0 else Color("3a4450")
		var claw_upper: PackedVector2Array = PackedVector2Array([
			Vector2(radius * 0.4, -4.0),
			Vector2(radius + 5.0, -7.0),
			Vector2(radius + 6.5, -4.0),
			Vector2(radius * 0.7, -1.5)
		])
		var claw_lower: PackedVector2Array = PackedVector2Array([
			Vector2(radius * 0.4, 4.0),
			Vector2(radius + 5.0, 7.0),
			Vector2(radius + 6.5, 4.0),
			Vector2(radius * 0.7, 1.5)
		])
		draw_colored_polygon(claw_upper, claw_color)
		draw_colored_polygon(claw_lower, claw_color)
		draw_polyline(claw_upper, Color("718096"), 1.0, true)
		draw_polyline(claw_lower, Color("718096"), 1.0, true)

		# 3. Main Dark Steel Hull (Facet octagon/diamond)
		var shape: PackedVector2Array = PackedVector2Array([
			Vector2(radius + 1.0, 0.0),
			Vector2(radius * 0.5, radius * 0.9),
			Vector2(-radius * 0.6, radius * 0.8),
			Vector2(-radius, 0.0),
			Vector2(-radius * 0.6, -radius * 0.8),
			Vector2(radius * 0.5, -radius * 0.9)
		])
		var body_color: Color = Color("374151") if stun_remaining > 0.0 else Color("1f2937")
		var border_color: Color = Color("9ca3af") if stun_remaining > 0.0 else Color("4b5563")
		draw_colored_polygon(shape, body_color)
		draw_polyline(PackedVector2Array([shape[0], shape[1], shape[2], shape[3], shape[4], shape[5], shape[0]]), border_color, 1.5, true)

		# 4. Glowing Red Cyclops Sensor Eye
		var eye_center: Vector2 = Vector2(2.5, 0.0)
		draw_circle(eye_center, 4.5, Color("0f141c")) # Eye housing
		if stun_remaining > 0.0:
			# Glitched flickering yellow eye
			draw_circle(eye_center, 3.2, Color("eab308"))
			draw_circle(eye_center, 1.5, Color.WHITE)
			# Electric arc sparks
			draw_line(eye_center, eye_center + Vector2(-6.0, -5.0), Color("38bdf8"), 1.2)
			draw_line(eye_center, eye_center + Vector2(-4.0, 6.0), Color("facc15"), 1.2)
		else:
			# Menacing Crimson Neon Eye with ambient glow
			draw_circle(eye_center, 6.0, Color(1.0, 0.1, 0.25, 0.25))
			draw_circle(eye_center, 3.2, Color("ef4444"))
			draw_circle(eye_center + Vector2(-0.8, -0.8), 1.2, Color("fca5a5"))
	else:
		# SPRINTER (Razor Dart Interceptor Droid)
		var tip: Vector2 = Vector2(radius + 4.0, 0.0)
		var wing_top: Vector2 = Vector2(-radius, radius + 2.0)
		var wing_bottom: Vector2 = Vector2(-radius, -radius - 2.0)
		var engine_notch: Vector2 = Vector2(-radius + 4.5, 0.0)
		var shape: PackedVector2Array = PackedVector2Array([tip, wing_top, engine_notch, wing_bottom])

		# 1. Jet Thruster Exhaust Flame
		var thruster_pos: Vector2 = engine_notch
		if sprinter_phase == SprinterPhase.DASH and stun_remaining <= 0.0:
			var jet_flare: Vector2 = thruster_pos + Vector2(-10.0, 0.0)
			draw_colored_polygon(PackedVector2Array([
				thruster_pos + Vector2(0.0, 3.5),
				thruster_pos + Vector2(0.0, -3.5),
				jet_flare
			]), Color("f97316"))
			draw_circle(thruster_pos, 2.5, Color("fde047"))
		elif sprinter_phase == SprinterPhase.TELEGRAPH and stun_remaining <= 0.0:
			draw_circle(thruster_pos, 2.5, Color("ef4444"))
		else:
			draw_circle(thruster_pos, 1.5, Color("ea580c") * Color(1, 1, 1, 0.7))

		# 2. Stealth Titan Dart Body
		var body_color: Color = Color("374151") if stun_remaining > 0.0 else Color("1e293b")
		var edge_color: Color = Color("64748b") if stun_remaining > 0.0 else Color("f97316")
		draw_colored_polygon(shape, body_color)
		draw_polyline(PackedVector2Array([shape[0], shape[1], shape[2], shape[3], shape[0]]), edge_color, 1.5, true)

		# 3. Neon Heat Sink Vents on Wings
		var vent_color: Color = Color("64748b") if stun_remaining > 0.0 else Color("fb923c")
		draw_line(Vector2(0.0, -3.0), Vector2(-radius + 3.0, -radius + 1.0), vent_color, 1.2)
		draw_line(Vector2(0.0, 3.0), Vector2(-radius + 3.0, radius - 1.0), vent_color, 1.2)

		# 4. Forward Targeting Optic
		var optic_pos: Vector2 = Vector2(radius - 1.0, 0.0)
		if stun_remaining > 0.0:
			draw_circle(optic_pos, 2.0, Color("94a3b8"))
		else:
			draw_circle(optic_pos, 3.5, Color(1.0, 0.3, 0.1, 0.35))
			draw_circle(optic_pos, 2.0, Color("ff3b00"))

		# 5. Precise Laser Telegraph Boundary (R03 Clamped)
		if sprinter_phase == SprinterPhase.TELEGRAPH and stun_remaining <= 0.0:
			var max_dist: float = 1200.0
			var start_world: Vector2 = position + locked_direction * (radius + 4.0)
			if locked_direction.x > 0.001:
				max_dist = minf(max_dist, (Config.PLAYFIELD.end.x - start_world.x) / locked_direction.x)
			elif locked_direction.x < -0.001:
				max_dist = minf(max_dist, (Config.PLAYFIELD.position.x - start_world.x) / locked_direction.x)
			if locked_direction.y > 0.001:
				max_dist = minf(max_dist, (Config.PLAYFIELD.end.y - start_world.y) / locked_direction.y)
			elif locked_direction.y < -0.001:
				max_dist = minf(max_dist, (Config.PLAYFIELD.position.y - start_world.y) / locked_direction.y)
			max_dist = maxf(0.0, max_dist)
			var start_point: Vector2 = Vector2(radius + 4.0, 0.0)
			var end_point: Vector2 = Vector2(radius + 4.0 + max_dist, 0.0)
			# Wide warning beam
			draw_line(start_point, end_point, Color(1.0, 0.25, 0.2, 0.5), 2.5)
			# Intense core beam
			draw_line(start_point, end_point, Color(1.0, 0.9, 0.7, 0.8), 1.0)

