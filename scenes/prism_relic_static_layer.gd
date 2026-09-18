extends Node2D
const PrismRelicBackground=preload("res://scenes/prism_relic_background.gd")
var progress:float=0.0
func set_progress(value:float)->void:
	progress=clampf(value,0.0,1.0)
	queue_redraw()
func _draw()->void:
	PrismRelicBackground.draw_static(self,progress)
