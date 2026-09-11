class_name DistortedSpaceBackground
extends RefCounted

static func draw_background(canvas: Node2D, progress: float, time: float):
	_draw_space(canvas, progress)
	_draw_star_field(canvas, progress, time)
	_draw_lensing(canvas, progress, time)
	_draw_warped_dust(canvas, progress, time)
	_draw_world_echoes(canvas, progress, time)
	_draw_anomaly_hint(canvas, progress, time)

static func _draw_space(canvas: Node2D, progress: float):
	var top = Color(0.004,0.003,0.016).lerp(Color(0.008,0.002,0.018),progress)
	var bottom = Color(0.010,0.008,0.030).lerp(Color(0.020,0.004,0.026),progress)
	for y in range(0,1080,18):
		var t = float(y)/1080.0
		canvas.draw_rect(Rect2(0,y,960,18),top.lerp(bottom,t))

static func _draw_star_field(canvas: Node2D, progress: float, time: float):
	var count = 118+int(progress*26.0)
	var bend_center = Vector2(790.0,235.0)
	for i in range(count):
		var base = Vector2(
			12.0+float((i*181+53)%936),
			58.0+float((i*127+37)%1000)
		)
		var to_center = bend_center-base
		var distance = max(to_center.length(),80.0)
		var tangent = Vector2(-to_center.y,to_center.x).normalized()
		var bend = tangent*(progress*progress*9500.0/(distance+130.0))*sin(float(i)*1.73)
		var p = base+bend
		var twinkle = 0.70+0.30*sin(time*(0.17+float(i%5)*0.03)+float(i)*1.19)
		var alpha = (0.055+progress*0.035)*(0.76+0.24*twinkle)
		var radius = 0.5+float(i%4)*0.22
		canvas.draw_circle(p,radius,Color(0.72,0.80,1.0,alpha))

	var stretched = 4+int(progress*9.0)
	for i in range(stretched):
		var p = Vector2(
			90.0+float((i*233+117)%780),
			110.0+float((i*169+71)%760)
		)
		var to_center = bend_center-p
		var tangent = Vector2(-to_center.y,to_center.x).normalized()
		var length = 2.0+progress*progress*(8.0+float(i%4)*2.5)
		var alpha = 0.025+progress*0.055
		canvas.draw_line(p-tangent*length,p+tangent*length,Color(0.62,0.72,1.0,alpha),0.8,true)

static func _draw_lensing(canvas: Node2D, progress: float, time: float):
	if progress < 0.12:
		return

	var strength = clamp((progress-0.12)/0.88,0.0,1.0)
	var center = Vector2(790.0,235.0)
	var pulse = 0.92+0.08*sin(time*0.09)
	for i in range(9):
		var radius = 52.0+float(i)*29.0
		var offset = sin(time*0.025+float(i))*0.05*strength
		var alpha = (0.006+float(i%3)*0.002)*strength*pulse
		canvas.draw_arc(center,radius,-2.55+offset,-0.42-offset,58,Color(0.32,0.30,0.58,alpha),1.0,true)
		canvas.draw_arc(center,radius,0.58-offset,2.72+offset,58,Color(0.20,0.34,0.60,alpha*0.72),1.0,true)

static func _draw_warped_dust(canvas: Node2D, progress: float, time: float):
	var count = 14+int(progress*20.0)
	for i in range(count):
		var base = Vector2(
			30.0+float((i*157+41)%900),
			430.0+float((i*103+67)%590)
		)
		var sway = sin(time*0.018+float(i)*1.4)*(3.0+progress*8.0)
		var rise = cos(time*0.012+float(i)*0.8)*(2.0+progress*4.0)
		var p = base+Vector2(sway,rise)
		var alpha = 0.018+progress*0.028
		canvas.draw_circle(p,0.7+float(i%3)*0.32,Color(0.48,0.48,0.72,alpha))

static func _draw_world_echoes(canvas: Node2D, progress: float, time: float):
	if progress < 0.42:
		return

	var appear = clamp((progress-0.42)/0.58,0.0,1.0)
	var pulse = 0.82+0.18*sin(time*0.14)

	var rock_alpha = 0.018*appear*pulse
	var left_rock = PackedVector2Array([
		Vector2(0,1080),Vector2(0,790),Vector2(38,760),Vector2(73,795),
		Vector2(58,850),Vector2(96,900),Vector2(75,960),Vector2(128,1080)
	])
	canvas.draw_colored_polygon(left_rock,Color(0.20,0.12,0.16,rock_alpha))
	canvas.draw_polyline(PackedVector2Array([Vector2(0,790),Vector2(38,760),Vector2(73,795),Vector2(58,850),Vector2(96,900)]),Color(0.44,0.18,0.25,rock_alpha*1.8),1.0,true)

	var plant_alpha = 0.020*appear*(0.88+0.12*cos(time*0.11))
	for i in range(4):
		var base = Vector2(875.0+float(i%2)*34.0,930.0-float(i)*58.0)
		var top = base+Vector2(sin(time*0.23+i)*4.0,-42.0-float(i%2)*15.0)
		canvas.draw_line(base,top,Color(0.20,0.62,0.43,plant_alpha),1.4,true)
		var leaf = PackedVector2Array([
			top+Vector2(0,-8),top+Vector2(7,0),top+Vector2(0,5),top+Vector2(-7,0)
		])
		canvas.draw_colored_polygon(leaf,Color(0.16,0.52,0.37,plant_alpha*0.8))

	if progress > 0.68:
		var satellite_alpha = (progress-0.68)/0.32*0.025
		var p = Vector2(105.0,310.0)+Vector2(sin(time*0.05)*5.0,cos(time*0.04)*3.0)
		canvas.draw_rect(Rect2(p-Vector2(10,4),Vector2(20,8)),Color(0.38,0.44,0.52,satellite_alpha))
		canvas.draw_line(p+Vector2(-11,0),p+Vector2(-27,0),Color(0.36,0.45,0.60,satellite_alpha),1.0,true)
		canvas.draw_line(p+Vector2(11,0),p+Vector2(27,0),Color(0.36,0.45,0.60,satellite_alpha),1.0,true)

static func _draw_anomaly_hint(canvas: Node2D, progress: float, time: float):
	if progress < 0.70:
		return

	var strength = clamp((progress-0.70)/0.30,0.0,1.0)
	var center = Vector2(790.0,235.0)
	var pulse = 0.88+0.12*sin(time*0.10)
	canvas.draw_circle(center,20.0+strength*10.0,Color(0.0,0.0,0.0,0.10*strength))
	for i in range(6):
		var radius = 34.0+float(i)*12.0
		var alpha = (0.008+float(5-i)*0.002)*strength*pulse
		canvas.draw_arc(center,radius,-2.95,0.15,54,Color(0.52,0.30,0.72,alpha),1.2,true)
		canvas.draw_arc(center,radius,0.38,3.05,54,Color(0.20,0.42,0.72,alpha*0.75),1.0,true)
