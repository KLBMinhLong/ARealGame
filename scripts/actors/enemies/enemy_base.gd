## enemy_base.gd — Stone Knight M0
## Base class cho tất cả enemy. M0 chỉ có Slime kế thừa.
## Quản lý: state machine (NORMAL → PUSHED → DYING), HP, push physics.
class_name EnemyBase
extends Node2D

signal died(enemy_position: Vector2, shard_amount: int, is_altar_seal: bool, enemy_color: Color)
signal wall_slammed(at_position: Vector2, is_spike: bool)

enum EnemyState { NORMAL, PUSHED, DYING, SEALING }

# ─── Config (override ở subclass) ────────────────────────
var max_hp: int = 1
var speed: float = 30.0
var push_weight: float = 1.0
var shard_drop: int = 1
var enemy_size: float = 10.0
var enemy_color: Color = Color.WHITE  # F009: override in subclass

# ─── State ───────────────────────────────────────────────
var hp: int = 1
var enemy_state: EnemyState = EnemyState.NORMAL
var velocity: Vector2 = Vector2.ZERO
var pushed_timer: float = 0.0
var dying_timer: float = 0.0
var sealing_timer: float = 0.0  # F015: Altar seal
var impact_processed: bool = false  # F019: Chống multi-hit per push episode

# ─── References ──────────────────────────────────────────
var target: Node2D = null  # Player reference
var arena_ref: Node2D = null  # F019: Arena reference for hazard detection


func _ready() -> void:
	hp = max_hp


func _process(delta: float) -> void:
	match enemy_state:
		EnemyState.NORMAL:
			_process_normal(delta)
		EnemyState.PUSHED:
			_process_pushed(delta)
		EnemyState.DYING:
			_process_dying(delta)
		EnemyState.SEALING:
			_process_sealing(delta)
	
	queue_redraw()


# ═══════════════════════════════════════════════════════════
# STATE: NORMAL — Di chuyển về player
# ═══════════════════════════════════════════════════════════

