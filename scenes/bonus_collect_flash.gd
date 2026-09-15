extends Node2D

var age: float = 0.0
var lifetime: float = 0.38
var accent: Color = Color(0.30, 0.82, 1.0)

func setup(effect_color: Color):
	accent = effect_color
	z_index = 45
	queue_redraw()

func _process(delta):
	age += delta
	if age >= lifetime:
		queue_free()
		return
	queue_redraw()

func _draw():
	var t = clamp(age / lifetime, 0.0, 1.0)
	var fade = pow(1.0 - t, 1.7)
	var snap_fade = max(0.0, 1.0 - t * 4.2)
	var radius = lerp(8.0, 52.0, t)

	if snap_fade > 0.0:
		draw_circle(Vector2.ZERO, 20.0 + t * 24.0, Color(accent, snap_fade * 0.10))
		draw_circle(Vector2.ZERO, 8.0 + t * 12.0, Color(0.92, 0.99, 1.0, snap_fade * 0.54))

	draw_arc(Vector2.ZERO, radius, PI, TAU, 40, Color(accent, fade * 0.72), 2.0, true)
	draw_arc(Vector2.ZERO, radius + 5.0, PI, TAU, 40, Color(accent, fade * 0.18), 4.0, true)

	for i in range(7):
		var x = lerp(-42.0, 42.0, float(i) / 6.0)
		var start = Vector2(x, -4.0 - t * 5.0)
		var finish = Vector2(x * 0.34, -15.0 - t * 25.0)
		draw_line(start, finish, Color(accent, fade * 0.34), 1.2, true)
