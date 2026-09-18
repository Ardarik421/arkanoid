extends Control

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
var animation_time: float = 0.0

const ITEMS: Array[Dictionary] = [
	{"kind":"bonus","icon":"fast","title":"УСКОРЕНИЕ","text":"Ускоряет шар"},
	{"kind":"bonus","icon":"hyper","title":"ГИПЕРСКОРОСТЬ","text":"Сильно ускоряет шар"},
	{"kind":"bonus","icon":"wide","title":"РАСШИРЕНИЕ","text":"Увеличивает платформу"},
	{"kind":"bonus","icon":"shrink","title":"УМЕНЬШЕНИЕ","text":"Уменьшает платформу"},
	{"kind":"bonus","icon":"life","title":"ЖИЗНЬ","text":"Добавляет одну жизнь"},
	{"kind":"bonus","icon":"split","title":"МУЛЬТИШАР","text":"Добавляет дополнительные шары"},
	{"kind":"bonus","icon":"piercing","title":"ПРОБИВАНИЕ","text":"Позволяет шару пробивать кирпичи"},
	{"kind":"bonus","icon":"explosive","title":"ВЗРЫВ","text":"Разрушает область вокруг кирпича"},
	{"kind":"bonus","icon":"shield","title":"ЩИТ","text":"Возвращает упавший шар в игру"},
	{"kind":"bonus","icon":"magnet","title":"МАГНИТ","text":"Ловит шар на платформу перед запуском"},
	{"kind":"brick","hits":1,"title":"ОБЫЧНЫЙ КИРПИЧ","text":"Разрушается с одного удара"},
	{"kind":"brick","hits":2,"title":"КРЕПКИЙ КИРПИЧ","text":"Требует два удара"},
	{"kind":"brick","hits":3,"title":"ОЧЕНЬ КРЕПКИЙ","text":"Требует три удара"},
	{"kind":"brick","hits":5,"title":"ТЁМНЫЙ КИРПИЧ","text":"Выдерживает пять ударов"}
]

func _ready() -> void:
	_build_cards()
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
	draw_line(Vector2(90,118),Vector2(size.x-90,118),Color(1.0,0.64,0.16,0.14+pulse*0.05),1.0,true)

func _build_cards() -> void:
	for data in ITEMS:
		var card:=PanelContainer.new()
		card.custom_minimum_size=Vector2(0,112)
		card.add_theme_stylebox_override("panel",_card_style())
		var row:=HBoxContainer.new()
		row.add_theme_constant_override("separation",14)
		card.add_child(row)
		var visual:=GuideIcon.new()
		visual.custom_minimum_size=Vector2(70,70)
		visual.kind=str(data["kind"])
		visual.icon_type=str(data.get("icon",""))
		visual.hits=int(data.get("hits",1))
		row.add_child(visual)
		var texts:=VBoxContainer.new()
		texts.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		texts.alignment=BoxContainer.ALIGNMENT_CENTER
		row.add_child(texts)
		var title:=Label.new()
		title.text=str(data["title"])
		title.add_theme_font_size_override("font_size",18)
		title.add_theme_color_override("font_color",Color(1.0,0.84,0.42))
		texts.add_child(title)
		var desc:=Label.new()
		desc.text=str(data["text"])
		desc.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_font_size_override("font_size",15)
		desc.add_theme_color_override("font_color",Color(0.84,0.84,0.78))
		texts.add_child(desc)
		$Margin/VBox/Grid.add_child(card)

func _style() -> void:
	$Margin/VBox/Title.add_theme_font_size_override("font_size",38)
	$Margin/VBox/Title.add_theme_color_override("font_color",Color(1.0,0.94,0.74))
	$Margin/VBox/Subtitle.add_theme_font_size_override("font_size",17)
	$Margin/VBox/Subtitle.add_theme_color_override("font_color",Color(0.90,0.78,0.56))
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
	s.content_margin_left=12; s.content_margin_right=12; s.content_margin_top=10; s.content_margin_bottom=10
	return s

