extends Control

const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var music_toggle: CheckButton = $Panel/VBox/MusicToggle
@onready var sounds_toggle: CheckButton = $Panel/VBox/SoundsToggle
@onready var mouse_slider: HSlider = $Panel/VBox/MouseRow/MouseSlider
@onready var mouse_value: Label = $Panel/VBox/MouseRow/MouseValue
@onready var keyboard_slider: HSlider = $Panel/VBox/KeyboardRow/KeyboardSlider
@onready var keyboard_value: Label = $Panel/VBox/KeyboardRow/KeyboardValue
@onready var gamepad_slider: HSlider = $Panel/VBox/GamepadRow/GamepadSlider
@onready var gamepad_value: Label = $Panel/VBox/GamepadRow/GamepadValue

func _ready():
	music_toggle.button_pressed = SettingsManager.music_enabled
	sounds_toggle.button_pressed = SettingsManager.sounds_enabled
	mouse_slider.value = SettingsManager.mouse_sensitivity
	keyboard_slider.value = SettingsManager.keyboard_sensitivity
	gamepad_slider.value = SettingsManager.gamepad_sensitivity
	_update_values()
	$Panel/VBox/BackButton.grab_focus()

func _on_music_toggled(enabled: bool):
	SettingsManager.music_enabled = enabled
	SettingsManager.save_settings()

func _on_sounds_toggled(enabled: bool):
	SettingsManager.sounds_enabled = enabled
	SettingsManager.save_settings()

func _on_mouse_changed(value: float):
	SettingsManager.mouse_sensitivity = value
	SettingsManager.save_settings()
	_update_values()

func _on_keyboard_changed(value: float):
	SettingsManager.keyboard_sensitivity = value
	SettingsManager.save_settings()
	_update_values()

func _on_gamepad_changed(value: float):
	SettingsManager.gamepad_sensitivity = value
	SettingsManager.save_settings()
	_update_values()

func _update_values():
	mouse_value.text = "%d%%" % roundi(mouse_slider.value * 100.0)
	keyboard_value.text = "%d%%" % roundi(keyboard_slider.value * 100.0)
	gamepad_value.text = "%d%%" % roundi(gamepad_slider.value * 100.0)

func _on_back_pressed():
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
