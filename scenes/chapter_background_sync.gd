extends Node

var _last_level: int = -1

func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if scene == null or not scene.has_method("start_next_level"):
		_last_level = -1
		return

	var level := int(scene.get("current_level"))
	if level == _last_level:
		return
	_last_level = level

	var background := scene.get_node_or_null("ChapterBackground")
	if background != null and background.has_method("_sync_level"):
		background.call_deferred("_sync_level")
