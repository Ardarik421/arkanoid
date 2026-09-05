extends CharacterBody2D

@export var speed: float = 700.0
@export var width: float = 160.0
@export var height: float = 24.0

@export var left_limit: float = 20.0
@export var right_limit: float = 940.0


func _ready():
	queue_redraw()


func _draw():
	var rect = Rect2(
		Vector2(-width / 2.0, -height / 2.0),
		Vector2(width, height)
	)

	draw_rect(rect, Color.WHITE)


func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		return
		
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	velocity.y = 0

	move_and_slide()

	var half_width = width / 2.0

	global_position.x = clamp(
		global_position.x,
		left_limit + half_width,
		right_limit - half_width
	)

var can_move: bool = true
