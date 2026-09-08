## player.gd — Stone Knight M0 + F014
## Di chuyển 8 hướng + Arcane Pulse + Dash + HP/damage.
## Placeholder: cyan square 12×12 px.
extends Node2D

signal pulse_fired(position: Vector2, radius: float)
signal player_hit(hp_remaining: int)
signal player_died
signal dash_started  # F016: audio feedback

# ─── State ───────────────────────────────────────────────
var hp: int = Config.PLAYER_MAX_HP
var max_hp: int = Config.PLAYER_MAX_HP
var pulse_cooldown_left: float = 0.0
var grace_timer: float = 0.0  # Bất tử sau nhận damage

# ─── F014: Dash State ─────────────────────────────────────
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_left: float = 0.0
var dash_direction: Vector2 = Vector2.RIGHT
var last_facing_dir: Vector2 = Vector2.RIGHT
var ghost_timer: float = 0.0
var ghost_trail: Array = []

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
	is_dashing = false
	dash_timer = 0.0
	dash_cooldown_left = 0.0
	dash_direction = Vector2.RIGHT
	last_facing_dir = Vector2.RIGHT
	ghost_timer = 0.0
	ghost_trail.clear()
	pulse_vfx_timer = 0.0


func _process(delta: float) -> void:
	if is_dashing:
		_handle_dash(delta)
	else:
		_handle_movement(delta)

	_handle_pulse_cooldown(delta)
	_handle_dash_cooldown(delta)
	_handle_grace_period(delta)
	_handle_ghost_trail(delta)
	_handle_pulse_vfx(delta)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pulse") and _can_pulse():
		_fire_pulse()

	if event.is_action_pressed("dash") and _can_dash():
		_start_dash(event)


# ═══════════════════════════════════════════════════════════
# MOVEMENT
# ═══════════════════════════════════════════════════════════

func _handle_movement(delta: float) -> void:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")

	if input_dir.length_squared() > 0.01:
		input_dir = input_dir.normalized()
		last_facing_dir = input_dir

	var velocity := input_dir * Config.PLAYER_SPEED
	position += velocity * delta
	_clamp_to_arena()


func _clamp_to_arena() -> void:
	position.x = clampf(position.x, Config.ARENA_ORIGIN.x + Config.PLAYER_HALF,
						Config.ARENA_END.x - Config.PLAYER_HALF)
	position.y = clampf(position.y, Config.ARENA_ORIGIN.y + Config.PLAYER_HALF,
						Config.ARENA_END.y - Config.PLAYER_HALF)


# ═══════════════════════════════════════════════════════════
# F014: DASH
# ═══════════════════════════════════════════════════════════

func _can_dash() -> bool:
	return dash_cooldown_left <= 0.0 and not is_dashing and hp > 0


func _start_dash(event: InputEvent) -> void:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")

	if input_dir.length_squared() > 0.01:
		dash_direction = input_dir.normalized()
	else:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			var mouse_offset := get_global_mouse_position() - global_position
			if mouse_offset.length_squared() > 16.0:
				dash_direction = mouse_offset.normalized()
			else:
				dash_direction = last_facing_dir
		else:
			dash_direction = last_facing_dir

	is_dashing = true
	dash_timer = Config.DASH_DURATION
	dash_cooldown_left = Config.DASH_COOLDOWN
	ghost_timer = Config.DASH_GHOST_INTERVAL
	ghost_trail.append({"world_pos": global_position, "alpha": 0.6})
	dash_started.emit()  # F016: SFX feedback


