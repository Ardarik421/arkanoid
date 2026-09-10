extends Control

var animation_time: float = 0.0

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _process(delta):
	animation_time += delta
	queue_redraw()

func _draw():
	_draw_space_gradient()
	_draw_stars()
	_draw_core_planet()
	_draw_planet_limb()
	_draw_nebula()
	_draw_asteroids()
	_draw_black_hole()
	_draw_route_markers()
	_draw_space_dust()

func _draw_space_gradient():
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.002, 0.006, 0.014, 1.0))
	for i in range(24):
		var y = float(i) * size.y / 24.0
		var t = y / max(size.y, 1.0)
		var c = Color(
			0.006 + 0.018 * (1.0 - t),
			0.012 + 0.022 * (1.0 - t),
			0.026 + 0.042 * (1.0 - t),
			0.32
		)
		draw_rect(Rect2(0, y, size.x, size.y / 24.0 + 1.0), c)

func _draw_stars():
	for i in range(120):
		var x = float((i * 163 + 37) % 960)
		var y = float((i * 97 + 23) % 1080)
		var twinkle = 0.22 + (sin(animation_time * 0.9 + i * 0.61) + 1.0) * 0.18
		var radius = 0.7 + float(i % 4) * 0.35
		var tint = Color(0.62, 0.79, 1.0, twinkle)
		if i % 11 == 0:
			tint = Color(0.82, 0.66, 1.0, twinkle + 0.08)
		draw_circle(Vector2(x, y), radius, tint)

func _draw_core_planet():
	var center = Vector2(-35, 1085)
	var radius = 430.0
	var pulse = 0.92 + sin(animation_time * 1.35) * 0.08

	for i in range(7, 0, -1):
		var r = radius + float(i) * 14.0
		draw_circle(center, r, Color(1.0, 0.12, 0.02, 0.012 * i * pulse))

	draw_circle(center, radius, Color(0.11, 0.025, 0.012, 1.0))
	for i in range(11):
		var angle = -1.18 + float(i) * 0.145
		var inner = center + Vector2(cos(angle), sin(angle)) * (radius * 0.18)
		var outer = center + Vector2(cos(angle + 0.08 * sin(i)), sin(angle + 0.08 * sin(i))) * (radius * 0.98)
		draw_line(inner, outer, Color(1.0, 0.18, 0.03, 0.34 * pulse), 18.0)
		draw_line(inner, outer, Color(1.0, 0.58, 0.12, 0.82 * pulse), 4.0)

	for i in range(18):
		var a = float(i) * 0.47
		var d = 95.0 + float((i * 41) % 250)
		var p = center + Vector2(cos(a), sin(a)) * d
		draw_circle(p, 12.0 + float(i % 5) * 5.0, Color(0.08, 0.045, 0.038, 0.96))

func _draw_planet_limb():
	var center = Vector2(120, 900)
	var radius = 560.0
	for i in range(8, 0, -1):
		var r = radius + float(i) * 8.0
		draw_arc(center, r, -1.72, -0.18, 96, Color(0.16, 0.52, 1.0, 0.025 * i), 4.0, true)
	draw_arc(center, radius, -1.72, -0.18, 96, Color(0.38, 0.76, 1.0, 0.72), 5.0, true)
	draw_arc(center, radius - 13.0, -1.72, -0.18, 96, Color(0.12, 0.31, 0.54, 0.42), 22.0, true)

func _draw_nebula():
	var center = Vector2(620, 330)
	for i in range(9, 0, -1):
		var r = Vector2(260.0 + i * 23.0, 115.0 + i * 11.0)
		var a = 0.012 + float(i) * 0.008
		_draw_haze_ellipse(center + Vector2(sin(animation_time * 0.08 + i) * 12.0, cos(animation_time * 0.06 + i) * 7.0), r, Color(0.23, 0.18, 0.62, a))
	for i in range(5):
		var radius = 150.0 + i * 32.0
		draw_arc(center, radius, -2.7 + i * 0.12, 0.4 + i * 0.3, 64, Color(0.45, 0.27, 0.9, 0.08), 3.0, true)

