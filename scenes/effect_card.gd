extends Label

@export var effect_kind: String = "piercing"

var time_left: float = 0.0
var max_time: float = 1.0
var accent: Color = Color.WHITE

func _ready():
	setup(effect_kind)
	_setup_lower_hud()

func _setup_lower_hud():
	var effects_ui = get_parent()
	if effects_ui is HBoxContainer:
		effects_ui.offset_left = 205.0
		effects_ui.offset_top = 1010.0
		effects_ui.offset_right = 755.0
		effects_ui.offset_bottom = 1056.0
		effects_ui.alignment = BoxContainer.ALIGNMENT_CENTER

	var main = effects_ui.get_parent()
	if main != null:
		var lives_label = main.get_node_or_null("LivesLabel")
		if lives_label != null:
			lives_label.visible = false

func setup(kind: String):
	effect_kind = kind
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(82.0, 46.0)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_update_accent()
	_update_style()
	queue_redraw()

func set_effect_time(value: float):
	time_left = max(value, 0.0)
	if time_left > max_time:
		max_time = time_left
	visible = time_left > 0.0
	text = "%.1f" % time_left
	queue_redraw()

func _update_accent():
	match effect_kind:
		"piercing": accent = Color(1.0, 0.82, 0.22)
		"explosive": accent = Color(1.0, 0.23, 0.08)
		"shield": accent = Color(0.20, 0.58, 1.0)
		"magnet": accent = Color(0.92, 0.24, 0.96)
		"fast": accent = Color(1.0, 0.62, 0.16)
		"hyper": accent = Color(0.82, 0.36, 1.0)

func _update_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.035, 0.055, 0.94)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(accent, 0.82)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 37.0
	style.content_margin_right = 8.0
	style.shadow_color = Color(accent, 0.16)
	style.shadow_size = 5
	add_theme_stylebox_override("normal", style)
	add_theme_color_override("font_color", Color(accent, 1.0))
	add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.035, 1.0))
	add_theme_constant_override("outline_size", 2)
	add_theme_font_size_override("font_size", 19)

func _draw():
	var icon_center = Vector2(20.0, 21.0)
	_draw_icon(icon_center)

	var ratio = 0.0
	if max_time > 0.0:
		ratio = clamp(time_left / max_time, 0.0, 1.0)

	draw_rect(Rect2(7.0, 40.0, size.x - 14.0, 2.0), Color(accent, 0.16), true)
	draw_rect(Rect2(7.0, 40.0, (size.x - 14.0) * ratio, 2.0), Color(accent, 0.95), true)

func _draw_icon(c: Vector2):
	var glow = Color(accent, 0.20)
	var bright = Color(accent, 1.0)
	draw_circle(c, 13.0, glow)

	match effect_kind:
		"piercing":
			var points = PackedVector2Array([c + Vector2(-7, 7), c + Vector2(7, -9), c + Vector2(3, 8), c + Vector2(0, 2)])
			draw_colored_polygon(points, bright)
		"explosive":
			for i in range(8):
				var a = TAU * float(i) / 8.0
				var p1 = c + Vector2(cos(a), sin(a)) * 4.0
				var p2 = c + Vector2(cos(a), sin(a)) * 11.0
				draw_line(p1, p2, bright, 2.5, true)
			draw_circle(c, 4.5, bright)
		"shield":
			var points = PackedVector2Array([c + Vector2(-8, -8), c + Vector2(8, -8), c + Vector2(7, 2), c + Vector2(0, 10), c + Vector2(-7, 2)])
			draw_polyline(points + PackedVector2Array([points[0]]), bright, 2.5, true)
		"magnet":
			draw_arc(c, 8.0, 0.0, PI, 20, bright, 3.5, true)
			draw_line(c + Vector2(-8, 0), c + Vector2(-8, -8), bright, 3.5, true)
			draw_line(c + Vector2(8, 0), c + Vector2(8, -8), bright, 3.5, true)
		"fast":
			for offset in [-4.0, 4.0]:
				draw_polyline(PackedVector2Array([c + Vector2(offset - 5, -7), c + Vector2(offset + 2, 0), c + Vector2(offset - 5, 7)]), bright, 3.0, true)
		"hyper":
			var points = PackedVector2Array()
			for i in range(8):
				var a = -PI / 2.0 + TAU * float(i) / 8.0
				var radius = 10.0 if i % 2 == 0 else 4.0
				points.append(c + Vector2(cos(a), sin(a)) * radius)
			draw_colored_polygon(points, bright)
