class_name DeepSpaceBackground
extends RefCounted

static func draw_background(canvas: Node2D, progress: float, time: float):
	_draw_space(canvas, progress)
	_draw_distant_nebulae(canvas, progress, time)
	_draw_star_layers(canvas, progress, time)
	_draw_distant_galaxy(canvas, progress, time)
	_draw_dust(canvas, progress, time)
	_draw_early_distortion(canvas, progress, time)

static func _draw_space(canvas: Node2D, progress: float):
	var top = Color(0.002,0.004,0.014).lerp(Color(0.001,0.002,0.009),progress)
	var bottom = Color(0.004,0.010,0.028).lerp(Color(0.003,0.006,0.018),progress)
	for y in range(0,1080,18):
		var t = float(y)/1080.0
		canvas.draw_rect(Rect2(0,y,960,18),top.lerp(bottom,t))

static func _draw_star_layers(canvas: Node2D, progress: float, time: float):
	var far_count = 88+int(progress*62.0)
	for i in range(far_count):
		var x = 8.0+float((i*179+37)%944)
		var y = 60.0+float((i*113+71)%1000)
		var twinkle = 0.70+0.30*sin(time*(0.16+float(i%6)*0.035)+float(i)*1.11)
		var alpha = (0.055+progress*0.045)*(0.76+0.24*twinkle)
		var radius = 0.45+float(i%4)*0.18
		canvas.draw_circle(Vector2(x,y),radius,Color(0.67,0.77,0.94,alpha))

	var mid_count = 24+int(progress*22.0)
	for i in range(mid_count):
		var base_x = 18.0+float((i*257+83)%920)
		var base_y = 90.0+float((i*191+47)%900)
		var drift = Vector2(sin(time*0.018+i)*2.5,cos(time*0.014+i*0.7)*1.5)
		var p = Vector2(base_x,base_y)+drift
		var pulse = 0.74+0.26*sin(time*(0.22+float(i%4)*0.04)+i*1.9)
		var alpha = (0.085+progress*0.065)*pulse
		var radius = 0.9+float(i%3)*0.45
		canvas.draw_circle(p,radius,Color(0.74,0.85,1.0,alpha))

	var bright_count = 4+int(progress*4.0)
	for i in range(bright_count):
		var x = 85.0+float((i*229+137)%790)
		var y = 115.0+float((i*173+91)%750)
		var phase = time*(0.18+float(i%3)*0.035)+i*2.4
		var brightness = pow(max(0.0,sin(phase)),8.0)
		if brightness < 0.035:
			continue
		var alpha = brightness*(0.11+progress*0.08)
		var p = Vector2(x,y)
		canvas.draw_circle(p,1.5+brightness*1.5,Color(0.86,0.93,1.0,alpha))
		canvas.draw_line(p+Vector2(-5.0*brightness,0),p+Vector2(5.0*brightness,0),Color(0.78,0.88,1.0,alpha*0.36),0.8,true)
		canvas.draw_line(p+Vector2(0,-5.0*brightness),p+Vector2(0,5.0*brightness),Color(0.78,0.88,1.0,alpha*0.36),0.8,true)

static func _draw_distant_nebulae(canvas: Node2D, progress: float, time: float):
	var pulse = 0.86+0.14*sin(time*0.06)
	var left_alpha = (0.010+progress*0.018)*pulse
	var right_alpha = (0.008+progress*0.015)*(0.90+0.10*cos(time*0.05))

	for r in range(300,70,-32):
		var depth = 1.0-float(r)/320.0
		canvas.draw_circle(Vector2(-55,610),r,Color(0.17,0.14,0.34,left_alpha*depth))

	for r in range(260,60,-30):
		var depth = 1.0-float(r)/280.0
		canvas.draw_circle(Vector2(1010,420),r,Color(0.08,0.22,0.34,right_alpha*depth))

static func _draw_distant_galaxy(canvas: Node2D, progress: float, time: float):
	if progress < 0.22:
		return

	var appear = clamp((progress-0.22)/0.78,0.0,1.0)
	var center = Vector2(785.0+sin(time*0.012)*3.0,245.0+cos(time*0.010)*2.0)
	var angle = -0.38
	var axis = Vector2(cos(angle),sin(angle))
	var normal = Vector2(-axis.y,axis.x)

	for i in range(8,0,-1):
		var half_length = 44.0+float(i)*10.0
		var thickness = 2.0+float(i)*2.0
		var alpha = appear*(0.004+float(9-i)*0.002)
		canvas.draw_line(center-axis*half_length,center+axis*half_length,Color(0.40,0.48,0.72,alpha),thickness,true)

	canvas.draw_circle(center,4.0+appear*2.0,Color(0.82,0.76,0.62,0.11*appear))
	canvas.draw_line(center-normal*18.0,center+normal*18.0,Color(0.58,0.62,0.78,0.035*appear),1.0,true)

static func _draw_dust(canvas: Node2D, progress: float, time: float):
	var count = 10+int(progress*14.0)
	for i in range(count):
		var base = Vector2(25.0+float((i*149+61)%910),420.0+float((i*101+29)%620))
		var drift = Vector2(sin(time*0.012+i)*3.5,cos(time*0.009+i*0.6)*2.0)
		var p = base+drift
		var alpha = 0.018+progress*0.018
		canvas.draw_circle(p,0.8+float(i%3)*0.35,Color(0.48,0.56,0.72,alpha))

static func _draw_early_distortion(canvas: Node2D, progress: float, time: float):
	if progress < 0.72:
		return

	var strength = (progress-0.72)/0.28
	var center = Vector2(155.0,245.0)
	var pulse = 0.90+0.10*sin(time*0.08)
	for i in range(5):
		var radius = 58.0+float(i)*24.0
		var start = -1.1+float(i)*0.08
		var end = 1.05-float(i)*0.06
		canvas.draw_arc(center,radius,start,end,42,Color(0.18,0.28,0.46,0.010*strength*pulse),1.0,true)
