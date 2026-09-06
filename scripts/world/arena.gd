## arena.gd — Stone Knight M0
## Vẽ arena background, walls, và altar zone.
## Tất cả placeholder — _draw() based.
extends Node2D


func _ready() -> void:
	pass


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
	
	# 4. Altar zone (placeholder — purple square)
	var altar_pos := Config.ALTAR_POSITION
	var altar_half := Config.ALTAR_SIZE / 2.0
	var altar_rect := Rect2(altar_pos.x - altar_half, altar_pos.y - altar_half,
							Config.ALTAR_SIZE, Config.ALTAR_SIZE)
	draw_rect(altar_rect, Config.COLOR_ALTAR)
	
	# Altar inner glow
	var inner_size := Config.ALTAR_SIZE * 0.6
	var inner_rect := Rect2(altar_pos.x - inner_size / 2, altar_pos.y - inner_size / 2,
							inner_size, inner_size)
	draw_rect(inner_rect, Color(Config.COLOR_ALTAR.r, Config.COLOR_ALTAR.g, 
								Config.COLOR_ALTAR.b, 0.4))
