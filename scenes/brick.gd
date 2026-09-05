extends StaticBody2D

signal destroyed(points: int)

@export var width: float = 70.0
@export var height: float = 30.0

@export var health: int = 1
@export var max_health: int = 1
@export var points: int = 100

func _ready():
	queue_redraw()

func _draw():
	var rect = Rect2(
		Vector2(-width / 2.0, -height / 2.0),
		Vector2(width, height)
	)

	if max_health == 1:
		draw_rect(rect, Color.WHITE)
	elif health == max_health:
		draw_rect(rect, Color(0.45, 0.45, 0.45))
	else:
		draw_rect(rect, Color(0.75, 0.75, 0.75))

func hit():
	health -= 1

	if health <= 0:
		destroyed.emit(points)
		queue_free()
	else:
		queue_redraw()
