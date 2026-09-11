class_name DistortedSpaceBackground
extends RefCounted

static func draw_background(canvas: Node2D, progress: float, time: float):
	var escalation = clamp(progress * 5.0, 0.0, 1.0)
	_draw_space(canvas, progress)
	_draw_celestial_objects(canvas, progress, escalation, time)
	_draw_star_field(canvas, progress, escalation, time)
	_draw_lensing(canvas, escalation, time)
	_draw_anomaly_details(canvas, progress, escalation, time)
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

static func _draw_celestial_objects(canvas: Node2D, progress: float, escalation: float, time: float):
	var doomed = Vector2(120.0+sin(time*0.010)*3.0,760.0+cos(time*0.008)*2.0)
	var alpha = 0.13*(1.0-clamp((progress-0.68)/0.32,0.0,1.0))
	canvas.draw_circle(doomed,48.0,Color(0.035,0.026,0.060,alpha))
	canvas.draw_circle(doomed+Vector2(-14,-9),31.0,Color(0.21,0.12,0.27,alpha*0.44))
	canvas.draw_arc(doomed,49.0,-1.32,1.30,54,Color(0.54,0.30,0.68,alpha*0.46),1.3,true)
	if escalation > 0.30:
		var crack = (escalation-0.30)/0.70
		canvas.draw_line(doomed+Vector2(-17,-4),doomed+Vector2(6,12),Color(0.82,0.32,0.82,0.07*crack),1.2,true)
		canvas.draw_line(doomed+Vector2(5,12),doomed+Vector2(20,3),Color(0.42,0.48,0.92,0.055*crack),1.0,true)

	if progress > 0.24:
		var appear = clamp((progress-0.24)/0.76,0.0,1.0)
		var p = Vector2(865.0+sin(time*0.012)*4.0,690.0+cos(time*0.010)*3.0)
		var moon_alpha = 0.10*appear
		canvas.draw_circle(p,25.0,Color(0.028,0.036,0.058,moon_alpha))
		canvas.draw_circle(p+Vector2(-7,-5),16.0,Color(0.17,0.21,0.30,moon_alpha*0.42))
		var pull = Vector2(790.0,235.0)-p
		var tangent = Vector2(-pull.y,pull.x).normalized()
		var trail = tangent*(5.0+appear*18.0)
		canvas.draw_line(p-trail,p+trail,Color(0.38,0.44,0.74,0.025+appear*0.045),1.0,true)

	if progress > 0.52:
		var appear = clamp((progress-0.52)/0.48,0.0,1.0)
		for i in range(9):
			var angle = -0.55+float(i)*0.14+sin(time*0.012+i)*0.025
			var distance = 150.0+float(i%3)*24.0
			var p = Vector2(790.0,235.0)+Vector2(cos(angle),sin(angle))*distance
			var r = 2.0+float(i%4)*1.0
			canvas.draw_circle(p,r,Color(0.30,0.20,0.38,0.035+appear*0.040))

static func _draw_star_field(canvas: Node2D, progress: float, escalation: float, time: float):
	var count = 118+int(progress*42.0)
	var bend_center = Vector2(790.0,235.0)
	for i in range(count):
		var base = Vector2(12.0+float((i*181+53)%936),58.0+float((i*127+37)%1000))
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
		var p = Vector2(70.0+float((i*233+117)%820),95.0+float((i*169+71)%820))
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

