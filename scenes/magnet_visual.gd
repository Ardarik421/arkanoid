extends Node2D

var animation_time: float = 0.0

func _process(delta):
	animation_time += delta
	var main = get_parent()
	visible = main != null and bool(main.get("magnet_active"))
	if visible:
		queue_redraw()

func _draw():
	var paddle = get_parent().get_node_or_null("Paddle")
	if paddle == null:
		return

	var center = paddle.position - position
	var half_width = paddle.width * 0.58
	var pulse = 0.86 + 0.14 * sin(animation_time * 2.6)
	var base_y = center.y - 2.0
	var top_y = center.y - 66.0

	for layer in range(4):
		var layer_t = float(layer) / 3.0
		var radius_x = half_width * (1.0 + layer_t * 0.18)
		var height = 58.0 + layer_t * 12.0
		var points = PackedVector2Array()
		for i in range(25):
			var t = float(i) / 24.0
			var x = lerp(-radius_x, radius_x, t)
			var normalized = x / radius_x
			var y = base_y - height * sqrt(max(0.0, 1.0 - normalized * normalized))
			points.append(Vector2(center.x + x, y))
		draw_polyline(points, Color(0.58, 0.26, 1.0, (0.055 - layer_t * 0.010) * pulse), 1.0 + float(3 - layer) * 0.5, true)

	var hex_radius = 11.0
	var hex_width = hex_radius * 1.732
	var row_height = hex_radius * 1.5
	var row = 0
	var y = top_y + 12.0
	while y < base_y - 5.0:
		var offset = hex_width * 0.5 if row % 2 == 1 else 0.0
		var x = center.x - half_width + offset
		while x <= center.x + half_width:
			var dx = (x - center.x) / half_width
			var dome_y = base_y - 58.0 * sqrt(max(0.0, 1.0 - dx * dx))
			if y >= dome_y:
				var points = PackedVector2Array()
				for i in range(6):
					var angle = deg_to_rad(60.0 * float(i) - 30.0)
					points.append(Vector2(x + cos(angle) * hex_radius, y + sin(angle) * hex_radius))
				points.append(points[0])
				draw_polyline(points, Color(0.68, 0.30, 1.0, 0.075 * pulse), 0.8, true)
			x += hex_width
		y += row_height
		row += 1
