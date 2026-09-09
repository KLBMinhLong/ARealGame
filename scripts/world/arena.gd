## arena.gd — Stone Knight M0 + F015
## Vẽ arena background, walls, và altar zone.
## Tất cả placeholder — _draw() based.
extends Node2D

var altar_flash_timer: float = 0.0

# ─── F019: Spike Wall Layouts ────────────────────────────
var active_spikes: Array[Rect2] = []


func _ready() -> void:
	set_layout(1)


func set_layout(wave_num: int) -> void:
	active_spikes.clear()
	var idx := clampi(wave_num - 1, 0, Config.ARENA_LAYOUTS.size() - 1)
	var layout_data: Dictionary = Config.ARENA_LAYOUTS[idx]
	var spikes: Array = layout_data.get("spike_walls", [])
	for s in spikes:
		if s is Rect2:
			active_spikes.append(s)
	queue_redraw()


func get_active_spikes() -> Array[Rect2]:
	return active_spikes


## Kiểm tra điểm va chạm biên có nằm trong đoạn tường gai nào không
func is_spike_contact(contact_pos: Vector2, tolerance: float = 6.0) -> bool:
	for spike_rect in active_spikes:
		if spike_rect.grow(tolerance).has_point(contact_pos):
			return true
	return false


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

	# 5. F019: Spike Walls
	for spike_rect in active_spikes:
		draw_rect(spike_rect, Config.COLOR_SPIKE_WALL)

		var is_vertical := spike_rect.size.x <= 10.0
		var tooth_len := 10.0
		var tooth_depth := Config.SPIKE_DEPTH

		if is_vertical:
			var is_left := spike_rect.position.x < Config.VIEWPORT_W / 2.0
			var x_base := spike_rect.position.x + (spike_rect.size.x if is_left else 0.0)
			var dir_x := 1.0 if is_left else -1.0
			var y_curr := spike_rect.position.y
			var y_end := spike_rect.position.y + spike_rect.size.y

			while y_curr + tooth_len <= y_end + 0.1:
				var p1 := Vector2(x_base, y_curr)
				var p2 := Vector2(x_base + dir_x * tooth_depth, y_curr + tooth_len * 0.5)
				var p3 := Vector2(x_base, y_curr + tooth_len)
				draw_colored_polygon(PackedVector2Array([p1, p2, p3]), Config.COLOR_SPIKE_TIP)
				y_curr += tooth_len
		else:
			var is_top := spike_rect.position.y < Config.VIEWPORT_H / 2.0
			var y_base := spike_rect.position.y + (spike_rect.size.y if is_top else 0.0)
			var dir_y := 1.0 if is_top else -1.0
			var x_curr := spike_rect.position.x
			var x_end := spike_rect.position.x + spike_rect.size.x

			while x_curr + tooth_len <= x_end + 0.1:
				var p1 := Vector2(x_curr, y_base)
				var p2 := Vector2(x_curr + tooth_len * 0.5, y_base + dir_y * tooth_depth)
				var p3 := Vector2(x_curr + tooth_len, y_base)
				draw_colored_polygon(PackedVector2Array([p1, p2, p3]), Config.COLOR_SPIKE_TIP)
				x_curr += tooth_len
