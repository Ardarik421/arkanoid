extends Node2D

var age: float = 0.0
var lifetime: float = 0.52

func _ready():
	z_index = 90

func _process(delta):
	age += delta
	if age >= lifetime:
		queue_free()
		return
	queue_redraw()

func _draw():
	var t = clamp(age / lifetime, 0.0, 1.0)
	var pulse = sin(t * PI)
	var fade = pow(1.0 - t, 1.5)
	var viewport_size = get_viewport().get_visible_rect().size
	var edge = 92.0
	var corner = 210.0

	var red = Color(1.0, 0.055, 0.025, 0.10 * pulse)
	var hot = Color(1.0, 0.22, 0.055, 0.18 * fade)

	draw_colored_polygon(PackedVector2Array([
		Vector2.ZERO,
		Vector2(corner, 0.0),
		Vector2(edge, edge),
		Vector2(0.0, corner)
	]), red)

	draw_colored_polygon(PackedVector2Array([
		Vector2(viewport_size.x, 0.0),
		Vector2(viewport_size.x - corner, 0.0),
		Vector2(viewport_size.x - edge, edge),
		Vector2(viewport_size.x, corner)
	]), red)

	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, viewport_size.y),
		Vector2(corner, viewport_size.y),
		Vector2(edge, viewport_size.y - edge),
		Vector2(0.0, viewport_size.y - corner)
	]), red)

	draw_colored_polygon(PackedVector2Array([
		viewport_size,
		Vector2(viewport_size.x - corner, viewport_size.y),
		Vector2(viewport_size.x - edge, viewport_size.y - edge),
		Vector2(viewport_size.x, viewport_size.y - corner)
	]), red)

	var line_alpha = 0.34 * fade
	draw_line(Vector2(0.0, 0.0), Vector2(105.0, 0.0), Color(hot, line_alpha), 3.0, true)
	draw_line(Vector2(0.0, 0.0), Vector2(0.0, 105.0), Color(hot, line_alpha), 3.0, true)
	draw_line(Vector2(viewport_size.x, 0.0), Vector2(viewport_size.x - 105.0, 0.0), Color(hot, line_alpha), 3.0, true)
	draw_line(Vector2(viewport_size.x, 0.0), Vector2(viewport_size.x, 105.0), Color(hot, line_alpha), 3.0, true)
	draw_line(Vector2(0.0, viewport_size.y), Vector2(105.0, viewport_size.y), Color(hot, line_alpha), 3.0, true)
	draw_line(Vector2(0.0, viewport_size.y), Vector2(0.0, viewport_size.y - 105.0), Color(hot, line_alpha), 3.0, true)
	draw_line(viewport_size, Vector2(viewport_size.x - 105.0, viewport_size.y), Color(hot, line_alpha), 3.0, true)
	draw_line(viewport_size, Vector2(viewport_size.x, viewport_size.y - 105.0), Color(hot, line_alpha), 3.0, true)
