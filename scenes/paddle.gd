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
var animation_time: float = 0.0

func _ready():
	fixed_y = global_position.y
	queue_redraw()

func _process(delta):
	animation_time += delta
	queue_redraw()

func _rounded_box(rect: Rect2, fill: Color, border: Color, border_width: float, radius: int):
	var box = StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(int(border_width))
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	draw_style_box(box, rect)

func _draw():
	var visual_width = width + 18.0
	var visual_height = 30.0
	var hw = visual_width * 0.5
	var hh = visual_height * 0.5
	var pulse = 0.86 + 0.14 * sin(animation_time * 2.0)
	var flow = fmod(animation_time * 34.0, max(1.0, visual_width - 42.0))

	_rounded_box(Rect2(Vector2(-hw - 4.0, -hh - 4.0), Vector2(visual_width + 8.0, visual_height + 8.0)), Color(0, 0, 0, 0), Color(0.08, 0.62, 1.0, 0.055 * pulse), 2.0, 13)
	_rounded_box(Rect2(Vector2(-hw, -hh), Vector2(visual_width, visual_height)), Color(0.006, 0.018, 0.034, 0.82), Color(0.18, 0.76, 1.0, 0.92), 2.0, 11)
	_rounded_box(Rect2(Vector2(-hw + 3.0, -hh + 3.0), Vector2(visual_width - 6.0, visual_height - 6.0)), Color(0.02, 0.12, 0.19, 0.20), Color(0.70, 0.94, 1.0, 0.18), 1.0, 8)

	var core_rect = Rect2(Vector2(-hw + 15.0, -hh + 7.0), Vector2(visual_width - 30.0, visual_height - 14.0))
	_rounded_box(core_rect, Color(0.002, 0.010, 0.024, 0.72), Color(0.08, 0.50, 0.82, 0.20), 1.0, 5)

	for i in range(5):
		var t = float(i) / 4.0
		var y = lerp(-4.5, 5.0, t)
		var alpha = (0.055 - t * 0.008) * pulse
		draw_line(Vector2(-hw + 23.0, y), Vector2(hw - 23.0, y), Color(0.10, 0.62, 1.0, alpha), 1.0, true)

	var flow_x = -hw + 21.0 + flow
	for i in range(3):
		var offset = float(i) * 7.0
		var x = flow_x - offset
		if x > hw - 21.0:
			x -= visual_width - 42.0
		draw_circle(Vector2(x, 0.5), 2.7 - float(i) * 0.55, Color(0.36, 0.86, 1.0, (0.24 - float(i) * 0.055) * pulse))

	for i in range(3):
		var spread = 16.0 + float(i) * 5.0
		draw_line(Vector2(-spread, -2.0), Vector2(spread, -2.0), Color(0.20, 0.76, 1.0, (0.12 - float(i) * 0.025) * pulse), 3.0 + float(2 - i), true)

	draw_line(Vector2(-hw + 13.0, -hh + 2.5), Vector2(hw - 13.0, -hh + 2.5), Color(0.76, 0.96, 1.0, 0.78), 1.6, true)
	draw_line(Vector2(-hw + 18.0, -hh + 5.0), Vector2(hw - 30.0, -hh + 5.0), Color(1.0, 1.0, 1.0, 0.18), 0.8, true)
	draw_line(Vector2(-hw + 17.0, hh - 3.0), Vector2(hw - 17.0, hh - 3.0), Color(0.08, 0.48, 0.82, 0.30), 1.0, true)

	var cap_width = 13.0
	for side in [-1.0, 1.0]:
		var cap_center = side * (hw - cap_width * 0.55)
		var cap_rect = Rect2(Vector2(cap_center - cap_width * 0.5, -hh + 4.0), Vector2(cap_width, visual_height - 8.0))
		_rounded_box(cap_rect, Color(0.035, 0.055, 0.075, 0.92), Color(0.48, 0.86, 1.0, 0.64), 1.0, 6)
		draw_circle(Vector2(cap_center, 0.0), 2.0, Color(0.30, 0.82, 1.0, 0.52 * pulse))

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
