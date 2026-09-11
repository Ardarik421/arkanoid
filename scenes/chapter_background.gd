extends Node2D

var displayed_level: int = -1
var animation_time: float = 0.0
var rock_shapes: Array[PackedVector2Array] = []
var mid_rock_shapes: Array[PackedVector2Array] = []
var ember_points: Array[Vector2] = []
var small_cracks: Array[PackedVector2Array] = []

func _ready():
	_build_environment()
	call_deferred("_sync_level")
	queue_redraw()

func _process(delta):
	animation_time += delta
	var main = get_parent()
	if main != null:
		var level_value = int(main.get("current_level"))
		if level_value != displayed_level:
			displayed_level = level_value
	queue_redraw()

func _sync_level():
	var main = get_parent()
	if main != null:
		displayed_level = int(main.get("current_level"))
	queue_redraw()

func _build_environment():
	rock_shapes = [
		PackedVector2Array([Vector2(0,1080),Vector2(0,470),Vector2(42,445),Vector2(78,475),Vector2(104,535),Vector2(145,570),Vector2(126,635),Vector2(171,690),Vector2(145,756),Vector2(190,824),Vector2(168,900),Vector2(220,970),Vector2(205,1080)]),
		PackedVector2Array([Vector2(960,1080),Vector2(960,430),Vector2(920,405),Vector2(884,442),Vector2(858,505),Vector2(817,548),Vector2(836,616),Vector2(795,681),Vector2(820,752),Vector2(778,820),Vector2(801,900),Vector2(748,978),Vector2(760,1080)])
	]
	mid_rock_shapes = [
		PackedVector2Array([Vector2(0,790),Vector2(0,600),Vector2(36,577),Vector2(68,610),Vector2(84,663),Vector2(61,715)]),
		PackedVector2Array([Vector2(960,770),Vector2(960,565),Vector2(925,548),Vector2(895,582),Vector2(881,640),Vector2(905,706)])
	]
	ember_points = [Vector2(104,742),Vector2(151,826),Vector2(222,929),Vector2(303,1015),Vector2(683,934),Vector2(748,828),Vector2(849,716),Vector2(902,594),Vector2(70,633),Vector2(880,894),Vector2(394,1032),Vector2(559,1008)]
	small_cracks = [
		PackedVector2Array([Vector2(18,584),Vector2(48,610),Vector2(39,649),Vector2(67,678)]),
		PackedVector2Array([Vector2(944,530),Vector2(918,563),Vector2(927,602),Vector2(899,633)])
	]

func _draw():
	if displayed_level <= 10:
		_draw_core()
	else:
		_draw_surface()
	_draw_vignette()

func _draw_core():
	var chapter_level = clamp(displayed_level, 1, 10)
	var progress = float(chapter_level - 1) / 9.0
	_draw_cavern_depth(progress)
	_draw_distant_rock(progress)
	_draw_depth_haze(progress)
	_draw_rock_mass(progress)
	_draw_lava_fissures(progress)
	_draw_rock_texture(progress)
	_draw_embres(progress)

func _draw_surface():
	var chapter_level = clamp(displayed_level, 11, 20)
	var progress = float(chapter_level - 11) / 9.0
	_draw_surface_sky(progress)
	_draw_surface_horizon(progress)
	_draw_surface_cliffs(progress)
	_draw_surface_crystals(progress)
	_draw_surface_dust(progress)

func _draw_surface_sky(progress: float):
	var top = Color(0.018,0.035,0.055).lerp(Color(0.025,0.065,0.10), progress)
	var bottom = Color(0.055,0.085,0.105).lerp(Color(0.075,0.13,0.15), progress)
	for y in range(0,1080,18):
		var t = float(y) / 1080.0
		draw_rect(Rect2(0,y,960,18), top.lerp(bottom,t))
	var glow = 0.5 + 0.5 * sin(animation_time * 0.25)
	for r in range(310,60,-35):
		draw_circle(Vector2(760,245),r,Color(0.16,0.42,0.55,(1.0-float(r)/330.0)*0.012*(0.85+glow*0.15)))
	for i in range(24):
		var x = float((i*137+61)%960)
		var y = 90.0 + float((i*83)%390)
		draw_circle(Vector2(x,y),1.0+float(i%2)*0.5,Color(0.62,0.82,0.9,0.12+0.08*sin(animation_time*0.7+i)))

func _draw_surface_horizon(progress: float):
	var distant = PackedVector2Array([Vector2(0,610),Vector2(90,570),Vector2(165,590),Vector2(250,530),Vector2(340,575),Vector2(430,545),Vector2(520,585),Vector2(610,520),Vector2(700,565),Vector2(805,505),Vector2(960,555),Vector2(960,1080),Vector2(0,1080)])
	draw_colored_polygon(distant,Color(0.035,0.065,0.075,0.92))
	var rim = PackedVector2Array([Vector2(0,610),Vector2(90,570),Vector2(165,590),Vector2(250,530),Vector2(340,575),Vector2(430,545),Vector2(520,585),Vector2(610,520),Vector2(700,565),Vector2(805,505),Vector2(960,555)])
	draw_polyline(rim,Color(0.18,0.48,0.54,0.28+progress*0.12),2.0,true)

