extends Control

const GAME_SCENE: String = "res://scenes/main.tscn"
const SKILL_TREE_SCENE: String = "res://scenes/skill_tree.tscn"
const LEVEL_SELECT_SCENE: String = "res://scenes/level_select.tscn"
const GUIDE_SCENE: String = "res://scenes/game_guide.tscn"
var animation_time: float = 0.0

func _ready():
	$Menu/ContinueButton.disabled = SaveManager.highest_unlocked_level <= 1
	$Menu/LevelSelectButton.disabled = false
	_setup_layout()
	_setup_title()
	_setup_buttons()
	_setup_confirmation_dialog()
	MenuMusic.play_menu_music()
	$Menu/NewGameButton.release_focus()
	_setup_gamepad_focus()
	queue_redraw()

func _setup_gamepad_focus() -> void:
	var first_button: Button = $Menu/ContinueButton if not $Menu/ContinueButton.disabled else $Menu/NewGameButton
	first_button.grab_focus()

func _process(delta):
	animation_time += delta
	queue_redraw()

func _draw():
	var viewport_size: Vector2 = size
	var pulse: float = 0.5 + 0.5 * sin(animation_time * 0.72)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.002, 0.006, 0.016, 1.0), true)
	_draw_menu_nebula(viewport_size)
	_draw_menu_stars(viewport_size, pulse)
	_draw_menu_planet(viewport_size, pulse)
	_draw_menu_moon(viewport_size, pulse)
	_draw_menu_orbit_dust(viewport_size, pulse)
	_draw_menu_sun(viewport_size, pulse)
	var panel_margin := Vector2(38.0, 22.0)
	var panel_rect := Rect2($Menu.position - panel_margin, $Menu.size + panel_margin * 2.0)
	draw_style_box(_make_panel_style(), panel_rect)
	draw_line(Vector2(panel_rect.position.x + 52.0,panel_rect.position.y + 3.0),Vector2(panel_rect.end.x - 52.0,panel_rect.position.y + 3.0),Color(1.0,0.78,0.30,0.30+pulse*0.08),1.0,true)
	draw_line(Vector2(panel_rect.position.x + 92.0,panel_rect.end.y + 5.0),Vector2(panel_rect.end.x - 92.0,panel_rect.end.y + 5.0),Color(0.80,0.55,0.18,0.16),1.0,true)

func _draw_menu_nebula(viewport_size: Vector2) -> void:
	var center:=Vector2(viewport_size.x*0.72,viewport_size.y*0.26)
	for i in range(10,0,-1):
		draw_circle(center,70+float(i)*38,Color(0.88,0.46,0.08,0.0038*float(i)))
	for i in range(6):
		var p:=center+Vector2(sin(float(i)*1.7)*210,float(i)*80-180)
		draw_circle(p,90+float(i%3)*28,Color(0.34,0.12,0.36,0.015))

func _draw_menu_stars(viewport_size: Vector2, pulse: float) -> void:
	for i in range(92):
		var x:=float((i*173+47)%int(viewport_size.x))
		var y:=float((i*97+31)%int(viewport_size.y))
		var twinkle:=0.5+0.5*sin(animation_time*(0.45+float(i%5)*0.08)+float(i)*1.37)
		var radius:=0.55+float(i%4)*0.28
		draw_circle(Vector2(x,y),radius,Color(1.0,0.92,0.68,0.10+twinkle*0.30))
		if i%23==0:
			var flare:=5.0+pulse*6.0
			draw_line(Vector2(x-flare,y),Vector2(x+flare,y),Color(1.0,0.82,0.38,0.16),1.0,true)
			draw_line(Vector2(x,y-flare),Vector2(x,y+flare),Color(1.0,0.82,0.38,0.16),1.0,true)

