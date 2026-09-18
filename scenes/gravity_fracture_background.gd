extends RefCounted

static func draw_static(c: CanvasItem, progress: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_space(c,progress)
	_draw_lensing_fog(c,progress)
	_draw_broken_planes(c,progress)
	_draw_gravity_well(c,progress)

static func draw_dynamic(c: CanvasItem, progress: float, time: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_warped_stars(c,progress,time)
	_draw_gravity_arcs(c,progress,time)
	_draw_reality_tears(c,progress,time)

static func _draw_space(c: CanvasItem, progress: float) -> void:
	var top:=Color(0.004,0.001,0.010)
	var bottom:=Color(0.025,0.003,0.022).lerp(Color(0.010,0.001,0.012),progress)
	for y in range(0,1080,18):
		var t:float=float(y)/1080.0
		c.draw_rect(Rect2(0,y,960,19),top.lerp(bottom,t))

static func _core(progress: float) -> Vector2:
	return Vector2(735-progress*260,285+progress*175)

static func _draw_lensing_fog(c: CanvasItem, progress: float) -> void:
	var center:=_core(progress)
	for i in range(13,0,-1):
		c.draw_circle(center,65+float(i)*38,Color(0.52,0.06,0.48,0.0028*float(i)))
	for i in range(8):
		var p:=center+Vector2(sin(float(i)*1.8)*300,float(i)*85-310)
		c.draw_circle(p,100+float(i%3)*38,Color(0.12,0.18,0.58,0.010))

static func _draw_broken_planes(c: CanvasItem, progress: float) -> void:
	var strength:=0.55+progress*0.45
	var polys:Array[PackedVector2Array]=[
		PackedVector2Array([Vector2(-40,90),Vector2(250,40),Vector2(180,330),Vector2(-20,390)]),
		PackedVector2Array([Vector2(770,40),Vector2(1020,100),Vector2(950,390),Vector2(735,305)]),
		PackedVector2Array([Vector2(-30,760),Vector2(230,680),Vector2(285,1030),Vector2(20,1120)]),
		PackedVector2Array([Vector2(760,720),Vector2(1010,620),Vector2(1020,1050),Vector2(830,960)])
	]
	for i in range(polys.size()):
		c.draw_colored_polygon(polys[i],Color(0.055+float(i%2)*0.025,0.025,0.090+float(i)*0.018,0.18*strength))
		var line:=PackedVector2Array(polys[i]); line.append(polys[i][0])
		c.draw_polyline(line,Color(0.46,0.16,0.66,0.14*strength),1.4,true)

static func _draw_gravity_well(c: CanvasItem, progress: float) -> void:
	var center:=_core(progress)
	var radius:=78.0+progress*38.0
	for i in range(10,0,-1):
		c.draw_circle(center,radius+float(i)*13,Color(0.45,0.10,0.70,0.004*float(i)))
	c.draw_circle(center,radius,Color(0.0,0.0,0.003,0.97))
	for ring in range(8):
		var pts:=PackedVector2Array()
		var rx:=radius+25.0+float(ring)*23.0
		var ry:=rx*(0.38+float(ring)*0.015)
		for j in range(65):
			var a:=TAU*float(j)/64.0
			pts.append(center+Vector2(cos(a)*rx,sin(a)*ry))
		c.draw_polyline(pts,Color(0.62,0.24,0.82,0.09-float(ring)*0.007),1.3,true)

static func _draw_warped_stars(c: CanvasItem, progress: float, time: float) -> void:
	var center:=_core(progress)
	for i in range(92):
		var base:=Vector2(float((i*193+47)%950)+5,float((i*131+29)%1060)+10)
		var to_core:=center-base
		var dist:=maxf(90.0,to_core.length())
		var tangent:=Vector2(-to_core.y,to_core.x).normalized()
		var warp:=tangent*sin(float(i)*1.73+time*0.08)*(8.0+progress*28.0)*(300.0/(dist+160.0))
		var p:=base+warp
		var pulse:=0.5+0.5*sin(time*0.42+float(i)*1.4)
		if i%5==0:
			c.draw_line(p-tangent*(2+progress*8),p+tangent*(2+progress*8),Color(0.72,0.68,1.0,0.08+pulse*0.16),1.0,true)
		else:
			c.draw_circle(p,0.55+float(i%3)*0.3,Color(0.72,0.78,1.0,0.08+pulse*0.18))

static func _draw_gravity_arcs(c: CanvasItem, progress: float, time: float) -> void:
	var center:=_core(progress)
	var pulse:=0.82+0.18*sin(time*0.64)
	for i in range(9):
		var radius:=120.0+float(i)*24.0
		var start:float=-2.8+float(i)*0.08+sin(time*0.12+float(i))*0.04
		c.draw_arc(center,radius,start,start+1.85,64,Color(0.82,0.28,0.92,0.06+0.07*pulse),1.4,true)
		c.draw_arc(center,radius,start+PI,start+PI+1.55,64,Color(0.20,0.54,1.0,0.045+0.05*pulse),1.1,true)

static func _draw_reality_tears(c: CanvasItem, progress: float, time: float) -> void:
	var strength:=0.45+progress*0.55
	var starts:Array[Vector2]=[Vector2(90,120),Vector2(880,180),Vector2(120,850),Vector2(790,760)]
	for i in range(starts.size()):
		var p:=starts[i]
		var pts:=PackedVector2Array([p,p+Vector2(45,-25),p+Vector2(30,65),p+Vector2(85,110),p+Vector2(62,185)])
		for j in range(pts.size()):
			pts[j]+=Vector2(sin(time*0.42+float(i+j))*2.5,cos(time*0.37+float(i+j))*2.0)*strength
		c.draw_polyline(pts,Color(0.78,0.28,0.92,0.12*strength),2.0,true)
		c.draw_polyline(pts,Color(0.24,0.62,1.0,0.045*strength),5.0,true)
