extends CanvasLayer

@onready var pause_overlay = $PauseOverlay
@onready var pause_menu = $PauseOverlay/PauseMenu
@onready var pause_title = $PauseOverlay/PauseMenu/PauseTitle
@onready var continue_button = $PauseOverlay/PauseMenu/ContinueButton
@onready var main_menu_button = $PauseOverlay/PauseMenu/MainMenuButton

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"

var pause_panel: Panel
var level_label: Label
var settings_button: Button
var settings_panel: Panel
var settings_box: VBoxContainer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_pause_style()
	_setup_settings_panel()
	hide_pause_menu()

	continue_button.pressed.connect(resume_game)
	main_menu_button.pressed.connect(return_to_main_menu)

func _setup_pause_style():
	pause_overlay.color = Color(0.005, 0.010, 0.016, 0.82)

	pause_panel = Panel.new()
	pause_panel.name = "PauseBackdrop"
	pause_overlay.add_child(pause_panel)
	pause_overlay.move_child(pause_panel, 0)
	pause_panel.set_anchors_preset(Control.PRESET_CENTER)
	pause_panel.offset_left = -220.0
	pause_panel.offset_top = -245.0
	pause_panel.offset_right = 220.0
	pause_panel.offset_bottom = 245.0
	pause_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_panel.add_theme_stylebox_override("panel", _make_panel_style())

	pause_menu.set_anchors_preset(Control.PRESET_CENTER)
	pause_menu.offset_left = -175.0
	pause_menu.offset_top = -185.0
	pause_menu.offset_right = 175.0
	pause_menu.offset_bottom = 185.0
	pause_menu.custom_minimum_size = Vector2(350.0, 0.0)
	pause_menu.add_theme_constant_override("separation", 18)

	pause_title.custom_minimum_size = Vector2(0.0, 72.0)
	pause_title.add_theme_font_size_override("font_size", 44)
	pause_title.add_theme_color_override("font_color", Color(0.82, 0.94, 1.0, 1.0))
	pause_title.add_theme_color_override("font_outline_color", Color(0.02, 0.16, 0.24, 1.0))
	pause_title.add_theme_constant_override("outline_size", 6)
	pause_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	level_label = Label.new()
	level_label.name = "PauseLevel"
	level_label.custom_minimum_size = Vector2(0.0, 38.0)
	level_label.add_theme_font_size_override("font_size", 20)
	level_label.add_theme_color_override("font_color", Color(0.48, 0.78, 0.94, 0.92))
	level_label.add_theme_color_override("font_outline_color", Color(0.01, 0.08, 0.12, 1.0))
	level_label.add_theme_constant_override("outline_size", 3)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_menu.add_child(level_label)
	pause_menu.move_child(level_label, pause_title.get_index() + 1)

	settings_button = Button.new()
	settings_button.name = "SettingsButton"
	settings_button.text = "Настройки"
	pause_menu.add_child(settings_button)
	pause_menu.move_child(settings_button, main_menu_button.get_index())
	settings_button.pressed.connect(show_settings)

	_style_button(continue_button)
	_style_button(settings_button)
	_style_button(main_menu_button)

func _setup_settings_panel():
	settings_panel = Panel.new()
	settings_panel.name = "PauseSettingsPanel"
	settings_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_overlay.add_child(settings_panel)
	settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	settings_panel.offset_left = -285.0
	settings_panel.offset_top = -390.0
	settings_panel.offset_right = 285.0
	settings_panel.offset_bottom = 390.0
	settings_panel.add_theme_stylebox_override("panel", _make_panel_style())
	settings_panel.visible = false

	settings_box = VBoxContainer.new()
	settings_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_box.offset_left = 30.0
	settings_box.offset_top = 22.0
	settings_box.offset_right = -30.0
	settings_box.offset_bottom = -22.0
	settings_box.add_theme_constant_override("separation", 17)
	settings_panel.add_child(settings_box)

	var title = Label.new()
	title.text = "НАСТРОЙКИ"
	title.custom_minimum_size = Vector2(0.0, 68.0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.88, 0.97, 1.0, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.02, 0.20, 0.31, 0.95))
	title.add_theme_constant_override("outline_size", 5)
	settings_box.add_child(title)

	var music_toggle = CheckButton.new()
	music_toggle.text = "МУЗЫКА"
	music_toggle.button_pressed = SettingsManager.music_enabled
	_style_toggle(music_toggle)
	music_toggle.toggled.connect(func(enabled): SettingsManager.music_enabled = enabled; SettingsManager.save_settings())
	settings_box.add_child(music_toggle)

	var sounds_toggle = CheckButton.new()
	sounds_toggle.text = "ЗВУКИ"
	sounds_toggle.button_pressed = SettingsManager.sounds_enabled
	_style_toggle(sounds_toggle)
	sounds_toggle.toggled.connect(func(enabled): SettingsManager.sounds_enabled = enabled; SettingsManager.save_settings())
	settings_box.add_child(sounds_toggle)

	_add_setting_slider("ЧУВСТВИТЕЛЬНОСТЬ МЫШИ", SettingsManager.mouse_sensitivity, func(value): SettingsManager.mouse_sensitivity = value; SettingsManager.save_settings())
	_add_setting_slider("СКОРОСТЬ КЛАВИАТУРЫ", SettingsManager.keyboard_sensitivity, func(value): SettingsManager.keyboard_sensitivity = value; SettingsManager.save_settings())
	_add_setting_slider("ЧУВСТВИТЕЛЬНОСТЬ ГЕЙМПАДА", SettingsManager.gamepad_sensitivity, func(value): SettingsManager.gamepad_sensitivity = value; SettingsManager.save_settings())

	var hint = Label.new()
	hint.text = "Диапазон: 50–200%"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", Color(0.42, 0.70, 0.84, 0.92))
	settings_box.add_child(hint)

	var back = Button.new()
	back.text = "НАЗАД"
	_style_button(back)
	back.pressed.connect(hide_settings)
	settings_box.add_child(back)

