class_name NebulaBackground
extends RefCounted

static func draw_background(canvas: Node2D, progress: float, time: float):
	_draw_space(canvas, progress)
	_draw_nebula_layers(canvas, progress, time)
	_draw_dark_lanes(canvas, progress, time)
	_draw_stars(canvas, progress, time)
	_draw_dust(canvas, progress, time)
	_draw_lensing_hint(canvas, progress, time)

static func _draw_space(canvas: Node2D, progress: float):
	var top = Color(0.0015,0.0025,0.009).lerp(Color(0.003,0.002,0.010),progress)
	var bottom = Color(0.003,0.006,0.018).lerp(Color(0.012,0.004,0.020),progress)
	for y in range(0,1080,18):
		var t = float(y)/1080.0
		canvas.draw_rect(Rect2(0,y,960,18),top.lerp(bottom,pow(t,1.08)))

static func _draw_nebula_layers(canvas: Node2D, progress: float, time: float):
	var pulse_a = 0.90+0.10*sin(time*0.045)
	var pulse_b = 0.91+0.09*cos(time*0.038)
	var alpha_a = (0.010+progress*0.024)*pulse_a
	var alpha_b = (0.008+progress*0.021)*pulse_b
	var alpha_c = (0.004+progress*0.016)*(0.92+0.08*sin(time*0.031+1.6))

	for r in range(390,90,-34):
		var depth = 1.0-float(r)/420.0
		canvas.draw_circle(Vector2(-40+sin(time*0.010)*8.0,690),r,Color(0.22,0.08,0.32,alpha_a*depth))

	for r in range(340,75,-30):
		var depth = 1.0-float(r)/370.0
		canvas.draw_circle(Vector2(1015+cos(time*0.009)*7.0,390),r,Color(0.05,0.18,0.30,alpha_b*depth))

	if progress > 0.35:
		var appear = (progress-0.35)/0.65
		for r in range(250,55,-27):
			var depth = 1.0-float(r)/275.0
			canvas.draw_circle(Vector2(710,980),r,Color(0.30,0.08,0.20,alpha_c*depth*appear))

static func _draw_dark_lanes(canvas: Node2D, progress: float, time: float):
	var lane_alpha = 0.018+progress*0.030
	for i in range(5):
		var phase = time*0.012+float(i)*1.4
		var y = 410.0+float(i)*115.0+sin(phase)*12.0
		var tilt = 32.0+float(i%2)*18.0
		canvas.draw_line(Vector2(-100,y),Vector2(1060,y-tilt),Color(0.002,0.003,0.008,lane_alpha*(0.72+float(i)*0.07)),20.0+float(i)*5.0,true)
		canvas.draw_line(Vector2(70,y+26.0),Vector2(890,y-tilt*0.55),Color(0.004,0.005,0.012,lane_alpha*0.55),7.0+float(i)*2.0,true)

static func _draw_stars(canvas: Node2D, progress: float, time: float):
	var far_count = 118+int(progress*72.0)
	for i in range(far_count):
		var x = 7.0+float((i*181+29)%946)
		var y = 56.0+float((i*127+83)%1010)
		var twinkle = 0.72+0.28*sin(time*(0.13+float(i%7)*0.024)+i*1.21)
		var alpha = (0.050+progress*0.038)*(0.78+0.22*twinkle)
		var radius = 0.42+float(i%4)*0.17
		var tint = i%9
		var color = Color(0.72,0.80,0.96,alpha)
		if tint == 2:
			color = Color(0.78,0.72,0.95,alpha*0.92)
		elif tint == 6:
			color = Color(0.66,0.84,1.0,alpha*0.96)
		canvas.draw_circle(Vector2(x,y),radius,color)

	var bright_count = 6+int(progress*5.0)
	for i in range(bright_count):
		var x = 70.0+float((i*233+121)%820)
		var y = 100.0+float((i*179+67)%800)
		var phase = time*(0.16+float(i%4)*0.028)+i*2.05
		var brightness = pow(max(0.0,sin(phase)),9.0)
		if brightness < 0.04:
			continue
		var alpha = brightness*(0.10+progress*0.07)
		var p = Vector2(x,y)
		var star_color = Color(0.88,0.91,1.0,alpha)
		if i%3 == 1:
			star_color = Color(0.92,0.80,1.0,alpha*0.95)
		canvas.draw_circle(p,1.5+brightness*1.8,star_color)
		canvas.draw_line(p+Vector2(-6.0*brightness,0),p+Vector2(6.0*brightness,0),Color(star_color.r,star_color.g,star_color.b,alpha*0.30),0.8,true)
		canvas.draw_line(p+Vector2(0,-6.0*brightness),p+Vector2(0,6.0*brightness),Color(star_color.r,star_color.g,star_color.b,alpha*0.30),0.8,true)

static func _draw_dust(canvas: Node2D, progress: float, time: float):
	var count = 20+int(progress*26.0)
	for i in range(count):
		var base = Vector2(20.0+float((i*157+53)%920),340.0+float((i*97+31)%690))
		var drift = Vector2(sin(time*0.010+i*0.7)*4.0,cos(time*0.008+i*0.45)*2.4)
		var p = base+drift
		var alpha = 0.015+progress*0.020
		var c = Color(0.52,0.43,0.68,alpha)
		if i%4 == 0:
			c = Color(0.36,0.52,0.68,alpha*0.9)
		canvas.draw_circle(p,0.7+float(i%3)*0.33,c)

static func _draw_lensing_hint(canvas: Node2D, progress: float, time: float):
	if progress < 0.70:
		return
	var strength = (progress-0.70)/0.30
	var pulse = 0.90+0.10*sin(time*0.07)
	var center = Vector2(790,245)
	for i in range(6):
		var radius = 48.0+float(i)*21.0
		var start = 2.05+float(i)*0.045
		var end = 4.25-float(i)*0.035
		canvas.draw_arc(center,radius,start,end,44,Color(0.34,0.28,0.52,0.010*strength*pulse),1.0,true)
