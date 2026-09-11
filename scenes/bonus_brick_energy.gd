extends Node2D

var animation_time: float = 0.0

func _process(delta):
	animation_time += delta
	queue_redraw()

func _draw():
	var brick = get_parent()
	if brick == null:
		return
	if not bool(brick.get("guaranteed_bonus")):
		return

	var powerful = bool(brick.get("powerful_bonus"))
	var energy = Color(1.0, 0.24, 0.07) if powerful else Color(1.0, 0.72, 0.12)
	var hot = Color(1.0, 0.72, 0.38) if powerful else Color(1.0, 0.94, 0.58)
	var pulse = 0.72 + 0.28 * sin(animation_time * 3.0)
	var wave = animation_time * 2.2

	_draw_soft_ellipse(Vector2.ZERO, 15.0 + pulse * 3.0, 8.0 + pulse * 1.5, Color(energy, 0.16 + pulse * 0.05))
	_draw_soft_ellipse(Vector2(sin(wave * 0.7) * 3.5, 0.0), 22.0 + pulse * 2.0, 7.0, Color(energy, 0.08 + pulse * 0.03))
	_draw_soft_ellipse(Vector2(cos(wave * 0.5) * 5.0, sin(wave * 0.4) * 1.5), 29.0, 5.5, Color(hot, 0.035 + pulse * 0.02))

	for layer in range(5):
		var radius_x = 20.0 + float(layer) * 4.0 + pulse * 2.5
		var radius_y = 5.0 + float(layer) * 1.8 + pulse * 1.2
		var center = Vector2(sin(wave * 0.55 + float(layer)) * 6.0, cos(wave * 0.42 + float(layer) * 0.7) * 2.3)
		var alpha = (0.050 - float(layer) * 0.007) * (0.80 + pulse * 0.20)
		_draw_soft_ellipse(center, radius_x, radius_y, Color(energy, alpha))

	for ribbon in range(3):
		var points = PackedVector2Array()
		var phase = wave + float(ribbon) * 2.1
		for i in range(19):
			var t = float(i) / 18.0
			var x = lerp(-27.0, 27.0, t)
			var y = sin(t * TAU * (1.1 + float(ribbon) * 0.12) + phase) * (2.0 + float(ribbon) * 0.8)
			y += cos(t * PI * 2.0 + phase * 0.6) * 0.8
			points.append(Vector2(x, y))
		var alpha = (0.12 - float(ribbon) * 0.025) * (0.72 + pulse * 0.28)
		draw_polyline(points, Color(energy, alpha), 1.0 + float(ribbon) * 0.35, true)

	for i in range(5):
		var phase = animation_time * (1.7 + float(i) * 0.11) + float(i) * 1.9
		var x = sin(phase * 0.73) * (18.0 + float(i % 2) * 6.0)
		var y = cos(phase) * 6.0
		var brightness = 0.55 + 0.45 * sin(phase * 1.4)
		draw_circle(Vector2(x, y), 0.7 + brightness * 0.9, Color(hot, 0.18 + brightness * 0.16))

	draw_circle(Vector2.ZERO, 3.5 + pulse * 2.0, Color(hot, 0.055 + pulse * 0.040))
	draw_circle(Vector2.ZERO, 1.2 + pulse * 0.7, Color(hot, 0.34 + pulse * 0.18))

func _draw_soft_ellipse(center: Vector2, radius_x: float, radius_y: float, color: Color):
	var points = PackedVector2Array()
	for i in range(33):
		var angle = TAU * float(i) / 32.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	draw_colored_polygon(points, color)
