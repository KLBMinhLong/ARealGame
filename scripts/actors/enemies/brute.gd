## brute.gd — Stone Knight F011
## Brute — to, chậm, 2 HP, nặng. Hình vuông đỏ thẫm.
extends EnemyBase


func _ready() -> void:
	max_hp = Config.BRUTE_HP
	speed = Config.BRUTE_SPEED
	push_weight = Config.BRUTE_PUSH_WEIGHT
	shard_drop = Config.BRUTE_SHARD_DROP
	enemy_size = Config.BRUTE_SIZE
	enemy_color = Config.COLOR_BRUTE
	super._ready()


func _draw() -> void:
	var half := enemy_size / 2.0
	var rect := Rect2(-half, -half, enemy_size, enemy_size)

	match enemy_state:
		EnemyState.DYING:
			# Flash trắng → lerp về đỏ → fade (F006 style)
			var progress := dying_timer / Config.DYING_DURATION
			var alpha := 1.0 - progress
			var color := Color(
				lerpf(1.0, Config.COLOR_BRUTE.r, minf(progress * 3.0, 1.0)),
				lerpf(1.0, Config.COLOR_BRUTE.g, minf(progress * 3.0, 1.0)),
				lerpf(1.0, Config.COLOR_BRUTE.b, minf(progress * 3.0, 1.0)),
				alpha,
			)
			draw_rect(rect, color)
			return

		EnemyState.SEALING:
			var progress := sealing_timer / Config.ALTAR_SEAL_DURATION
			var alpha := 1.0 - progress
			var color := Color(
				lerpf(Config.COLOR_BRUTE.r, Config.COLOR_ALTAR.r, progress),
				lerpf(Config.COLOR_BRUTE.g, Config.COLOR_ALTAR.g, progress),
				lerpf(Config.COLOR_BRUTE.b, Config.COLOR_ALTAR.b, progress),
				alpha,
			)
			draw_rect(rect, color)
			return

		EnemyState.PUSHED:
			var base_color := Config.COLOR_BRUTE_PUSHED if hp > 1 else Config.COLOR_BRUTE_DAMAGED
			draw_rect(rect, base_color)
			# Viền ngoài
			draw_rect(rect, Color.WHITE, false, 1.0)

		EnemyState.NORMAL:
			if hp >= 2:
				# Khối giáp đỏ đầy đủ + lõi tối bên trong
				draw_rect(rect, Config.COLOR_BRUTE)
				var inner := Rect2(-half + 2, -half + 2, enemy_size - 4, enemy_size - 4)
				draw_rect(inner, Color(0.5, 0.08, 0.12))
			else:
				# 1 HP: Sắc đỏ nhạt hơn + viền cảnh báo
				draw_rect(rect, Config.COLOR_BRUTE_DAMAGED)

	# Nếu còn 1 HP, vẽ thêm vết nứt (crack lines) ở cả NORMAL lẫn PUSHED
	if hp == 1:
		draw_line(Vector2(-half + 2, -half + 3), Vector2(1, 0), Color.WHITE, 1.2)
		draw_line(Vector2(1, 0), Vector2(half - 2, half - 3), Color.WHITE, 1.2)
		draw_line(Vector2(1, 0), Vector2(half - 3, -half + 2), Color(0.3, 0.05, 0.05), 1.0)
