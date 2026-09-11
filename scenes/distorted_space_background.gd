class_name DistortedSpaceBackground
extends RefCounted

static func draw_background(canvas: Node2D, progress: float, time: float):
	var escalation = clamp(progress * 5.0, 0.0, 1.0)
	_draw_space(canvas, progress)
	_draw_star_field(canvas, progress, escalation, time)
	_draw_lensing(canvas, escalation, time)
	_draw_warped_dust(canvas, progress, escalation, time)
	_draw_world_echoes(canvas, escalation, time)
	_draw_anomaly(canvas, escalation, time)
	_draw_space_rifts(canvas, progress, time)
	_draw_fragmented_reality(canvas, progress, time)

static func _draw_space(canvas: Node2D, progress: float):
	var top = Color(0.004,0.003,0.016).lerp(Color(0.020,0.001,0.024),progress)
	var bottom = Color(0.010,0.008,0.030).lerp(Color(0.005,0.002,0.016),progress)
	for y in range(0,1080,18):
		var t = float(y)/1080.0
		canvas.draw_rect(Rect2(0,y,960,18),top.lerp(bottom,t))

static func _draw_star_field(canvas: Node2D, progress: float, escalation: float, time: float):
	var count = 118+int(progress*42.0)
	var bend_center = Vector2(790.0,235.0)
	for i in range(count):
		var base = Vector2(
			12.0+float((i*181+53)%936),
			58.0+float((i*127+37)%1000)
		)
		var to_center = bend_center-base
		var distance = max(to_center.length(),80.0)
		var tangent = Vector2(-to_center.y,to_center.x).normalized()
		var bend = tangent*(escalation*escalation*13500.0/(distance+110.0))*sin(float(i)*1.73)
		var radial_pull = to_center.normalized()*progress*progress*24.0*sin(float(i)*0.91)
		var p = base+bend+radial_pull
		var twinkle = 0.65+0.35*sin(time*(0.17+float(i%5)*0.03)+float(i)*1.19)
		var alpha = (0.06+progress*0.055)*(0.72+0.28*twinkle)
		var radius = 0.5+float(i%4)*0.22
		canvas.draw_circle(p,radius,Color(0.72,0.80,1.0,alpha))

	var stretched = 10+int(progress*24.0)
	for i in range(stretched):
		var p = Vector2(
			70.0+float((i*233+117)%820),
			95.0+float((i*169+71)%820)
		)
		var to_center = bend_center-p
		var tangent = Vector2(-to_center.y,to_center.x).normalized()
		var length = 5.0+escalation*(10.0+float(i%5)*4.0)+progress*progress*18.0
		var alpha = 0.035+progress*0.085
		canvas.draw_line(p-tangent*length,p+tangent*length,Color(0.62,0.72,1.0,alpha),0.9,true)

static func _draw_lensing(canvas: Node2D, strength: float, time: float):
	if strength <= 0.01:
		return

	var center = Vector2(790.0,235.0)
	var pulse = 0.90+0.10*sin(time*0.11)
	for i in range(12):
		var radius = 42.0+float(i)*24.0
		var offset = sin(time*0.035+float(i))*0.10*strength
		var alpha = (0.010+float(i%3)*0.003)*strength*pulse
		canvas.draw_arc(center,radius,-2.70+offset,-0.32-offset,64,Color(0.46,0.26,0.72,alpha),1.2,true)
		canvas.draw_arc(center,radius,0.42-offset,2.84+offset,64,Color(0.18,0.45,0.78,alpha*0.82),1.0,true)

static func _draw_warped_dust(canvas: Node2D, progress: float, escalation: float, time: float):
	var count = 18+int(progress*34.0)
	for i in range(count):
		var base = Vector2(
			30.0+float((i*157+41)%900),
			390.0+float((i*103+67)%640)
		)
		var sway = sin(time*0.022+float(i)*1.4)*(4.0+escalation*14.0)
		var rise = cos(time*0.015+float(i)*0.8)*(3.0+progress*7.0)
		var p = base+Vector2(sway,rise)
		var alpha = 0.022+progress*0.042
		canvas.draw_circle(p,0.7+float(i%3)*0.35,Color(0.52,0.46,0.76,alpha))