func _add_setting_slider(label_text: String, initial_value: float, callback: Callable):
	var label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.68, 0.84, 0.92, 1.0))
	settings_box.add_child(label)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	settings_box.add_child(row)

	var slider = HSlider.new()
	slider.min_value = 0.5
	slider.max_value = 2.0
	slider.step = 0.05
	slider.value = initial_value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(0.0, 34.0)
	_style_slider(slider)
	row.add_child(slider)

	var value_label = Label.new()
	value_label.custom_minimum_size = Vector2(68.0, 34.0)
	value_label.text = "%d%%" % roundi(initial_value * 100.0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 17)
	value_label.add_theme_color_override("font_color", Color(0.78, 0.93, 1.0, 1.0))
	row.add_child(value_label)

	slider.value_changed.connect(func(value): value_label.text = "%d%%" % roundi(value * 100.0); callback.call(value))

func _make_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.012, 0.026, 0.038, 0.97)
	style.border_color = Color(0.26, 0.68, 0.92, 0.56)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.72)
	style.shadow_size = 18
	return style

func _style_toggle(toggle: CheckButton):
	toggle.custom_minimum_size = Vector2(0.0, 48.0)
	toggle.add_theme_font_size_override("font_size", 20)
	toggle.add_theme_color_override("font_color", Color(0.74, 0.89, 0.96, 1.0))

func _style_slider(slider: HSlider):
	slider.add_theme_stylebox_override("slider", _make_slider_style(Color(0.025, 0.075, 0.105, 0.95), 4))
	slider.add_theme_stylebox_override("grabber_area", _make_slider_style(Color(0.20, 0.70, 0.94, 0.88), 5))
	slider.add_theme_stylebox_override("grabber_area_highlight", _make_slider_style(Color(0.34, 0.84, 1.0, 1.0), 6))

func _make_slider_style(color: Color, thickness: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(thickness)
	style.content_margin_top = float(thickness)
	style.content_margin_bottom = float(thickness)
	return style

func _style_button(button: Button):
	button.custom_minimum_size = Vector2(0.0, 64.0)
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color(0.78, 0.90, 0.96, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.96, 0.99, 1.0, 1.0))
	button.add_theme_color_override("font_focus_color", Color(0.96, 0.99, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.72, 0.90, 1.0, 1.0))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.20, 0.58, 0.78, 0.48), Color(0.016, 0.034, 0.048, 0.96), 2))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.30, 0.76, 1.0, 0.92), Color(0.022, 0.060, 0.084, 0.99), 2))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(0.38, 0.82, 1.0, 1.0), Color(0.020, 0.052, 0.074, 0.99), 3))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.22, 0.66, 0.92, 1.0), Color(0.012, 0.030, 0.046, 1.0), 2))

func _make_button_style(border: Color, background: Color, border_width: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(9)
	style.content_margin_left = 20.0
	style.content_margin_right = 20.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	style.shadow_size = 6
	return style

func _unhandled_input(event):
	if not event.is_action_pressed("ui_cancel"):
		return

	if get_tree().paused:
		if settings_panel != null and settings_panel.visible:
			hide_settings()
		else:
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
	var main = get_parent()
	if level_label != null and main != null:
		level_label.text = "УРОВЕНЬ %d" % int(main.current_level)
	settings_panel.visible = false
	pause_panel.visible = true
	pause_menu.visible = true
	visible = true
	continue_button.grab_focus()

func hide_pause_menu():
	visible = false

func show_settings():
	pause_panel.visible = false
	pause_menu.visible = false
	settings_panel.visible = true
	for child in settings_box.get_children():
		if child is CheckButton:
			child.grab_focus()
			break

func hide_settings():
	settings_panel.visible = false
	pause_panel.visible = true
	pause_menu.visible = true
	settings_button.grab_focus()

func return_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
