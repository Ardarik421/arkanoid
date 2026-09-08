extends Control

const GAME_SCENE: PackedScene = preload("res://scenes/main.tscn")

func _ready():
	$Menu/ContinueButton.disabled = SaveManager.highest_unlocked_level <= 1
	$Menu/NewGameButton.grab_focus()

func _on_new_game_pressed():
	SaveManager.reset_progress()
	start_game(1)

func _on_continue_pressed():
	start_game(SaveManager.highest_unlocked_level)

func _on_exit_pressed():
	get_tree().quit()

func start_game(level: int):
	SaveManager.selected_level = level

	var game = GAME_SCENE.instantiate()
	game.use_test_level = true
	game.test_start_level = level

	get_tree().root.add_child(game)
	get_tree().current_scene = game
	queue_free()
