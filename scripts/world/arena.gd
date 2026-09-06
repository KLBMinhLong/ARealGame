extends Node2D

const Config = preload("res://scripts/core/game_config.gd")

var pulse_time: float = 0.0

func _process(delta: float) -> void:
	pulse_time += delta
	queue_redraw()

func _draw() -> void:
	var field: Rect2 = Config.PLAYFIELD

	# 1. Dark Industrial Base Floor (#10141a)
	draw_rect(field, Color("10141a"))

	# 2. Metal Panel Grid (64x64) with plate seams and rivet accents
	var grid_size: int = 64
	var seam_color: Color = Color(0.16, 0.20, 0.26, 0.45)
	var rivet_color: Color = Color(0.24, 0.30, 0.38, 0.35)

	for x in range(int(field.position.x), int(field.end.x), grid_size):
		draw_line(Vector2(x, field.position.y), Vector2(x, field.end.y), seam_color, 1.0)
		for y in range(int(field.position.y), int(field.end.y), grid_size):
			draw_circle(Vector2(x + 3, y + 3), 1.2, rivet_color)

	for y in range(int(field.position.y), int(field.end.y), grid_size):
		draw_line(Vector2(field.position.x, y), Vector2(field.end.x, y), seam_color, 1.0)

	# 3. Center Scrap Recycling Hub
	var center: Vector2 = field.get_center()
	var hub_glow: float = 0.85 + 0.15 * sin(pulse_time * 2.0)
	draw_arc(center, 54.0, 0.0, TAU, 64, Color(0.12, 0.22, 0.32, 0.4), 2.0, true)
	draw_arc(center, 42.0, 0.0, TAU, 48, Color(0.0, 0.75, 1.0, 0.18 * hub_glow), 1.5, true)
	draw_circle(center, 12.0, Color(0.08, 0.14, 0.20, 0.7))
	draw_circle(center, 4.0, Color("00f0ff") * Color(1, 1, 1, 0.7 * hub_glow))

	# 4. Corner Hazard Markings (Diagonal warning chevrons)
	var corner_len: float = 36.0
	var hazard_color: Color = Color(0.85, 0.65, 0.15, 0.22)
	# Top-left
	draw_line(field.position, field.position + Vector2(corner_len, 0), hazard_color, 2.5)
	draw_line(field.position, field.position + Vector2(0, corner_len), hazard_color, 2.5)
	# Top-right
	var tr: Vector2 = Vector2(field.end.x, field.position.y)
	draw_line(tr, tr - Vector2(corner_len, 0), hazard_color, 2.5)
	draw_line(tr, tr + Vector2(0, corner_len), hazard_color, 2.5)
	# Bottom-left
	var bl: Vector2 = Vector2(field.position.x, field.end.y)
	draw_line(bl, bl + Vector2(corner_len, 0), hazard_color, 2.5)
	draw_line(bl, bl - Vector2(0, corner_len), hazard_color, 2.5)
	# Bottom-right
	draw_line(field.end, field.end - Vector2(corner_len, 0), hazard_color, 2.5)
	draw_line(field.end, field.end - Vector2(0, corner_len), hazard_color, 2.5)

	# 5. Neon Boundary Energy Fence (Pulsing Electric Cyan)
	var border_glow: float = 0.75 + 0.25 * sin(pulse_time * 3.5)
	var border_outer: Color = Color(0.0, 0.85, 1.0, 0.25 * border_glow)
	var border_core: Color = Color(0.38, 0.82, 1.0, 0.85 * border_glow)

	draw_rect(field.grow(1.5), border_outer, false, 3.0)
	draw_rect(field, border_core, false, 1.5)