func _draw_asteroids():
	for i in range(24):
		var base = Vector2(300 + float((i * 71) % 520), 250 + float((i * 53) % 500))
		var drift = Vector2(sin(animation_time * 0.12 + i) * 4.0, cos(animation_time * 0.09 + i) * 3.0)
		var radius = 5.0 + float((i * 7) % 18)
		_draw_asteroid(base + drift, radius, float(i) * 0.73)

func _draw_black_hole():
	var center = Vector2(735, 150)
	var pulse = 1.0 + sin(animation_time * 0.55) * 0.018

	for i in range(9, 0, -1):
		var r = (78.0 + i * 18.0) * pulse
		draw_circle(center, r, Color(0.19, 0.07, 0.34, 0.014 + i * 0.008))

	for i in range(8):
		var radius = (94.0 + i * 11.0) * pulse
		var start = -2.95 + animation_time * (0.018 + i * 0.002) + i * 0.17
		var length = 2.2 + float(i % 3) * 0.42
		var color = Color(0.48 + i * 0.035, 0.24 + i * 0.018, 1.0, 0.18 + i * 0.035)
		draw_arc(center, radius, start, start + length, 72, color, 2.0 + float(i % 3), true)

	draw_arc(center, 89.0 * pulse, 0.08 + animation_time * 0.032, 3.55 + animation_time * 0.032, 96, Color(0.36, 0.72, 1.0, 0.78), 5.0, true)
	draw_arc(center, 102.0 * pulse, -3.0 - animation_time * 0.028, 0.32 - animation_time * 0.028, 96, Color(0.86, 0.42, 1.0, 0.72), 6.0, true)
	draw_circle(center, 70.0 * pulse, Color(0.001, 0.001, 0.004, 1.0))
	draw_circle(center, 57.0 * pulse, Color(0, 0, 0, 1.0))

func _draw_route_markers():
	var x = size.x - 48.0
	var points = [
		Vector2(x, 970),
		Vector2(x, 760),
		Vector2(x, 555),
		Vector2(x, 350),
		Vector2(x, 150)
	]
	var colors = [
		Color(1.0, 0.46, 0.08, 0.95),
		Color(0.45, 0.85, 0.48, 0.95),
		Color(0.35, 0.7, 1.0, 0.95),
		Color(0.49, 0.46, 1.0, 0.95),
		Color(0.83, 0.46, 1.0, 0.95)
	]
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color(0.56, 0.72, 1.0, 0.28), 2.0)
	for i in range(points.size()):
		for r in range(4, 0, -1):
			draw_circle(points[i], 5.0 + r * 3.0, Color(colors[i].r, colors[i].g, colors[i].b, 0.025 * r))
		draw_circle(points[i], 5.5, colors[i])

func _draw_space_dust():
	for i in range(42):
		var x = float((i * 139 + 29) % 960)
		var y = float((i * 181 + 17) % 1080)
		var offset = fmod(animation_time * (2.0 + float(i % 4)) + i * 7.0, 46.0)
		var p = Vector2(x + sin(animation_time * 0.18 + i) * 3.0, fmod(y - offset + 1080.0, 1080.0))
		draw_circle(p, 1.0 + float(i % 2), Color(0.68, 0.76, 0.92, 0.10))

func _draw_asteroid(center: Vector2, radius: float, phase: float):
	var points = PackedVector2Array()
	for i in range(9):
		var a = TAU * float(i) / 9.0
		var wobble = 0.78 + 0.18 * sin(phase + i * 1.7)
		points.append(center + Vector2(cos(a), sin(a)) * radius * wobble)
	draw_colored_polygon(points, Color(0.055, 0.06, 0.075, 0.96))
	if points.size() > 1:
		var outline = PackedVector2Array(points)
		outline.append(points[0])
		draw_polyline(outline, Color(0.22, 0.27, 0.34, 0.45), 1.5, true)

func _draw_haze_ellipse(center: Vector2, radii: Vector2, color: Color):
	var points = PackedVector2Array()
	for i in range(48):
		var a = TAU * float(i) / 48.0
		points.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(points, color)