func _button_style(border:Color,bg:Color,width:int)->StyleBoxFlat:
	var s:=StyleBoxFlat.new(); s.bg_color=bg; s.border_color=border
	s.set_border_width_all(width); s.set_corner_radius_all(10)
	return s

func _back() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

class GuideIcon extends Control:
	var kind:String="bonus"
	var icon_type:String=""
	var hits:int=1
	func _draw()->void:
		var r:=Rect2(6,12,size.x-12,size.y-24)
		if kind=="brick":
			var cols:Array[Color]=[Color(0.24,0.72,1.0),Color(0.24,0.88,0.52),Color(1.0,0.62,0.16),Color(0.38,0.24,0.48)]
			var col:Color=cols[0 if hits==1 else 1 if hits==2 else 2 if hits==3 else 3]
			draw_rect(r,Color(col,0.13),true); draw_rect(r,Color(col,0.88),false,2.0)
			for i in range(hits):
				var x:=r.position.x+10+float(i)*9
				draw_circle(Vector2(x,r.get_center().y),2.2,Color(col,0.85))
		else:
			var col:=_bonus_color()
			draw_circle(size*0.5,26,Color(col,0.10))
			draw_circle(size*0.5,19,Color(col,0.22))
			var p:=size*0.5
			match icon_type:
				"fast","hyper":
					for i in range(3): draw_line(p+Vector2(-14+i*7,-10),p+Vector2(5+i*7,0),col,3.0,true)
				"wide": draw_rect(Rect2(p-Vector2(24,5),Vector2(48,10)),col,true)
				"shrink": draw_rect(Rect2(p-Vector2(12,5),Vector2(24,10)),col,true)
				"life":
					draw_circle(p+Vector2(-7,-4),8,col); draw_circle(p+Vector2(7,-4),8,col)
					draw_colored_polygon(PackedVector2Array([p+Vector2(-14,0),p+Vector2(14,0),p+Vector2(0,17)]),col)
				"split":
					draw_circle(p+Vector2(-11,3),7,col); draw_circle(p+Vector2(11,3),7,col); draw_circle(p+Vector2(0,-10),7,col)
				"piercing": draw_colored_polygon(PackedVector2Array([p+Vector2(0,-22),p+Vector2(9,0),p+Vector2(0,22),p+Vector2(-9,0)]),col)
				"explosive":
					draw_circle(p,9,col)
					for i in range(8):
						var d:=Vector2.from_angle(TAU*float(i)/8.0)
						draw_line(p+d*12,p+d*23,col,2.5,true)
				"shield":
					var pts:=PackedVector2Array([p+Vector2(0,-21),p+Vector2(17,-13),p+Vector2(14,7),p+Vector2(0,22),p+Vector2(-14,7),p+Vector2(-17,-13)])
					draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[4],pts[5],pts[0]]),col,3.0,true)
				"magnet":
					draw_arc(p,18,0,PI,24,col,6.0,true); draw_line(p+Vector2(-18,0),p+Vector2(-18,-15),col,6.0); draw_line(p+Vector2(18,0),p+Vector2(18,-15),col,6.0)
	func _bonus_color()->Color:
		match icon_type:
			"fast": return Color(1.0,0.78,0.22)
			"hyper": return Color(1.0,0.35,0.12)
			"wide": return Color(0.20,0.82,1.0)
			"shrink": return Color(0.68,0.42,1.0)
			"life": return Color(1.0,0.28,0.42)
			"split": return Color(0.36,1.0,0.62)
			"piercing": return Color(1.0,0.82,0.22)
			"explosive": return Color(1.0,0.23,0.08)
			"shield": return Color(0.20,0.58,1.0)
			"magnet": return Color(0.92,0.24,0.96)
		return Color.WHITE
