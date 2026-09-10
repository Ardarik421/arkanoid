extends Node2D

var displayed_level: int = -1
var rock_shapes: Array[PackedVector2Array] = []
var mid_rock_shapes: Array[PackedVector2Array] = []
var ember_points: Array[Vector2] = []
var small_cracks: Array[PackedVector2Array] = []

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
		PackedVector2Array([Vector2(0, 1080), Vector2(0, 470), Vector2(42, 445), Vector2(78, 475), Vector2(104, 535), Vector2(145, 570), Vector2(126, 635), Vector2(171, 690), Vector2(145, 756), Vector2(190, 824), Vector2(168, 900), Vector2(220, 970), Vector2(205, 1080)]),
		PackedVector2Array([Vector2(960, 1080), Vector2(960, 430), Vector2(920, 405), Vector2(884, 442), Vector2(858, 505), Vector2(817, 548), Vector2(836, 616), Vector2(795, 681), Vector2(820, 752), Vector2(778, 820), Vector2(801, 900), Vector2(748, 978), Vector2(760, 1080)]),
		PackedVector2Array([Vector2(92, 1080), Vector2(135, 970), Vector2(184, 912), Vector2(235, 872), Vector2(286, 900), Vector2(322, 964), Vector2(337, 1080)]),
		PackedVector2Array([Vector2(618, 1080), Vector2(635, 966), Vector2(681, 902), Vector2(729, 878), Vector2(781, 909), Vector2(820, 984), Vector2(844, 1080)])
	]

	mid_rock_shapes = [
		PackedVector2Array([Vector2(0, 790), Vector2(0, 600), Vector2(36, 577), Vector2(68, 610), Vector2(84, 663), Vector2(61, 715)]),
		PackedVector2Array([Vector2(960, 770), Vector2(960, 565), Vector2(925, 548), Vector2(895, 582), Vector2(881, 640), Vector2(905, 706)]),
		PackedVector2Array([Vector2(235, 1080), Vector2(269, 1010), Vector2(307, 982), Vector2(351, 1004), Vector2(375, 1080)]),
		PackedVector2Array([Vector2(590, 1080), Vector2(612, 1009), Vector2(651, 979), Vector2(695, 1001), Vector2(721, 1080)])
	]

	ember_points = [
		Vector2(104, 742), Vector2(151, 826), Vector2(222, 929), Vector2(303, 1015),
		Vector2(683, 934), Vector2(748, 828), Vector2(849, 716), Vector2(902, 594),
		Vector2(70, 633), Vector2(880, 894), Vector2(394, 1032), Vector2(559, 1008),
		Vector2(54, 892), Vector2(916, 833), Vector2(270, 758), Vector2(713, 742),
		Vector2(333, 883), Vector2(621, 847), Vector2(447, 941), Vector2(520, 788)
	]

	small_cracks = [
		PackedVector2Array([Vector2(18, 584), Vector2(48, 610), Vector2(39, 649), Vector2(67, 678)]),
		PackedVector2Array([Vector2(944, 530), Vector2(918, 563), Vector2(927, 602), Vector2(899, 633)]),
		PackedVector2Array([Vector2(132, 907), Vector2(162, 884), Vector2(183, 901), Vector2(202, 878)]),
		PackedVector2Array([Vector2(828, 901), Vector2(803, 875), Vector2(781, 895), Vector2(756, 870)]),
		PackedVector2Array([Vector2(282, 1034), Vector2(306, 1013), Vector2(326, 1030), Vector2(346, 1008)]),
		PackedVector2Array([Vector2(674, 1037), Vector2(652, 1015), Vector2(632, 1032), Vector2(611, 1010)])
	]

func _draw():
	var chapter_level = clamp(displayed_level, 1, 10)
	var progress = float(chapter_level - 1) / 9.0

	_draw_cavern_depth(progress)
	_draw_distant_rock(progress)
	_draw_depth_haze(progress)
	_draw_rock_mass(progress)
	_draw_lava_fissures(progress)
	_draw_rock_texture(progress)
	_draw_embres(progress)
	_draw_vignette()

func _draw_cavern_depth(progress: float):
	var top_color = Color(0.010, 0.012, 0.016).lerp(Color(0.026, 0.015, 0.014), progress)
	var bottom_color = Color(0.020, 0.012, 0.014).lerp(Color(0.075, 0.023, 0.012), progress)

	for y in range(0, 1080, 18):
		var t = float(y) / 1080.0
		var vertical = pow(t, 1.55)
		var band_color = top_color.lerp(bottom_color, vertical)
		draw_rect(Rect2(0, y, 960, 18), band_color)

	for i in range(7):
		var radius = 430.0 - float(i) * 48.0
		var alpha = 0.012 + float(i) * 0.004
		draw_circle(Vector2(480, 760), radius, Color(0.0, 0.0, 0.0, alpha))

func _draw_distant_rock(progress: float):
	for shape in mid_rock_shapes:
		draw_colored_polygon(shape, Color(0.020 + progress * 0.010, 0.022 + progress * 0.006, 0.026 + progress * 0.003, 0.86))
		var outline = PackedVector2Array(shape)
		outline.append(shape[0])
		draw_polyline(outline, Color(0.16, 0.065, 0.035, 0.14 + progress * 0.08), 2.0, true)

func _draw_depth_haze(progress: float):
	var center = Vector2(480, 965)
	for radius in range(520, 80, -44):
		var depth = 1.0 - float(radius) / 560.0
		var alpha = (0.004 + progress * 0.009) * depth
		draw_circle(center, radius, Color(0.72, 0.11, 0.018, alpha))

	for i in range(6):
		var y = 760.0 + float(i) * 52.0
		var width_value = 270.0 + float(i) * 54.0
		var alpha = (0.006 + progress * 0.010) * (1.0 - float(i) * 0.09)
		_draw_haze_ellipse(Vector2(480, y), Vector2(width_value, 30.0 + float(i) * 5.0), Color(0.65, 0.12, 0.025, alpha))

