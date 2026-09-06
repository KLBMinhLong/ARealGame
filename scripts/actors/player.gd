extends Node2D
## Intentional simple geometry: no physics body and no obstacle collisions.
## Main calls tick(); one owner controls pause, update order, and game state.

signal health_changed(value: int)
signal pulse_triggered

const Config = preload("res://scripts/core/game_config.gd")
const PULSE_VISUAL_DURATION: float = 0.25
var max_health: int = Config.MAX_HEALTH
var health: int = Config.MAX_HEALTH
var grace_remaining: float = 0.0
var pulse_cooldown_remaining: float = 0.0
var pulse_cooldown_max: float = Config.PULSE_COOLDOWN_SECONDS
var pulse_radius: float = Config.PULSE_RADIUS
var pulse_push_force: float = 1.0
var magnet_radius: float = 120.0
var magnet_speed: float = 280.0
var tesla_arc_level: int = 0
var aegis_shield_duration: float = 0.0

var pulse_visual_timer: float = 0.0
var facing: Vector2 = Vector2.UP
var reduced_effects: bool = false

func reset() -> void:
	position = Config.PLAYFIELD.get_center()
	health = max_health
	grace_remaining = 0.0
	pulse_cooldown_remaining = 0.0
	pulse_visual_timer = 0.0
	facing = Vector2.UP
	pulse_radius = Config.PULSE_RADIUS
	pulse_push_force = 1.0
	pulse_cooldown_max = Config.PULSE_COOLDOWN_SECONDS
	magnet_radius = 120.0
	magnet_speed = 280.0
	tesla_arc_level = 0
	aegis_shield_duration = 0.0
	health_changed.emit(health)
	queue_redraw()

func tick(delta: float) -> void:
	grace_remaining = maxf(0.0, grace_remaining - delta)
	pulse_cooldown_remaining = maxf(0.0, pulse_cooldown_remaining - delta)
	pulse_visual_timer = maxf(0.0, pulse_visual_timer - delta)
	if Input.is_action_just_pressed("pulse") and pulse_cooldown_remaining <= 0.0:
		trigger_pulse()
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_by(direction, delta)
	queue_redraw()

func trigger_pulse() -> bool:
	if pulse_cooldown_remaining > 0.0:
		return false
	pulse_cooldown_remaining = pulse_cooldown_max
	pulse_visual_timer = PULSE_VISUAL_DURATION
	if aegis_shield_duration > 0.0:
		grace_remaining = maxf(grace_remaining, aegis_shield_duration)
	pulse_triggered.emit()
	queue_redraw()
	return true

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
	var r: float = Config.PLAYER_RADIUS
	var ortho: Vector2 = facing.orthogonal()

	# 1. Rear Thruster Flare (when moving)
	var thruster_pos: Vector2 = -facing * (r - 2.0)
	var thruster_flare: Vector2 = -facing * (r + 7.0 + randf_range(-1.5, 2.0))
	draw_colored_polygon(PackedVector2Array([
		thruster_pos + ortho * 4.0,
		thruster_pos - ortho * 4.0,
		thruster_flare
	]), Color("00f0ff") * Color(1, 1, 1, 0.85))
	draw_circle(thruster_pos, 2.5, Color("38bdf8"))

	# 2. Side Stabilizer Fins / Antennas
	var fin_left: Vector2 = -facing * 4.0 - ortho * (r + 4.0)
	var fin_right: Vector2 = -facing * 4.0 + ortho * (r + 4.0)
	draw_line(Vector2.ZERO - ortho * 8.0, fin_left, Color("52708b"), 2.0)
	draw_line(Vector2.ZERO + ortho * 8.0, fin_right, Color("52708b"), 2.0)
	draw_circle(fin_left, 2.0, Color("00f0ff"))
	draw_circle(fin_right, 2.0, Color("00f0ff"))

	# 3. Main Spherical Metal Hull
	draw_circle(Vector2.ZERO, r + 2.0, Color(0.0, 0.9, 1.0, 0.15)) # Ambient glow
	draw_circle(Vector2.ZERO, r, Color("222f3e")) # Dark steel plate
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color("576574"), 1.5, true) # Rim plating seam

	# 4. Cute Chibi Visor & Cyan LED Eye
	var eye_center: Vector2 = facing * 4.5
	var eye_width: float = 6.0
	draw_circle(eye_center, eye_width, Color("0c141f")) # Dark visor background
	draw_circle(eye_center, 3.8, Color("00f0ff")) # Glowing cyan iris
	draw_circle(eye_center + Vector2(-1.0, -1.0), 1.4, Color.WHITE) # Sparkle highlight

	# 5. Invulnerability Shield (Electric Bubble)
	if grace_remaining > 0.0:
		var shield_alpha: float = clampf(grace_remaining / Config.HIT_GRACE_SECONDS, 0.2, 0.9)
		draw_arc(Vector2.ZERO, r + 9.0, 0.0, TAU, 32, Color(0.95, 0.85, 0.40, shield_alpha * 0.8), 2.0, true)
		draw_circle(Vector2.ZERO, r + 9.0, Color(1.0, 0.9, 0.4, 0.12 * shield_alpha))

	# 6. Pulse Charging Indicator Arc
	if pulse_cooldown_remaining > 0.0:
		var recharge_ratio: float = 1.0 - clampf(pulse_cooldown_remaining / pulse_cooldown_max, 0.0, 1.0)
		draw_arc(Vector2.ZERO, r + 5.0, -PI / 2.0, -PI / 2.0 + TAU * recharge_ratio, 32, Color("00f0ff") * Color(1, 1, 1, 0.6), 2.0, true)
	else:
		# Subtle ready ring
		draw_arc(Vector2.ZERO, r + 5.0, 0.0, TAU, 32, Color(0.0, 0.94, 1.0, 0.35), 1.2, true)

	# 7. Pulse Shockwave Expanding Ring
	if pulse_visual_timer > 0.0:
		var progress: float = 1.0 - (pulse_visual_timer / PULSE_VISUAL_DURATION)
		var shock_radius: float = lerpf(r, pulse_radius, progress)
		var base_alpha: float = 0.35 if reduced_effects else 0.75
		var shock_alpha: float = (1.0 - progress) * base_alpha
		draw_arc(Vector2.ZERO, shock_radius, 0.0, TAU, 48, Color("00f0ff") * Color(1, 1, 1, shock_alpha), 2.5, true)
		draw_circle(Vector2.ZERO, shock_radius * 0.9, Color(0.0, 0.94, 1.0, shock_alpha * 0.08))
