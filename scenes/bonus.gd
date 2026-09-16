extends Area2D

class_name Bonus

signal collected(bonus_type: BonusType)

const PICKUP_SOUND: AudioStream = preload("res://audio/sfx/bonus_pickup.wav")

enum BonusType {
	EXPAND_PADDLE,
	SHRINK_PADDLE,
	EXTRA_LIFE,
	HYPER_BALL,
	FAST_BALL,
	SPLIT_BALLS,
	PIERCING_BALL,
	EXPLOSIVE_BALL,
	SHIELD,
	MAGNET
}

enum DropPool {
	ANY,
	UTILITY,
	POWERFUL
}

@export var bonus_type: BonusType = BonusType.EXPAND_PADDLE
@export var fall_speed: float = 250.0
@export var size: float = 28.0

static var next_drop_pool: DropPool = DropPool.ANY
var forced_bonus_type: int = -1
var visual_time: float = 0.0

func _ready():
	if forced_bonus_type >= 0:
		bonus_type = forced_bonus_type as BonusType
	else:
		match next_drop_pool:
			DropPool.UTILITY:
				bonus_type = [
					BonusType.EXPAND_PADDLE,
					BonusType.EXTRA_LIFE,
					BonusType.HYPER_BALL,
					BonusType.FAST_BALL,
					BonusType.SHIELD,
					BonusType.MAGNET
				].pick_random()

			DropPool.POWERFUL:
				bonus_type = [
					BonusType.PIERCING_BALL,
					BonusType.EXPLOSIVE_BALL,
					BonusType.SPLIT_BALLS
				].pick_random()

			DropPool.ANY:
				var bonus_pool = [
					BonusType.EXPAND_PADDLE,
					BonusType.EXPAND_PADDLE,
					BonusType.EXPAND_PADDLE,
					BonusType.EXPAND_PADDLE,
					BonusType.SHRINK_PADDLE,
					BonusType.SHRINK_PADDLE,
					BonusType.SHRINK_PADDLE,
					BonusType.HYPER_BALL,
					BonusType.HYPER_BALL,
					BonusType.HYPER_BALL,
					BonusType.FAST_BALL,
					BonusType.FAST_BALL,
					BonusType.FAST_BALL,
					BonusType.SHIELD,
					BonusType.SHIELD,
					BonusType.SHIELD,
					BonusType.MAGNET,
					BonusType.MAGNET,
					BonusType.MAGNET,
					BonusType.EXTRA_LIFE,
					BonusType.EXTRA_LIFE,
					BonusType.SPLIT_BALLS,
					BonusType.SPLIT_BALLS,
					BonusType.PIERCING_BALL,
					BonusType.EXPLOSIVE_BALL
				]
				bonus_type = bonus_pool.pick_random()

	next_drop_pool = DropPool.ANY
	queue_redraw()
	body_entered.connect(_on_body_entered)

func _draw():
	var pulse = 0.5 + 0.5 * sin(visual_time * 4.0)
	var accent = _get_bonus_color()
	var half = size / 2.0
	var outer = Rect2(Vector2(-half, -half), Vector2(size, size))
	var middle = outer.grow(-2.0)
	var inner = outer.grow(-4.0)

	draw_circle(Vector2.ZERO, half + 5.0 + pulse * 1.5, Color(accent, 0.045 + pulse * 0.025))
	draw_circle(Vector2.ZERO, half + 2.5, Color(accent, 0.06))
	draw_rect(outer, Color(0.008, 0.015, 0.027))
	draw_rect(middle, Color(0.045, 0.065, 0.09))
	draw_rect(inner, Color(0.08, 0.105, 0.14))
	draw_rect(outer, Color(accent, 0.45 + pulse * 0.15), false, 1.4)
	draw_rect(middle, Color(accent, 0.22), false, 1.0)

	for side in [-1.0, 1.0]:
		draw_line(Vector2(side * (half - 2.0), -half + 5.0), Vector2(side * (half - 2.0), half - 5.0), Color(accent, 0.72), 1.0, true)

	_draw_bonus_icon(accent)

func _get_bonus_color() -> Color:
	match bonus_type:
		BonusType.EXPAND_PADDLE:
			return Color(0.30, 0.82, 1.0)
		BonusType.SHRINK_PADDLE:
			return Color(0.58, 0.60, 0.76)
		BonusType.EXTRA_LIFE:
			return Color(0.35, 1.0, 0.62)
		BonusType.HYPER_BALL:
			return Color(0.82, 0.36, 1.0)
		BonusType.FAST_BALL:
			return Color(1.0, 0.62, 0.16)
		BonusType.SPLIT_BALLS:
			return Color(0.18, 0.90, 1.0)
		BonusType.PIERCING_BALL:
			return Color(1.0, 0.82, 0.22)
		BonusType.EXPLOSIVE_BALL:
			return Color(1.0, 0.23, 0.08)
		BonusType.SHIELD:
			return Color(0.20, 0.58, 1.0)
		BonusType.MAGNET:
			return Color(0.92, 0.24, 0.96)
	return Color.WHITE

