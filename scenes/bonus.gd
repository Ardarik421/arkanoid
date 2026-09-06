extends Area2D

class_name Bonus

signal collected(bonus_type: BonusType)

enum BonusType {
	EXPAND_PADDLE,
	SHRINK_PADDLE,
	EXTRA_LIFE,
	SLOW_BALL,
	FAST_BALL
}

@export var bonus_type: BonusType = BonusType.EXPAND_PADDLE

@export var fall_speed: float = 250.0
@export var size: float = 20.0


func _ready():
	bonus_type = BonusType.values().pick_random()
	
	queue_redraw()
	body_entered.connect(_on_body_entered)

func _draw():
	var rect = Rect2(
		Vector2(-size / 2.0, -size / 2.0),
		Vector2(size, size)
	)

	match bonus_type:
		BonusType.EXPAND_PADDLE:
			draw_rect(rect, Color.WHITE)

		BonusType.SHRINK_PADDLE:
			draw_rect(rect, Color(0.5, 0.5, 0.5))
			
		BonusType.EXTRA_LIFE:
			draw_rect(rect, Color(0.8, 0.8, 0.8))
		
		BonusType.SLOW_BALL:
			draw_rect(rect, Color(0.65, 0.65, 0.65))

		BonusType.FAST_BALL:
			draw_rect(rect, Color(0.3, 0.3, 0.3))

func _process(delta):
	global_position.y += fall_speed * delta

	if global_position.y > 1100:
		queue_free()

func _on_body_entered(body):
	if body.name == "Paddle":
		collected.emit(bonus_type)
		queue_free()
