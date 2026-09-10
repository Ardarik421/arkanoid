extends Node2D

const BURST_SCRIPT = preload("res://scenes/brick_burst.gd")

var previous_health: int = -1
var previous_barrier_hits: int = -1
var flash_time: float = 0.0
var pulse_time: float = 0.0

func _ready():
	var brick = get_parent()
	previous_health = int(brick.get("health"))
	previous_barrier_hits = int(brick.get("barrier_hits"))
	queue_redraw()

func _process(delta):
	pulse_time += delta
	var brick = get_parent()

	if brick == null:
		return

	var current_health = int(brick.get("health"))
	var current_barrier_hits = int(brick.get("barrier_hits"))

	if current_health < previous_health or current_barrier_hits > previous_barrier_hits:
		flash_time = 0.11

	previous_health = current_health
	previous_barrier_hits = current_barrier_hits

	if flash_time > 0.0:
		flash_time = max(0.0, flash_time - delta)

	queue_redraw()

func _draw():
	var brick = get_parent()
	if brick == null:
		return

	var width_value = float(brick.get("width"))
	var height_value = float(brick.get("height"))
	var hw = width_value / 2.0
	var hh = height_value / 2.0
	var color = _get_effect_color(brick)
	var pulse = 0.5 + sin(pulse_time * 2.2) * 0.5
	var outer_alpha = 0.07 + pulse * 0.025

	for i in range(3):
		var expand = 2.0 + float(i) * 2.5
		var glow_rect = Rect2(Vector2(-hw - expand, -hh - expand), Vector2(width_value + expand * 2.0, height_value + expand * 2.0))
		draw_rect(glow_rect, Color(color, outer_alpha / float(i + 1)), false, 1.5 + float(i) * 0.6)

	var edge_rect = Rect2(Vector2(-hw - 0.5, -hh - 0.5), Vector2(width_value + 1.0, height_value + 1.0))
	draw_rect(edge_rect, Color(color, 0.44 + pulse * 0.10), false, 1.15)

	if flash_time > 0.0:
		var strength = flash_time / 0.11
		var flash_rect = Rect2(Vector2(-hw - 3.0, -hh - 3.0), Vector2(width_value + 6.0, height_value + 6.0))
		draw_rect(flash_rect, Color(color, strength * 0.33), false, 3.5)
		draw_rect(Rect2(Vector2(-hw + 2.0, -hh + 2.0), Vector2(width_value - 4.0, height_value - 4.0)), Color(1.0, 0.96, 0.88, strength * 0.16))
		draw_circle(Vector2.ZERO, 4.0 + (1.0 - strength) * 8.0, Color(1.0, 0.93, 0.76, strength * 0.30))

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
	if bool(brick.get("powerful_bonus")):
		return Color(1.0, 0.22, 0.06)
	if bool(brick.get("guaranteed_bonus")):
		return Color(1.0, 0.70, 0.10)
	if bool(brick.get("indestructible")):
		return Color(0.36, 0.78, 1.0)
	if int(brick.get("max_health")) >= 3:
		return Color(0.30, 0.78, 1.0)
	if int(brick.get("max_health")) == 2:
		return Color(0.42, 0.75, 1.0)
	return Color(0.28, 0.66, 1.0)