static func _draw_anomaly_details(canvas: Node2D, progress: float, escalation: float, time: float):
	var center = Vector2(790.0,235.0)
	var stream_alpha = 0.025+progress*0.045
	for i in range(14):
		var angle = 1.82+float(i)*0.075+sin(time*0.018+i)*0.018
		var distance = 260.0+float(i%5)*42.0
		var p = center+Vector2(cos(angle),sin(angle))*distance
		var tangent = Vector2(-sin(angle),cos(angle))
		var length = 3.0+progress*9.0+float(i%3)*2.0
		canvas.draw_line(p-tangent*length,p+tangent*length,Color(0.38,0.46,0.72,stream_alpha),0.8,true)

	if progress > 0.18:
		var appear = clamp((progress-0.18)/0.82,0.0,1.0)
		var ghost = Vector2(235.0+sin(time*0.014)*5.0,185.0+cos(time*0.011)*3.0)
		for i in range(5):
			var radius = 18.0+float(i)*11.0
			canvas.draw_arc(ghost,radius,-2.4,-0.45,30,Color(0.20,0.52,0.78,0.018*appear),0.9,true)
			canvas.draw_arc(ghost,radius,0.62,2.18,28,Color(0.62,0.28,0.76,0.014*appear),0.8,true)

	if progress > 0.34:
		var appear = clamp((progress-0.34)/0.66,0.0,1.0)
		var debris_center = Vector2(130.0,410.0)
		for i in range(12):
			var angle = -0.35+float(i)*0.12+sin(time*0.025+i)*0.02
			var distance = 25.0+float(i)*12.0
			var p = debris_center+Vector2(cos(angle),sin(angle))*distance
			var size = 1.5+float(i%4)*0.8
			canvas.draw_circle(p,size,Color(0.30,0.22,0.40,0.035+appear*0.035))

	if progress > 0.56:
		var appear = clamp((progress-0.56)/0.44,0.0,1.0)
		var anchors = [Vector2(330,890),Vector2(610,805),Vector2(895,475)]
		for i in range(anchors.size()):
			var p = anchors[i]+Vector2(sin(time*0.08+i)*4.0,cos(time*0.07+i)*3.0)
			var size = 12.0+float(i)*4.0
			canvas.draw_line(p+Vector2(-size,0),p+Vector2(size,0),Color(0.52,0.24,0.72,0.028*appear),1.0,true)
			canvas.draw_line(p+Vector2(0,-size*0.65),p+Vector2(0,size*0.65),Color(0.20,0.52,0.86,0.024*appear),1.0,true)
			canvas.draw_circle(p,2.0,Color(0.76,0.52,0.90,0.045*appear))

	if progress > 0.72:
		var appear = clamp((progress-0.72)/0.28,0.0,1.0)
		for i in range(4):
			var radius = 205.0+float(i)*37.0
			var offset = sin(time*0.04+i)*0.05
			canvas.draw_arc(center,radius,1.55+offset,2.75-offset,48,Color(0.54,0.20,0.70,0.018*appear),1.0,true)
			canvas.draw_arc(center,radius,2.92-offset,3.65+offset,36,Color(0.18,0.46,0.82,0.014*appear),0.9,true)

static func _draw_warped_dust(canvas: Node2D, progress: float, escalation: float, time: float):
	var count = 18+int(progress*34.0)
	for i in range(count):
		var base = Vector2(30.0+float((i*157+41)%900),390.0+float((i*103+67)%640))
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
	var left_rock = PackedVector2Array([Vector2(0,1080),Vector2(0,790),Vector2(38,760),Vector2(73,795),Vector2(58,850),Vector2(96,900),Vector2(75,960),Vector2(128,1080)])
	canvas.draw_colored_polygon(left_rock,Color(0.24,0.10,0.18,rock_alpha))
	canvas.draw_polyline(PackedVector2Array([Vector2(0,790),Vector2(38,760),Vector2(73,795),Vector2(58,850),Vector2(96,900)]),Color(0.55,0.16,0.30,rock_alpha*2.0),1.2,true)
	var plant_alpha = 0.032*appear*(0.86+0.14*cos(time*0.13))
	for i in range(5):
		var base = Vector2(865.0+float(i%2)*34.0,960.0-float(i)*62.0)
		var top = base+Vector2(sin(time*0.26+i)*6.0,-48.0-float(i%2)*18.0)
		canvas.draw_line(base,top,Color(0.18,0.72,0.42,plant_alpha),1.6,true)
		var leaf = PackedVector2Array([top+Vector2(0,-9),top+Vector2(8,0),top+Vector2(0,6),top+Vector2(-8,0)])
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
		var shard = PackedVector2Array([p+Vector2(-size*0.5,-size*0.2),p+Vector2(size*0.1,-size),p+Vector2(size*0.65,-size*0.1),p+Vector2(size*0.2,size*0.75),p+Vector2(-size*0.7,size*0.35)])
		canvas.draw_colored_polygon(shard,Color(0.18,0.08,0.28,0.025+strength*0.035))
		canvas.draw_polyline(PackedVector2Array([shard[0],shard[1],shard[2],shard[3],shard[4],shard[0]]),Color(0.56,0.28,0.78,0.045+strength*0.055),1.0,true)