func _draw_menu_planet(viewport_size: Vector2, pulse: float) -> void:
	var center:=Vector2(-75.0,viewport_size.y*0.82)
	var radius:=355.0
	for i in range(12,0,-1):
		draw_circle(center,radius+float(i)*12,Color(1.0,0.65,0.14,0.0035*float(i)))
	draw_circle(center,radius,Color(0.025,0.080,0.078))
	for i in range(8):
		var yy:=center.y-radius*0.55+float(i)*radius*0.14
		var half:=sqrt(maxf(0.0,radius*radius-pow(yy-center.y,2.0)))
		draw_line(Vector2(center.x-half*0.75,yy),Vector2(center.x+half*0.70,yy-10),Color(0.65,0.68,0.40,0.055),15.0,true)
	draw_circle(center+Vector2(-radius*0.46,radius*0.25),radius*0.88,Color(0.001,0.006,0.014,0.62))
	draw_arc(center,radius,-1.55,1.05,128,Color(1.0,0.88,0.46,0.82+pulse*0.08),4.0,true)
	draw_arc(center,radius+10,-1.62,1.12,128,Color(1.0,0.68,0.18,0.28),10.0,true)

func _draw_menu_moon(viewport_size: Vector2, pulse: float) -> void:
	var center:=Vector2(viewport_size.x*0.78,viewport_size.y*0.73)
	var radius:=46.0
	for i in range(5,0,-1):
		draw_circle(center,radius+float(i)*8,Color(1.0,0.70,0.20,0.004*float(i)))
	draw_circle(center,radius,Color(0.045,0.052,0.058,0.96))
	draw_circle(center+Vector2(-12,8),radius*0.72,Color(0.012,0.018,0.025,0.68))
	for i in range(6):
		var a:=float(i)*2.2
		var p:=center+Vector2(cos(a),sin(a))*(10.0+float((i*11)%25))
		draw_circle(p,2.5+float(i%2)*1.8,Color(0.16,0.14,0.10,0.38))
	draw_arc(center,radius,-1.48,1.55,48,Color(1.0,0.82,0.42,0.48+pulse*0.10),1.7,true)

func _draw_menu_orbit_dust(viewport_size: Vector2, pulse: float) -> void:
	for i in range(28):
		var t:=float(i)/27.0
		var x:=viewport_size.x*0.12+t*viewport_size.x*0.88
		var y:=viewport_size.y*0.78-t*viewport_size.y*0.36+sin(float(i)*1.8)*18.0
		var r:=0.7+float(i%4)*0.42
		draw_circle(Vector2(x,y),r,Color(1.0,0.72,0.28,0.07+pulse*0.035))
		if i%7==0:
			draw_line(Vector2(x-5,y),Vector2(x+5,y),Color(1.0,0.82,0.44,0.09),1.0,true)

func _draw_menu_sun(viewport_size: Vector2, pulse: float) -> void:
	var p:=Vector2(viewport_size.x*0.86,145.0)
	for i in range(9,0,-1):
		draw_circle(p,12+float(i)*11,Color(1.0,0.70,0.16,0.006*float(i)*pulse))
	for i in range(16):
		var a:=TAU*float(i)/16.0
		var d:=Vector2(cos(a),sin(a))
		var length:float=(45.0 if i%2==0 else 25.0)*pulse
		draw_line(p+d*9,p+d*length,Color(1.0,0.86,0.42,0.20),1.2,true)
	draw_circle(p,9*pulse,Color(1.0,0.95,0.72,0.92))
	draw_circle(p,3.5*pulse,Color.WHITE)

func _make_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.006, 0.014, 0.025, 0.78)
	style.border_color = Color(0.82, 0.58, 0.22, 0.24)
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	style.shadow_size = 22
	return style

func _setup_layout():
	var landscape := SettingsManager.display_mode == 1
	var menu_width := 430.0 if landscape else 390.0
	var menu_height := 560.0 if landscape else 516.0
	var center := size * 0.5
	$Menu.offset_left = center.x - menu_width * 0.5
	$Menu.offset_top = center.y - menu_height * 0.5
	$Menu.offset_right = center.x + menu_width * 0.5
	$Menu.offset_bottom = center.y + menu_height * 0.5
	$Menu.add_theme_constant_override("separation", 6 if landscape else 15)

