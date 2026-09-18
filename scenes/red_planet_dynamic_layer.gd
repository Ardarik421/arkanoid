extends Node2D
const RedPlanetBackground = preload("res://scenes/red_planet_background.gd")
var progress: float = 0.0
var animation_time: float = 0.0
var accumulator: float = 0.0
func set_progress(value: float) -> void:
	progress=clampf(value,0.0,1.0)
	queue_redraw()
func _process(delta: float) -> void:
	animation_time+=delta
	accumulator+=delta
	if accumulator>=1.0/30.0:
		accumulator=0.0
		queue_redraw()
func _draw() -> void:
	RedPlanetBackground.draw_dynamic(self,progress,animation_time)