func _process_normal(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	
	var direction := (target.position - position).normalized()
	position += direction * speed * delta
	
	# Clamp inside arena
	_clamp_to_arena()
	
	# Check contact damage to player
	if target.position.distance_to(position) < (enemy_size / 2.0 + Config.PLAYER_HALF):
		if target.has_method("take_damage"):
			target.take_damage(Config.PLAYER_CONTACT_DAMAGE)


# ═══════════════════════════════════════════════════════════
# STATE: PUSHED — Đang bay sau bị pulse/domino
# ═══════════════════════════════════════════════════════════

func _process_pushed(delta: float) -> void:
	pushed_timer += delta
	
	# Apply deceleration
	var speed_val := velocity.length()
	if speed_val > 0:
		var decel := Config.PULSE_DECELERATION * delta
		var new_speed := maxf(speed_val - decel, 0.0)
		velocity = velocity.normalized() * new_speed
	
	# Move
	position += velocity * delta
	
	# Check collisions while pushed
	_check_wall_collision()
	_check_altar_collision()
	
	# Exit PUSHED state
	if velocity.length() < Config.PUSHED_VELOCITY_THRESHOLD or pushed_timer >= Config.PUSHED_TIMEOUT:
		if hp > 0:
			enemy_state = EnemyState.NORMAL
			velocity = Vector2.ZERO
			pushed_timer = 0.0


# ═══════════════════════════════════════════════════════════
# STATE: DYING — Xác bay tiếp 0.15s, vẫn collision
# ═══════════════════════════════════════════════════════════

func _process_dying(delta: float) -> void:
	dying_timer += delta
	
	# Xác tiếp tục bay (với deceleration)
	var speed_val := velocity.length()
	if speed_val > 0:
		var decel := Config.PULSE_DECELERATION * delta
		var new_speed := maxf(speed_val - decel, 0.0)
		velocity = velocity.normalized() * new_speed
	
	position += velocity * delta
	_clamp_to_arena()
	
	if dying_timer >= Config.DYING_DURATION:
		queue_free()


# ═══════════════════════════════════════════════════════════
# PUSH — Nhận lực đẩy từ Pulse hoặc domino
# ═══════════════════════════════════════════════════════════

func receive_push(push_velocity: Vector2) -> void:
	if enemy_state == EnemyState.SEALING:
		return
	velocity = push_velocity / push_weight
	enemy_state = EnemyState.PUSHED
	pushed_timer = 0.0
	impact_processed = false  # Reset cho đợt push mới


# ═══════════════════════════════════════════════════════════
# DAMAGE
# ═══════════════════════════════════════════════════════════

func take_damage(amount: int, is_altar: bool = false, is_spike_slam: bool = false) -> void:
	if enemy_state == EnemyState.DYING or enemy_state == EnemyState.SEALING:
		return  # Already dying or sealing
	
	hp -= amount
	
	if hp <= 0:
		_die(is_altar, is_spike_slam)


func _die(is_altar_seal: bool = false, is_spike_slam: bool = false) -> void:
	enemy_state = EnemyState.DYING
	dying_timer = 0.0
	var final_shards := shard_drop
	if is_altar_seal:
		final_shards = Config.SHARD_ALTAR_BONUS
	elif is_spike_slam:
		final_shards = shard_drop + Config.SHARD_SPIKE_BONUS
	died.emit(position, final_shards, is_altar_seal, enemy_color)


# ═══════════════════════════════════════════════════════════
# COLLISION CHECKS (khi PUSHED)
# ═══════════════════════════════════════════════════════════

func _check_wall_collision() -> void:
	# F019: Chỉ kiểm tra khi đang PUSHED và chưa xử lý va chạm cho đợt đẩy này
	if enemy_state != EnemyState.PUSHED or impact_processed:
		return

	var half := enemy_size / 2.0

	# Lấy arena reference nếu chưa có
	if arena_ref == null and get_tree() != null and get_tree().current_scene != null:
		arena_ref = get_tree().current_scene.get_node_or_null("Arena")

	# F019 Tuning: 1. Kiểm tra va chạm mặt trước gai nhọn (Front-Edge Collision)
	# Quái đâm vào gai dừng lại ngay trước gai, không bay xuyên qua gai rồi mới chết ở tường xám
	if arena_ref != null and arena_ref.has_method("check_spike_front_collision"):
		var spike_hit: Dictionary = arena_ref.check_spike_front_collision(position, half, velocity)
		if spike_hit.get("hit", false):
			impact_processed = true
			velocity = Vector2.ZERO
			position = spike_hit.get("snap_pos", position)
			var hit_pos: Vector2 = spike_hit.get("hit_pos", position)
			take_damage(Config.DAMAGE_SPIKE_SLAM, false, true)
			wall_slammed.emit(hit_pos, true)
			return

	# 2. Kiểm tra va chạm tường xám bình thường (Normal Wall)
	var hit_wall := false
	var hit_points: Array[Vector2] = []

	if velocity.x < 0 and position.x - half <= Config.ARENA_ORIGIN.x:
		position.x = Config.ARENA_ORIGIN.x + half
		velocity.x = 0
		hit_wall = true
		hit_points.append(Vector2(Config.ARENA_ORIGIN.x, position.y))
	elif velocity.x > 0 and position.x + half >= Config.ARENA_END.x:
		position.x = Config.ARENA_END.x - half
		velocity.x = 0
		hit_wall = true
		hit_points.append(Vector2(Config.ARENA_END.x, position.y))

	if velocity.y < 0 and position.y - half <= Config.ARENA_ORIGIN.y:
		position.y = Config.ARENA_ORIGIN.y + half
		velocity.y = 0
		hit_wall = true
		hit_points.append(Vector2(position.x, Config.ARENA_ORIGIN.y))
	elif velocity.y > 0 and position.y + half >= Config.ARENA_END.y:
		position.y = Config.ARENA_END.y - half
		velocity.y = 0
		hit_wall = true
		hit_points.append(Vector2(position.x, Config.ARENA_END.y))

	# 3. Single Impact Resolution cho tường thường
	if hit_wall:
		impact_processed = true
		velocity = Vector2.ZERO
		var final_hit_pos := hit_points[0] if not hit_points.is_empty() else position
		take_damage(Config.DAMAGE_WALL_SLAM, false, false)
		wall_slammed.emit(final_hit_pos, false)


# ═══════════════════════════════════════════════════════════
# STATE: SEALING — Bị hút vào tâm Altar, co nhỏ vào hư không (F015)
# ═══════════════════════════════════════════════════════════

func _process_sealing(delta: float) -> void:
	sealing_timer += delta
	var progress := clampf(sealing_timer / Config.ALTAR_SEAL_DURATION, 0.0, 1.0)

	# Hút nhanh dần về tâm Altar
	position = position.lerp(Config.ALTAR_POSITION, delta * 16.0)

	# Thu nhỏ dần về zero (scale co nhỏ)
	var s := lerpf(1.0, 0.0, progress)
	scale = Vector2(s, s)

	if sealing_timer >= Config.ALTAR_SEAL_DURATION:
		died.emit(Config.ALTAR_POSITION, Config.SHARD_ALTAR_BONUS, true, enemy_color)
		queue_free()


func _check_altar_collision() -> void:
	if enemy_state == EnemyState.SEALING or enemy_state == EnemyState.DYING:
		return

	var altar_pos := Config.ALTAR_POSITION
	var altar_half := Config.ALTAR_SIZE / 2.0
	var my_half := enemy_size / 2.0

	if abs(position.x - altar_pos.x) < (altar_half + my_half) and \
	   abs(position.y - altar_pos.y) < (altar_half + my_half):
		_start_altar_seal()


func _start_altar_seal() -> void:
	enemy_state = EnemyState.SEALING
	sealing_timer = 0.0
	velocity = Vector2.ZERO
	hp = 0


func _clamp_to_arena() -> void:
	var half := enemy_size / 2.0
	position.x = clampf(position.x, Config.ARENA_ORIGIN.x + half, Config.ARENA_END.x - half)
	position.y = clampf(position.y, Config.ARENA_ORIGIN.y + half, Config.ARENA_END.y - half)


# ═══════════════════════════════════════════════════════════
# HELPERS
# ═══════════════════════════════════════════════════════════

func is_pushed() -> bool:
	return enemy_state == EnemyState.PUSHED or enemy_state == EnemyState.DYING


func get_push_velocity() -> Vector2:
	return velocity
