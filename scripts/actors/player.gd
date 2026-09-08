## player.gd — Stone Knight M0
## Di chuyển 8 hướng + Arcane Pulse + HP/damage.
## Placeholder: cyan square 12×12 px.
extends Node2D

signal pulse_fired(position: Vector2, radius: float)
signal player_hit(hp_remaining: int)
signal player_died

# ─── State ───────────────────────────────────────────────
var hp: int = Config.PLAYER_MAX_HP
var max_hp: int = Config.PLAYER_MAX_HP
var pulse_cooldown_left: float = 0.0
var grace_timer: float = 0.0  # Bất tử sau nhận damage
var is_invulnerable: bool = false

# ─── Pulse VFX ───────────────────────────────────────────
var pulse_vfx_timer: float = 0.0
var pulse_vfx_radius: float = 0.0


func _ready() -> void:
	reset()


func reset() -> void:
	hp = Config.PLAYER_MAX_HP
	max_hp = Config.PLAYER_MAX_HP
	position = Config.PLAYER_START
	pulse_cooldown_left = 0.0
	grace_timer = 0.0
	is_invulnerable = false
	pulse_vfx_timer = 0.0


func _process(delta: float) -> void:
	_handle_movement(delta)
	_handle_pulse_cooldown(delta)
	_handle_grace_period(delta)
	_handle_pulse_vfx(delta)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pulse") and _can_pulse():
		_fire_pulse()


# ═══════════════════════════════════════════════════════════
# MOVEMENT
# ═══════════════════════════════════════════════════════════

func _handle_movement(delta: float) -> void:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()

	var velocity := input_dir * Config.PLAYER_SPEED
	position += velocity * delta

	# Clamp inside playable area
	position.x = clampf(position.x, Config.ARENA_ORIGIN.x + Config.PLAYER_HALF,
						Config.ARENA_END.x - Config.PLAYER_HALF)
	position.y = clampf(position.y, Config.ARENA_ORIGIN.y + Config.PLAYER_HALF,
						Config.ARENA_END.y - Config.PLAYER_HALF)


# ═══════════════════════════════════════════════════════════
# ARCANE PULSE
# ═══════════════════════════════════════════════════════════

func _can_pulse() -> bool:
	return pulse_cooldown_left <= 0.0


func _fire_pulse() -> void:
	pulse_cooldown_left = Config.PULSE_COOLDOWN
	pulse_vfx_timer = Config.PULSE_VFX_DURATION
	pulse_vfx_radius = 0.0
	pulse_fired.emit(position, Config.PULSE_RADIUS)


func _handle_pulse_cooldown(delta: float) -> void:
	if pulse_cooldown_left > 0.0:
		pulse_cooldown_left = maxf(pulse_cooldown_left - delta, 0.0)


# ═══════════════════════════════════════════════════════════
# DAMAGE
# ═══════════════════════════════════════════════════════════

func take_damage(amount: int) -> void:
	if is_invulnerable:
		return

	hp -= amount
	is_invulnerable = true
	grace_timer = Config.PLAYER_GRACE_PERIOD
	player_hit.emit(hp)

	if hp <= 0:
		player_died.emit()


func _handle_grace_period(delta: float) -> void:
	if is_invulnerable:
		grace_timer -= delta
		if grace_timer <= 0.0:
			is_invulnerable = false
			grace_timer = 0.0


# ═══════════════════════════════════════════════════════════
# PULSE VFX (Expanding ring)
# ═══════════════════════════════════════════════════════════

func _handle_pulse_vfx(delta: float) -> void:
	if pulse_vfx_timer > 0.0:
		pulse_vfx_timer -= delta
		var progress := 1.0 - (pulse_vfx_timer / Config.PULSE_VFX_DURATION)
		pulse_vfx_radius = Config.PULSE_RADIUS * progress


# ═══════════════════════════════════════════════════════════
# DRAW (Placeholder visuals)
# ═══════════════════════════════════════════════════════════

func _draw() -> void:
	# Player body — cyan square
	var color := Config.COLOR_PLAYER
	if is_invulnerable:
		# Flash effect: toggle visibility every 0.1s
		if fmod(grace_timer, 0.2) < 0.1:
			color = Config.COLOR_PLAYER_HIT
		else:
			color.a = 0.5

	var rect := Rect2(-Config.PLAYER_HALF, -Config.PLAYER_HALF,
					  Config.PLAYER_SIZE, Config.PLAYER_SIZE)
	draw_rect(rect, color)

	# F008: Pulse ready indicator — glow ring khi CD=0
	if pulse_cooldown_left <= 0.0:
		var t := Time.get_ticks_msec() / 1000.0
		var glow_alpha := lerpf(0.15, 0.4, (sin(t * 4.0) + 1.0) / 2.0)
		var glow_color := Color(Config.COLOR_PLAYER.r, Config.COLOR_PLAYER.g,
								Config.COLOR_PLAYER.b, glow_alpha)
		draw_arc(Vector2.ZERO, Config.PLAYER_HALF + 3.0, 0, TAU, 24, glow_color, 1.5)

	# Pulse VFX — expanding shockwave (F005: multi-layer)
	if pulse_vfx_timer > 0.0:
		var progress := 1.0 - (pulse_vfx_timer / Config.PULSE_VFX_DURATION)
		var alpha := pulse_vfx_timer / Config.PULSE_VFX_DURATION
		var base_color := Config.COLOR_PULSE_RING

		# Layer 1: Inner glow fill — circle mờ co lại
		var fill_alpha := alpha * 0.12
		var fill_color := Color(base_color.r, base_color.g, base_color.b, fill_alpha)
		draw_circle(Vector2.ZERO, pulse_vfx_radius, fill_color)

		# Layer 2: Main ring — dày lúc đầu, mỏng khi expand
		var ring_width := lerpf(3.5, 1.0, progress)
		var ring_alpha := alpha * base_color.a
		var ring_color := Color(base_color.r, base_color.g, base_color.b, ring_alpha)
		draw_arc(Vector2.ZERO, pulse_vfx_radius, 0, TAU, 48, ring_color, ring_width)

		# Layer 3: Outer halo — ring mờ bên ngoài
		var halo_radius := pulse_vfx_radius + 4.0
		var halo_alpha := alpha * 0.25
		var halo_color := Color(base_color.r, base_color.g, base_color.b, halo_alpha)
		draw_arc(Vector2.ZERO, halo_radius, 0, TAU, 48, halo_color, 1.0)
