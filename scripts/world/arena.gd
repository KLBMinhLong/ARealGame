extends Node2D

const Config = preload("res://scripts/core/game_config.gd")

func _draw() -> void:
	var field: Rect2 = Config.PLAYFIELD
	draw_rect(field, Color("12222d"))
	for x in range(int(field.position.x), int(field.end.x), 48):
		draw_line(Vector2(x, field.position.y), Vector2(x, field.end.y), Color(0.32, 0.44, 0.53, 0.12), 1.0)
	for y in range(int(field.position.y), int(field.end.y), 48):
		draw_line(Vector2(field.position.x, y), Vector2(field.end.x, y), Color(0.32, 0.44, 0.53, 0.12), 1.0)
	draw_rect(field, Color("405b6b"), false, 1.5)
	var center: Vector2 = field.get_center()
	draw_arc(center, 48.0, 0.0, TAU, 64, Color(0.39, 0.72, 1.0, 0.13), 1.0, true)
	draw_line(center - Vector2(8, 0), center + Vector2(8, 0), Color("405b6b"), 1.0)
	draw_line(center - Vector2(0, 8), center + Vector2(0, 8), Color("405b6b"), 1.0)
