extends Node2D
const GravityFractureBackground=preload("res://scenes/gravity_fracture_background.gd")
var progress:float=0.0
func set_progress(value:float)->void:
	progress=clampf(value,0.0,1.0); queue_redraw()
func _draw()->void: GravityFractureBackground.draw_static(self,progress)