static func _draw_world_echoes(canvas: Node2D, strength: float, time: float):
	if strength < 0.18:
		return

	var appear = clamp((strength-0.18)/0.82,0.0,1.0)
	var pulse = 0.78+0.22*sin(time*0.16)

	var rock_alpha = 0.030*appear*pulse
	var left_rock = PackedVector2Array([
		Vector2(0,1080),Vector2(0,790),Vector2(38,760),Vector2(73,795),
		Vector2(58,850),Vector2(96,900),Vector2(75,960),Vector2(128,1080)
	])
	canvas.draw_colored_polygon(left_rock,Color(0.24,0.10,0.18,rock_alpha))
	canvas.draw_polyline(PackedVector2Array([Vector2(0,790),Vector2(38,760),Vector2(73,795),Vector2(58,850),Vector2(96,900)]),Color(0.55,0.16,0.30,rock_alpha*2.0),1.2,true)

	var plant_alpha = 0.032*appear*(0.86+0.14*cos(time*0.13))
	for i in range(5):
		var base = Vector2(865.0+float(i%2)*34.0,960.0-float(i)*62.0)
		var top = base+Vector2(sin(time*0.26+i)*6.0,-48.0-float(i%2)*18.0)
		canvas.draw_line(base,top,Color(0.18,0.72,0.42,plant_alpha),1.6,true)
		var leaf = PackedVector2Array([
			top+Vector2(0,-9),top+Vector2(8,0),top+Vector2(0,6),top+Vector2(-8,0)
		])
		canvas.draw_colored_polygon(leaf,Color(0.14,0.60,0.36,plant_alpha*0.9))

	if strength > 0.45:
		var satellite_alpha = (strength-0.45)/0.55*0.045
		var p = Vector2(105.0,310.0)+Vector2(sin(time*0.06)*7.0,cos(time*0.05)*4.0)
		canvas.draw_rect(Rect2(p-Vector2(10,4),Vector2(20,8)),Color(0.40,0.46,0.56,satellite_alpha))
		canvas.draw_line(p+Vector2(-11,0),p+Vector2(-29,0),Color(0.40,0.48,0.66,satellite_alpha),1.0,true)
		canvas.draw_line(p+Vector2(11,0),p+Vector2(29,0),Color(0.40,0.48,0.66,satellite_alpha),1.0,true)

static func _draw_anomaly(canvas: Node2D, strength: float, time: float):
	if strength < 0.22:
		return

	var appear = clamp((strength-0.22)/0.78,0.0,1.0)
	var center = Vector2(790.0,235.0)
	var pulse = 0.86+0.14*sin(time*0.12)
	canvas.draw_circle(center,22.0+appear*22.0,Color(0.0,0.0,0.0,0.16+appear*0.22))
	canvas.draw_circle(center,12.0+appear*15.0,Color(0.0,0.0,0.0,0.32+appear*0.24))
	for i in range(9):
		var radius = 38.0+float(i)*13.0
		var alpha = (0.012+float(8-i)*0.0025)*appear*pulse
		canvas.draw_arc(center,radius,-3.05,0.10,72,Color(0.66,0.26,0.86,alpha),1.4,true)
		canvas.draw_arc(center,radius,0.30,3.12,72,Color(0.16,0.50,0.88,alpha*0.82),1.1,true)

static func _draw_space_rifts(canvas: Node2D, progress: float, time: float):
	if progress < 0.28:
		return

	var strength = clamp((progress-0.28)/0.72,0.0,1.0)
	var rift_count = 1+int(strength*3.0)
	var centers = [Vector2(85,520),Vector2(875,650),Vector2(160,860),Vector2(820,930)]

	for i in range(min(rift_count,centers.size())):
		var c = centers[i]
		var sway = Vector2(sin(time*0.10+i)*5.0,cos(time*0.08+i)*4.0)
		var p = c+sway
		var height = 70.0+float(i%2)*35.0+strength*45.0
		var alpha = (0.030+strength*0.045)*(0.85+0.15*sin(time*0.18+i))
		var points = PackedVector2Array()
		for j in range(7):
			var t = float(j)/6.0
			var x = sin(t*PI*3.0+float(i))*8.0*strength
			points.append(p+Vector2(x,lerp(-height*0.5,height*0.5,t)))
		canvas.draw_polyline(points,Color(0.70,0.26,0.92,alpha),1.5,true)
		canvas.draw_polyline(points,Color(0.22,0.58,1.0,alpha*0.55),4.5,true)

static func _draw_fragmented_reality(canvas: Node2D, progress: float, time: float):
	if progress < 0.52:
		return

	var strength = clamp((progress-0.52)/0.48,0.0,1.0)
	var shard_count = 2+int(strength*6.0)
	for i in range(shard_count):
		var side = -1.0 if i%2 == 0 else 1.0
		var x = 45.0 if side < 0.0 else 915.0
		var y = 180.0+float((i*137+73)%760)
		var drift = Vector2(sin(time*0.07+i)*10.0,cos(time*0.05+i)*7.0)
		var p = Vector2(x,y)+drift
		var size = 14.0+float(i%3)*7.0+strength*10.0
		var shard = PackedVector2Array([
			p+Vector2(-size*0.5,-size*0.2),
			p+Vector2(size*0.1,-size),
			p+Vector2(size*0.65,-size*0.1),
			p+Vector2(size*0.2,size*0.75),
			p+Vector2(-size*0.7,size*0.35)
		])
		canvas.draw_colored_polygon(shard,Color(0.18,0.08,0.28,0.025+strength*0.035))
		canvas.draw_polyline(PackedVector2Array([shard[0],shard[1],shard[2],shard[3],shard[4],shard[0]]),Color(0.56,0.28,0.78,0.045+strength*0.055),1.0,true)
