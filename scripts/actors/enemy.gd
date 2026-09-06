extends Node2D

signal telegraph_started
signal dash_started

const Config = preload("res://scripts/core/game_config.gd")

enum Type { CHASER, SPRINTER }
enum SprinterPhase { STALK, TELEGRAPH, DASH, REST }

var enemy_type: Type = Type.CHASER
var speed: float = Config.ENEMY_SPEED_START
var stun_remaining: float = 0.0

var sprinter_phase: SprinterPhase = SprinterPhase.STALK
var phase_timer: float = 0.0
var locked_direction: Vector2 = Vector2.RIGHT

func configure(spawn_position: Vector2, move_speed: float, type: Type = Type.CHASER) -> void:
	position = spawn_position
	speed = move_speed
	enemy_type = type
	stun_remaining = 0.0
	if enemy_type == Type.SPRINTER:
		sprinter_phase = SprinterPhase.STALK
		phase_timer = Config.SPRINTER_STALK_SECONDS
	queue_redraw()

func push_back(from_position: Vector2, distance: float, stun_duration: float) -> void:
	var diff: Vector2 = position - from_position
	var push_dir: Vector2 = diff.normalized() if diff.length_squared() > 0.001 else Vector2.UP
	position = Config.clamp_inside(position + push_dir * distance, Config.ENEMY_RADIUS)
	stun_remaining = maxf(stun_remaining, stun_duration)
	if enemy_type == Type.SPRINTER:
		if sprinter_phase == SprinterPhase.TELEGRAPH or sprinter_phase == SprinterPhase.DASH:
			sprinter_phase = SprinterPhase.REST
			phase_timer = Config.SPRINTER_REST_SECONDS
	queue_redraw()

func tick(delta: float, target_position: Vector2) -> void:
	if stun_remaining > 0.0:
		stun_remaining = maxf(0.0, stun_remaining - delta)
		if stun_remaining <= 0.0:
			queue_redraw()
		return

	if enemy_type == Type.CHASER:
		_tick_chaser(delta, target_position)
	else:
		_tick_sprinter(delta, target_position)

func _tick_chaser(delta: float, target_position: Vector2) -> void:
	var offset: Vector2 = target_position - position
	position = position.move_toward(target_position, speed * delta)
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
		var shape: PackedVector2Array = PackedVector2Array([Vector2(radius, 0.0), Vector2(0.0, radius), Vector2(-radius, 0.0), Vector2(0.0, -radius)])
		var body_color: Color = Color("e5bc99") if stun_remaining > 0.0 else Color("f19a69")
		draw_colored_polygon(shape, body_color)
		draw_polyline(PackedVector2Array([shape[0], shape[1], shape[2], shape[3], shape[0]]), Color("ffd5b7"), 1.2, true)
		draw_circle(Vector2(3.0, 0.0), 2.2, Color("542e20"))
	else:
		var tip: Vector2 = Vector2(radius + 3.0, 0.0)
		var back_top: Vector2 = Vector2(-radius, radius - 2.0)
		var back_bottom: Vector2 = Vector2(-radius, -radius + 2.0)
		var indent: Vector2 = Vector2(-radius + 4.0, 0.0)
		var shape: PackedVector2Array = PackedVector2Array([tip, back_top, indent, back_bottom])
		var body_color: Color = Color("f0a8a8") if stun_remaining > 0.0 else Color("e85050")
		draw_colored_polygon(shape, body_color)
		draw_polyline(PackedVector2Array([shape[0], shape[1], shape[2], shape[3], shape[0]]), Color("ffb0b0"), 1.4, true)
		draw_circle(Vector2(2.0, 0.0), 2.0, Color("4a1212"))

		if sprinter_phase == SprinterPhase.TELEGRAPH and stun_remaining <= 0.0:
			var ray_length: float = 1200.0
			var start_point: Vector2 = Vector2(radius + 4.0, 0.0)
			var end_point: Vector2 = Vector2(radius + 4.0 + ray_length, 0.0)
			draw_line(start_point, end_point, Color(1.0, 0.32, 0.25, 0.55), 2.0)
			draw_line(start_point, end_point, Color(1.0, 0.85, 0.70, 0.30), 1.0)
