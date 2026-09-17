extends Control

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
var animation_time: float = 0.0

@onready var sp_label: Label = $Margin/VBox/Header/SPLabel
@onready var status_label: Label = $Margin/VBox/StatusLabel

func _ready():
	_setup_style()
	_refresh()
	$Margin/VBox/Branches/Piercing/Content/Gameplay.grab_focus()
	queue_redraw()

func _process(delta):
	animation_time += delta
	queue_redraw()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_back_to_menu()

func _draw():
	var viewport_size := size
	var pulse := 0.5 + 0.5 * sin(animation_time * 0.7)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.004, 0.008, 0.016, 1.0), true)
	for i in range(48):
		var x := float((i * 173 + 47) % int(viewport_size.x))
		var y := float((i * 97 + 31) % int(viewport_size.y))
		var twinkle := 0.5 + 0.5 * sin(animation_time * 0.55 + float(i) * 1.37)
		draw_circle(Vector2(x, y), 0.7 + float(i % 3) * 0.3, Color(0.58, 0.86, 1.0, 0.08 + twinkle * 0.22))
	var center := viewport_size * 0.5
	for i in range(7, 0, -1):
		draw_circle(center, 110.0 + float(i) * 55.0, Color(0.04, 0.24, 0.38, 0.004 + float(8 - i) * 0.004))
	draw_line(Vector2(80, 116), Vector2(viewport_size.x - 80, 116), Color(0.28, 0.76, 1.0, 0.12 + pulse * 0.05), 1.0)

func _setup_style():
	$Margin/VBox/Title.add_theme_font_size_override("font_size", 40)
	$Margin/VBox/Title.add_theme_color_override("font_color", Color(0.84, 0.96, 1.0))
	$Margin/VBox/Title.add_theme_color_override("font_outline_color", Color(0.02, 0.20, 0.31, 0.95))
	$Margin/VBox/Title.add_theme_constant_override("outline_size", 5)
	sp_label.add_theme_font_size_override("font_size", 23)
	sp_label.add_theme_color_override("font_color", Color(0.74, 0.92, 1.0))
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(0.50, 0.72, 0.82))
	for branch in $Margin/VBox/Branches.get_children():
		branch.add_theme_stylebox_override("panel", _make_card_style())
		var content: VBoxContainer = branch.get_node("Content")
		content.add_theme_constant_override("separation", 8)
		for child in content.get_children():
			if child is Button:
				child.custom_minimum_size = Vector2(0, 58)
				child.add_theme_font_size_override("font_size", 15)
		var duration_button: Button = content.get_node("Duration")
		duration_button.custom_minimum_size = Vector2(0, 76)
	$Margin/VBox/BackButton.add_theme_font_size_override("font_size", 19)
	_style_back_button($Margin/VBox/BackButton)

func _make_card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.006, 0.020, 0.032, 0.88)
	style.border_color = Color(0.20, 0.58, 0.78, 0.30)
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	style.shadow_color = Color(0, 0, 0, 0.48)
	style.shadow_size = 9
	return style

func _make_button_style(border: Color, background: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(10)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = 5
	return style

func _apply_node_style(button: Button, purchased: bool, available: bool):
	button.add_theme_color_override("font_color", Color(0.76, 0.90, 0.96))
	button.add_theme_color_override("font_hover_color", Color(0.96, 0.995, 1.0))
	button.add_theme_color_override("font_focus_color", Color(0.96, 0.995, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.34, 0.43, 0.48, 0.72))
	if purchased:
		button.add_theme_stylebox_override("normal", _make_button_style(Color(0.34, 0.86, 1.0, 0.72), Color(0.02, 0.11, 0.15, 0.92), 2))
		button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.28, 0.70, 0.84, 0.48), Color(0.015, 0.075, 0.10, 0.86), 1))
	elif available:
		button.add_theme_stylebox_override("normal", _make_button_style(Color(0.18, 0.52, 0.70, 0.55), Color(0.01, 0.035, 0.052, 0.82), 1))
		button.add_theme_stylebox_override("hover", _make_button_style(Color(0.42, 0.88, 1.0, 0.92), Color(0.02, 0.08, 0.11, 0.94), 2))
		button.add_theme_stylebox_override("focus", _make_button_style(Color(0.48, 0.90, 1.0, 0.96), Color(0.02, 0.07, 0.10, 0.94), 2))
	else:
		button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.10, 0.20, 0.25, 0.42), Color(0.008, 0.016, 0.024, 0.80), 1))

func _style_back_button(button: Button):
	button.add_theme_color_override("font_color", Color(0.72, 0.87, 0.94))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.18, 0.50, 0.68, 0.38), Color(0.012, 0.035, 0.052, 0.72), 1))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.38, 0.84, 1.0, 0.88), Color(0.020, 0.075, 0.105, 0.90), 2))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(0.46, 0.88, 1.0, 0.96), Color(0.018, 0.062, 0.090, 0.92), 2))

