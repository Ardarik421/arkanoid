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

var trail_points: Array[Vector2] = []
var trail_max_points: int = 10
var trail_min_distance: float = 10.0

func _ready():
	set_collision_mask_value(1, true)
	trail_points.append(global_position)
	queue_redraw()

func _draw():
	if trail_points.size() >= 2:
		for i in range(trail_points.size() - 1):
			var local_a = to_local(trail_points[i])
			var local_b = to_local(trail_points[i + 1])
			var t = float(i + 1) / float(trail_points.size())
			var alpha = lerp(0.02, 0.34, t)
			var width = lerp(1.0, 5.0, t)
			draw_line(local_a, local_b, Color(0.12, 0.52, 1.0, alpha), width, true)

	draw_circle(Vector2.ZERO, radius + 8.0, Color(0.08, 0.38, 1.0, 0.08))
	draw_circle(Vector2.ZERO, radius + 4.0, Color(0.12, 0.55, 1.0, 0.16))

	var outer_color = Color(0.2, 0.72, 1.0)
	var inner_color = Color(0.78, 0.94, 1.0)
	var core_color = Color.WHITE

	if is_piercing:
		outer_color = Color(0.28, 0.62, 1.0)
		inner_color = Color(0.72, 0.88, 1.0)

	if is_explosive:
		outer_color = Color(1.0, 0.18, 0.08)
		inner_color = Color(1.0, 0.58, 0.18)
		core_color = Color(1.0, 0.92, 0.72)

	draw_circle(Vector2.ZERO, radius, outer_color)
	draw_circle(Vector2(-1.0, -1.0), radius - 2.0, inner_color)
	draw_circle(Vector2(-2.5, -3.0), radius * 0.5, core_color)
	draw_circle(Vector2(-4.0, -5.0), radius * 0.2, Color(1.0, 1.0, 1.0, 0.95))

func _physics_process(delta):
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
