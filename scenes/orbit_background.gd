class_name OrbitBackground
extends RefCounted

static func draw_background(canvas: Node2D, progress: float, time: float):
	_draw_space(canvas, progress, time)
	_draw_stars(canvas, progress, time)
	_draw_planet(canvas, progress)
	_draw_orbit_lines(canvas, progress)
	_draw_satellites(canvas, progress, time)
	_draw_debris(canvas, progress, time)

static func _draw_space(canvas: Node2D, progress: float, time: float):
	var top = Color(0.004,0.009,0.024).lerp(Color(0.002,0.004,0.014),progress)
	var bottom = Color(0.012,0.035,0.072).lerp(Color(0.004,0.010,0.028),progress)
	for y in range(0,1080,18):
		var t = float(y)/1080.0
		canvas.draw_rect(Rect2(0,y,960,18),top.lerp(bottom,t))
	var pulse = 0.85+0.15*sin(time*0.12)
	for r in range(360,80,-40):
		var depth = 1.0-float(r)/380.0
		canvas.draw_circle(Vector2(770,300),r,Color(0.08,0.20,0.42,0.006*depth*pulse*(1.0-progress*0.45)))

static func _draw_stars(canvas: Node2D, progress: float, time: float):
	var late_space = clamp((progress-0.44)/0.56,0.0,1.0)
	var count = 54+int(progress*20.0)+int(late_space*74.0)
	for i in range(count):
		var x = 12.0+float((i*173+47)%936)
		var y = 72.0+float((i*109+31)%970)
		var twinkle = 0.62+0.38*sin(time*(0.28+float(i%5)*0.055)+i*1.37)
		var alpha = (0.075+progress*0.055+late_space*0.025)*(0.72+0.28*twinkle)
		var radius = 0.65+float(i%4)*0.28
		canvas.draw_circle(Vector2(x,y),radius,Color(0.70,0.82,1.0,alpha))
	for i in range(5+int(progress*4.0)+int(late_space*4.0)):
		var x = 95.0+float((i*211+83)%770)
		var y = 120.0+float((i*157+59)%720)
		var brightness = pow(max(0.0,sin(time*(0.34+float(i%3)*0.06)+i*2.2)),10.0)
		if brightness > 0.06:
			var a = brightness*(0.10+progress*0.07+late_space*0.04)
			canvas.draw_circle(Vector2(x,y),1.5+brightness,Color(0.82,0.91,1.0,a))

static func _draw_planet(canvas: Node2D, progress: float):
	var retreat = progress
	var center = Vector2(480.0,1370.0+retreat*430.0)
	var radius = 720.0-retreat*115.0
	var visibility = 1.0-retreat*0.68
	for i in range(7,0,-1):
		canvas.draw_circle(center,radius+float(i)*14.0,Color(0.12,0.44,0.82,0.006*float(i)*visibility))
	canvas.draw_circle(center,radius,Color(0.010,0.030,0.055,0.96*visibility))
	canvas.draw_arc(center,radius,-2.88,-0.26,112,Color(0.26,0.65,1.0,0.46*visibility),2.5,true)
	canvas.draw_arc(center,radius-9.0,-2.88,-0.26,112,Color(0.62,0.86,1.0,0.13*visibility),1.0,true)

static func _draw_orbit_lines(canvas: Node2D, progress: float):
	var fade = 1.0-progress*0.55
	for i in range(3):
		var center = Vector2(480,1230+float(i)*85.0+progress*150.0)
		var radius = 590.0+float(i)*105.0
		canvas.draw_arc(center,radius,-2.75,-0.39,80,Color(0.18,0.42,0.68,0.045*fade),1.0,true)

static func _draw_satellites(canvas: Node2D, progress: float, time: float):
	if progress > 0.45:
		return

	var positions = [Vector2(790,650),Vector2(145,760)]
	var fade = clamp((0.45-progress)/0.18,0.35,1.0)
	for i in range(positions.size()):
		var p = positions[i]+Vector2(sin(time*0.055+i)*12.0,cos(time*0.043+i)*7.0)
		var s = 0.72+float(i)*0.10
		canvas.draw_rect(Rect2(p-Vector2(11,4)*s,Vector2(22,8)*s),Color(0.16,0.20,0.26,0.44*fade))
		canvas.draw_line(p+Vector2(-12,0)*s,p+Vector2(-27,0)*s,Color(0.28,0.38,0.48,0.30*fade),1.2,true)
		canvas.draw_line(p+Vector2(12,0)*s,p+Vector2(27,0)*s,Color(0.28,0.38,0.48,0.30*fade),1.2,true)
		canvas.draw_rect(Rect2(p+Vector2(-35,-7)*s,Vector2(10,14)*s),Color(0.06,0.17,0.30,0.32*fade))
		canvas.draw_rect(Rect2(p+Vector2(25,-7)*s,Vector2(10,14)*s),Color(0.06,0.17,0.30,0.32*fade))
		canvas.draw_circle(p,1.5*s,Color(0.48,0.72,0.92,0.30*fade))

static func _draw_debris(canvas: Node2D, progress: float, time: float):
	var count = 5+int(progress*10.0)
	for i in range(count):
		var base = Vector2(45.0+float((i*151+73)%870),560.0+float((i*97+41)%470))
		var drift = Vector2(sin(time*0.035+i)*8.0,cos(time*0.028+i*0.7)*5.0)
		var p = base+drift
		var r = 2.8+float(i%4)*1.6
		var shard = PackedVector2Array([p+Vector2(-r,1),p+Vector2(-r*0.25,-r),p+Vector2(r*0.8,-r*0.15),p+Vector2(r*0.25,r*0.7)])
		canvas.draw_colored_polygon(shard,Color(0.08,0.10,0.14,0.32+progress*0.08))
		canvas.draw_polyline(PackedVector2Array([shard[0],shard[1],shard[2],shard[3],shard[0]]),Color(0.28,0.38,0.52,0.10),0.8,true)
