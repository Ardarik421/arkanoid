extends StaticBody2D

signal destroyed(points: int, brick_position: Vector2, guaranteed_bonus: bool)
signal exploded(brick_position: Vector2)

@export var width: float = 70.0
@export var height: float = 30.0

@export var health: int = 1
@export var max_health: int = 1
@export var points: int = 100
@export var indestructible: bool = false
var guaranteed_bonus: bool = false

const BONUS_BRICK_CHANCE: float = 0.10

var is_destroyed: bool = false

func _ready():
	if not indestructible:
		guaranteed_bonus = randf() < BONUS_BRICK_CHANCE

	queue_redraw()

func _draw():
	var rect = Rect2(
		Vector2(-width / 2.0, -height / 2.0),
		Vector2(width, height)
	)

	if indestructible:
		draw_rect(rect, Color(0.15, 0.15, 0.15))
		return

	if max_health == 1:
		draw_rect(rect, Color.WHITE)

	elif max_health == 2:
		if health == 2:
			draw_rect(rect, Color(0.45, 0.45, 0.45))
		else:
			draw_rect(rect, Color(0.75, 0.75, 0.75))

	elif max_health == 3:
		if health == 3:
			draw_rect(rect, Color(0.25, 0.25, 0.25))
		elif health == 2:
			draw_rect(rect, Color(0.50, 0.50, 0.50))
		else:
			draw_rect(rect, Color(0.80, 0.80, 0.80))

	if guaranteed_bonus:
		draw_rect(rect, Color(1.0, 0.75, 0.15), false, 4.0)

func hit(explosive_hit: bool = false):
	if indestructible or is_destroyed:
		return

	health -= 1

	if health <= 0:
		is_destroyed = true

		destroyed.emit(points, global_position, guaranteed_bonus)

		if explosive_hit:
			exploded.emit(global_position)

		queue_free()
	else:
		queue_redraw()

func destroy(explosive_hit: bool = false):
	if indestructible or is_destroyed:
		return

	is_destroyed = true

	destroyed.emit(points, global_position, guaranteed_bonus)

	if explosive_hit:
		exploded.emit(global_position)

	queue_free()
