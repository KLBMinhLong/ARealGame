## arena.gd — Stone Knight M0 + F015
## Vẽ arena background, walls, và altar zone.
## Tất cả placeholder — _draw() based.
extends Node2D

var altar_flash_timer: float = 0.0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if altar_flash_timer > 0.0:
		altar_flash_timer = maxf(altar_flash_timer - delta, 0.0)
		queue_redraw()


func trigger_altar_flash() -> void:
	altar_flash_timer = Config.ALTAR_FLASH_DURATION
	queue_redraw()


func _draw() -> void:
	# 1. Background (full viewport)
	draw_rect(Rect2(0, 0, Config.VIEWPORT_W, Config.VIEWPORT_H), Config.COLOR_BACKGROUND)

	# 2. Arena floor (playable area)
	draw_rect(Rect2(Config.ARENA_ORIGIN, Vector2(Config.ARENA_W, Config.ARENA_H)), Config.COLOR_ARENA_FLOOR)

	# 3. Walls (border) — draw 4 rects around playable area
	var ts := Config.TILE_SIZE
	# Top wall
	draw_rect(Rect2(0, 0, Config.VIEWPORT_W, ts), Config.COLOR_WALL)
	# Bottom wall
	draw_rect(Rect2(0, Config.VIEWPORT_H - ts, Config.VIEWPORT_W, ts), Config.COLOR_WALL)
	# Left wall
	draw_rect(Rect2(0, ts, ts, Config.VIEWPORT_H - ts * 2), Config.COLOR_WALL)
	# Right wall
	draw_rect(Rect2(Config.VIEWPORT_W - ts, ts, ts, Config.VIEWPORT_H - ts * 2), Config.COLOR_WALL)

	# 4. Altar zone (purple square + flash on seal)
	var altar_pos := Config.ALTAR_POSITION
	var altar_half := Config.ALTAR_SIZE / 2.0
	var altar_rect := Rect2(altar_pos.x - altar_half, altar_pos.y - altar_half,
							Config.ALTAR_SIZE, Config.ALTAR_SIZE)

	if altar_flash_timer > 0.0:
		var progress := altar_flash_timer / Config.ALTAR_FLASH_DURATION
		var flash_color := Color(
			lerpf(Config.COLOR_ALTAR.r, Config.COLOR_ALTAR_FLASH.r, progress),
			lerpf(Config.COLOR_ALTAR.g, Config.COLOR_ALTAR_FLASH.g, progress),
			lerpf(Config.COLOR_ALTAR.b, Config.COLOR_ALTAR_FLASH.b, progress),
			0.95
		)
		draw_rect(altar_rect, flash_color)

		# Outer aura ring
		var ring_size := Config.ALTAR_SIZE + (1.0 - progress) * 16.0
		var ring_half := ring_size / 2.0
		var ring_rect := Rect2(altar_pos.x - ring_half, altar_pos.y - ring_half, ring_size, ring_size)
		draw_rect(ring_rect, Color(Config.COLOR_ALTAR_FLASH.r, Config.COLOR_ALTAR_FLASH.g, Config.COLOR_ALTAR_FLASH.b, progress * 0.4), false, 1.5)
	else:
		draw_rect(altar_rect, Config.COLOR_ALTAR)

	# Altar inner glow
	var inner_size := Config.ALTAR_SIZE * 0.6
	var inner_rect := Rect2(altar_pos.x - inner_size / 2, altar_pos.y - inner_size / 2,
							inner_size, inner_size)
	var inner_color := Color.WHITE if altar_flash_timer > 0.0 else Color(Config.COLOR_ALTAR.r, Config.COLOR_ALTAR.g, Config.COLOR_ALTAR.b, 0.4)
	draw_rect(inner_rect, inner_color)
