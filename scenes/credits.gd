extends Control

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"

func _ready() -> void:
	_setup_layout()
	get_viewport().size_changed.connect(_setup_layout)
	$Panel/VBox/BackButton.release_focus()

func _setup_layout() -> void:
	var landscape: bool = SettingsManager.display_mode == 1
	var panel_width: float = 620.0 if landscape else 720.0
	var panel_height: float = 520.0 if landscape else 650.0
	var center: Vector2 = size * 0.5
	$Panel.position = center - Vector2(panel_width, panel_height) * 0.5
	$Panel.size = Vector2(panel_width, panel_height)
	$Panel/VBox.offset_left = 48.0
	$Panel/VBox.offset_top = 38.0
	$Panel/VBox.offset_right = -48.0
	$Panel/VBox.offset_bottom = -38.0
	$Panel/VBox.add_theme_constant_override("separation", 16 if landscape else 24)
	$Panel/VBox/Title.add_theme_font_size_override("font_size", 38 if landscape else 44)
	$Panel/VBox/Credits.add_theme_font_size_override("font_size", 21 if landscape else 24)
	$Panel/VBox/BackButton.custom_minimum_size.y = 48.0 if landscape else 58.0

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
