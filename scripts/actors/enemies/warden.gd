## warden.gd — Stone Knight F020
## Dungeon Warden — Mini-Boss của Wave 5.
## HP: 10, Kích thước: 24px, Nặng: 1.6, Tốc độ: 45px/s.
## Sở hữu đòn AoE Ground Slam (bán kính 80px) có thể bị Pulse ngắt chiêu (interrupt).
## Miễn nhiễm Altar Seal tức tử (chỉ nhận 1 damage khi đập vào Altar).
extends EnemyBase

signal slam_triggered(slam_position: Vector2, slam_radius: float)

enum WardenAction { CHASE, TELEGRAPH, RECOVERY }

var action_state: WardenAction = WardenAction.CHASE
var slam_timer: float = 3.0  # Lần slam đầu tiên sau 3.0s spawn
var telegraph_timer: float = 0.0
var recovery_timer: float = 0.0
var is_enraged: bool = false


func _ready() -> void:
	max_hp = Config.WARDEN_HP
	hp = Config.WARDEN_HP
	speed = Config.WARDEN_SPEED
	push_weight = Config.WARDEN_PUSH_WEIGHT
	shard_drop = Config.WARDEN_SHARD_DROP
	enemy_size = Config.WARDEN_SIZE
	enemy_color = Config.COLOR_WARDEN
	super._ready()


func set_enraged(enraged: bool) -> void:
	is_enraged = enraged
	if is_enraged:
		speed = Config.WARDEN_SPEED * Config.WARDEN_ENRAGE_SPEED_MULT


func _process(delta: float) -> void:
	# Cập nhật redraw cho hiệu ứng vòng cảnh báo đang mở rộng
	if action_state == WardenAction.TELEGRAPH:
		queue_redraw()
	super._process(delta)