func _node(branch: String, node_name: String) -> Button:
	return get_node("Margin/VBox/Branches/%s/Content/%s" % [branch, node_name]) as Button

func _refresh():
	sp_label.text = "%d SP     •     УЛУЧШЕНИЕ: %d SP" % [SaveManager.skill_points, SaveManager.SKILL_COST]
	_set_gameplay_button(_node("Piercing", "Gameplay"), SaveManager.piercing_gameplay, 1, "ТЁМНЫЕ СТЕНЫ ×5")
	_set_duration_button(_node("Piercing", "Duration"), SaveManager.piercing_duration, SaveManager.piercing_gameplay >= 1)
	_set_gameplay_button(_node("Explosive", "Gameplay"), SaveManager.explosive_gameplay, 3, _explosive_text())
	_set_duration_button(_node("Explosive", "Duration"), SaveManager.explosive_duration, SaveManager.explosive_gameplay >= 3)
	_set_gameplay_button(_node("Shield", "Gameplay"), SaveManager.shield_gameplay, 1, "ВОЗВРАТ ОТ ЩИТА ×2")
	_set_duration_button(_node("Shield", "Duration"), SaveManager.shield_duration, SaveManager.shield_gameplay >= 1)
	_set_gameplay_button(_node("Magnet", "Gameplay"), SaveManager.magnet_gameplay, 2, _magnet_text())
	_set_duration_button(_node("Magnet", "Duration"), SaveManager.magnet_duration, SaveManager.magnet_gameplay >= 2)

func _set_gameplay_button(button: Button, rank: int, max_rank: int, description: String):
	var complete := rank >= max_rank
	var affordable := SaveManager.can_afford_skill()
	button.disabled = complete or not affordable
	button.text = description + ("    ✓" if complete else "    %d/%d  •  5 SP" % [rank, max_rank])
	_apply_node_style(button, complete, affordable and not complete)

func _set_duration_button(button: Button, rank: int, prerequisite_met: bool):
	var stars := ""
	for i in range(SaveManager.MAX_DURATION_RANK):
		stars += "★" if i < rank else "☆"
	var complete := rank >= SaveManager.MAX_DURATION_RANK
	var available := prerequisite_met and SaveManager.can_afford_skill() and not complete
	button.disabled = not available
	if complete:
		button.text = "ПРОДОЛЖИТЕЛЬНОСТЬ   %s\n+%.1f сек   ✓" % [stars, rank * 0.5]
	elif prerequisite_met:
		button.text = "ПРОДОЛЖИТЕЛЬНОСТЬ   %s\n+%.1f → +%.1f сек   •   5 SP" % [stars, rank * 0.5, (rank + 1) * 0.5]
	else:
		button.text = "ПРОДОЛЖИТЕЛЬНОСТЬ   %s\nЗАБЛОКИРОВАНО" % stars
	_apply_node_style(button, complete, available)

func _explosive_text() -> String:
	match SaveManager.explosive_gameplay:
		0: return "I   МГНОВЕННО ×2"
		1: return "II  МГНОВЕННО ×3"
		_: return "III МГНОВЕННО ×5"

func _magnet_text() -> String:
	if SaveManager.magnet_gameplay == 0:
		return "I   КОРОТКИЙ ПРИЦЕЛ"
	return "II  ДАЛЬНИЙ ПРИЦЕЛ"

func _purchase(callable: Callable, success_text: String):
	if callable.call(): status_label.text = success_text
	else: status_label.text = "Улучшение сейчас недоступно."
	_refresh()

func _on_piercing_gameplay_pressed(): _purchase(SaveManager.purchase_piercing_gameplay, "PIERCING улучшен.")
func _on_piercing_duration_pressed(): _purchase(SaveManager.purchase_piercing_duration, "PIERCING: продолжительность увеличена.")
func _on_explosive_gameplay_pressed(): _purchase(SaveManager.purchase_explosive_gameplay, "EXPLOSIVE улучшен.")
func _on_explosive_duration_pressed(): _purchase(SaveManager.purchase_explosive_duration, "EXPLOSIVE: продолжительность увеличена.")
func _on_shield_gameplay_pressed(): _purchase(SaveManager.purchase_shield_gameplay, "SHIELD улучшен.")
func _on_shield_duration_pressed(): _purchase(SaveManager.purchase_shield_duration, "SHIELD: продолжительность увеличена.")
func _on_magnet_gameplay_pressed(): _purchase(SaveManager.purchase_magnet_gameplay, "MAGNET улучшен.")
func _on_magnet_duration_pressed(): _purchase(SaveManager.purchase_magnet_duration, "MAGNET: продолжительность увеличена.")
func _on_back_pressed(): _back_to_menu()
func _back_to_menu(): get_tree().change_scene_to_file(MAIN_MENU_SCENE)
