extends Node2D

const BURST_SCRIPT = preload("res://scenes/brick_burst.gd")

var previous_health: int = -1
var previous_barrier_hits: int = -1
var flash_time: float = 0.0

func _ready():
	var brick = get_parent()
	previous_health = int(brick.get("health"))
	previous_barrier_hits = int(brick.get("barrier_hits"))
	queue_redraw()

func _process(delta):
	var brick = get_parent()

	if brick == null:
		return

	var current_health = int(brick.get("health"))
	var current_barrier_hits = int(brick.get("barrier_hits"))
	var was_hit = current_health < previous_health or current_barrier_hits > previous_barrier_hits

	if was_hit:
		flash_time = 0.11
		queue_redraw()

	previous_health = current_health
	previous_barrier_hits = current_barrier_hits

	if flash_time > 0.0:
		flash_time = max(0.0, flash_time - delta)
		queue_redraw()

func _rounded_outline(rect: Rect2, color: Color, width: int, radius: int):
	var box = StyleBoxFlat.new()
	box.bg_color = Color(0, 0, 0, 0)
	box.border_color = color
	box.set_border_width_all(width)
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	draw_style_box(box, rect)

func _rounded_fill(rect: Rect2, color: Color, radius: int):
	var box = StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	draw_style_box(box, rect)

func _draw():
	var brick = get_parent()
	if brick == null:
		return

	var width_value = float(brick.get("width"))
	var height_value = float(brick.get("height"))
	var hw = width_value / 2.0
	var hh = height_value / 2.0
	var color = _get_effect_color(brick)
	var outer_alpha = 0.067

	for i in range(3):
		var expand = 2.0 + float(i) * 2.5
		var glow_rect = Rect2(Vector2(-hw - expand, -hh - expand), Vector2(width_value + expand * 2.0, height_value + expand * 2.0))
		_rounded_outline(glow_rect, Color(color, outer_alpha / float(i + 1)), 1 + i, 8 + i * 2)

	var edge_rect = Rect2(Vector2(-hw - 0.5, -hh - 0.5), Vector2(width_value + 1.0, height_value + 1.0))
	_rounded_outline(edge_rect, Color(color, 0.35), 1, 7)

	if flash_time > 0.0:
		var strength = flash_time / 0.11
		var flash_rect = Rect2(Vector2(-hw - 3.0, -hh - 3.0), Vector2(width_value + 6.0, height_value + 6.0))
		_rounded_outline(flash_rect, Color(color, strength * 0.33), 3, 10)
		_rounded_fill(Rect2(Vector2(-hw + 2.0, -hh + 2.0), Vector2(width_value - 4.0, height_value - 4.0)), Color(color, strength * 0.11), 5)
		draw_circle(Vector2.ZERO, 4.0 + (1.0 - strength) * 8.0, Color(color, strength * 0.24))

func _exit_tree():
	var brick = get_parent()
	if brick == null:
		return

	if not bool(brick.get("is_destroyed")):
		return

	var scene = get_tree().current_scene
	if scene == null:
		return

	var burst = Node2D.new()
	burst.set_script(BURST_SCRIPT)
	burst.global_position = brick.global_position
	scene.add_child.call_deferred(burst)
	burst.call_deferred("setup", _get_effect_color(brick))

func _get_effect_color(brick) -> Color:
	if bool(brick.get("indestructible")):
		return Color(1.0, 0.30, 0.055)
	var color_value = brick.get("glass_color")
	if color_value is Color:
		return color_value
	return Color(0.34, 0.76, 1.0)
