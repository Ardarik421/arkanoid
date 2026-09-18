extends Control

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const BONUS_SCENE: PackedScene = preload("res://scenes/bonus.tscn")
const BRICK_SCENE: PackedScene = preload("res://scenes/brick.tscn")
var animation_time: float = 0.0

const BONUSES: Array[Dictionary] = [
	{"type":4,"title":"УСКОРЕНИЕ","text":"Ускоряет шар"},
	{"type":3,"title":"ГИПЕРСКОРОСТЬ","text":"Сильно ускоряет шар"},
	{"type":0,"title":"РАСШИРЕНИЕ","text":"Увеличивает платформу"},
	{"type":1,"title":"УМЕНЬШЕНИЕ","text":"Уменьшает платформу"},
	{"type":2,"title":"ЖИЗНЬ","text":"Добавляет одну жизнь"},
	{"type":5,"title":"МУЛЬТИШАР","text":"Добавляет дополнительные шары"},
	{"type":6,"title":"ПРОБИВАНИЕ","text":"Позволяет шару пробивать кирпичи"},
	{"type":7,"title":"ВЗРЫВ","text":"Разрушает область вокруг кирпича"},
	{"type":8,"title":"ЩИТ","text":"Возвращает упавший шар в игру"},
	{"type":9,"title":"МАГНИТ","text":"Ловит шар на платформу перед запуском"}
]
const BRICKS: Array[Dictionary] = [
	{"hits":1,"title":"ОБЫЧНЫЙ КИРПИЧ","text":"Разрушается с одного удара"},
	{"hits":2,"title":"КРЕПКИЙ КИРПИЧ","text":"Требует два удара"},
	{"hits":3,"title":"ОЧЕНЬ КРЕПКИЙ КИРПИЧ","text":"Требует три удара"},
	{"hits":1,"bonus":true,"title":"КИРПИЧ С БОНУСОМ","text":"Гарантированно содержит бонус"},
	{"hits":1,"powerful":true,"title":"КИРПИЧ С ОСОБЫМ БОНУСОМ","text":"Гарантированно содержит мощный бонус"},
	{"hits":5,"dark":true,"title":"ТЁМНЫЙ КИРПИЧ","text":"Выдерживает пять ударов"}
]

func _ready() -> void:
	_build_bonus_cards()
	_build_brick_cards()
	_style()
	$Margin/VBox/BackButton.grab_focus()
	queue_redraw()

func _process(delta: float) -> void:
	animation_time += delta
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()

func _draw() -> void:
	var pulse: float = 0.5 + 0.5 * sin(animation_time * 0.65)
	draw_rect(Rect2(Vector2.ZERO,size),Color(0.003,0.007,0.014),true)
	for i in range(62):
		var p:=Vector2(float((i*173+43)%int(size.x)),float((i*109+31)%int(size.y)))
		var twinkle:=0.5+0.5*sin(animation_time*0.45+float(i)*1.41)
		draw_circle(p,0.6+float(i%3)*0.3,Color(1.0,0.82,0.42,0.07+twinkle*0.20))
	draw_line(Vector2(90,116),Vector2(size.x-90,116),Color(1.0,0.64,0.16,0.14+pulse*0.05),1.0,true)

func _build_bonus_cards() -> void:
	for data in BONUSES:
		var visual: Node2D = BONUS_SCENE.instantiate()
		visual.set("forced_bonus_type",int(data["type"]))
		visual.set("fall_speed",0.0)
		_add_card($Margin/VBox/BonusGrid,visual,str(data["title"]),str(data["text"]))

func _build_brick_cards() -> void:
	for data in BRICKS:
		var visual: Node2D = BRICK_SCENE.instantiate()
		var hits: int = int(data["hits"])
		visual.set("health",hits)
		visual.set("max_health",hits)
		visual.set("indestructible",bool(data.get("dark",false)))
		visual.set("guaranteed_bonus",bool(data.get("bonus",false)) or bool(data.get("powerful",false)))
		visual.set("powerful_bonus",bool(data.get("powerful",false)))
		_add_card($Margin/VBox/BrickGrid,visual,str(data["title"]),str(data["text"]))
		if bool(data.get("bonus",false)) or bool(data.get("powerful",false)):
			var badge:=BonusBadge.new()
			badge.powerful=bool(data.get("powerful",false))
			visual.add_child(badge)

