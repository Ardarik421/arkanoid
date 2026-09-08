extends Control

const GAME_SCENE: String = "res://scenes/main.tscn"
const LEVEL_SELECT_SCENE: String = "res://scenes/level_select.tscn"

func _ready():
	$Menu/ContinueButton.disabled = SaveManager.highest_unlocked_level <= 1
	$Menu/LevelSelectButton.disabled = SaveManager.highest_unlocked_level < 5
	$Menu/NewGameButton.grab_focus()

func _on_new_game_pressed():
	if SaveManager.highest_unlocked_level > 1:
		$NewGameConfirmation.popup_centered()
		$NewGameConfirmation.get_ok_button().grab_focus()
		return

	start_new_game()

func _on_new_game_confirmed():
	start_new_game()

func start_new_game():
	SaveManager.reset_progress()
	SaveManager.selected_level = 1
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_continue_pressed():
	SaveManager.selected_level = SaveManager.highest_unlocked_level
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_level_select_pressed():
	get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)

func _on_exit_pressed():
	get_tree().quit()
