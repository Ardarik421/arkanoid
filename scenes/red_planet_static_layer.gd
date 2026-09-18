extends Node2D
const RedPlanetBackground = preload("res://scenes/red_planet_background.gd")
var progress: float = 0.0
func set_progress(value: float) -> void:
	progress = clampf(value,0.0,1.0)
	queue_redraw()
func _draw() -> void:
	RedPlanetBackground.draw_static(self,progress)
