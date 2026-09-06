## enemy_base.gd — Stone Knight M0
## Base class cho tất cả enemy. M0 chỉ có Slime kế thừa.
## Quản lý: state machine (NORMAL → PUSHED → DYING), HP, push physics.
class_name EnemyBase
extends Node2D

signal died(enemy_position: Vector2, shard_amount: int, is_altar_seal: bool)

enum EnemyState { NORMAL, PUSHED, DYING }

# ─── Config (override ở subclass) ────────────────────────
var max_hp: int = 1
var speed: float = 30.0
var push_weight: float = 1.0
var shard_drop: int = 1
var enemy_size: float = 10.0

# ─── State ───────────────────────────────────────────────
var hp: int = 1
var enemy_state: EnemyState = EnemyState.NORMAL
var velocity: Vector2 = Vector2.ZERO
var pushed_timer: float = 0.0
var dying_timer: float = 0.0

# ─── References ──────────────────────────────────────────
var target: Node2D = null  # Player reference


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
	velocity = push_velocity / push_weight
	enemy_state = EnemyState.PUSHED
	pushed_timer = 0.0


# ═══════════════════════════════════════════════════════════
# DAMAGE
# ═══════════════════════════════════════════════════════════

func take_damage(amount: int, is_altar: bool = false) -> void:
	if enemy_state == EnemyState.DYING:
		return  # Already dying
	
	hp -= amount
	
	if hp <= 0:
		_die(is_altar)


func _die(is_altar_seal: bool = false) -> void:
	enemy_state = EnemyState.DYING
	dying_timer = 0.0
	died.emit(position, shard_drop if not is_altar_seal else Config.SHARD_ALTAR_BONUS, is_altar_seal)


# ═══════════════════════════════════════════════════════════
# COLLISION CHECKS (khi PUSHED)
# ═══════════════════════════════════════════════════════════

func _check_wall_collision() -> void:
	var half := enemy_size / 2.0
	var hit_wall := false
	
	if position.x - half <= Config.ARENA_ORIGIN.x:
		position.x = Config.ARENA_ORIGIN.x + half
		velocity.x = 0
		hit_wall = true
	elif position.x + half >= Config.ARENA_END.x:
		position.x = Config.ARENA_END.x - half
		velocity.x = 0
		hit_wall = true
	
	if position.y - half <= Config.ARENA_ORIGIN.y:
		position.y = Config.ARENA_ORIGIN.y + half
		velocity.y = 0
		hit_wall = true
	elif position.y + half >= Config.ARENA_END.y:
		position.y = Config.ARENA_END.y - half
		velocity.y = 0
		hit_wall = true
	
	if hit_wall:
		take_damage(Config.DAMAGE_WALL_SLAM)
		# Signal for VFX/SFX (wall dust, screen shake) sẽ thêm sau


func _check_altar_collision() -> void:
	var altar_pos := Config.ALTAR_POSITION
	var altar_half := Config.ALTAR_SIZE / 2.0
	var my_half := enemy_size / 2.0
	
	if abs(position.x - altar_pos.x) < (altar_half + my_half) and \
	   abs(position.y - altar_pos.y) < (altar_half + my_half):
		take_damage(Config.DAMAGE_ALTAR_SEAL, true)


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