func _draw_bonus_icon(accent: Color):
	var bright = Color(0.88, 0.97, 1.0)
	var glow = Color(accent, 0.65)

	match bonus_type:
		BonusType.EXPAND_PADDLE:
			draw_line(Vector2(-7, 0), Vector2(7, 0), bright, 2.0, true)
			draw_polyline(PackedVector2Array([Vector2(-4, -4), Vector2(-8, 0), Vector2(-4, 4)]), glow, 2.0, true)
			draw_polyline(PackedVector2Array([Vector2(4, -4), Vector2(8, 0), Vector2(4, 4)]), glow, 2.0, true)
			draw_circle(Vector2.ZERO, 2.0, Color(accent, 0.9))

		BonusType.SHRINK_PADDLE:
			draw_line(Vector2(-7, 0), Vector2(7, 0), bright, 2.0, true)
			draw_polyline(PackedVector2Array([Vector2(-8, -4), Vector2(-4, 0), Vector2(-8, 4)]), glow, 2.0, true)
			draw_polyline(PackedVector2Array([Vector2(8, -4), Vector2(4, 0), Vector2(8, 4)]), glow, 2.0, true)
			draw_circle(Vector2.ZERO, 1.8, Color(accent, 0.85))

		BonusType.EXTRA_LIFE:
			draw_circle(Vector2(-3.2, -2.0), 4.0, Color(accent, 0.78))
			draw_circle(Vector2(3.2, -2.0), 4.0, Color(accent, 0.78))
			draw_colored_polygon(PackedVector2Array([Vector2(-7, -1), Vector2(7, -1), Vector2(0, 8)]), Color(accent, 0.78))
			draw_line(Vector2(0, -4), Vector2(0, 5), bright, 1.6, true)
			draw_line(Vector2(-4, 0), Vector2(4, 0), bright, 1.6, true)

		BonusType.HYPER_BALL:
			for x in [-7.0, -1.0, 5.0]:
				draw_polyline(PackedVector2Array([Vector2(x - 3, -6), Vector2(x + 2, 0), Vector2(x - 3, 6)]), glow, 2.2, true)
			draw_line(Vector2(-10, 0), Vector2(9, 0), Color(bright, 0.82), 1.0, true)

		BonusType.FAST_BALL:
			for x in [-5.0, 1.0]:
				draw_polyline(PackedVector2Array([Vector2(x - 3, -6), Vector2(x + 2, 0), Vector2(x - 3, 6)]), glow, 2.2, true)
			draw_line(Vector2(-8, 0), Vector2(8, 0), Color(bright, 0.75), 1.0, true)

		BonusType.SPLIT_BALLS:
			draw_circle(Vector2(-4.5, 2.0), 4.0, Color(accent, 0.70))
			draw_circle(Vector2(4.5, -2.0), 4.0, Color(accent, 0.90))
			draw_circle(Vector2(-4.5, 2.0), 2.0, bright)
			draw_circle(Vector2(4.5, -2.0), 2.0, bright)
			draw_line(Vector2(-1.5, -4), Vector2(1.5, 4), Color(accent, 0.7), 1.2, true)

		BonusType.PIERCING_BALL:
			var tip = PackedVector2Array([Vector2(0, -9), Vector2(5, -1), Vector2(2, 8), Vector2(0, 5), Vector2(-2, 8), Vector2(-5, -1)])
			draw_colored_polygon(tip, Color(accent, 0.70))
			draw_polyline(PackedVector2Array([tip[0], tip[1], tip[2], tip[3], tip[4], tip[5], tip[0]]), bright, 1.1, true)
			draw_line(Vector2(0, -6), Vector2(0, 6), bright, 1.4, true)

		BonusType.EXPLOSIVE_BALL:
			for i in range(8):
				var angle = TAU * float(i) / 8.0
				var start = Vector2(cos(angle), sin(angle)) * 4.0
				var finish = Vector2(cos(angle), sin(angle)) * (8.0 if i % 2 == 0 else 6.5)
				draw_line(start, finish, glow, 1.5, true)
			draw_circle(Vector2.ZERO, 4.3, Color(accent, 0.86))
			draw_circle(Vector2(-1.2, -1.2), 1.6, Color(1.0, 0.94, 0.72))

		BonusType.SHIELD:
			var shield = PackedVector2Array([Vector2(0, -9), Vector2(7, -6), Vector2(6, 2), Vector2(0, 9), Vector2(-6, 2), Vector2(-7, -6)])
			draw_colored_polygon(shield, Color(accent, 0.38))
			draw_polyline(PackedVector2Array([shield[0], shield[1], shield[2], shield[3], shield[4], shield[5], shield[0]]), bright, 1.5, true)
			draw_line(Vector2(0, -6), Vector2(0, 5), Color(accent, 0.9), 1.2, true)

		BonusType.MAGNET:
			draw_arc(Vector2.ZERO, 7.0, 0.0, PI, 20, glow, 3.0, true)
			draw_line(Vector2(-7, 0), Vector2(-7, -6), bright, 2.5, true)
			draw_line(Vector2(7, 0), Vector2(7, -6), bright, 2.5, true)
			draw_line(Vector2(-7, -6), Vector2(-3, -6), Color(accent, 0.9), 2.5, true)
			draw_line(Vector2(3, -6), Vector2(7, -6), Color(accent, 0.9), 2.5, true)

func _process(delta):
	visual_time += delta
	global_position.y += fall_speed * delta
	queue_redraw()

	if global_position.y > 1100:
		queue_free()

func _spawn_collect_feedback(body):
	var flash_script = load("res://scenes/bonus_collect_flash.gd")
	if flash_script == null:
		return

	var flash = Node2D.new()
	flash.set_script(flash_script)
	body.get_parent().add_child(flash)
	flash.global_position = Vector2(global_position.x, body.global_position.y - 10.0)
	if flash.has_method("setup"):
		flash.setup(_get_bonus_color())

	if body.has_method("play_bonus_feedback"):
		body.play_bonus_feedback(_get_bonus_color())

func _play_pickup_sound():
	var player = AudioStreamPlayer.new()
	player.stream = PICKUP_SOUND
	player.volume_db = -4.0
	player.bus = "SFX"
	get_parent().add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func _on_body_entered(body):
	if body.name == "Paddle":
		_spawn_collect_feedback(body)
		_play_pickup_sound()
		collected.emit(bonus_type)
		queue_free()
