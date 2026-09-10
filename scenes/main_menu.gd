extends Control

const GAME_SCENE: String = "res://scenes/main.tscn"
const LEVEL_SELECT_SCENE: String = "res://scenes/level_select.tscn"

var animation_time: float = 0.0

func _ready():
	$Menu/ContinueButton.disabled = SaveManager.highest_unlocked_level <= 1
	$Menu/LevelSelectButton.disabled = false
	_setup_layout()
	_setup_title()
	_setup_buttons()
	_setup_confirmation_dialog()
	$Menu/NewGameButton.grab_focus()
	queue_redraw()

func _process(delta):
	animation_time += delta
	queue_redraw()

func _draw():
	var viewport_size = size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.008, 0.012, 0.018, 1.0), true)

	var glow_center = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.72)
	var pulse = 0.5 + sin(animation_time * 0.55) * 0.5

	for i in range(7, 0, -1):
		var radius = Vector2(150.0 + i * 95.0, 70.0 + i * 48.0)
		var alpha = (0.012 + 0.004 * pulse) * float(8 - i)
		_draw_haze_ellipse(glow_center + Vector2(0.0, i * 10.0), radius, Color(0.18, 0.42, 0.58, alpha))

	_draw_rock_mass(PackedVector2Array([
		Vector2(0, 0), Vector2(210, 0), Vector2(184, 115), Vector2(220, 205),
		Vector2(170, 330), Vector2(215, 470), Vector2(145, 620), Vector2(180, viewport_size.y), Vector2(0, viewport_size.y)
	]), Color(0.025, 0.034, 0.042, 1.0))

	_draw_rock_mass(PackedVector2Array([
		Vector2(viewport_size.x, 0), Vector2(viewport_size.x - 190, 0), Vector2(viewport_size.x - 165, 130),
		Vector2(viewport_size.x - 220, 250), Vector2(viewport_size.x - 175, 390), Vector2(viewport_size.x - 225, 560),
		Vector2(viewport_size.x - 155, 730), Vector2(viewport_size.x - 190, viewport_size.y), Vector2(viewport_size.x, viewport_size.y)
	]), Color(0.023, 0.031, 0.039, 1.0))

	for i in range(12):
		var x = 70.0 + float((i * 83) % 820)
		var y = viewport_size.y - 70.0 - float((i * 37) % 240)
		var drift = sin(animation_time * 0.8 + i * 0.9) * 5.0
		draw_circle(Vector2(x + drift, y), 1.5 + float(i % 3), Color(0.28, 0.72, 1.0, 0.15 + 0.05 * pulse))

	var line_y = viewport_size.y * 0.80
	draw_line(Vector2(110, line_y), Vector2(viewport_size.x - 110, line_y), Color(0.24, 0.66, 0.92, 0.18), 1.0, true)

func _draw_haze_ellipse(center: Vector2, radii: Vector2, color: Color):
	var points = PackedVector2Array()
	for i in range(48):
		var angle = TAU * float(i) / 48.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)

func _draw_rock_mass(points: PackedVector2Array, color: Color):
	draw_colored_polygon(points, color)
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color(0.18, 0.35, 0.44, 0.12), 2.0, true)

func _setup_layout():
	$Menu.offset_left = 270.0
	$Menu.offset_top = 205.0
	$Menu.offset_right = 690.0
	$Menu.offset_bottom = 830.0
	$Menu.add_theme_constant_override("separation", 18)

func _setup_title():
	var title = $Menu/Title
	title.text = "ARKANOID"
	title.custom_minimum_size = Vector2(0, 125)
	title.add_theme_font_size_override("font_size", 54)
	title.add_theme_color_override("font_color", Color(0.82, 0.94, 1.0, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.02, 0.16, 0.24, 1.0))
	title.add_theme_constant_override("outline_size", 7)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _setup_buttons():
	for button in [
		$Menu/NewGameButton,
		$Menu/ContinueButton,
		$Menu/LevelSelectButton,
		$Menu/ExitButton
	]:
		_style_button(button)

func _style_button(button: Button):
	button.custom_minimum_size = Vector2(0, 68)
	button.add_theme_font_size_override("font_size", 25)
	button.add_theme_color_override("font_color", Color(0.78, 0.90, 0.96, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.95, 0.99, 1.0, 1.0))
	button.add_theme_color_override("font_focus_color", Color(0.95, 0.99, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.72, 0.90, 1.0, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.40, 0.47, 0.52, 0.72))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.20, 0.58, 0.78, 0.46), Color(0.015, 0.030, 0.043, 0.94), 2))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.30, 0.76, 1.0, 0.90), Color(0.020, 0.055, 0.078, 0.98), 2))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(0.38, 0.82, 1.0, 1.0), Color(0.018, 0.048, 0.070, 0.98), 3))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.22, 0.66, 0.92, 1.0), Color(0.010, 0.028, 0.045, 1.0), 2))
	button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.16, 0.21, 0.24, 0.60), Color(0.015, 0.020, 0.026, 0.88), 1))

func _make_button_style(border: Color, background: Color, border_width: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(9)
	style.content_margin_left = 22.0
	style.content_margin_right = 22.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.48)
	style.shadow_size = 7
	return style

func _setup_confirmation_dialog():
	var dialog = $NewGameConfirmation
	dialog.add_theme_font_size_override("font_size", 20)
	_style_button(dialog.get_ok_button())
	_style_button(dialog.get_cancel_button())

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
