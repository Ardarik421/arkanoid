extends Control

const GAME_SCENE: String = "res://scenes/main.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const CHECKPOINTS: Array[int] = [
	1, 5, 10, 15, 20,
	25, 30, 35, 40, 45,
	50, 55, 60, 65, 70,
	75, 80, 85, 90, 95,
	100
]

func _ready():
	create_level_buttons()
	$Panel/Content/BackButton.grab_focus()

func create_level_buttons():
	for level in CHECKPOINTS:
		var button = Button.new()
		button.text = str(level)
		button.custom_minimum_size = Vector2(130, 70)
		button.add_theme_font_size_override("font_size", 26)
		button.disabled = level > SaveManager.highest_unlocked_level
		button.pressed.connect(_on_level_pressed.bind(level))
		$Panel/Content/LevelGrid.add_child(button)

func _on_level_pressed(level: int):
	SaveManager.selected_level = level
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_back_pressed():
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
