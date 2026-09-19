extends Control

const GAME_SCENE: String = "res://scenes/main.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const CHECKPOINTS: Array[int] = [
	1, 5, 10, 15, 20,
	25, 30, 35, 40, 45,
	50, 55, 60, 65, 70,
	75, 80, 85, 90, 95,
	100
]

const CHAPTER_COLORS: Array[Color] = [
	Color(1.0, 0.38, 0.12, 1.0),
	Color(0.88, 0.55, 0.16, 1.0),
	Color(0.42, 0.76, 0.38, 1.0),
	Color(0.28, 0.72, 0.72, 1.0),
	Color(0.28, 0.62, 0.96, 1.0),
	Color(0.34, 0.48, 1.0, 1.0),
	Color(0.48, 0.38, 1.0, 1.0),
	Color(0.66, 0.34, 1.0, 1.0),
	Color(0.82, 0.32, 0.96, 1.0),
	Color(0.94, 0.42, 0.82, 1.0)
]

func _ready():
	_apply_layout()
	create_level_buttons()
	$Panel/Content/BackButton.grab_focus()

func _apply_layout() -> void:
	if SettingsManager.display_mode == 1:
		$Panel.position = Vector2(60.0, 48.0)
		$Panel.size = Vector2(size.x - 120.0, size.y - 96.0)
	else:
		$Panel.position = Vector2(56.0, 42.0)
		$Panel.size = Vector2(798.0, 962.0)

func create_level_buttons():
	for level in CHECKPOINTS:
		if level == 100:
			add_grid_spacer()
			add_grid_spacer()

		var button = Button.new()
		button.text = str(level)
		button.custom_minimum_size = Vector2(190, 62) if SettingsManager.display_mode == 1 else Vector2(136, 72)
		button.add_theme_font_size_override("font_size", 25)
		button.add_theme_constant_override("outline_size", 2)
		button.add_theme_color_override("font_outline_color", Color(0.01, 0.018, 0.03, 1.0))
		button.disabled = level > SaveManager.highest_unlocked_level
		apply_checkpoint_style(button, level)
		button.pressed.connect(_on_level_pressed.bind(level))
		$Panel/Content/LevelGrid.add_child(button)

func add_grid_spacer():
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(190, 62) if SettingsManager.display_mode == 1 else Vector2(136, 72)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Panel/Content/LevelGrid.add_child(spacer)

func apply_checkpoint_style(button: Button, level: int):
	var chapter_index = clampi(int((max(level, 1) - 1) / 10), 0, CHAPTER_COLORS.size() - 1)
	var accent = CHAPTER_COLORS[chapter_index]
	var unlocked = not button.disabled

	if unlocked:
		button.add_theme_color_override("font_color", accent.lightened(0.38))
		button.add_theme_color_override("font_hover_color", Color(0.96, 0.99, 1.0, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.96, 0.99, 1.0, 1.0))
		button.add_theme_color_override("font_pressed_color", accent.lightened(0.2))
		button.add_theme_stylebox_override("normal", make_checkpoint_box(accent, false, false))
		button.add_theme_stylebox_override("hover", make_checkpoint_box(accent, true, false))
		button.add_theme_stylebox_override("focus", make_checkpoint_box(accent, true, false))
		button.add_theme_stylebox_override("pressed", make_checkpoint_box(accent, false, true))
	else:
		button.add_theme_color_override("font_disabled_color", Color(0.42, 0.5, 0.62, 0.56))
		button.add_theme_stylebox_override("disabled", make_locked_box())

func make_checkpoint_box(accent: Color, highlighted: bool, pressed: bool) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = Color(0.012, 0.024, 0.042, 0.82)
	if highlighted:
		box.bg_color = Color(accent.r * 0.1 + 0.02, accent.g * 0.1 + 0.03, accent.b * 0.1 + 0.05, 0.9)
	if pressed:
		box.bg_color = Color(0.008, 0.018, 0.032, 0.96)
	box.border_width_left = 2
	box.border_width_top = 2
	box.border_width_right = 2
	box.border_width_bottom = 2
	box.border_color = Color(accent.r, accent.g, accent.b, 0.95 if highlighted else 0.72)
	box.corner_radius_top_left = 10
	box.corner_radius_top_right = 10
	box.corner_radius_bottom_right = 10
	box.corner_radius_bottom_left = 10
	box.shadow_color = Color(accent.r, accent.g, accent.b, 0.22 if highlighted else 0.1)
	box.shadow_size = 9 if highlighted else 5
	return box

func make_locked_box() -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = Color(0.008, 0.016, 0.028, 0.68)
	box.border_width_left = 1
	box.border_width_top = 1
	box.border_width_right = 1
	box.border_width_bottom = 1
	box.border_color = Color(0.26, 0.34, 0.46, 0.46)
	box.corner_radius_top_left = 10
	box.corner_radius_top_right = 10
	box.corner_radius_bottom_right = 10
	box.corner_radius_bottom_left = 10
	return box

func _on_level_pressed(level: int):
	SaveManager.selected_level = level
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_back_pressed():
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