func _draw_haze_ellipse(center: Vector2, radii: Vector2, color: Color):
	var points = PackedVector2Array()
	for i in range(33):
		var angle = TAU * float(i) / 32.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)

func _draw_rock_mass(progress: float):
	for i in range(rock_shapes.size()):
		var base = Color(0.026, 0.028, 0.031)
		var lift = 0.008 + progress * 0.013 + float(i % 2) * 0.004
		var rock_color = Color(base.r + lift, base.g + lift * 0.72, base.b + lift * 0.48)
		draw_colored_polygon(rock_shapes[i], rock_color)

		var outline = PackedVector2Array(rock_shapes[i])
		outline.append(rock_shapes[i][0])
		draw_polyline(outline, Color(0.22, 0.075, 0.035, 0.18 + progress * 0.10), 2.0, true)

		for p in range(1, rock_shapes[i].size() - 1, 2):
			var point = rock_shapes[i][p]
			var inward = Vector2(18.0 if point.x < 480.0 else -18.0, 24.0)
			draw_line(point, point + inward, Color(0.18, 0.16, 0.15, 0.16), 1.0, true)

func _draw_lava_fissures(progress: float):
	var dim = Color(0.30, 0.045, 0.010, 0.34 + progress * 0.16)
	var hot = Color(0.96, 0.18 + progress * 0.09, 0.018, 0.52 + progress * 0.27)
	var core = Color(1.0, 0.60, 0.12, 0.22 + progress * 0.42)

	var cracks = [
		PackedVector2Array([Vector2(35, 1075), Vector2(68, 1018), Vector2(57, 960), Vector2(91, 914), Vector2(78, 858), Vector2(112, 811), Vector2(102, 756), Vector2(132, 711)]),
		PackedVector2Array([Vector2(925, 1070), Vector2(892, 1014), Vector2(903, 955), Vector2(870, 909), Vector2(882, 852), Vector2(849, 804), Vector2(860, 748), Vector2(830, 703)]),
		PackedVector2Array([Vector2(236, 1078), Vector2(260, 1040), Vector2(253, 1005), Vector2(279, 972), Vector2(270, 940)]),
		PackedVector2Array([Vector2(724, 1078), Vector2(701, 1041), Vector2(708, 1006), Vector2(683, 974), Vector2(691, 941)])
	]

	for crack in cracks:
		draw_polyline(crack, dim, 8.0, true)
		draw_polyline(crack, hot, 3.2, true)
		draw_polyline(crack, core, 1.0, true)

	var small_count = int(2 + progress * float(small_cracks.size() - 2))
	for i in range(small_count):
		draw_polyline(small_cracks[i], Color(dim, dim.a * 0.75), 3.0, true)
		draw_polyline(small_cracks[i], Color(hot, hot.a * 0.62), 1.0, true)

	var horizon_alpha = 0.09 + progress * 0.18
	for radius in range(330, 80, -42):
		var ring_t = 1.0 - float(radius - 80) / 250.0
		var color = Color(0.92, 0.12 + ring_t * 0.10, 0.012, horizon_alpha * ring_t * 0.30)
		draw_circle(Vector2(480, 1125), radius + progress * 36.0, color)

	draw_circle(Vector2(480, 1128), 116.0 + progress * 38.0, Color(1.0, 0.30, 0.018, 0.12 + progress * 0.18))
	draw_circle(Vector2(480, 1138), 72.0 + progress * 24.0, Color(1.0, 0.58, 0.08, 0.08 + progress * 0.14))

func _draw_rock_texture(progress: float):
	var facets = [
		[Vector2(18, 538), Vector2(64, 505), Vector2(98, 550)],
		[Vector2(22, 700), Vector2(75, 660), Vector2(112, 718)],
		[Vector2(46, 865), Vector2(103, 823), Vector2(145, 883)],
		[Vector2(842, 520), Vector2(892, 474), Vector2(940, 531)],
		[Vector2(835, 681), Vector2(890, 638), Vector2(944, 699)],
		[Vector2(813, 854), Vector2(870, 811), Vector2(925, 873)],
		[Vector2(173, 982), Vector2(229, 925), Vector2(286, 970)],
		[Vector2(675, 969), Vector2(732, 921), Vector2(790, 980)]
	]

	for facet in facets:
		var polygon = PackedVector2Array(facet)
		draw_colored_polygon(polygon, Color(0.12, 0.10, 0.09, 0.055 + progress * 0.025))
		draw_polyline(PackedVector2Array([polygon[0], polygon[1], polygon[2], polygon[0]]), Color(0.28, 0.12, 0.065, 0.08 + progress * 0.04), 1.0, true)

func _draw_embres(progress: float):
	var visible_count = int(6 + progress * float(ember_points.size() - 6))
	for i in range(visible_count):
		var point = ember_points[i]
		var radius = 0.8 + float(i % 3) * 0.45
		var alpha = 0.14 + progress * 0.30
		draw_circle(point, radius + 2.5, Color(1.0, 0.12, 0.01, alpha * 0.08))
		draw_circle(point, radius, Color(1.0, 0.36, 0.045, alpha))

func _draw_vignette():
	for i in range(12):
		var inset = float(i) * 9.0
		var alpha = 0.014 + float(i) * 0.004
		draw_rect(Rect2(inset, inset, 960.0 - inset * 2.0, 1080.0 - inset * 2.0), Color(0.0, 0.0, 0.0, alpha), false, 18.0)
