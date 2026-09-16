extends Control

const GAME_SCENE: String = "res://scenes/main.tscn"
const LEVEL_SELECT_SCENE: String = "res://scenes/level_select.tscn"
const MENU_MUSIC: AudioStream = preload("res://audio/music/menu_theme.wav")

var animation_time: float = 0.0
var menu_music_player: AudioStreamPlayer

func _ready():
	$Menu/ContinueButton.disabled = SaveManager.highest_unlocked_level <= 1
	$Menu/LevelSelectButton.disabled = false
	_setup_layout()
	_setup_title()
	_setup_buttons()
	_setup_confirmation_dialog()
	_setup_music()
	$Menu/NewGameButton.grab_focus()
	queue_redraw()

func _setup_music():
	menu_music_player = AudioStreamPlayer.new()
	menu_music_player.stream = MENU_MUSIC
	menu_music_player.volume_db = -5.0
	menu_music_player.finished.connect(_on_menu_music_finished)
	add_child(menu_music_player)
	menu_music_player.play()

func _on_menu_music_finished():
	if is_instance_valid(menu_music_player):
		menu_music_player.play()

func _process(delta):
	animation_time += delta
	queue_redraw()

func _draw():
	var viewport_size = size
	var center = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.43)
	var pulse = 0.5 + 0.5 * sin(animation_time * 0.72)

	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.004, 0.008, 0.016, 1.0), true)

	for i in range(9, 0, -1):
		var radius = 95.0 + float(i) * 42.0
		var alpha = 0.006 + float(10 - i) * 0.0035
		draw_circle(center, radius, Color(0.06, 0.30, 0.48, alpha))

	_draw_stars(viewport_size, pulse)
	_draw_edge_crystals(viewport_size, pulse)
	_draw_portal(center, pulse)
	_draw_energy_path(center, viewport_size, pulse)

	var panel_rect = Rect2(Vector2(247.0, 318.0), Vector2(466.0, 484.0))
	draw_style_box(_make_panel_style(), panel_rect)

	draw_line(Vector2(300.0, 321.0), Vector2(660.0, 321.0), Color(0.42, 0.88, 1.0, 0.24 + pulse * 0.08), 1.0, true)
	draw_line(Vector2(342.0, 807.0), Vector2(618.0, 807.0), Color(0.26, 0.66, 0.92, 0.13), 1.0, true)

	for side in [-1.0, 1.0]:
		var x = center.x + side * 232.0
		draw_line(Vector2(x, 353.0), Vector2(x, 760.0), Color(0.28, 0.72, 1.0, 0.09), 1.0, true)

func _draw_stars(viewport_size: Vector2, pulse: float):
	for i in range(54):
		var x = float((i * 173 + 47) % int(viewport_size.x))
		var y = float((i * 97 + 31) % int(viewport_size.y))
		var twinkle = 0.5 + 0.5 * sin(animation_time * (0.55 + float(i % 5) * 0.08) + float(i) * 1.37)
		var radius = 0.55 + float(i % 4) * 0.28
		var alpha = 0.10 + twinkle * 0.30
		if i % 11 == 0:
			radius += 0.8
			alpha += 0.16 * pulse
		draw_circle(Vector2(x, y), radius, Color(0.62, 0.88, 1.0, alpha))

func _draw_edge_crystals(viewport_size: Vector2, pulse: float):
	var left_points = PackedVector2Array([
		Vector2(0, 0), Vector2(158, 0), Vector2(128, 92), Vector2(176, 174),
		Vector2(121, 292), Vector2(154, 405), Vector2(96, 526), Vector2(142, 668),
		Vector2(92, 814), Vector2(132, viewport_size.y), Vector2(0, viewport_size.y)
	])
	var right_points = PackedVector2Array()
	for point in left_points:
		right_points.append(Vector2(viewport_size.x - point.x, point.y))

	draw_colored_polygon(left_points, Color(0.008, 0.022, 0.034, 0.98))
	draw_colored_polygon(right_points, Color(0.008, 0.020, 0.032, 0.98))

	var left_edge = PackedVector2Array([Vector2(158, 0), Vector2(128, 92), Vector2(176, 174), Vector2(121, 292), Vector2(154, 405), Vector2(96, 526), Vector2(142, 668), Vector2(92, 814), Vector2(132, viewport_size.y)])
	var right_edge = PackedVector2Array()
	for point in left_edge:
		right_edge.append(Vector2(viewport_size.x - point.x, point.y))

	draw_polyline(left_edge, Color(0.18, 0.58, 0.78, 0.18), 1.4, true)
	draw_polyline(right_edge, Color(0.18, 0.58, 0.78, 0.18), 1.4, true)

	for i in range(7):
		var y = 92.0 + float(i) * 142.0
		var flicker = 0.16 + 0.08 * sin(animation_time * 0.8 + float(i))
		var crystal_left = PackedVector2Array([
			Vector2(20.0, y), Vector2(58.0, y - 30.0), Vector2(86.0, y + 5.0), Vector2(48.0, y + 54.0)
		])
		var crystal_right = PackedVector2Array()
		for point in crystal_left:
			crystal_right.append(Vector2(viewport_size.x - point.x, point.y + 35.0))
		draw_colored_polygon(crystal_left, Color(0.08, 0.30, 0.42, 0.20))
		draw_polyline(PackedVector2Array([crystal_left[0], crystal_left[1], crystal_left[2], crystal_left[3], crystal_left[0]]), Color(0.30, 0.78, 1.0, flicker), 1.0, true)
		draw_colored_polygon(crystal_right, Color(0.08, 0.28, 0.40, 0.18))
		draw_polyline(PackedVector2Array([crystal_right[0], crystal_right[1], crystal_right[2], crystal_right[3], crystal_right[0]]), Color(0.30, 0.78, 1.0, flicker), 1.0, true)

