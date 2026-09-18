extends Button

const SETTINGS_SCENE := "res://scenes/settings_menu.tscn"

func _ready():
	pressed.connect(_open_settings)
	_style_self()
	call_deferred("_compact_menu")

func _style_self():
	custom_minimum_size = Vector2(0, 56)
	add_theme_font_size_override("font_size", 22)
	add_theme_color_override("font_color", Color(0.92, 0.86, 0.68, 1.0))
	add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.86, 1.0))
	add_theme_color_override("font_focus_color", Color(1.0, 0.98, 0.86, 1.0))
	add_theme_color_override("font_pressed_color", Color(1.0, 0.86, 0.48, 1.0))
	add_theme_stylebox_override("normal", _make_style(Color(0.58, 0.38, 0.12, 0.42), Color(0.018, 0.028, 0.035, 0.78), 1))
	add_theme_stylebox_override("hover", _make_style(Color(1.0, 0.72, 0.24, 0.90), Color(0.075, 0.055, 0.025, 0.92), 2))
	add_theme_stylebox_override("focus", _make_style(Color(1.0, 0.80, 0.34, 0.96), Color(0.065, 0.045, 0.020, 0.92), 2))
	add_theme_stylebox_override("pressed", _make_style(Color(1.0, 0.76, 0.24, 1.0), Color(0.095, 0.055, 0.012, 0.96), 2))

func _compact_menu():
	var menu = get_parent()
	if menu == null:
		return
	menu.offset_top = 330.0
	menu.offset_bottom = 800.0
	menu.add_theme_constant_override("separation", 10)
	for child in menu.get_children():
		if child is Button:
			child.custom_minimum_size = Vector2(0, 56)

func _make_style(border: Color, background: Color, border_width: int) -> StyleBoxFlat:
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

func _open_settings():
	get_tree().change_scene_to_file(SETTINGS_SCENE)
