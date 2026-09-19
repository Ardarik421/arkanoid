extends CharacterBody2D

@export var speed: float = 700.0
@export var width: float = 160.0
@export var height: float = 24.0

@export var left_limit: float = 20.0
@export var right_limit: float = 940.0
@export var mouse_speed: float = 1800.0

var can_move: bool = true
var use_mouse_control: bool = false
var last_mouse_x: float = NAN
var fixed_y: float
var animation_time: float = 0.0
var hit_feedback: float = 0.0
var bonus_feedback: float = 0.0
var bonus_feedback_color: Color = Color(0.30, 0.82, 1.0)
var life_loss_feedback: float = 0.0

func _ready():
	fixed_y = global_position.y
	# Mouse control must be available immediately after entering a level.
	# Depending on the display mode, the initial mouse position can already be
	# inside the viewport, so no MouseMotion event is guaranteed before launch.
	use_mouse_control = true
	last_mouse_x = get_global_mouse_position().x
	queue_redraw()

func _process(delta):
	animation_time += delta
	hit_feedback = move_toward(hit_feedback, 0.0, delta * 8.0)
	bonus_feedback = move_toward(bonus_feedback, 0.0, delta * 4.8)
	life_loss_feedback = move_toward(life_loss_feedback, 0.0, delta * 3.6)
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
	var impact = hit_feedback * hit_feedback
	var bonus_glow = bonus_feedback * bonus_feedback
	var damage_glow = life_loss_feedback * life_loss_feedback

	_rounded_box(Rect2(Vector2(-hw - 4.0, -hh - 4.0), Vector2(visual_width + 8.0, visual_height + 8.0)), Color(0, 0, 0, 0), Color(0.08, 0.62, 1.0, 0.055 * pulse + 0.12 * impact), 2.0, 13)
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

	_draw_life_cores(hw, pulse)

	draw_line(Vector2(-hw + 13.0, -hh + 2.5), Vector2(hw - 13.0, -hh + 2.5), Color(0.76, 0.96, 1.0, 0.78 + 0.22 * impact), 1.6 + 1.2 * impact, true)
	draw_line(Vector2(-hw + 18.0, -hh + 5.0), Vector2(hw - 30.0, -hh + 5.0), Color(1.0, 1.0, 1.0, 0.18 + 0.32 * impact), 0.8 + 0.8 * impact, true)
	draw_line(Vector2(-hw + 17.0, hh - 3.0), Vector2(hw - 17.0, hh - 3.0), Color(0.08, 0.48, 0.82, 0.30), 1.0, true)

	if impact > 0.01:
		var wave_half_width = lerp(hw * 0.22, hw * 0.94, 1.0 - hit_feedback)
		var wave_alpha = 0.46 * impact
		draw_line(Vector2(-wave_half_width, -hh - 1.0), Vector2(wave_half_width, -hh - 1.0), Color(0.76, 0.97, 1.0, wave_alpha), 2.2, true)
		draw_line(Vector2(-wave_half_width, -hh - 4.0), Vector2(wave_half_width, -hh - 4.0), Color(0.12, 0.68, 1.0, wave_alpha * 0.32), 4.5, true)

	if bonus_glow > 0.01:
		var bonus_width = lerp(hw * 0.20, hw * 0.92, 1.0 - bonus_feedback)
		draw_line(Vector2(-bonus_width, -hh - 2.0), Vector2(bonus_width, -hh - 2.0), Color(bonus_feedback_color, 0.72 * bonus_glow), 3.0, true)
		draw_line(Vector2(-bonus_width, 0.0), Vector2(bonus_width, 0.0), Color(bonus_feedback_color, 0.28 * bonus_glow), 6.0, true)
		draw_circle(Vector2.ZERO, 7.0 + 8.0 * (1.0 - bonus_feedback), Color(bonus_feedback_color, 0.20 * bonus_glow))

	if damage_glow > 0.01:
		var alarm = 0.55 + 0.45 * sin(animation_time * 28.0)
		_rounded_box(Rect2(Vector2(-hw - 5.0, -hh - 5.0), Vector2(visual_width + 10.0, visual_height + 10.0)), Color(0, 0, 0, 0), Color(1.0, 0.08, 0.025, damage_glow * (0.30 + alarm * 0.42)), 3.0, 14)
		draw_line(Vector2(-hw + 10.0, -hh + 1.0), Vector2(hw - 10.0, -hh + 1.0), Color(1.0, 0.36, 0.08, damage_glow * 0.82), 3.0, true)
		draw_line(Vector2(-hw + 18.0, 1.0), Vector2(hw - 18.0, 1.0), Color(1.0, 0.06, 0.02, damage_glow * 0.38), 7.0, true)

	var cap_width = 13.0
	for side in [-1.0, 1.0]:
		var cap_center = side * (hw - cap_width * 0.55)
		var cap_rect = Rect2(Vector2(cap_center - cap_width * 0.5, -hh + 4.0), Vector2(cap_width, visual_height - 8.0))
		_rounded_box(cap_rect, Color(0.035, 0.055, 0.075, 0.92), Color(0.48, 0.86, 1.0, 0.64), 1.0, 6)
		draw_circle(Vector2(cap_center, 0.0), 2.0, Color(0.30, 0.82, 1.0, 0.52 * pulse))

func _draw_life_cores(hw: float, pulse: float):
	var main = get_parent()
	if main == null:
		return

	var life_count = int(main.get("lives"))
	if life_count <= 0:
		return

	var available_width = max(28.0, hw * 2.0 - 76.0)
	var spacing = min(17.0, available_width / max(1.0, float(life_count)))
	var radius = clamp(spacing * 0.26, 2.4, 4.2)
	var total_width = spacing * float(life_count - 1)
	var start_x = -total_width * 0.5

	for i in range(life_count):
		var center = Vector2(start_x + spacing * float(i), 1.0)
		draw_circle(center, radius + 3.5, Color(0.08, 0.58, 1.0, 0.07 * pulse))
		draw_circle(center, radius + 1.5, Color(0.16, 0.72, 1.0, 0.15))
		draw_circle(center, radius, Color(0.72, 0.95, 1.0, 0.90))
		draw_circle(center + Vector2(-radius * 0.28, -radius * 0.28), max(0.8, radius * 0.28), Color(1.0, 1.0, 1.0, 0.92))

func _input(event):
	if event is InputEventMouseMotion:
		use_mouse_control = true

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		return

	# Detect mouse movement from its actual viewport position as well as _input().
	# This avoids depending on an initial MouseMotion event after a portrait window resize.
	var current_mouse_x := get_global_mouse_position().x
	if is_nan(last_mouse_x) or abs(current_mouse_x - last_mouse_x) > 0.1:
		use_mouse_control = true
	last_mouse_x = current_mouse_x

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

func configure_horizontal_limits(new_left_limit: float, new_right_limit: float) -> void:
	left_limit = new_left_limit
	right_limit = new_right_limit

func set_fixed_y(new_y: float) -> void:
	fixed_y = new_y
	global_position.y = new_y

func set_width(new_width: float):
	width = new_width

	var shape = $CollisionShape2D.shape

	if shape is RectangleShape2D:
		shape.size.x = width

	queue_redraw()

func play_hit_feedback():
	hit_feedback = 1.0
	queue_redraw()

func play_bonus_feedback(effect_color: Color):
	bonus_feedback_color = effect_color
	bonus_feedback = 1.0
	queue_redraw()

func play_life_loss_feedback():
	life_loss_feedback = 1.0
	queue_redraw()
