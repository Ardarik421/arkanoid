class_name BlackHoleBackground
extends RefCounted

static func draw_background(canvas: Node2D, progress: float, time: float):
	_draw_void(canvas, progress)
	_draw_warped_stars(canvas, progress, time)
	_draw_reality_fragments(canvas, progress, time)
	_draw_accretion_disk(canvas, progress, time)
	_draw_black_hole(canvas, progress, time)
	_draw_infall(canvas, progress, time)
	_draw_engulfing_darkness(canvas, progress, time)

static func _draw_void(canvas: Node2D, progress: float):
	var top = Color(0.008,0.001,0.010).lerp(Color(0.001,0.001,0.003),progress)
	var bottom = Color(0.022,0.003,0.014).lerp(Color(0.003,0.002,0.006),progress)
	for y in range(0,1080,18):
		var t = float(y)/1080.0
		canvas.draw_rect(Rect2(0,y,canvas.get_viewport_rect().size.x,18),top.lerp(bottom,t))

static func _hole_center(progress: float) -> Vector2:
	return Vector2(745.0,270.0).lerp(Vector2(560.0,455.0),pow(progress,1.35))

static func _hole_radius(progress: float) -> float:
	return 54.0+pow(progress,1.18)*245.0

static func _draw_warped_stars(canvas: Node2D, progress: float, time: float):
	var center = _hole_center(progress)
	var radius = _hole_radius(progress)
	var count = 94-int(progress*34.0)
	for i in range(max(count,38)):
		var base = Vector2(16.0+float((i*193+47)%928),58.0+float((i*139+83)%990))
		var delta = center-base
		var distance = max(delta.length(),46.0)
		var radial = delta.normalized()
		var tangent = Vector2(-radial.y,radial.x)
		var pull = radial*(progress*progress*72.0)*(330.0/(distance+120.0))
		var curve = tangent*sin(float(i)*1.71+time*0.035)*(10.0+progress*48.0)*(260.0/(distance+160.0))
		var p = base+pull+curve
		if p.distance_to(center) < radius*1.04:
			continue
		var stretch = 1.5+progress*16.0*(300.0/(distance+160.0))
		var alpha = (0.065-progress*0.018)*(0.80+0.20*sin(time*0.22+i))
		if progress < 0.22:
			canvas.draw_circle(p,0.55+float(i%3)*0.28,Color(0.72,0.80,1.0,alpha))
		else:
			canvas.draw_line(p-tangent*stretch,p+tangent*stretch,Color(0.66,0.76,1.0,alpha),0.9,true)

static func _draw_reality_fragments(canvas: Node2D, progress: float, time: float):
	var fade = 1.0-clamp((progress-0.58)/0.42,0.0,1.0)
	if fade <= 0.0:
		return
	var center = _hole_center(progress)
	var fragments = [
		[Vector2(70,185),Color(0.18,0.48,0.72,0.08)],
		[Vector2(120,865),Color(0.95,0.24,0.07,0.075)],
		[Vector2(870,850),Color(0.12,0.72,0.43,0.07)],
		[Vector2(875,130),Color(0.52,0.28,0.72,0.07)]
	]
	for i in range(fragments.size()):
		var base: Vector2 = fragments[i][0]
		var color: Color = fragments[i][1]
		var pull_amount = progress*(0.18+float(i)*0.025)
		var p = base.lerp(center,pull_amount)+Vector2(sin(time*0.10+i)*5.0,cos(time*0.08+i)*4.0)
		var size = (34.0-float(i)*3.0)*(1.0-progress*0.28)
		var points = PackedVector2Array([
			p+Vector2(-size,6),
			p+Vector2(-size*0.25,-size*0.65),
			p+Vector2(size*0.75,-size*0.20),
			p+Vector2(size*0.45,size*0.55)
		])
		color.a *= fade
		canvas.draw_colored_polygon(points,color)
		var closed = PackedVector2Array(points)
		closed.append(points[0])
		canvas.draw_polyline(closed,Color(color.r*1.5,color.g*1.5,color.b*1.5,color.a*0.8),1.0,true)

