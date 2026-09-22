extends Control

const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var panel: PanelContainer = $Panel
@onready var title: Label = $Panel/VBox/Title
@onready var music_toggle: CheckButton = $Panel/VBox/MusicToggle
@onready var sounds_toggle: CheckButton = $Panel/VBox/SoundsToggle
@onready var hints_toggle: CheckButton = $Panel/VBox/HintsToggle
@onready var display_option: OptionButton = $Panel/VBox/DisplayOption
@onready var fullscreen_toggle: CheckButton = $Panel/VBox/FullscreenToggle
@onready var mouse_label: Label = $Panel/VBox/MouseLabel
@onready var mouse_slider: HSlider = $Panel/VBox/MouseRow/MouseSlider
@onready var mouse_value: Label = $Panel/VBox/MouseRow/MouseValue
@onready var keyboard_label: Label = $Panel/VBox/KeyboardLabel
@onready var keyboard_slider: HSlider = $Panel/VBox/KeyboardRow/KeyboardSlider
@onready var keyboard_value: Label = $Panel/VBox/KeyboardRow/KeyboardValue
@onready var gamepad_label: Label = $Panel/VBox/GamepadLabel
@onready var gamepad_slider: HSlider = $Panel/VBox/GamepadRow/GamepadSlider
@onready var gamepad_value: Label = $Panel/VBox/GamepadRow/GamepadValue
@onready var hint: Label = $Panel/VBox/Hint
@onready var back_button: Button = $Panel/VBox/BackButton

var animation_time: float = 0.0

func _ready():
	_setup_style()
	_setup_layout()
	get_viewport().size_changed.connect(_setup_layout)
	call_deferred("_setup_layout")
	music_toggle.button_pressed = SettingsManager.music_enabled
	sounds_toggle.button_pressed = SettingsManager.sounds_enabled
	hints_toggle.button_pressed = SettingsManager.tutorial_hints_enabled
	display_option.select(SettingsManager.display_mode)
	fullscreen_toggle.button_pressed = SettingsManager.fullscreen_enabled
	mouse_slider.value = SettingsManager.mouse_sensitivity
	keyboard_slider.value = SettingsManager.keyboard_sensitivity
	gamepad_slider.value = SettingsManager.gamepad_sensitivity
	_update_values()
	back_button.grab_focus()
	queue_redraw()

func _setup_layout() -> void:
	var landscape := SettingsManager.display_mode == 1
	var panel_size := Vector2(620.0, 720.0) if landscape else Vector2(580.0, 940.0)
	panel.position = (size - panel_size) * 0.5
	panel.size = panel_size
	$Panel/VBox.add_theme_constant_override("separation", 5 if landscape else 16)

func _process(delta):
	animation_time += delta
	queue_redraw()

func _draw():
	var pulse = 0.5 + 0.5 * sin(animation_time * 0.8)
	for i in range(38):
		var x = float((i * 173 + 47) % int(size.x))
		var y = float((i * 97 + 31) % int(size.y))
		var twinkle = 0.5 + 0.5 * sin(animation_time * (0.5 + float(i % 4) * 0.09) + float(i) * 1.31)
		draw_circle(Vector2(x, y), 0.7 + float(i % 3) * 0.25, Color(1.0, 0.82, 0.42, 0.08 + twinkle * 0.18))

	for side in [-1.0, 1.0]:
		var x = panel.position.x - 26.0 if side < 0.0 else panel.position.x + panel.size.x + 26.0
		draw_line(Vector2(x, panel.position.y + 50.0), Vector2(x, panel.position.y + panel.size.y - 50.0), Color(0.88, 0.58, 0.16, 0.08 + pulse * 0.05), 1.0, true)

func _setup_style():
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	$Panel/VBox.add_theme_constant_override("separation", 5 if SettingsManager.display_mode == 1 else 16)

	title.custom_minimum_size.y = 62.0 if SettingsManager.display_mode == 1 else 92.0
	title.add_theme_font_size_override("font_size", 36 if SettingsManager.display_mode == 1 else 42)
	title.add_theme_color_override("font_color", Color(1.0, 0.94, 0.74, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.25, 0.12, 0.015, 0.95))
	title.add_theme_constant_override("outline_size", 6)

	for label in [mouse_label, keyboard_label, gamepad_label]:
		label.add_theme_font_size_override("font_size", 19)
		label.add_theme_color_override("font_color", Color(0.90, 0.82, 0.64, 1.0))
		label.add_theme_color_override("font_outline_color", Color(0.01, 0.07, 0.11, 1.0))
		label.add_theme_constant_override("outline_size", 2)

	for value_label in [mouse_value, keyboard_value, gamepad_value]:
		value_label.add_theme_font_size_override("font_size", 18)
		value_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.62, 1.0))

	_style_toggle(music_toggle)
	_style_toggle(sounds_toggle)
	_style_toggle(hints_toggle)
	_style_button(display_option)
	_style_display_popup()
	_style_toggle(fullscreen_toggle)
	_style_slider(mouse_slider)
	_style_slider(keyboard_slider)
	_style_slider(gamepad_slider)
	_style_button(back_button)

	hint.add_theme_color_override("font_color", Color(0.78, 0.58, 0.28, 0.92))
	hint.custom_minimum_size.y = 42.0 if SettingsManager.display_mode == 1 else 58.0
	hint.add_theme_font_size_override("font_size", 14 if SettingsManager.display_mode == 1 else 16)