func _process_normal(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return

	match action_state:
		WardenAction.CHASE:
			# Di chuyển về player
			var current_speed := speed * (Config.WARDEN_ENRAGE_SPEED_MULT if is_enraged else 1.0)
			var direction := (target.position - position).normalized()
			position += direction * current_speed * delta
			_clamp_to_arena()

			# Sát thương va chạm thông thường khi chạm thân
			if target.position.distance_to(position) < (enemy_size / 2.0 + Config.PLAYER_HALF):
				if target.has_method("take_damage"):
					target.take_damage(Config.PLAYER_CONTACT_DAMAGE)

			# Đếm ngược hồi chiêu AoE Slam
			slam_timer -= delta
			if slam_timer <= 0.0:
				_start_telegraph()

		WardenAction.TELEGRAPH:
			# Bất động khi đang gồng chiêu
			telegraph_timer += delta
			if telegraph_timer >= Config.WARDEN_TELEGRAPH_DURATION:
				_execute_slam()

		WardenAction.RECOVERY:
			# Khựng lại sau khi đập búa — cơ hội phản công của Player
			recovery_timer += delta
			if recovery_timer >= Config.WARDEN_RECOVERY_DURATION:
				action_state = WardenAction.CHASE
				var next_interval := Config.WARDEN_SLAM_INTERVAL_ENRAGED if is_enraged else Config.WARDEN_SLAM_INTERVAL
				slam_timer = next_interval
				queue_redraw()


func _start_telegraph() -> void:
	action_state = WardenAction.TELEGRAPH
	telegraph_timer = 0.0
	queue_redraw()


func _execute_slam() -> void:
	action_state = WardenAction.RECOVERY
	recovery_timer = 0.0
	queue_redraw()

	# Phát tín hiệu để Main tạo VFX bụi đất, âm thanh chấn động và camera shake
	slam_triggered.emit(position, Config.WARDEN_SLAM_RADIUS)

	# Kiểm tra sát thương AoE lên Player
	if target != null and is_instance_valid(target):
		var dist := target.position.distance_to(position)
		if dist <= Config.WARDEN_SLAM_RADIUS:
			if target.has_method("take_damage"):
				target.take_damage(Config.WARDEN_SLAM_DAMAGE)
			# Đẩy văng nhẹ Player ra khỏi tâm chấn
			if target is CharacterBody2D or "velocity" in target:
				var knockback_dir := (target.position - position).normalized()
				if knockback_dir == Vector2.ZERO:
					knockback_dir = Vector2.DOWN
				target.position += knockback_dir * 8.0


## Counter-Play / Interrupt: Khi bị Pulse trong lúc Telegraph, đòn slam bị hủy!
func receive_push(push_velocity: Vector2) -> void:
	if action_state == WardenAction.TELEGRAPH:
		# Bị ngắt chiêu gồng!
		action_state = WardenAction.CHASE
		slam_timer = 3.0  # Cho người chơi 3 giây hồi phục nhịp độ
		queue_redraw()
	elif action_state == WardenAction.RECOVERY:
		# Đang khựng mà bị đẩy -> tiếp tục bị đẩy bình thường
		action_state = WardenAction.CHASE
		slam_timer = 2.0
		queue_redraw()

	super.receive_push(push_velocity)


## F020: Miễn nhiễm Altar Seal tức tử — Chạm Altar chỉ nhận 1 damage và bị nảy lùi ra ngoài
func _check_altar_collision() -> void:
	if enemy_state != EnemyState.PUSHED:
		return

	var altar_pos := Config.ALTAR_POSITION
	var altar_half := Config.ALTAR_SIZE / 2.0
	var my_half := enemy_size / 2.0

	if abs(position.x - altar_pos.x) < (altar_half + my_half) and \
	   abs(position.y - altar_pos.y) < (altar_half + my_half):
		# Không seal chết ngay! Nhận 1 holy damage
		impact_processed = true
		take_damage(1, true)
		# Bật lùi ra khỏi tâm Altar
		var bounce_dir := (position - altar_pos).normalized()
		if bounce_dir == Vector2.ZERO:
			bounce_dir = Vector2.DOWN
		velocity = bounce_dir * 100.0
		wall_slammed.emit(position, false)


func _draw() -> void:
	var half := enemy_size / 2.0
	var rect := Rect2(-half, -half, enemy_size, enemy_size)

	# 1. Vẽ vòng cảnh báo AoE Slam khi ở trạng thái TELEGRAPH
	if action_state == WardenAction.TELEGRAPH and enemy_state != EnemyState.DYING:
		var progress := clampf(telegraph_timer / Config.WARDEN_TELEGRAPH_DURATION, 0.0, 1.0)
		var circle_color := Color(
			Config.COLOR_WARDEN_TELEGRAPH.r,
			Config.COLOR_WARDEN_TELEGRAPH.g,
			Config.COLOR_WARDEN_TELEGRAPH.b,
			lerpf(0.2, 0.6, progress)
		)
		# Vòng ngoài
		draw_arc(Vector2.ZERO, Config.WARDEN_SLAM_RADIUS, 0.0, TAU, 40, circle_color, 1.5)
		# Vùng mở rộng từ trong ra ngoài
		var fill_radius := Config.WARDEN_SLAM_RADIUS * progress
		var fill_color := Color(1.0, 0.1, 0.1, 0.12 * progress)
		draw_circle(Vector2.ZERO, fill_radius, fill_color)

	# 2. Vẽ thân thể theo trạng thái
	match enemy_state:
		EnemyState.DYING:
			var progress := dying_timer / Config.DYING_DURATION
			var alpha := 1.0 - progress
			var color := Color(
				lerpf(1.0, Config.COLOR_WARDEN.r, minf(progress * 2.0, 1.0)),
				lerpf(1.0, Config.COLOR_WARDEN.g, minf(progress * 2.0, 1.0)),
				lerpf(1.0, Config.COLOR_WARDEN.b, minf(progress * 2.0, 1.0)),
				alpha
			)
			draw_rect(rect, color)
			return

		EnemyState.PUSHED:
			draw_rect(rect, Config.COLOR_WARDEN_PUSHED)
			draw_rect(rect, Color.WHITE, false, 1.5)

		EnemyState.NORMAL:
			if action_state == WardenAction.RECOVERY:
				# Trạng thái khựng (xám sẫm bốc khói)
				draw_rect(rect, Config.COLOR_WARDEN_RECOVERY)
				draw_rect(rect, Color(0.3, 0.3, 0.3), false, 1.0)
			elif action_state == WardenAction.TELEGRAPH:
				# Trạng thái gồng: nhấp nháy đỏ rực
				var flash_freq := sin(telegraph_timer * 18.0) * 0.5 + 0.5
				var g_color := Config.COLOR_WARDEN.lerp(Color.WHITE, flash_freq * 0.4)
				draw_rect(rect, g_color)
				draw_rect(rect, Color.RED, false, 1.5)
			else:
				# Giáp đá đỏ thẫm
				draw_rect(rect, Config.COLOR_WARDEN)
				# Lớp giáp đá sẫm bên trong
				var inner_armor := Rect2(-half + 2, -half + 2, enemy_size - 4, enemy_size - 4)
				draw_rect(inner_armor, Config.COLOR_WARDEN_ARMOR)
				# Lõi Rune phát sáng đỏ
				var core_size := 10.0
				var core_half := core_size / 2.0
				var rune_core := Rect2(-core_half, -core_half, core_size, core_size)
				draw_rect(rune_core, Config.COLOR_WARDEN_CORE)
				draw_rect(rect, Color(0.9, 0.2, 0.2, 0.8), false, 1.0)

	# 3. Vẽ Thanh Máu Boss (Boss Health Bar) trực quan 10 vạch
	if enemy_state != EnemyState.DYING:
		_draw_boss_health_bar(half)


func _draw_boss_health_bar(half: float) -> void:
	var bar_w := 28.0
	var bar_h := 4.0
	var bar_x := -bar_w / 2.0
	var bar_y := -half - 8.0

	# Khung nền đen
	draw_rect(Rect2(bar_x - 1, bar_y - 1, bar_w + 2, bar_h + 2), Color(0.05, 0.05, 0.08, 0.9))
	draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), Color(0.2, 0.05, 0.05))

	# Máu hiện tại
	var fill_ratio := clampf(float(hp) / float(max_hp), 0.0, 1.0)
	if fill_ratio > 0:
		var fill_w := bar_w * fill_ratio
		var bar_color := Color(0.95, 0.2, 0.2) if not is_enraged else Color(1.0, 0.4, 0.0)
		draw_rect(Rect2(bar_x, bar_y, fill_w, bar_h), bar_color)

	# 10 vạch chia phân đoạn (Pips)
	for i in range(1, max_hp):
		var tick_x := bar_x + (bar_w / float(max_hp)) * float(i)
		draw_line(Vector2(tick_x, bar_y), Vector2(tick_x, bar_y + bar_h), Color(0.1, 0.1, 0.1, 0.8), 1.0)