func _draw_portal(center: Vector2, pulse: float):
	var portal_center = center + Vector2(0.0, -126.0)

	for i in range(6, 0, -1):
		var radius = 34.0 + float(i) * 15.0
		draw_circle(portal_center, radius, Color(0.12, 0.58, 0.86, 0.010 + float(7 - i) * 0.009))

	draw_circle(portal_center, 56.0 + pulse * 2.0, Color(0.01, 0.04, 0.075, 0.96))
	draw_arc(portal_center, 57.0 + pulse * 2.0, 0.0, TAU, 72, Color(0.32, 0.84, 1.0, 0.34), 1.5, true)
	draw_arc(portal_center, 48.0, animation_time * 0.16, animation_time * 0.16 + PI * 1.35, 54, Color(0.54, 0.92, 1.0, 0.34), 2.0, true)
	draw_arc(portal_center, 39.0, -animation_time * 0.22, -animation_time * 0.22 + PI * 1.55, 48, Color(0.20, 0.64, 1.0, 0.30), 1.3, true)
	draw_circle(portal_center, 25.0, Color(0.01, 0.018, 0.036, 1.0))
	draw_circle(portal_center, 17.0 + pulse * 1.5, Color(0.20, 0.62, 0.92, 0.11))

	for i in range(8):
		var angle = animation_time * 0.18 + TAU * float(i) / 8.0
		var inner = portal_center + Vector2(cos(angle), sin(angle)) * 64.0
		var outer = portal_center + Vector2(cos(angle), sin(angle)) * (72.0 + float(i % 3) * 5.0)
		draw_line(inner, outer, Color(0.38, 0.84, 1.0, 0.20 + pulse * 0.08), 1.1, true)

func _draw_energy_path(center: Vector2, viewport_size: Vector2, pulse: float):
	var path = PackedVector2Array([
		Vector2(center.x, 145.0),
		Vector2(center.x - 18.0, 215.0),
		Vector2(center.x + 10.0, 285.0),
		Vector2(center.x, 320.0)
	])
	draw_polyline(path, Color(0.26, 0.74, 1.0, 0.08 + pulse * 0.04), 1.0, true)

	for i in range(5):
		var y = viewport_size.y - 72.0 - float(i) * 34.0
		var width = 95.0 + float(i) * 31.0
		draw_line(Vector2(center.x - width, y), Vector2(center.x + width, y), Color(0.20, 0.56, 0.82, 0.025 + float(i) * 0.012), 1.0, true)

func _make_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.008, 0.022, 0.036, 0.73)
	style.border_color = Color(0.22, 0.62, 0.82, 0.18)
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	style.shadow_size = 18
	return style

func _setup_layout():
	$Menu.offset_left = 285.0
	$Menu.offset_top = 340.0
	$Menu.offset_right = 675.0
	$Menu.offset_bottom = 785.0
	$Menu.add_theme_constant_override("separation", 15)

func _setup_title():
	var title = $Menu/Title
	title.text = "SPACE CRYSTALL"
	title.custom_minimum_size = Vector2(0, 105)
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.88, 0.97, 1.0, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.02, 0.20, 0.31, 0.95))
	title.add_theme_constant_override("outline_size", 6)
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
	button.custom_minimum_size = Vector2(0, 62)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color(0.72, 0.87, 0.94, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.96, 0.995, 1.0, 1.0))
	button.add_theme_color_override("font_focus_color", Color(0.96, 0.995, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.72, 0.92, 1.0, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.34, 0.42, 0.47, 0.68))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.18, 0.50, 0.68, 0.38), Color(0.012, 0.035, 0.052, 0.72), 1))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.38, 0.84, 1.0, 0.88), Color(0.020, 0.075, 0.105, 0.90), 2))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(0.46, 0.88, 1.0, 0.96), Color(0.018, 0.062, 0.090, 0.92), 2))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.70, 0.94, 1.0, 1.0), Color(0.012, 0.045, 0.070, 0.96), 2))
	button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.12, 0.19, 0.23, 0.48), Color(0.010, 0.018, 0.025, 0.72), 1))

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
