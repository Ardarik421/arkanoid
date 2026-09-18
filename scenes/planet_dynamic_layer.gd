extends Node2D

const PlanetSpaceBackground = preload("res://scenes/planet_space_background.gd")
var progress: float = 0.0
var animation_time: float = 0.0
var redraw_accumulator: float = 0.0
const REDRAW_INTERVAL: float = 1.0 / 30.0

func set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	queue_redraw()

func _process(delta: float) -> void:
	animation_time += delta
	redraw_accumulator += delta
	if redraw_accumulator >= REDRAW_INTERVAL:
		redraw_accumulator = 0.0
		queue_redraw()

func _draw() -> void:
	PlanetSpaceBackground.draw_dynamic(self, progress, animation_time)
