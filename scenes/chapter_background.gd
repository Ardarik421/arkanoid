extends Node2D

var displayed_level: int = -1
var rock_shapes: Array[PackedVector2Array] = []
var ember_points: Array[Vector2] = []

func _ready():
	_build_environment()
	call_deferred("_sync_level")
	queue_redraw()

func _process(_delta):
	var main = get_parent()
	if main == null:
		return

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
		PackedVector2Array([Vector2(0, 1080), Vector2(0, 530), Vector2(70, 485), Vector2(130, 520), Vector2(180, 610), Vector2(160, 730), Vector2(205, 820), Vector2(175, 930), Vector2(240, 1080)]),
		PackedVector2Array([Vector2(960, 1080), Vector2(960, 460), Vector2(905, 420), Vector2(845, 470), Vector2(810, 570), Vector2(835, 665), Vector2(790, 770), Vector2(820, 890), Vector2(755, 1080)]),
		PackedVector2Array([Vector2(135, 1080), Vector2(190, 900), Vector2(260, 835), Vector2(325, 865), Vector2(350, 955), Vector2(330, 1080)]),
		PackedVector2Array([Vector2(630, 1080), Vector2(650, 930), Vector2(710, 860), Vector2(775, 885), Vector2(810, 980), Vector2(835, 1080)])
	]

	ember_points = [
		Vector2(104, 742), Vector2(151, 826), Vector2(222, 929), Vector2(303, 1015),
		Vector2(683, 934), Vector2(748, 828), Vector2(849, 716), Vector2(902, 594),
		Vector2(70, 633), Vector2(880, 894), Vector2(394, 1032), Vector2(559, 1008)
	]

func _draw():
	var chapter_level = clamp(displayed_level, 1, 10)
	var progress = float(chapter_level - 1) / 9.0

	var top_color = Color(0.018, 0.022, 0.030).lerp(Color(0.050, 0.026, 0.024), progress)
	var bottom_color = Color(0.030, 0.018, 0.020).lerp(Color(0.11, 0.035, 0.018), progress)

	for y in range(0, 1080, 24):
		var t = float(y) / 1080.0
		var band_color = top_color.lerp(bottom_color, t)
		draw_rect(Rect2(0, y, 960, 24), band_color)

	_draw_depth_haze(progress)
	_draw_rock_mass(progress)
	_draw_lava_fissures(progress)
	_draw_embres(progress)
	_draw_vignette()

func _draw_depth_haze(progress: float):
	var center = Vector2(480, 850)
	for radius in range(520, 80, -55):
		var alpha = lerp(0.006, 0.022, progress) * (1.0 - float(radius) / 600.0)
		draw_circle(center, radius, Color(0.55, 0.10, 0.025, alpha))

func _draw_rock_mass(progress: float):
	for i in range(rock_shapes.size()):
		var base = Color(0.025, 0.030, 0.038)
		var lift = 0.016 + progress * 0.022 + float(i % 2) * 0.008
		var rock_color = Color(base.r + lift, base.g + lift * 0.78, base.b + lift * 0.60)
		draw_colored_polygon(rock_shapes[i], rock_color)

		var outline = PackedVector2Array(rock_shapes[i])
		outline.append(rock_shapes[i][0])
		draw_polyline(outline, Color(0.16, 0.12, 0.12, 0.32), 2.0, true)

func _draw_lava_fissures(progress: float):
	var dim = Color(0.42, 0.075, 0.018, 0.45 + progress * 0.18)
	var hot = Color(1.0, 0.28 + progress * 0.10, 0.035, 0.60 + progress * 0.30)
	var core = Color(1.0, 0.70, 0.20, 0.30 + progress * 0.50)

	var cracks = [
		PackedVector2Array([Vector2(38, 1055), Vector2(86, 955), Vector2(72, 865), Vector2(118, 782), Vector2(105, 690), Vector2(146, 618)]),
		PackedVector2Array([Vector2(922, 1038), Vector2(878, 948), Vector2(898, 866), Vector2(854, 776), Vector2(872, 680), Vector2(830, 598)]),
		PackedVector2Array([Vector2(236, 1078), Vector2(268, 1002), Vector2(257, 946), Vector2(296, 899)]),
		PackedVector2Array([Vector2(733, 1078), Vector2(706, 1008), Vector2(718, 951), Vector2(686, 906)])
	]

	for crack in cracks:
		draw_polyline(crack, dim, 7.0, true)
		draw_polyline(crack, hot, 3.0, true)
		draw_polyline(crack, core, 1.0, true)

	var horizon_alpha = 0.16 + progress * 0.28
	draw_circle(Vector2(480, 1090), 240 + progress * 85.0, Color(0.75, 0.11, 0.015, horizon_alpha))
	draw_circle(Vector2(480, 1105), 150 + progress * 65.0, Color(1.0, 0.31, 0.025, horizon_alpha * 0.72))

func _draw_embres(progress: float):
	var visible_count = int(4 + progress * float(ember_points.size() - 4))
	for i in range(visible_count):
		var point = ember_points[i]
		var radius = 1.0 + float(i % 3) * 0.55
		var alpha = 0.18 + progress * 0.38
		draw_circle(point, radius + 3.0, Color(1.0, 0.15, 0.02, alpha * 0.10))
		draw_circle(point, radius, Color(1.0, 0.42, 0.08, alpha))

func _draw_vignette():
	for i in range(10):
		var inset = float(i) * 10.0
		var alpha = 0.018 + float(i) * 0.006
		draw_rect(Rect2(inset, inset, 960.0 - inset * 2.0, 1080.0 - inset * 2.0), Color(0.0, 0.0, 0.0, alpha), false, 20.0)
