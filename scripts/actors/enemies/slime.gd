## slime.gd — Stone Knight M0
## Cursed Ooze — enemy duy nhất trong M0.
## Chậm, đi thẳng về player, 1 HP, light push weight.
extends EnemyBase


func _ready() -> void:
	max_hp = Config.SLIME_HP
	speed = Config.SLIME_SPEED
	push_weight = Config.SLIME_PUSH_WEIGHT
	shard_drop = Config.SLIME_SHARD_DROP
	enemy_size = Config.SLIME_SIZE
	enemy_color = Config.COLOR_SLIME  # F009: for death VFX
	super._ready()


func _draw() -> void:
	var half := enemy_size / 2.0
	var color: Color
	
	match enemy_state:
		EnemyState.NORMAL:
			color = Config.COLOR_SLIME
		EnemyState.PUSHED:
			color = Config.COLOR_SLIME_PUSHED
		EnemyState.DYING:
			# F006: Flash trắng → lerp về xanh → fade
			var progress := dying_timer / Config.DYING_DURATION  # 0→1
			var alpha := 1.0 - progress
			var flash := lerpf(1.0, 0.0, minf(progress * 4.0, 1.0))  # Trắng → xanh nhanh
			color = Color(
				lerpf(1.0, Config.COLOR_SLIME.r, minf(progress * 3.0, 1.0)),
				lerpf(1.0, Config.COLOR_SLIME.g, minf(progress * 3.0, 1.0)),
				lerpf(1.0, Config.COLOR_SLIME.b, minf(progress * 3.0, 1.0)),
				alpha,
			)
		EnemyState.SEALING:
			# F015: Hòa vào tím hư không, mờ dần
			var progress := sealing_timer / Config.ALTAR_SEAL_DURATION
			var alpha := 1.0 - progress
			color = Color(
				lerpf(Config.COLOR_SLIME.r, Config.COLOR_ALTAR.r, progress),
				lerpf(Config.COLOR_SLIME.g, Config.COLOR_ALTAR.g, progress),
				lerpf(Config.COLOR_SLIME.b, Config.COLOR_ALTAR.b, progress),
				alpha,
			)
	
	# Draw circle (slime = blob)
	draw_circle(Vector2.ZERO, half, color)
