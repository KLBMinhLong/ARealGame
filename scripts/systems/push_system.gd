## push_system.gd — Stone Knight M0
## Xử lý Arcane Pulse: tìm enemy trong radius, apply push velocity.
## Xử lý domino: enemy PUSHED va enemy khác → truyền lực.
## Xử lý chain counting.
extends Node

signal chain_updated(chain_count: int)
# Unused legacy signals (handled via enemy_base.gd):
# signal wall_slam_occurred(at_position: Vector2)
# signal altar_seal_occurred(at_position: Vector2)
signal pulse_hit(enemy_count: int)  # F002: khi pulse trúng quái
signal chain_hit_visual(at_position: Vector2, chain_count: int)  # F003: combo popup

# ─── References ──────────────────────────────────────────
var enemies_container: Node2D
var player: Node2D

# ─── Chain tracking ──────────────────────────────────────
var chain_count: int = 0
var chain_timer: float = 0.0
var chain_active: bool = false
var _domino_pairs: Dictionary = {}  # Chống domino lặp giữa cùng cặp enemy


func setup(p_player: Node2D, p_enemies: Node2D) -> void:
	player = p_player
	enemies_container = p_enemies
	
	# Connect to player pulse signal
	if player.has_signal("pulse_fired"):
		player.pulse_fired.connect(_on_pulse_fired)


func _process(delta: float) -> void:
	if chain_active:
		chain_timer -= delta
		if chain_timer <= 0.0:
			_end_chain()
	
	# Check domino collisions between pushed enemies and others
	_check_domino_collisions()


# ═══════════════════════════════════════════════════════════
# PULSE — Khi player nhấn Space
# ═══════════════════════════════════════════════════════════

func _on_pulse_fired(pulse_position: Vector2, radius: float, force: float = Config.PULSE_VELOCITY) -> void:
	var enemies := _get_enemies_in_radius(pulse_position, radius)
	
	if enemies.size() == 0:
		return
	
	# Start chain tracking
	_start_chain()
	_domino_pairs.clear()  # Reset pairs cho đợt push mới
	
	for enemy: EnemyBase in enemies:
		var direction := (enemy.position - pulse_position).normalized()
		var distance := enemy.position.distance_to(pulse_position)
		
		# Distance falloff: gần = 100%, rìa = 50%
		var falloff := lerpf(1.0, Config.PULSE_DISTANCE_FALLOFF, distance / radius)
		var push_speed := force * falloff
		
		var push_vel := direction * push_speed
		enemy.receive_push(push_vel)

	pulse_hit.emit(enemies.size())  # F002: hit-stop trigger


func _get_enemies_in_radius(center: Vector2, radius: float) -> Array:
	var result: Array = []
	for child in enemies_container.get_children():
		if child is EnemyBase and child.enemy_state != EnemyBase.EnemyState.DYING:
			if child.position.distance_to(center) <= radius:
				result.append(child)
	return result


# ═══════════════════════════════════════════════════════════
# DOMINO — Enemy PUSHED va enemy khác
# ═══════════════════════════════════════════════════════════

func _check_domino_collisions() -> void:
	var enemies: Array = []
	for child in enemies_container.get_children():
		if child is EnemyBase:
			# Quái đang DYING không tham gia domino nữa
			if child.enemy_state != EnemyBase.EnemyState.DYING and child.enemy_state != EnemyBase.EnemyState.SEALING:
				enemies.append(child)
	
	for i in range(enemies.size()):
		var a: EnemyBase = enemies[i]
		if not a.is_pushed():
			continue
		if a.velocity.length() < Config.PUSHED_VELOCITY_THRESHOLD:
			continue
		
		for j in range(i + 1, enemies.size()):
			var b: EnemyBase = enemies[j]
			if a == b:
				continue
			
			var dist := a.position.distance_to(b.position)
			var min_dist := (a.enemy_size + b.enemy_size) / 2.0
			
			if dist < min_dist:
				_resolve_domino(a, b)


func _resolve_domino(a: EnemyBase, b: EnemyBase) -> void:
	if chain_count >= Config.CHAIN_MAX_DEPTH:
		return

	# Chống domino lặp: cùng cặp chỉ va 1 lần per push episode
	var pair_key := _make_pair_key(a, b)
	if _domino_pairs.has(pair_key):
		# Chỉ tách vị trí, không damage/chain lại
		var sep_dir := (b.position - a.position).normalized()
		var sep_overlap := (a.enemy_size + b.enemy_size) / 2.0 - a.position.distance_to(b.position)
		if sep_overlap > 0:
			b.position += sep_dir * (sep_overlap + 1)
		return
	_domino_pairs[pair_key] = true

	# Direction: A → B
	var direction := (b.position - a.position).normalized()

	# Transfer velocity
	var transfer_speed := a.velocity.length() * Config.PUSHED_FORCE_TRANSFER
	var transfer_vel := direction * transfer_speed

	# Both take domino damage
	a.take_damage(Config.DAMAGE_DOMINO)
	b.take_damage(Config.DAMAGE_DOMINO)

	# B receives push (becomes PUSHED) — chỉ khi B còn sống
	if b.enemy_state != EnemyBase.EnemyState.DYING and b.enemy_state != EnemyBase.EnemyState.SEALING:
		b.receive_push(transfer_vel)

	# Separate to avoid repeated collision
	var overlap := (a.enemy_size + b.enemy_size) / 2.0 - a.position.distance_to(b.position)
	if overlap > 0:
		b.position += direction * (overlap + 1)

	# Update chain
	_increment_chain()
	# F003: visual event tại trung điểm va chạm
	var midpoint := (a.position + b.position) / 2.0
	chain_hit_visual.emit(midpoint, chain_count)


func _make_pair_key(a: EnemyBase, b: EnemyBase) -> int:
	var id_a := a.get_instance_id()
	var id_b := b.get_instance_id()
	# Sắp xếp để (a,b) và (b,a) cùng key
	if id_a > id_b:
		var tmp := id_a
		id_a = id_b
		id_b = tmp
	return id_a * 100000 + id_b


# ═══════════════════════════════════════════════════════════
# CHAIN TRACKING
# ═══════════════════════════════════════════════════════════

func _start_chain() -> void:
	chain_count = 1
	chain_timer = Config.CHAIN_WINDOW
	chain_active = true
	chain_updated.emit(chain_count)


func _increment_chain() -> void:
	chain_count += 1
	chain_timer = Config.CHAIN_WINDOW  # Reset timer on each new chain hit
	chain_updated.emit(chain_count)


func _end_chain() -> void:
	chain_active = false
	chain_count = 0
	chain_timer = 0.0
	_domino_pairs.clear()