func _draw_surface_cliffs(progress: float):
	var left = PackedVector2Array([Vector2(0,1080),Vector2(0,650),Vector2(55,620),Vector2(105,665),Vector2(145,740),Vector2(122,815),Vector2(185,900),Vector2(220,1080)])
	var right = PackedVector2Array([Vector2(960,1080),Vector2(960,620),Vector2(900,595),Vector2(850,650),Vector2(820,730),Vector2(842,805),Vector2(780,900),Vector2(742,1080)])
	for cliff in [left,right]:
		draw_colored_polygon(cliff,Color(0.045,0.06,0.064,0.96))
		var outline = PackedVector2Array(cliff)
		outline.append(cliff[0])
		draw_polyline(outline,Color(0.18,0.34,0.36,0.26),2.0,true)
	for i in range(7):
		var y = 700.0 + i*48.0
		draw_line(Vector2(18,y),Vector2(92+i*5,y-18),Color(0.16,0.25,0.25,0.18),1.0,true)
		draw_line(Vector2(942,y-25),Vector2(868-i*4,y),Color(0.16,0.25,0.25,0.18),1.0,true)

func _draw_surface_crystals(progress: float):
	var pulse = 0.82 + 0.18*sin(animation_time*0.8)
	var positions = [Vector2(72,850),Vector2(135,930),Vector2(825,875),Vector2(900,790),Vector2(270,1025),Vector2(690,1015)]
	for i in range(positions.size()):
		var p = positions[i]
		var h = 25.0 + float((i*17)%38)
		var w = 8.0 + float(i%3)*3.0
		var crystal = PackedVector2Array([p+Vector2(-w,0),p+Vector2(-w*0.55,-h*0.65),p+Vector2(0,-h),p+Vector2(w*0.55,-h*0.65),p+Vector2(w,0)])
		draw_colored_polygon(crystal,Color(0.08,0.30+progress*0.08,0.36+progress*0.10,0.55))
		draw_polyline(PackedVector2Array([crystal[0],crystal[1],crystal[2],crystal[3],crystal[4]]),Color(0.32,0.78,0.82,0.42*pulse),1.5,true)
		draw_line(p+Vector2(0,-h+4),p+Vector2(0,-5),Color(0.55,0.95,0.95,0.20*pulse),1.0,true)

func _draw_surface_dust(progress: float):
	var count = 10 + int(progress*8.0)
	for i in range(count):
		var x = float((i*113+47)%900)+30.0
		var base_y = 570.0+float((i*71)%440)
		var rise = fmod(animation_time*(3.0+float(i%4))+i*29.0,95.0)
		var drift = sin(animation_time*0.35+i*1.7)*5.0
		draw_circle(Vector2(x+drift,base_y-rise),1.0+float(i%2)*0.5,Color(0.35,0.72,0.70,0.08+progress*0.06))

func _draw_cavern_depth(progress: float):
	var top_color = Color(0.010,0.012,0.016).lerp(Color(0.026,0.015,0.014),progress)
	var bottom_color = Color(0.020,0.012,0.014).lerp(Color(0.075,0.023,0.012),progress)
	for y in range(0,1080,18):
		var t = float(y)/1080.0
		draw_rect(Rect2(0,y,960,18),top_color.lerp(bottom_color,pow(t,1.55)))

func _draw_distant_rock(progress: float):
	for shape in mid_rock_shapes:
		draw_colored_polygon(shape,Color(0.025,0.025,0.028,0.86))

func _draw_depth_haze(progress: float):
	var pulse = 0.5+0.5*sin(animation_time*0.42)
	for radius in range(520,80,-44):
		var depth = 1.0-float(radius)/560.0
		draw_circle(Vector2(480,965),radius,Color(0.72,0.11,0.018,(0.004+progress*0.009)*depth*(0.82+pulse*0.3)))

func _draw_rock_mass(progress: float):
	for shape in rock_shapes:
		draw_colored_polygon(shape,Color(0.035+progress*0.01,0.032,0.031,1.0))

func _draw_lava_fissures(progress: float):
	var pulse = 0.82+0.18*sin(animation_time*1.15)
	var cracks = [PackedVector2Array([Vector2(35,1075),Vector2(68,1018),Vector2(57,960),Vector2(91,914),Vector2(78,858),Vector2(112,811),Vector2(102,756),Vector2(132,711)]),PackedVector2Array([Vector2(925,1070),Vector2(892,1014),Vector2(903,955),Vector2(870,909),Vector2(882,852),Vector2(849,804),Vector2(860,748),Vector2(830,703)])]
	for crack in cracks:
		draw_polyline(crack,Color(0.45,0.06,0.01,0.45),8.0,true)
		draw_polyline(crack,Color(1.0,0.30,0.03,0.75*pulse),2.8,true)

func _draw_rock_texture(progress: float):
	for i in range(8):
		var x = 35.0+float((i*117)%870)
		var y = 650.0+float((i*83)%390)
		draw_line(Vector2(x,y),Vector2(x+35,y-20),Color(0.25,0.12,0.07,0.10),1.0,true)

func _draw_embres(progress: float):
	var visible_count = 6+int(progress*6.0)
	for i in range(visible_count):
		var p = ember_points[i]
		var travel = fmod(animation_time*(7.0+float(i%5)*2.4)+float(i)*37.0,190.0)
		draw_circle(Vector2(p.x+sin(animation_time*0.6+i)*4.0,p.y-travel),1.2,Color(1.0,0.36,0.045,0.22+progress*0.25))

func _draw_vignette():
	for i in range(12):
		var inset = float(i)*9.0
		draw_rect(Rect2(inset,inset,960.0-inset*2.0,1080.0-inset*2.0),Color(0,0,0,0.014+float(i)*0.004),false,18.0)
