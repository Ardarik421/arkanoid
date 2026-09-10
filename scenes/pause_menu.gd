extends CanvasLayer

@onready var pause_overlay = $PauseOverlay
@onready var continue_button = $PauseOverlay/PauseMenu/ContinueButton
@onready var main_menu_button = $PauseOverlay/PauseMenu/MainMenuButton

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide_pause_menu()

	continue_button.pressed.connect(resume_game)
	main_menu_button.pressed.connect(return_to_main_menu)

func _unhandled_input(event):
	if not event.is_action_pressed("ui_cancel"):
		return

	if get_tree().paused:
		resume_game()
		get_viewport().set_input_as_handled()
		return

	var main = get_parent()

	if main.game_won or main.game_over:
		return

	pause_game()
	get_viewport().set_input_as_handled()

func pause_game():
	get_tree().paused = true
	show_pause_menu()

func resume_game():
	get_tree().paused = false
	hide_pause_menu()

func show_pause_menu():
	visible = true

func hide_pause_menu():
	visible = false

func return_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
