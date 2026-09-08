## shard.gd — Stone Knight M0
## Soul Shard — loot drop, magnet pickup.
## Placeholder: yellow dot 4×4 px.
extends Node2D

signal collected(at_position: Vector2)  # F007: thêm position

var player_ref: Node2D = null
var lifetime: float = Config.SHARD_LIFETIME
var is_magnetized: bool = false


func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	
	if player_ref == null or not is_instance_valid(player_ref):
		return
	
	var dist := position.distance_to(player_ref.position)
	
	# Magnet: lerp toward player when in range
	if dist <= Config.SHARD_MAGNET_RADIUS:
		is_magnetized = true
	
	if is_magnetized:
		var direction := (player_ref.position - position).normalized()
		position += direction * Config.SHARD_MAGNET_SPEED * delta
		
		# Pickup
		if position.distance_to(player_ref.position) < 6.0:
			collected.emit(position)  # F007: emit position
			queue_free()
	
	queue_redraw()


func _draw() -> void:
	var half := Config.SHARD_SIZE / 2.0
	var alpha := 1.0
	
	# Fade out when about to expire (last 2s)
	if lifetime < 2.0:
		alpha = lifetime / 2.0
	
	var color := Color(Config.COLOR_SHARD.r, Config.COLOR_SHARD.g, Config.COLOR_SHARD.b, alpha)
	
	# Small diamond shape
	var points := PackedVector2Array([
		Vector2(0, -half),
		Vector2(half, 0),
		Vector2(0, half),
		Vector2(-half, 0),
	])
	draw_colored_polygon(points, color)
