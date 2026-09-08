## speeder.gd — Stone Knight F009
## Speeder — nhanh, nhỏ, nhẹ. Hình triangle cam.
extends EnemyBase


func _ready() -> void:
	max_hp = Config.SPEEDER_HP
	speed = Config.SPEEDER_SPEED
	push_weight = Config.SPEEDER_PUSH_WEIGHT
	shard_drop = Config.SPEEDER_SHARD_DROP
	enemy_size = Config.SPEEDER_SIZE
	enemy_color = Config.COLOR_SPEEDER
	super._ready()


func _draw() -> void:
	var half := enemy_size / 2.0
	var color: Color

	match enemy_state:
		EnemyState.NORMAL:
			color = Config.COLOR_SPEEDER
		EnemyState.PUSHED:
			color = Config.COLOR_SPEEDER_PUSHED
		EnemyState.DYING:
			# Flash trắng → lerp về cam → fade (giống slime F006)
			var progress := dying_timer / Config.DYING_DURATION
			var alpha := 1.0 - progress
			color = Color(
				lerpf(1.0, Config.COLOR_SPEEDER.r, minf(progress * 3.0, 1.0)),
				lerpf(1.0, Config.COLOR_SPEEDER.g, minf(progress * 3.0, 1.0)),
				lerpf(1.0, Config.COLOR_SPEEDER.b, minf(progress * 3.0, 1.0)),
				alpha,
			)
		EnemyState.SEALING:
			var progress := sealing_timer / Config.ALTAR_SEAL_DURATION
			var alpha := 1.0 - progress
			color = Color(
				lerpf(Config.COLOR_SPEEDER.r, Config.COLOR_ALTAR.r, progress),
				lerpf(Config.COLOR_SPEEDER.g, Config.COLOR_ALTAR.g, progress),
				lerpf(Config.COLOR_SPEEDER.b, Config.COLOR_ALTAR.b, progress),
				alpha,
			)

	# Triangle shape (khác circle slime)
	var points := PackedVector2Array([
		Vector2(0, -half),       # Top
		Vector2(half, half),     # Bottom-right
		Vector2(-half, half),    # Bottom-left
	])
	draw_colored_polygon(points, color)