func _add_card(grid: GridContainer, visual: Node2D, title_text: String, desc_text: String) -> void:
	var card:=PanelContainer.new()
	card.custom_minimum_size=Vector2(0,88)
	card.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel",_card_style())
	var row:=HBoxContainer.new()
	row.add_theme_constant_override("separation",16)
	card.add_child(row)
	var holder:=Control.new()
	holder.custom_minimum_size=Vector2(92,66)
	row.add_child(holder)
	holder.add_child(visual)
	visual.position=Vector2(46,33)
	if visual is Bonus:
		visual.scale=Vector2(1.55,1.55)
	var texts:=VBoxContainer.new()
	texts.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	texts.alignment=BoxContainer.ALIGNMENT_CENTER
	row.add_child(texts)
	var title:=Label.new()
	title.text=title_text
	title.add_theme_font_size_override("font_size",16)
	title.add_theme_color_override("font_color",Color(1.0,0.84,0.42))
	texts.add_child(title)
	var desc:=Label.new()
	desc.text=desc_text
	desc.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size",14)
	desc.add_theme_color_override("font_color",Color(0.84,0.84,0.78))
	texts.add_child(desc)
	grid.add_child(card)

func _style() -> void:
	$Margin/VBox/Title.add_theme_font_size_override("font_size",36)
	$Margin/VBox/Title.add_theme_color_override("font_color",Color(1.0,0.94,0.74))
	$Margin/VBox/Subtitle.add_theme_font_size_override("font_size",15)
	$Margin/VBox/Subtitle.add_theme_color_override("font_color",Color(0.90,0.78,0.56))
	for header in [$Margin/VBox/BonusHeader,$Margin/VBox/BrickHeader]:
		header.add_theme_font_size_override("font_size",22)
		header.add_theme_color_override("font_color",Color(1.0,0.88,0.56))
	$Margin/VBox/BackButton.add_theme_font_size_override("font_size",20)
	var normal:=_button_style(Color(0.58,0.38,0.12,0.50),Color(0.018,0.025,0.030,0.90),1)
	var hover:=_button_style(Color(1.0,0.72,0.24,0.92),Color(0.075,0.050,0.018,0.96),2)
	$Margin/VBox/BackButton.add_theme_stylebox_override("normal",normal)
	$Margin/VBox/BackButton.add_theme_stylebox_override("hover",hover)
	$Margin/VBox/BackButton.add_theme_stylebox_override("focus",hover)
	$Margin/VBox/BackButton.add_theme_color_override("font_color",Color(0.94,0.87,0.68))

func _card_style() -> StyleBoxFlat:
	var s:=StyleBoxFlat.new()
	s.bg_color=Color(0.006,0.012,0.018,0.90)
	s.border_color=Color(0.72,0.46,0.10,0.42)
	s.set_border_width_all(1); s.set_corner_radius_all(12)
	s.content_margin_left=12; s.content_margin_right=12; s.content_margin_top=7; s.content_margin_bottom=7
	return s

func _button_style(border:Color,bg:Color,width:int)->StyleBoxFlat:
	var s:=StyleBoxFlat.new(); s.bg_color=bg; s.border_color=border
	s.set_border_width_all(width); s.set_corner_radius_all(10)
	return s

func _back() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

class BonusBadge extends Node2D:
	var powerful: bool=false
	func _draw()->void:
		var c:=Color(1.0,0.82,0.22) if not powerful else Color(1.0,0.30,0.82)
		var points:=PackedVector2Array()
		for i in range(10):
			var a:float=-PI/2.0+TAU*float(i)/10.0
			var r:float=8.0 if i%2==0 else 3.8
			points.append(Vector2(cos(a),sin(a))*r)
		draw_colored_polygon(points,Color(c,0.92))
		draw_polyline(PackedVector2Array(Array(points)+[points[0]]),Color.WHITE,1.0,true)
