extends Area2D

class_name Bonus

signal collected(bonus_type: BonusType)

enum BonusType {
	EXPAND_PADDLE,
	SHRINK_PADDLE,
	EXTRA_LIFE,
	SLOW_BALL,
	FAST_BALL,
	SPLIT_BALLS,
	PIERCING_BALL,
	EXPLOSIVE_BALL,
	SHIELD,
	MAGNET
}

@export var bonus_type: BonusType = BonusType.EXPAND_PADDLE


@export var fall_speed: float = 250.0
@export var size: float = 28.0


func _ready():
	bonus_type = BonusType.values().pick_random()
	
	queue_redraw()
	body_entered.connect(_on_body_entered)

func _draw():
	var rect = Rect2(
		Vector2(-size / 2.0, -size / 2.0),
		Vector2(size, size)
	)

	var bonus_color = Color.WHITE
	var bonus_text = ""

	match bonus_type:
		BonusType.EXPAND_PADDLE:
			bonus_color = Color.WHITE
			bonus_text = "+W"

		BonusType.SHRINK_PADDLE:
			bonus_color = Color(0.5, 0.5, 0.5)
			bonus_text = "-W"

		BonusType.EXTRA_LIFE:
			bonus_color = Color(0.8, 0.8, 0.8)
			bonus_text = "+1"

		BonusType.SLOW_BALL:
			bonus_color = Color(0.65, 0.65, 0.65)
			bonus_text = "S"

		BonusType.FAST_BALL:
			bonus_color = Color(0.6, 0.3, 0.3)
			bonus_text = "F"

		BonusType.SPLIT_BALLS:
			bonus_color = Color(0.0, 0.8, 1.0)
			bonus_text = "x2"
		
		BonusType.PIERCING_BALL:
			bonus_color = Color(0.8, 0.6, 0.2)
			bonus_text = "P"
		
		BonusType.EXPLOSIVE_BALL:
			bonus_color = Color(1.0, 0.2, 0.1)
			bonus_text = "E"
		
		BonusType.SHIELD:
			bonus_color = Color(0.2, 0.6, 1.0)
			bonus_text = "B"
		
		BonusType.MAGNET:
			bonus_color = Color(0.7, 0.2, 0.9)
			bonus_text = "M"

	draw_rect(rect, bonus_color)

	var font = ThemeDB.fallback_font
	var font_size = 12

	var text_size = font.get_string_size(
		bonus_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size
	)

	var text_position = Vector2(
		-text_size.x / 2.0,
		text_size.y / 2.0
	)

	draw_string(
		font,
		text_position,
		bonus_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		Color.BLACK
	)

func _process(delta):
	global_position.y += fall_speed * delta

	if global_position.y > 1100:
		queue_free()

func _on_body_entered(body):
	if body.name == "Paddle":
		collected.emit(bonus_type)
		queue_free()