func _make_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.007, 0.012, 0.018, 0.94)
	style.border_color = Color(0.90, 0.60, 0.16, 0.42)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	style.content_margin_top = 16.0
	style.content_margin_bottom = 16.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.60)
	style.shadow_size = 18
	return style

func _style_toggle(toggle: CheckButton):
	toggle.custom_minimum_size = Vector2(0.0, 44.0 if SettingsManager.display_mode == 1 else 56.0)
	toggle.add_theme_font_size_override("font_size", 21)
	toggle.add_theme_color_override("font_color", Color(0.94, 0.87, 0.68, 1.0))
	toggle.add_theme_color_override("font_hover_color", Color(1.0, 0.97, 0.84, 1.0))
	toggle.add_theme_color_override("font_focus_color", Color(1.0, 0.97, 0.84, 1.0))

func _style_display_popup() -> void:
	var popup := display_option.get_popup()
	popup.add_theme_font_size_override("font_size", 20)
	popup.add_theme_color_override("font_color", Color(0.94, 0.87, 0.68, 1.0))
	popup.add_theme_color_override("font_hover_color", Color(1.0, 0.97, 0.84, 1.0))
	popup.add_theme_stylebox_override("panel", _make_popup_style())
	popup.add_theme_stylebox_override("hover", _make_button_style(Color(1.0, 0.70, 0.20, 0.72), Color(0.075, 0.050, 0.018, 0.96), 1))

func _make_popup_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.008, 0.014, 0.020, 0.99)
	style.border_color = Color(0.90, 0.60, 0.16, 0.68)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style

func _style_slider(slider: HSlider):
	slider.custom_minimum_size = Vector2(0.0, 26.0 if SettingsManager.display_mode == 1 else 36.0)
	slider.add_theme_icon_override("grabber", _make_grabber(Color(1.0, 0.78, 0.30, 1.0)))
	slider.add_theme_icon_override("grabber_highlight", _make_grabber(Color(1.0, 0.94, 0.66, 1.0)))
	slider.add_theme_stylebox_override("slider", _make_slider_style(Color(0.075, 0.052, 0.018, 0.95), 4))
	slider.add_theme_stylebox_override("grabber_area", _make_slider_style(Color(0.94, 0.62, 0.16, 0.90), 5))
	slider.add_theme_stylebox_override("grabber_area_highlight", _make_slider_style(Color(1.0, 0.78, 0.30, 1.0), 6))

func _make_slider_style(color: Color, thickness: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(thickness)
	style.content_margin_top = float(thickness)
	style.content_margin_bottom = float(thickness)
	return style

func _make_grabber(color: Color) -> GradientTexture2D:
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([color, color])
	var texture = GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 16
	texture.height = 16
	return texture

func _style_button(button: Button):
	button.custom_minimum_size = Vector2(0.0, 48.0 if SettingsManager.display_mode == 1 else 62.0)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color(0.94, 0.87, 0.68, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.97, 0.84, 1.0))
	button.add_theme_color_override("font_focus_color", Color(1.0, 0.97, 0.84, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.84, 0.42, 1.0))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.58, 0.38, 0.12, 0.44), Color(0.014, 0.020, 0.022, 0.82), 1))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(1.0, 0.70, 0.20, 0.92), Color(0.075, 0.050, 0.018, 0.94), 2))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(1.0, 0.78, 0.30, 0.98), Color(0.065, 0.044, 0.016, 0.96), 2))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(1.0, 0.78, 0.30, 1.0), Color(0.012, 0.045, 0.070, 0.96), 2))

func _make_button_style(border: Color, background: Color, border_width: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(10)
	style.content_margin_left = 22.0
	style.content_margin_right = 22.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.38)
	style.shadow_size = 5
	return style

func _on_music_toggled(enabled: bool):
	SettingsManager.music_enabled = enabled
	SettingsManager.save_settings()

func _on_sounds_toggled(enabled: bool):
	SettingsManager.sounds_enabled = enabled
	SettingsManager.save_settings()

func _on_hints_toggled(enabled: bool):
	SettingsManager.tutorial_hints_enabled = enabled
	SettingsManager.save_settings()

func _on_display_mode_selected(index: int):
	SettingsManager.set_display_mode(index)

func _on_fullscreen_toggled(enabled: bool):
	SettingsManager.set_fullscreen(enabled)

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