func _handle_dash(delta: float) -> void:
	if not is_dashing:
		return

	dash_timer -= delta
	position += dash_direction * Config.DASH_SPEED * delta

	# Kiểm tra bị biên chặn theo hướng lướt:
	# Đang sát tường nhưng lướt song song hoặc ra xa tường không tự động hủy Dash
	var min_x := Config.ARENA_ORIGIN.x + Config.PLAYER_HALF
	var max_x := Config.ARENA_END.x - Config.PLAYER_HALF
	var min_y := Config.ARENA_ORIGIN.y + Config.PLAYER_HALF
	var max_y := Config.ARENA_END.y - Config.PLAYER_HALF

	var blocked := false
	if dash_direction.x < 0 and position.x <= min_x:
		position.x = min_x
		blocked = true
	elif dash_direction.x > 0 and position.x >= max_x:
		position.x = max_x
		blocked = true

	if dash_direction.y < 0 and position.y <= min_y:
		position.y = min_y
		blocked = true
	elif dash_direction.y > 0 and position.y >= max_y:
		position.y = max_y
		blocked = true

	_clamp_to_arena()

	# Sinh vệt bóng mờ định kỳ
	ghost_timer -= delta
	if ghost_timer <= 0.0:
		ghost_timer = Config.DASH_GHOST_INTERVAL
		if ghost_trail.size() < 5:
			ghost_trail.append({"world_pos": global_position, "alpha": 0.6})

	# Hết thời gian hoặc bị biên chặn theo hướng lướt -> kết thúc Dash sớm
	if blocked or dash_timer <= 0.0:
		is_dashing = false
		dash_timer = 0.0


func _handle_dash_cooldown(delta: float) -> void:
	if dash_cooldown_left > 0.0:
		dash_cooldown_left = maxf(dash_cooldown_left - delta, 0.0)


func _handle_ghost_trail(delta: float) -> void:
	var i := ghost_trail.size() - 1
	while i >= 0:
		ghost_trail[i]["alpha"] -= delta / Config.DASH_GHOST_LIFETIME
		if ghost_trail[i]["alpha"] <= 0.0:
			ghost_trail.remove_at(i)
		i -= 1


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
# DAMAGE & INVULNERABILITY
# ═══════════════════════════════════════════════════════════

func is_damage_immune() -> bool:
	return grace_timer > 0.0 or is_dashing


func take_damage(amount: int) -> void:
	if is_damage_immune():
		return

	hp -= amount
	grace_timer = Config.PLAYER_GRACE_PERIOD
	player_hit.emit(hp)

	if hp <= 0:
		player_died.emit()


func _handle_grace_period(delta: float) -> void:
	if grace_timer > 0.0:
		grace_timer = maxf(grace_timer - delta, 0.0)


# ═══════════════════════════════════════════════════════════
# PULSE VFX (Expanding ring)
# ═══════════════════════════════════════════════════════════

func _handle_pulse_vfx(delta: float) -> void:
	if pulse_vfx_timer > 0.0:
		pulse_vfx_timer -= delta
		var progress := 1.0 - (pulse_vfx_timer / Config.PULSE_VFX_DURATION)
		pulse_vfx_radius = Config.PULSE_RADIUS * progress


# ═══════════════════════════════════════════════════════════
# DRAW (Visuals)
# ═══════════════════════════════════════════════════════════

func _draw() -> void:
	# F014: Ghost trail sau lưng (chuyển world_pos sang local space)
	for ghost in ghost_trail:
		var local_pos: Vector2 = to_local(ghost["world_pos"])
		var ghost_rect := Rect2(local_pos - Vector2(Config.PLAYER_HALF, Config.PLAYER_HALF),
								Vector2(Config.PLAYER_SIZE, Config.PLAYER_SIZE))
		var ghost_color := Color(Config.COLOR_PLAYER.r, Config.COLOR_PLAYER.g,
								Config.COLOR_PLAYER.b, ghost["alpha"] * 0.45)
		draw_rect(ghost_rect, ghost_color)

	# Player body — cyan square
	var color := Config.COLOR_PLAYER
	if is_dashing:
		# Sáng nổi bật khi lướt
		color = Color(0.6, 1.0, 1.0)
	elif grace_timer > 0.0:
		# Flash effect sau khi dính hit
		if fmod(grace_timer, 0.2) < 0.1:
			color = Config.COLOR_PLAYER_HIT
		else:
			color.a = 0.5

	var rect := Rect2(-Config.PLAYER_HALF, -Config.PLAYER_HALF,
					  Config.PLAYER_SIZE, Config.PLAYER_SIZE)
	draw_rect(rect, color)

	# Viền trắng khi lướt
	if is_dashing:
		draw_rect(rect, Color.WHITE, false, 1.0)

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
