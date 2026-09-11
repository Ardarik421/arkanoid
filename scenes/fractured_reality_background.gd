class_name FracturedRealityBackground
extends RefCounted

static func draw_background(canvas: Node2D, progress: float, time: float):
	_draw_void(canvas, progress)
	_draw_shards(canvas, progress, time)
	_draw_broken_stars(canvas, progress, time)
	_draw_rift_lines(canvas, progress, time)
	_draw_echo_fragments(canvas, progress, time)
	_draw_gravity_core(canvas, progress, time)

static func _draw_void(canvas: Node2D, progress: float):
	var top = Color(0.006,0.002,0.014).lerp(Color(0.010,0.001,0.010),progress)
	var bottom = Color(0.018,0.004,0.026).lerp(Color(0.028,0.003,0.016),progress)
	for y in range(0,1080,18):
		var t = float(y)/1080.0
		canvas.draw_rect(Rect2(0,y,960,18),top.lerp(bottom,t))

static func _draw_shards(canvas: Node2D, progress: float, time: float):
	var strength = 0.35+progress*0.65
	var shards = [
		PackedVector2Array([Vector2(-40,150),Vector2(150,95),Vector2(115,330),Vector2(-20,410)]),
		PackedVector2Array([Vector2(820,80),Vector2(1030,145),Vector2(970,365),Vector2(790,300)]),
		PackedVector2Array([Vector2(-35,760),Vector2(150,690),Vector2(195,930),Vector2(35,1110)]),
		PackedVector2Array([Vector2(805,720),Vector2(1010,650),Vector2(1000,1010),Vector2(850,940)])
	]
	var colors = [
		Color(0.12,0.28,0.42,0.06),
		Color(0.24,0.10,0.34,0.055),
		Color(0.30,0.13,0.09,0.05),
		Color(0.08,0.31,0.23,0.05)
	]
	for i in range(shards.size()):
		var offset = Vector2(sin(time*0.06+i)*7.0,cos(time*0.045+i*0.8)*5.0)*strength
		var moved = PackedVector2Array()
		for point in shards[i]:
			moved.append(point+offset)
		var c = colors[i]
		c.a *= strength
		canvas.draw_colored_polygon(moved,c)
		var outline = Color(c.r*1.8,c.g*1.8,c.b*1.8,0.045*strength)
		var closed = PackedVector2Array(moved)
		closed.append(moved[0])
		canvas.draw_polyline(closed,outline,1.2,true)

static func _draw_broken_stars(canvas: Node2D, progress: float, time: float):
	var count = 72+int(progress*26.0)
	var pull_center = Vector2(745.0,270.0)
	for i in range(count):
		var base = Vector2(20.0+float((i*197+29)%920),70.0+float((i*137+61)%940))
		var to_core = pull_center-base
		var d = max(90.0,to_core.length())
		var tangent = Vector2(-to_core.y,to_core.x).normalized()
		var radial = to_core.normalized()
		var warp = tangent*sin(float(i)*1.91)*(8.0+progress*34.0)*(260.0/(d+180.0))
		warp += radial*(progress*progress*18.0)*(340.0/(d+220.0))
		var p = base+warp
		var alpha = 0.05+progress*0.035
		if i%6 == 0 and progress > 0.25:
			var streak = tangent*(2.0+progress*10.0)
			canvas.draw_line(p-streak,p+streak,Color(0.72,0.78,1.0,alpha),0.9,true)
		else:
			canvas.draw_circle(p,0.55+float(i%3)*0.22,Color(0.72,0.80,1.0,alpha))

