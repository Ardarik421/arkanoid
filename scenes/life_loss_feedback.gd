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
	var inset = 22.0
	var left = inset
	var top = inset
	var right = viewport_size.x - inset
	var bottom = viewport_size.y - inset
	var alarm = 0.62 + 0.38 * sin(age * 34.0)

	var outer = Color(1.0, 0.045, 0.018, pulse * 0.16)
	var inner = Color(1.0, 0.24, 0.055, fade * (0.34 + alarm * 0.22))
	var hot = Color(1.0, 0.62, 0.18, fade * 0.18)

	draw_rect(Rect2(Vector2(left, top), Vector2(right - left, bottom - top)), outer, false, 10.0)
	draw_rect(Rect2(Vector2(left + 5.0, top + 5.0), Vector2(right - left - 10.0, bottom - top - 10.0)), inner, false, 3.0)
	draw_rect(Rect2(Vector2(left + 9.0, top + 9.0), Vector2(right - left - 18.0, bottom - top - 18.0)), hot, false, 1.0)
