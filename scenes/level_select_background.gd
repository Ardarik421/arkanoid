extends Control

var animation_time: float = 0.0

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _process(delta):
	animation_time += delta
	queue_redraw()

func _draw():
	_draw_base()
	_draw_core_zone()
	_draw_surface_zone()
	_draw_atmosphere_zone()
	_draw_space_zone()
	_draw_distortion_zone()
	_draw_black_hole()
	_draw_dust()

func _draw_base():
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.006, 0.009, 0.016, 1.0))
	for i in range(18):
		var y = float(i) * size.y / 18.0
		var t = y / max(size.y, 1.0)
		var c = Color(0.018 + 0.018 * t, 0.024 + 0.012 * t, 0.04 + 0.025 * t, 0.16)
		draw_rect(Rect2(0, y, size.x, size.y / 18.0 + 1.0), c)

func _draw_core_zone():
	var pulse = 0.85 + sin(animation_time * 1.7) * 0.12
	for i in range(8):
		var y = 960.0 - i * 42.0
		var x = 70.0 + float((i * 97) % 760)
		var length = 85.0 + float((i * 43) % 140)
		draw_line(Vector2(x, y), Vector2(x + length, y - 30.0), Color(1.0, 0.23, 0.045, 0.12 * pulse), 12.0)
		draw_line(Vector2(x, y), Vector2(x + length, y - 30.0), Color(1.0, 0.52, 0.12, 0.62 * pulse), 3.0)
	for i in range(7):
		var base_x = float(i) * 155.0 - 50.0
		var points = PackedVector2Array([
			Vector2(base_x, 1080), Vector2(base_x + 45, 900), Vector2(base_x + 98, 865),
			Vector2(base_x + 135, 930), Vector2(base_x + 170, 1080)
		])
		draw_colored_polygon(points, Color(0.055, 0.045, 0.048, 0.92))

func _draw_surface_zone():
	var y0 = 610.0
	draw_rect(Rect2(0, y0, size.x, 210), Color(0.025, 0.055, 0.05, 0.22))
	for i in range(22):
		var x = float((i * 47) % 960)
		var h = 16.0 + float((i * 19) % 42)
		var sway = sin(animation_time * 0.6 + i) * 3.0
		draw_line(Vector2(x, 805), Vector2(x + sway, 805 - h), Color(0.18, 0.43, 0.26, 0.32), 2.0)
		if i % 3 == 0:
			draw_circle(Vector2(x + sway, 805 - h), 4.0, Color(0.32, 0.65, 0.38, 0.34))

func _draw_atmosphere_zone():
	for i in range(8):
		var y = 475.0 + i * 18.0
		var alpha = 0.035 + i * 0.008
		draw_line(Vector2(0, y), Vector2(size.x, y - 18.0), Color(0.18, 0.48, 0.78, alpha), 14.0)
	var moon_x = 780.0 + sin(animation_time * 0.08) * 8.0
	draw_circle(Vector2(moon_x, 500), 46.0, Color(0.16, 0.18, 0.22, 0.7))
	draw_circle(Vector2(moon_x - 12, 487), 10.0, Color(0.08, 0.09, 0.12, 0.55))
	draw_circle(Vector2(moon_x + 15, 512), 7.0, Color(0.08, 0.09, 0.12, 0.48))

func _draw_space_zone():
	for i in range(52):
		var x = float((i * 157 + 83) % 960)
		var y = 130.0 + float((i * 73) % 330)
		var twinkle = 0.25 + (sin(animation_time * 1.2 + i * 0.7) + 1.0) * 0.16
		var r = 1.0 + float(i % 3) * 0.45
		draw_circle(Vector2(x, y), r, Color(0.62, 0.8, 1.0, twinkle))

func _draw_distortion_zone():
	var center = Vector2(790, 170)
	for i in range(5):
		var radius = 90.0 + i * 24.0 + sin(animation_time * 0.5 + i) * 4.0
		_draw_arc_segment(center, radius, -2.45 + i * 0.1, 1.0 + i * 0.07, Color(0.38, 0.28, 0.72, 0.12 - i * 0.012), 2.0)

func _draw_black_hole():
	var center = Vector2(790, 155)
	var pulse = 1.0 + sin(animation_time * 0.7) * 0.025
	for i in range(5, 0, -1):
		var r = (55.0 + i * 16.0) * pulse
		draw_circle(center, r, Color(0.16, 0.08, 0.28, 0.028 + i * 0.012))
	_draw_arc_segment(center, 87.0, -2.8 + animation_time * 0.06, 2.4, Color(0.78, 0.45, 1.0, 0.52), 5.0)
	_draw_arc_segment(center, 74.0, 0.25 + animation_time * 0.045, 2.15, Color(0.32, 0.62, 1.0, 0.35), 3.0)
	draw_circle(center, 48.0, Color(0.001, 0.001, 0.004, 1.0))
	draw_circle(center, 39.0, Color(0, 0, 0, 1.0))

func _draw_dust():
	for i in range(28):
		var base_x = float((i * 131 + 17) % 960)
		var base_y = float((i * 89 + 41) % 1080)
		var drift = fmod(animation_time * (2.0 + float(i % 5)) + i * 11.0, 70.0)
		var p = Vector2(base_x + sin(animation_time * 0.2 + i) * 5.0, fmod(base_y - drift + 1080.0, 1080.0))
		draw_circle(p, 1.2 + float(i % 2), Color(0.72, 0.72, 0.75, 0.11))

func _draw_arc_segment(center: Vector2, radius: float, start_angle: float, length: float, color: Color, width: float):
	var points = PackedVector2Array()
	for i in range(25):
		var a = start_angle + length * float(i) / 24.0
		points.append(center + Vector2(cos(a), sin(a)) * radius)
	if points.size() > 1:
		draw_polyline(points, color, width, true)