static func _draw_rift_lines(canvas: Node2D, progress: float, time: float):
	var strength = clamp(0.20+progress*0.95,0.0,1.0)
	var lines = [
		[Vector2(80,40),Vector2(150,210),Vector2(115,390),Vector2(175,560)],
		[Vector2(905,180),Vector2(835,360),Vector2(875,545),Vector2(810,720)],
		[Vector2(40,910),Vector2(210,830),Vector2(300,875),Vector2(410,820)]
	]
	for i in range(lines.size()):
		var points = PackedVector2Array()
		for j in range(lines[i].size()):
			var p = lines[i][j]
			var jitter = Vector2(sin(time*0.5+i*2.0+j)*2.0,cos(time*0.43+i+j)*2.0)*strength
			points.append(p+jitter)
		canvas.draw_polyline(points,Color(0.58,0.24,0.78,0.09*strength),2.0,true)
		canvas.draw_polyline(points,Color(0.24,0.58,0.88,0.035*strength),5.5,true)

static func _draw_echo_fragments(canvas: Node2D, progress: float, time: float):
	if progress < 0.18:
		return
	var appear = clamp((progress-0.18)/0.82,0.0,1.0)
	var pulse = 0.82+0.18*sin(time*0.16)

	var lava_alpha = 0.055*appear*pulse
	canvas.draw_line(Vector2(15,860),Vector2(115,805),Color(0.95,0.26,0.08,lava_alpha),5.0,true)
	canvas.draw_line(Vector2(115,805),Vector2(150,850),Color(1.0,0.48,0.12,lava_alpha*0.8),2.0,true)

	var bio_alpha = 0.05*appear*(0.9+0.1*cos(time*0.14))
	for i in range(3):
		var base = Vector2(900.0-float(i)*18.0,900.0-float(i)*70.0)
		var top = base+Vector2(sin(time*0.28+i)*8.0,-55.0)
		canvas.draw_line(base,top,Color(0.12,0.72,0.45,bio_alpha),2.0,true)
		canvas.draw_circle(top,4.0,Color(0.18,0.82,0.58,bio_alpha*0.8))

	if progress > 0.48:
		var sat_alpha = (progress-0.48)/0.52*0.055
		var p = Vector2(115.0,250.0)+Vector2(sin(time*0.12)*8.0,cos(time*0.1)*6.0)
		canvas.draw_rect(Rect2(p-Vector2(12,5),Vector2(24,10)),Color(0.55,0.62,0.70,sat_alpha))
		canvas.draw_line(p+Vector2(-13,0),p+Vector2(-34,0),Color(0.52,0.66,0.82,sat_alpha),1.3,true)
		canvas.draw_line(p+Vector2(13,0),p+Vector2(34,0),Color(0.52,0.66,0.82,sat_alpha),1.3,true)

static func _draw_gravity_core(canvas: Node2D, progress: float, time: float):
	var center = Vector2(745.0,270.0)
	var pulse = 0.9+0.1*sin(time*0.11)
	var core_radius = 22.0+progress*34.0
	canvas.draw_circle(center,core_radius,Color(0.0,0.0,0.0,0.18+progress*0.28))
	for i in range(8):
		var radius = core_radius+16.0+float(i)*15.0
		var alpha = (0.015+float(7-i)*0.004)*(0.35+progress*0.65)*pulse
		canvas.draw_arc(center,radius,-3.0+float(i)*0.035,0.2-float(i)*0.02,64,Color(0.72,0.28,0.86,alpha),1.4,true)
		canvas.draw_arc(center,radius,0.34+float(i)*0.015,3.02-float(i)*0.025,64,Color(0.24,0.54,0.96,alpha*0.75),1.1,true)
	if progress > 0.62:
		var tear = (progress-0.62)/0.38
		for i in range(5):
			var angle = -1.0+float(i)*0.5+sin(time*0.17+i)*0.06
			var inner = center+Vector2(cos(angle),sin(angle))*(core_radius+8.0)
			var outer = center+Vector2(cos(angle),sin(angle))*(core_radius+50.0+float(i)*9.0)*tear
			canvas.draw_line(inner,outer,Color(0.88,0.40,0.92,0.06*tear),1.2,true)
