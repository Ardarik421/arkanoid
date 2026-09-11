extends CharacterBody2D

@export var speed: float = 450.0
@export var radius: float = 12.0
@export var max_bounce_angle: float = 50.0

var direction := Vector2(0.7, -1.0).normalized()
var is_attached: bool = true
var is_piercing: bool = false
var is_explosive: bool = false
var shield_active: bool = false
var magnet_active: bool = false
var shield_y: float = 1040.0
var attached_offset_x: float = 0.0
var visual_time: float = 0.0

var trail_points: Array[Vector2] = []
var trail_max_points: int = 10
var trail_min_distance: float = 10.0

func _ready():
	set_collision_mask_value(1, true)
	trail_points.append(global_position)
	queue_redraw()

func _draw():
	var pulse = 0.88 + 0.12 * sin(visual_time * 5.0)
	var accent = Color(0.20, 0.72, 1.0)
	var shell = Color(0.36, 0.82, 1.0)
	var energy = Color(0.72, 0.95, 1.0)
	var core = Color(1.0, 1.0, 1.0)

	if is_piercing:
		accent = Color(0.38, 0.68, 1.0)
		shell = Color(0.50, 0.78, 1.0)
		energy = Color(0.82, 0.93, 1.0)

	if is_explosive:
		accent = Color(1.0, 0.18, 0.06)
		shell = Color(1.0, 0.42, 0.10)
		energy = Color(1.0, 0.76, 0.30)
		core = Color(1.0, 0.96, 0.82)

	if trail_points.size() >= 2:
		for i in range(trail_points.size() - 1):
			var local_a = to_local(trail_points[i])
			var local_b = to_local(trail_points[i + 1])
			var t = float(i + 1) / float(trail_points.size())
			var alpha = lerp(0.015, 0.25, t)
			var width = lerp(0.8, 3.8, t)
			draw_line(local_a, local_b, Color(accent, alpha), width, true)

	draw_circle(Vector2.ZERO, radius + 9.0, Color(accent, 0.045 * pulse))
	draw_circle(Vector2.ZERO, radius + 5.0, Color(accent, 0.10 * pulse))
	draw_circle(Vector2.ZERO, radius + 2.0, Color(shell, 0.18))

	draw_circle(Vector2.ZERO, radius, Color(0.008, 0.025, 0.045, 0.96))
	draw_circle(Vector2.ZERO, radius - 1.2, Color(shell, 0.34))
	draw_circle(Vector2(1.2, 1.6), radius - 3.0, Color(0.015, 0.10, 0.16, 0.58))

	draw_circle(Vector2.ZERO, radius * 0.53, Color(energy, 0.22 * pulse))
	draw_circle(Vector2.ZERO, radius * 0.35, Color(energy, 0.62))
	draw_circle(Vector2.ZERO, radius * 0.19, core)

	draw_arc(Vector2.ZERO, radius - 1.0, deg_to_rad(205.0), deg_to_rad(335.0), 20, Color(accent, 0.68), 1.25, true)
	draw_arc(Vector2.ZERO, radius - 2.0, deg_to_rad(25.0), deg_to_rad(112.0), 16, Color(1.0, 1.0, 1.0, 0.72), 1.05, true)
	draw_circle(Vector2(-3.7, -4.1), 1.7, Color(1.0, 1.0, 1.0, 0.92))
	draw_circle(Vector2(-5.1, -5.4), 0.75, Color(1.0, 1.0, 1.0, 0.72))

	if is_piercing:
		for side in [-1.0, 1.0]:
			var x = side * (radius + 2.5)
			draw_line(Vector2(x, -4.5), Vector2(x, 4.5), Color(accent, 0.78 * pulse), 1.5, true)
		draw_line(Vector2(-radius - 4.0, 0.0), Vector2(radius + 4.0, 0.0), Color(energy, 0.34 * pulse), 1.0, true)

	if is_explosive:
		for i in range(4):
			var angle = visual_time * 1.8 + TAU * float(i) / 4.0
			var p1 = Vector2(cos(angle), sin(angle)) * (radius + 1.5)
			var p2 = Vector2(cos(angle), sin(angle)) * (radius + 5.0 + 1.5 * pulse)
			draw_line(p1, p2, Color(accent, 0.68), 1.4, true)

func _physics_process(delta):
	visual_time += delta

	if is_attached:
		var paddle = get_parent().get_node("Paddle")

		global_position.x = paddle.global_position.x + attached_offset_x
		global_position.y = paddle.global_position.y - 40
		_update_trail(true)

		return
	
	if shield_active and direction.y > 0.0:
		if global_position.y + radius >= shield_y:
			global_position.y = shield_y - radius
			direction.y = -abs(direction.y)
	
	var collision = move_and_collide(direction * speed * delta)

	if collision:
		var collider = collision.get_collider()

		if collider.name == "Paddle":
			if magnet_active:
				attach_to_paddle()
			else:
				bounce_from_paddle(collider)

		elif collider.has_method("hit"):
			if is_piercing:
				collider.destroy(is_explosive)
			else:
				direction = direction.bounce(collision.get_normal())
				collider.hit(is_explosive)

		else:
			direction = direction.bounce(collision.get_normal())

	_update_trail(false)

func _update_trail(reset_trail: bool):
	if reset_trail:
		trail_points.clear()
		trail_points.append(global_position)
		queue_redraw()
		return

	if trail_points.is_empty() or trail_points.back().distance_to(global_position) >= trail_min_distance:
		trail_points.append(global_position)

	while trail_points.size() > trail_max_points:
		trail_points.pop_front()

	queue_redraw()

func bounce_from_paddle(paddle):
	var offset = global_position.x - paddle.global_position.x
	var half_width = paddle.width / 2.0

	var normalized_offset = clamp(offset / half_width, -1.0, 1.0)
	var angle = deg_to_rad(normalized_offset * max_bounce_angle)

	direction = Vector2(
		sin(angle),
		-cos(angle)
	).normalized()
	
	var is_attached: bool = false

func attach_to_paddle():
	is_attached = true

	var paddle = get_parent().get_node("Paddle")

	attached_offset_x = global_position.x - paddle.global_position.x
	global_position.y = paddle.global_position.y - 40
	_update_trail(true)

func launch():
	is_attached = false
	trail_points.clear()
	trail_points.append(global_position)

	var horizontal = randf_range(0.45, 0.75)

	if randf() < 0.5:
		horizontal *= -1.0

	direction = Vector2(
		horizontal,
		-1.0
	).normalized()
