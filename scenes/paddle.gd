extends CharacterBody2D

@export var speed: float = 700.0
@export var width: float = 160.0
@export var height: float = 24.0

@export var left_limit: float = 20.0
@export var right_limit: float = 940.0
@export var mouse_speed: float = 1800.0

var can_move: bool = true
var use_mouse_control: bool = false
var fixed_y: float

func _ready():
	fixed_y = global_position.y
	queue_redraw()

func _draw():
	var rect = Rect2(
		Vector2(-width / 2.0, -height / 2.0),
		Vector2(width, height)
	)

	draw_rect(rect, Color.WHITE)

func _input(event):
	if event is InputEventMouseMotion:
		use_mouse_control = true

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		return

	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		use_mouse_control = false
		velocity.x = direction * speed
		velocity.y = 0
		move_and_slide()

	elif use_mouse_control:
		var target_x = get_global_mouse_position().x
		var distance = target_x - global_position.x

		velocity.x = clamp(
			distance / delta,
			-mouse_speed,
			mouse_speed
		)

		velocity.y = 0
		move_and_slide()

	else:
		velocity = Vector2.ZERO

	var half_width = width / 2.0
	global_position.x = clamp(
		global_position.x,
		left_limit + half_width,
		right_limit - half_width
	)

	global_position.y = fixed_y
	velocity.y = 0.0

func set_width(new_width: float):
	width = new_width

	var shape = $CollisionShape2D.shape

	if shape is RectangleShape2D:
		shape.size.x = width

	queue_redraw()
