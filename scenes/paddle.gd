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
	var half_width = width / 2.0
	var half_height = height / 2.0
	var corner = min(10.0, width * 0.08)

	var glow_points = PackedVector2Array([
		Vector2(-half_width + corner, -half_height - 3.0),
		Vector2(half_width - corner, -half_height - 3.0),
		Vector2(half_width + 4.0, -half_height + 5.0),
		Vector2(half_width + 4.0, half_height - 3.0),
		Vector2(half_width - corner, half_height + 3.0),
		Vector2(-half_width + corner, half_height + 3.0),
		Vector2(-half_width - 4.0, half_height - 3.0),
		Vector2(-half_width - 4.0, -half_height + 5.0)
	])
	draw_colored_polygon(glow_points, Color(0.08, 0.55, 1.0, 0.16))

	var body_points = PackedVector2Array([
		Vector2(-half_width + corner, -half_height),
		Vector2(half_width - corner, -half_height),
		Vector2(half_width, -half_height + 6.0),
		Vector2(half_width - 4.0, half_height - 2.0),
		Vector2(half_width - 14.0, half_height),
		Vector2(-half_width + 14.0, half_height),
		Vector2(-half_width + 4.0, half_height - 2.0),
		Vector2(-half_width, -half_height + 6.0)
	])
	draw_colored_polygon(body_points, Color(0.055, 0.075, 0.11))

	var outline_points = PackedVector2Array(body_points)
	outline_points.append(body_points[0])
	draw_polyline(outline_points, Color(0.33, 0.48, 0.64), 2.0, true)

	var inner_margin = min(22.0, width * 0.16)
	var inner_points = PackedVector2Array([
		Vector2(-half_width + inner_margin, -half_height + 5.0),
		Vector2(half_width - inner_margin, -half_height + 5.0),
		Vector2(half_width - inner_margin - 7.0, half_height - 5.0),
		Vector2(-half_width + inner_margin + 7.0, half_height - 5.0)
	])
	draw_colored_polygon(inner_points, Color(0.11, 0.16, 0.23))

	var core_width = min(72.0, width * 0.56)
	var core_outer = Rect2(Vector2(-core_width / 2.0, -7.0), Vector2(core_width, 10.0))
	var core_inner = Rect2(Vector2(-core_width / 2.0 + 5.0, -5.0), Vector2(core_width - 10.0, 5.0))
	draw_rect(core_outer, Color(0.08, 0.37, 0.68, 0.85))
	draw_rect(core_inner, Color(0.72, 0.93, 1.0))
	draw_line(Vector2(-core_width / 2.0 + 7.0, -3.5), Vector2(core_width / 2.0 - 7.0, -3.5), Color.WHITE, 1.5, true)

	var wing_length = max(12.0, (width - core_width) / 2.0 - 8.0)
	var left_start = -core_width / 2.0 - 5.0
	var right_start = core_width / 2.0 + 5.0

	draw_line(Vector2(left_start, -1.0), Vector2(left_start - wing_length, 3.0), Color(0.16, 0.5, 0.86), 3.0, true)
	draw_line(Vector2(right_start, -1.0), Vector2(right_start + wing_length, 3.0), Color(0.16, 0.5, 0.86), 3.0, true)

	draw_circle(Vector2(-half_width + 12.0, 2.0), 3.5, Color(0.22, 0.76, 1.0))
	draw_circle(Vector2(half_width - 12.0, 2.0), 3.5, Color(0.22, 0.76, 1.0))

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
