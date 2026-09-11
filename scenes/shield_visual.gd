extends Node2D

var animation_time: float = 0.0

func _process(delta):
	animation_time += delta
	queue_redraw()

func _draw():
	var pulse = 0.86 + 0.14 * sin(animation_time * 2.2)
	var top_y = -6.0
	var bottom_y = 46.0

	for i in range(7):
		var y = top_y + float(i) * 7.0
		var alpha = (0.045 - float(i) * 0.0045) * pulse
		draw_rect(Rect2(-460.0, y, 920.0, 8.0), Color(0.04, 0.34, 0.78, alpha))

	for i in range(5):
		var y = top_y + float(i) * 3.0
		var alpha = (0.16 - float(i) * 0.025) * pulse
		draw_line(Vector2(-460.0, y), Vector2(460.0, y), Color(0.20, 0.72, 1.0, alpha), 1.2 + float(4 - i) * 0.45, true)

	var radius = 14.0
	var hex_width = radius * 1.732
	var row_height = radius * 1.5
	var scroll = fmod(animation_time * 10.0, hex_width)
	var row = 0
	var y = top_y + 7.0

	while y < bottom_y:
		var offset = hex_width * 0.5 if row % 2 == 1 else 0.0
		var x = -480.0 - scroll + offset
		while x < 480.0:
			var points = PackedVector2Array()
			for point_index in range(6):
				var angle = deg_to_rad(60.0 * float(point_index) - 30.0)
				points.append(Vector2(x + cos(angle) * radius, y + sin(angle) * radius))
			points.append(points[0])
			draw_polyline(points, Color(0.18, 0.68, 1.0, 0.105 * pulse), 0.8, true)
			x += hex_width
		y += row_height
		row += 1

	for i in range(12):
		var phase = animation_time * (0.65 + float(i % 4) * 0.11) + float(i) * 1.73
		var x = -430.0 + float((i * 157 + 83) % 860)
		var y_pos = 8.0 + float((i * 37) % 32) + sin(phase) * 3.0
		var brightness = 0.45 + 0.55 * max(0.0, sin(phase * 1.7))
		draw_circle(Vector2(x, y_pos), 0.8 + brightness * 0.8, Color(0.42, 0.86, 1.0, 0.12 * brightness))
