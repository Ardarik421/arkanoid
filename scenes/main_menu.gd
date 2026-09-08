extends Control

const GAME_SCENE: String = "res://scenes/main.tscn"

func _ready():
	$Menu/ContinueButton.disabled = SaveManager.highest_unlocked_level <= 1
	$Menu/NewGameButton.grab_focus()

func _on_new_game_pressed():
	SaveManager.reset_progress()
	SaveManager.selected_level = 1
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_continue_pressed():
	SaveManager.selected_level = SaveManager.highest_unlocked_level
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_exit_pressed():
	get_tree().quit()
