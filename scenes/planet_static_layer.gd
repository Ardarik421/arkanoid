extends Node2D

const PlanetSpaceBackground = preload("res://scenes/planet_space_background.gd")
var progress: float = 0.0

func set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	PlanetSpaceBackground.draw_static(self, progress)
