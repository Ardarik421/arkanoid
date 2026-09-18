extends Control

@export_enum("piercing", "explosive", "shield", "magnet") var icon_type: String = "piercing"

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _draw():
	var accent: Color = _accent_color()
	var center: Vector2 = size * 0.5
	var half: float = minf(size.x, size.y) * 0.5 - 3.0
	draw_circle(center, half + 2.0, Color(accent, 0.08))
	draw_rect(Rect2(center - Vector2(half, half), Vector2(half * 2.0, half * 2.0)), Color(0.018, 0.035, 0.052, 0.96))
	draw_rect(Rect2(center - Vector2(half, half), Vector2(half * 2.0, half * 2.0)), Color(accent, 0.72), false, 1.5)
	draw_set_transform(center, 0.0, Vector2(1.65, 1.65))
	_draw_icon(accent)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _accent_color() -> Color:
	match icon_type:
		"piercing": return Color(1.0, 0.82, 0.22)
		"explosive": return Color(1.0, 0.23, 0.08)
		"shield": return Color(0.20, 0.58, 1.0)
		"magnet": return Color(0.92, 0.24, 0.96)
	return Color.WHITE

func _draw_icon(accent: Color):
	var bright: Color = Color(0.88, 0.97, 1.0)
	var glow: Color = Color(accent, 0.65)
	match icon_type:
		"piercing":
			var tip: PackedVector2Array = PackedVector2Array([Vector2(0, -9), Vector2(5, -1), Vector2(2, 8), Vector2(0, 5), Vector2(-2, 8), Vector2(-5, -1)])
			draw_colored_polygon(tip, Color(accent, 0.70))
			draw_polyline(PackedVector2Array([tip[0], tip[1], tip[2], tip[3], tip[4], tip[5], tip[0]]), bright, 1.1, true)
			draw_line(Vector2(0, -6), Vector2(0, 6), bright, 1.4, true)
		"explosive":
			for i in range(8):
				var angle: float = TAU * float(i) / 8.0
				var start: Vector2 = Vector2(cos(angle), sin(angle)) * 4.0
				var finish: Vector2 = Vector2(cos(angle), sin(angle)) * (8.0 if i % 2 == 0 else 6.5)
				draw_line(start, finish, glow, 1.5, true)
			draw_circle(Vector2.ZERO, 4.3, Color(accent, 0.86))
			draw_circle(Vector2(-1.2, -1.2), 1.6, Color(1.0, 0.94, 0.72))
		"shield":
			var shield: PackedVector2Array = PackedVector2Array([Vector2(0, -9), Vector2(7, -6), Vector2(6, 2), Vector2(0, 9), Vector2(-6, 2), Vector2(-7, -6)])
			draw_colored_polygon(shield, Color(accent, 0.38))
			draw_polyline(PackedVector2Array([shield[0], shield[1], shield[2], shield[3], shield[4], shield[5], shield[0]]), bright, 1.5, true)
			draw_line(Vector2(0, -6), Vector2(0, 5), Color(accent, 0.9), 1.2, true)
		"magnet":
			draw_arc(Vector2.ZERO, 7.0, 0.0, PI, 20, glow, 3.0, true)
			draw_line(Vector2(-7, 0), Vector2(-7, -6), bright, 2.5, true)
			draw_line(Vector2(7, 0), Vector2(7, -6), bright, 2.5, true)
			draw_line(Vector2(-7, -6), Vector2(-3, -6), Color(accent, 0.9), 2.5, true)
			draw_line(Vector2(3, -6), Vector2(7, -6), Color(accent, 0.9), 2.5, true)