static func _draw_accretion_disk(canvas: Node2D, progress: float, time: float):
	var center = _hole_center(progress)
	var radius = _hole_radius(progress)
	var appear = clamp((progress-0.05)/0.30,0.0,1.0)
	if appear <= 0.0:
		return
	var pulse = 0.92+0.08*sin(time*0.18)
	var disk_width = radius*(1.9+progress*0.55)
	var thickness = 8.0+progress*20.0
	var angle = -0.20-progress*0.10
	var axis = Vector2(cos(angle),sin(angle))
	for i in range(10,0,-1):
		var layer = float(i)/10.0
		var half_length = disk_width*(0.58+layer*0.42)
		var width = thickness*(0.45+layer*0.75)
		var alpha = appear*pulse*(0.006+float(11-i)*0.005)*(1.0-progress*0.18)
		var color = Color(0.55+0.35*(1.0-layer),0.18+0.32*(1.0-layer),0.78,alpha)
		canvas.draw_line(center-axis*half_length,center+axis*half_length,color,width,true)
	var hot_alpha = appear*(0.08+progress*0.10)*pulse
	canvas.draw_line(center-axis*disk_width*0.92,center+axis*disk_width*0.92,Color(0.92,0.52,0.96,hot_alpha),1.2+progress*1.8,true)
	canvas.draw_line(center-axis*disk_width*0.72,center+axis*disk_width*0.72,Color(0.42,0.68,1.0,hot_alpha*0.70),1.0,true)

static func _draw_black_hole(canvas: Node2D, progress: float, time: float):
	var center = _hole_center(progress)
	var radius = _hole_radius(progress)
	var pulse = 0.94+0.06*sin(time*0.11)
	for i in range(12,0,-1):
		var ring_radius = radius+float(i)*8.0
		var alpha = (0.004+float(13-i)*0.0018)*(0.50+progress*0.50)*pulse
		canvas.draw_circle(center,ring_radius,Color(0.20,0.10,0.32,alpha))
	canvas.draw_circle(center,radius,Color(0.0,0.0,0.0,0.985))
	canvas.draw_arc(center,radius+5.0,-3.04,0.16,96,Color(0.82,0.42,1.0,0.10+progress*0.10),1.5,true)
	canvas.draw_arc(center,radius+7.0,0.28,3.02,96,Color(0.30,0.58,1.0,0.07+progress*0.08),1.2,true)

static func _draw_infall(canvas: Node2D, progress: float, time: float):
	if progress < 0.24:
		return
	var strength = clamp((progress-0.24)/0.76,0.0,1.0)
	var center = _hole_center(progress)
	var radius = _hole_radius(progress)
	var count = 10+int(strength*22.0)
	for i in range(count):
		var angle = float(i)*2.399+time*(0.05+float(i%4)*0.009)
		var outer = radius+95.0+float((i*47)%210)*(1.0-strength*0.28)
		var spiral = angle+strength*1.6
		var p1 = center+Vector2(cos(angle),sin(angle))*outer
		var p2 = center+Vector2(cos(spiral),sin(spiral))*(radius+18.0+float(i%3)*7.0)
		var alpha = (0.025+float(i%4)*0.008)*strength
		var color = Color(0.64,0.38+float(i%3)*0.08,0.90,alpha)
		canvas.draw_line(p1,p2,color,0.8+float(i%2)*0.4,true)

static func _draw_engulfing_darkness(canvas: Node2D, progress: float, time: float):
	if progress < 0.52:
		return
	var strength = clamp((progress-0.52)/0.48,0.0,1.0)
	var center = _hole_center(progress)
	var pulse = 0.96+0.04*sin(time*0.09)
	var edge_alpha = 0.04+strength*0.20
	var left = 110.0*strength
	var right = 135.0*strength
	var top = 75.0*strength
	var bottom = 110.0*strength
	canvas.draw_rect(Rect2(0,0,left,1080),Color(0.0,0.0,0.0,edge_alpha*pulse))
	canvas.draw_rect(Rect2(960-right,0,right,1080),Color(0.0,0.0,0.0,edge_alpha*pulse))
	canvas.draw_rect(Rect2(0,0,960,top),Color(0.0,0.0,0.0,edge_alpha*0.8*pulse))
	canvas.draw_rect(Rect2(0,1080-bottom,960,bottom),Color(0.0,0.0,0.0,edge_alpha*0.9*pulse))
	if progress > 0.82:
		var final_strength = (progress-0.82)/0.18
		for i in range(7):
			var radius = 520.0-float(i)*48.0
			canvas.draw_arc(center,radius,-PI,PI,96,Color(0.0,0.0,0.0,0.018*final_strength*float(7-i)),14.0,true)
