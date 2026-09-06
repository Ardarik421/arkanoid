extends Area2D

signal collected(bonus_type: BonusType)

enum BonusType {
	EXPAND_PADDLE,
	SHRINK_PADDLE,
	SLOW_BALL,
	FAST_BALL,
	EXTRA_LIFE
}

@export var bonus_type: BonusType = BonusType.EXPAND_PADDLE

@export var fall_speed: float = 250.0
@export var size: float = 20.0


func _ready():
	queue_redraw()
	body_entered.connect(_on_body_entered)

func _draw():
	var rect = Rect2(
		Vector2(-size / 2.0, -size / 2.0),
		Vector2(size, size)
	)

	draw_rect(rect, Color.WHITE)

func _process(delta):
	global_position.y += fall_speed * delta

	if global_position.y > 1100:
		queue_free()

func _on_body_entered(body):
	if body.name == "Paddle":
		collected.emit(bonus_type)
		queue_free()