func _setup_title():
	var title = $Menu/Title
	title.text = "Space\n     Ball"
	title.custom_minimum_size = Vector2(0, 82 if SettingsManager.display_mode == 1 else 118)
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(1.0, 0.96, 0.78, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.24, 0.12, 0.02, 0.95))
	title.add_theme_constant_override("outline_size", 7)
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 3)
	title.add_theme_color_override("font_shadow_color", Color(0.95, 0.55, 0.12, 0.22))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _setup_buttons():
	for button in [
		$Menu/NewGameButton,
		$Menu/ContinueButton,
		$Menu/LevelSelectButton,
		$Menu/SkillTreeButton,
		$Menu/SettingsButton,
		$Menu/ExitButton
	]:
		_style_button(button)
	_style_guide_button()

func _style_guide_button() -> void:
	var button: Button = $GuideButton
	button.add_theme_color_override("font_color", Color(1.0, 0.90, 0.58))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.82))
	button.add_theme_color_override("font_focus_color", Color(1.0, 0.98, 0.82))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.92, 0.60, 0.14, 0.72), Color(0.025, 0.018, 0.010, 0.88), 2))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(1.0, 0.80, 0.28, 1.0), Color(0.10, 0.060, 0.012, 0.96), 3))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(1.0, 0.80, 0.28, 1.0), Color(0.10, 0.060, 0.012, 0.96), 3))

func _style_button(button: Button):
	button.custom_minimum_size = Vector2(0, 48 if SettingsManager.display_mode == 1 else 62)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color(0.92, 0.86, 0.68, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.86, 1.0))
	button.add_theme_color_override("font_focus_color", Color(1.0, 0.98, 0.86, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.86, 0.48, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.34, 0.42, 0.47, 0.68))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.58, 0.38, 0.12, 0.42), Color(0.018, 0.028, 0.035, 0.78), 1))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(1.0, 0.72, 0.24, 0.90), Color(0.075, 0.055, 0.025, 0.92), 2))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(1.0, 0.80, 0.34, 0.96), Color(0.065, 0.045, 0.020, 0.92), 2))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(1.0, 0.76, 0.24, 1.0), Color(0.095, 0.055, 0.012, 0.96), 2))
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
	dialog.add_theme_color_override("font_color", Color(1.0, 0.94, 0.76, 1.0))
	dialog.add_theme_stylebox_override("panel", _make_dialog_style())
	_style_button(dialog.get_ok_button())
	_style_button(dialog.get_cancel_button())

func _make_dialog_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.008, 0.012, 0.016, 0.985)
	style.border_color = Color(0.92, 0.62, 0.16, 0.72)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	style.shadow_color = Color(0.90, 0.48, 0.08, 0.14)
	style.shadow_size = 16
	return style

func _on_new_game_pressed():
	if SaveManager.highest_unlocked_level > 1:
		$NewGameConfirmation.popup_centered()
		$NewGameConfirmation.get_ok_button().grab_focus()
		return

	start_new_game()

func _on_new_game_confirmed():
	start_new_game()

func _leave_menu_for_game() -> void:
	MenuMusic.stop_menu_music()

func start_new_game():
	SaveManager.reset_progress()
	SaveManager.selected_level = 1
	_leave_menu_for_game()
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_continue_pressed():
	SaveManager.selected_level = SaveManager.highest_unlocked_level
	_leave_menu_for_game()
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_level_select_pressed():
	get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)

func _on_skill_tree_pressed():
	get_tree().change_scene_to_file(SKILL_TREE_SCENE)

func _on_guide_pressed():
	get_tree().change_scene_to_file(GUIDE_SCENE)

func _on_exit_pressed():
	get_tree().quit()
