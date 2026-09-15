extends Node2D

var age: float = 0.0
var lifetime: float = 0.34

func _ready():
	z_index = 40
	queue_redraw()

func _process(delta):
	age += delta
	if age >= lifetime:
		queue_free()
		return
	queue_redraw()

func _draw():
	var t = clamp(age / lifetime, 0.0, 1.0)
	var fast_fade = max(0.0, 1.0 - t * 3.8)
	var ring_fade = pow(1.0 - t, 1.6)
	var core_radius = lerp(10.0, 46.0, min(t * 2.2, 1.0))

	if fast_fade > 0.0:
		draw_circle(Vector2.ZERO, core_radius + 18.0, Color(1.0, 0.18, 0.025, fast_fade * 0.08))
		draw_circle(Vector2.ZERO, core_radius, Color(1.0, 0.48, 0.08, fast_fade * 0.18))
		draw_circle(Vector2.ZERO, core_radius * 0.48, Color(1.0, 0.94, 0.70, fast_fade * 0.54))

	var ring_radius = 22.0 + t * 92.0
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 64, Color(1.0, 0.30, 0.035, ring_fade * 0.68), 2.4, true)
	draw_arc(Vector2.ZERO, ring_radius + 5.0, 0.0, TAU, 64, Color(1.0, 0.72, 0.18, ring_fade * 0.22), 1.2, true)

	for i in range(8):
		var angle = TAU * float(i) / 8.0 + 0.18
		var direction = Vector2(cos(angle), sin(angle))
		var start = direction * (18.0 + t * 22.0)
		var finish = direction * (32.0 + t * 58.0)
		draw_line(start, finish, Color(1.0, 0.42, 0.06, ring_fade * 0.34), 1.2, true)
