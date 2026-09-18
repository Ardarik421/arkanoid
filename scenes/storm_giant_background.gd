extends RefCounted

static func draw_static(c: CanvasItem, progress: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_space(c,progress)
	_draw_storm_nebula(c,progress)
	_draw_ocean_giant(c,progress)
	_draw_moons(c,progress)

static func draw_dynamic(c: CanvasItem, progress: float, time: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_stars(c,time)
	_draw_great_storm(c,progress,time)
	_draw_lightning(c,progress,time)
	_draw_mist(c,progress,time)

static func _draw_space(c: CanvasItem, progress: float) -> void:
	var top:=Color(0.001,0.007,0.020)
	var bottom:=Color(0.003,0.030,0.065).lerp(Color(0.010,0.015,0.052),progress)
	for y in range(0,1080,18):
		var t:float=float(y)/1080.0
		c.draw_rect(Rect2(0,y,960,19),top.lerp(bottom,t))

static func _draw_storm_nebula(c: CanvasItem, progress: float) -> void:
	var center:=Vector2(690-progress*170,270+progress*55)
	for i in range(12,0,-1):
		c.draw_circle(center,55+float(i)*40,Color(0.02,0.36,0.58,0.0032*float(i)))
	for i in range(8):
		var p:=center+Vector2(sin(float(i)*1.63)*260,float(i)*65-220)
		c.draw_circle(p,90+float(i%3)*32,Color(0.05,0.12,0.48,0.014))

static func _planet_data(progress: float) -> Array:
	var arc:=sin(progress*PI)
	return [Vector2(-145+progress*250,720-progress*45-arc*35),455.0+arc*105.0]

static func _draw_ocean_giant(c: CanvasItem, progress: float) -> void:
	var d:=_planet_data(progress)
	var center:Vector2=d[0]; var radius:float=d[1]
	for i in range(14,0,-1):
		c.draw_circle(center,radius+float(i)*14,Color(0.02,0.62,0.92,0.0027*float(i)))
	c.draw_circle(center,radius,Color(0.006,0.060,0.125))
	# Deep atmospheric bands.
	for i in range(15):
		var yy:=center.y-radius*0.73+float(i)*radius*0.102
		var half:=sqrt(maxf(0.0,radius*radius-pow(yy-center.y,2.0)))
		var bend:=sin(float(i)*1.55)*18.0
		var col:=Color(0.02,0.42+float(i%3)*0.055,0.60+float(i%2)*0.10,0.065)
		c.draw_line(Vector2(center.x-half*0.84,yy+bend),Vector2(center.x+half*0.78,yy-bend*0.45),col,16.0+float(i%3)*4.0,true)
	# Long turquoise cloud ribbons.
	for band in range(5):
		var pts:=PackedVector2Array()
		for j in range(49):
			var x:float=center.x-radius*0.78+float(j)*radius*1.56/48.0
			var normalized:float=(x-center.x)/radius
			var yy:float=center.y-radius*0.48+float(band)*radius*0.22+sin(float(j)*0.43+float(band))*9.0
			if normalized*normalized<1.0:
				pts.append(Vector2(x,yy))
		if pts.size()>1: c.draw_polyline(pts,Color(0.18,0.86,0.90,0.13),3.0,true)
	c.draw_circle(center+Vector2(-radius*0.42,radius*0.08),radius*0.92,Color(0.001,0.006,0.020,0.55))
	c.draw_arc(center,radius,-1.48,1.45,128,Color(0.28,0.90,1.0,0.70),4.0,true)

static func _draw_moons(c: CanvasItem, progress: float) -> void:
	var pos:Array[Vector2]=[Vector2(735-progress*260,205+progress*40),Vector2(860-progress*80,535-progress*95),Vector2(650+progress*150,890-progress*110)]
	for k in range(pos.size()):
		var p:=pos[k]; var r:=24.0+float(k)*7.0
		for i in range(4,0,-1): c.draw_circle(p,r+float(i)*7,Color(0.16,0.68,1.0,0.007*float(i)))
		c.draw_circle(p,r,Color(0.025,0.070,0.100))
		c.draw_circle(p+Vector2(-r*0.28,r*0.18),r*0.70,Color(0.002,0.010,0.020,0.64))
		c.draw_arc(p,r,-1.45,1.4,48,Color(0.42,0.88,1.0,0.48),1.5,true)

static func _storm_center(progress: float) -> Vector2:
	var d:=_planet_data(progress)
	var center:Vector2=d[0]; var radius:float=d[1]
	return center+Vector2(radius*0.43,-radius*0.10)

static func _draw_great_storm(c: CanvasItem, progress: float, time: float) -> void:
	var p:=_storm_center(progress)
	var pulse:=0.92+0.08*sin(time*1.08)
	for i in range(9,0,-1):
		var rr:=30.0+float(i)*12.0
		c.draw_set_transform(p,time*0.018*float(i%2*2-1),Vector2(1.75,0.68))
		c.draw_circle(Vector2.ZERO,rr,Color(0.08,0.82,0.94,0.006*float(i)*pulse))
	c.draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
	for ring in range(6):
		var pts:=PackedVector2Array()
		for j in range(65):
			var a:=TAU*float(j)/64.0+time*(0.10+float(ring)*0.012)
			var rx:=82.0-float(ring)*10.0
			var ry:=34.0-float(ring)*3.5
			pts.append(p+Vector2(cos(a)*rx,sin(a)*ry))
		c.draw_polyline(pts,Color(0.28+float(ring)*0.06,0.90,1.0,0.10+float(ring)*0.025),1.4,true)
	c.draw_circle(p,10.0*pulse,Color(0.70,0.98,1.0,0.72))

static func _draw_lightning(c: CanvasItem, progress: float, time: float) -> void:
	var p:=_storm_center(progress)
	for i in range(5):
		var phase:=fmod(time*0.62+float(i)*0.217,1.0)
		if phase<0.13:
			var a:float=-1.7+float(i)*0.72
			var start:=p+Vector2(cos(a),sin(a))*95.0
			var dir:=Vector2(cos(a),sin(a))
			var side:=Vector2(-dir.y,dir.x)
			var pts:=PackedVector2Array([start,start+dir*18+side*8,start+dir*38-side*7,start+dir*62+side*4])
			c.draw_polyline(pts,Color(0.72,0.96,1.0,0.30*(1.0-phase/0.13)),1.6,true)

static func _draw_stars(c: CanvasItem, time: float) -> void:
	for i in range(98):
		var p:=Vector2(float((i*181+31)%950)+5,float((i*107+47)%1060)+10)
		var pulse:=0.5+0.5*sin(time*(0.43+float(i%5)*0.07)+float(i)*1.49)
		c.draw_circle(p,0.55+float(i%4)*0.29,Color(0.58,0.88,1.0,0.10+pulse*0.30))

static func _draw_mist(c: CanvasItem, progress: float, time: float) -> void:
	for i in range(30):
		var x:=float((i*149+71)%940)+sin(time*0.09+float(i))*9.0
		var y:=float((i*79+53)%920)+80.0+cos(time*0.07+float(i)*1.7)*6.0
		c.draw_circle(Vector2(x,y),1.0+float(i%3)*0.65,Color(0.18,0.72,0.92,0.045))
