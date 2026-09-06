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
			# Fade out during dying
			var alpha := 1.0 - (dying_timer / Config.DYING_DURATION)
			color = Color(Config.COLOR_SLIME.r, Config.COLOR_SLIME.g, Config.COLOR_SLIME.b, alpha)
	
	# Draw circle (slime = blob)
	draw_circle(Vector2.ZERO, half, color)
