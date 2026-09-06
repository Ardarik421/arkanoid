extends CharacterBody2D

@export var speed: float = 450.0
@export var radius: float = 12.0
@export var max_bounce_angle: float = 50.0

var direction := Vector2(0.7, -1.0).normalized()
var is_attached: bool = true
var is_piercing: bool = false
var is_explosive: bool = false

func _ready():
	queue_redraw()

func _draw():
	var ball_color = Color.WHITE

	if is_piercing:
		ball_color = Color(1.0, 0.45, 0.1)

	draw_circle(Vector2.ZERO, radius, ball_color)

func _physics_process(delta):
	if is_attached:
		return

	var collision = move_and_collide(direction * speed * delta)

	if collision:
		var collider = collision.get_collider()

		if collider.name == "Paddle":
			bounce_from_paddle(collider)

		elif collider.has_method("hit"):
			if is_piercing and not collider.indestructible:
				collider.destroy(is_explosive)
			else:
				direction = direction.bounce(collision.get_normal())
				collider.hit(is_explosive)

		else:
			direction = direction.bounce(collision.get_normal())

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

func launch():
	is_attached = false

	var horizontal = randf_range(0.45, 0.75)

	if randf() < 0.5:
		horizontal *= -1.0

	direction = Vector2(
		horizontal,
		-1.0
	).normalized()
