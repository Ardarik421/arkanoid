extends CanvasLayer

@onready var pause_overlay = $PauseOverlay
@onready var pause_menu = $PauseOverlay/PauseMenu
@onready var pause_title = $PauseOverlay/PauseMenu/PauseTitle
@onready var continue_button = $PauseOverlay/PauseMenu/ContinueButton
@onready var main_menu_button = $PauseOverlay/PauseMenu/MainMenuButton

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"

var pause_panel: Panel
var level_label: Label

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_pause_style()
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
	pause_panel.offset_top = -205.0
	pause_panel.offset_right = 220.0
	pause_panel.offset_bottom = 205.0
	pause_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_panel.add_theme_stylebox_override("panel", _make_panel_style())

	pause_menu.set_anchors_preset(Control.PRESET_CENTER)
	pause_menu.offset_left = -175.0
	pause_menu.offset_top = -145.0
	pause_menu.offset_right = 175.0
	pause_menu.offset_bottom = 145.0
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

	_style_button(continue_button)
	_style_button(main_menu_button)

func _make_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.012, 0.026, 0.038, 0.97)
	style.border_color = Color(0.26, 0.68, 0.92, 0.56)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.72)
	style.shadow_size = 18
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
	visible = true
	continue_button.grab_focus()

func hide_pause_menu():
	visible = false

func return_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
