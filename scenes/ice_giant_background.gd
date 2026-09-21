extends RefCounted

static func draw_static(c: CanvasItem, progress: float) -> void:
	progress = clampf(progress, 0.0, 1.0)
	_draw_space(c, progress)
	_draw_nebula(c, progress)
	_draw_ice_giant(c, progress)
	_draw_vertical_rings(c, progress)
	_draw_moons(c, progress)
	_draw_crystal_field(c, progress)

static func draw_dynamic(c: CanvasItem, progress: float, time: float) -> void:
	progress = clampf(progress, 0.0, 1.0)
	_draw_stars(c, time)
	_draw_ice_dust(c, progress, time)
	_draw_blue_star(c, progress, time)

static func _draw_space(c: CanvasItem, progress: float) -> void:
	var top := Color(0.002,0.010,0.026)
	var bottom := Color(0.008,0.045,0.070).lerp(Color(0.015,0.018,0.060),progress)
	for y in range(0,1080,18):
		var t: float=float(y)/1080.0
		c.draw_rect(Rect2(0, y, c.get_viewport_rect().size.x, 19),top.lerp(bottom,t))

static func _draw_nebula(c: CanvasItem, progress: float) -> void:
	var center:=Vector2(700-progress*170,300+progress*70)
	for i in range(11,0,-1):
		c.draw_circle(center,50+float(i)*34,Color(0.05,0.52,0.72,0.0038*float(i)))
	for i in range(8):
		var p:=center+Vector2(sin(float(i)*1.8)*210,float(i)*62-210)
		c.draw_circle(p,75+float(i%3)*28,Color(0.10,0.18,0.62,0.017))

static func _planet_data(progress: float) -> Array:
	var arc: float=sin(progress*PI)
	return [Vector2(-120+progress*245,690+progress*80-arc*70),390+arc*105-progress*25]

static func _draw_ice_giant(c: CanvasItem, progress: float) -> void:
	var data:=_planet_data(progress)
	var center: Vector2=data[0]
	var radius: float=data[1]
	for i in range(12,0,-1):
		c.draw_circle(center,radius+float(i)*13,Color(0.10,0.72,0.92,0.0036*float(i)))
	c.draw_circle(center,radius,Color(0.015,0.105,0.145))
	for i in range(11):
		var y:=center.y-radius*0.68+float(i)*radius*0.13
		var half:=sqrt(maxf(0.0,radius*radius-pow(y-center.y,2.0)))
		var alpha:=0.035+float(i%3)*0.012
		c.draw_line(Vector2(center.x-half*0.80,y),Vector2(center.x+half*0.77,y-8),Color(0.24,0.82,0.92,alpha),15.0,true)
	c.draw_circle(center+Vector2(-radius*0.42,radius*0.10),radius*0.91,Color(0.002,0.012,0.025,0.60))
	c.draw_arc(center,radius,-1.45,1.45,128,Color(0.42,0.94,1.0,0.78),4.0,true)
	c.draw_arc(center,radius+10,-1.50,1.50,128,Color(0.20,0.72,1.0,0.24),13.0,true)

static func _draw_vertical_rings(c: CanvasItem, progress: float) -> void:
	var data:=_planet_data(progress)
	var center: Vector2=data[0]
	var radius: float=data[1]
	# Tall luminous arcs deliberately break the silhouette of earlier chapters.
	for i in range(10):
		var offset: float=(float(i)-4.5)*8.0
		var alpha: float=0.13-float(i)*0.008
		var pts:=PackedVector2Array()
		for j in range(65):
			var a: float=-1.34+2.68*float(j)/64.0
			pts.append(center+Vector2(cos(a)*(radius*0.48+offset),sin(a)*(radius*1.62+offset*1.7)))
		c.draw_polyline(pts,Color(0.32,0.88,1.0,alpha),1.4,true)

static func _draw_moons(c: CanvasItem, progress: float) -> void:
	var positions:Array[Vector2]=[Vector2(700-progress*310,190+progress*80),Vector2(835-progress*80,640-progress*160),Vector2(560+progress*160,875-progress*40)]
	for j in range(positions.size()):
		var p:=positions[j]
		var r:=34.0+float(j%2)*13.0
		for i in range(4,0,-1): c.draw_circle(p,r+float(i)*7,Color(0.18,0.70,1.0,0.008*float(i)))
		c.draw_circle(p,r,Color(0.035,0.085,0.12))
		c.draw_circle(p+Vector2(-r*0.25,r*0.20),r*0.72,Color(0.006,0.018,0.035,0.62))
		c.draw_arc(p,r,-1.5,1.45,48,Color(0.55,0.92,1.0,0.55),1.6,true)

static func _draw_crystal_field(c: CanvasItem, progress: float) -> void:
	for i in range(48):
		var t:=float(i)/47.0
		var p:=Vector2(160+t*900-progress*100,310+t*390+sin(float(i)*1.77)*75)
		var r:=3.0+float(i%7)*1.5
		var a:=float(i)*0.83
		var dir:=Vector2(cos(a),sin(a))
		var side:=Vector2(-dir.y,dir.x)
		var pts:=PackedVector2Array([p+dir*r*1.8,p+side*r*0.65,p-dir*r*1.15,p-side*r*0.65])
		c.draw_colored_polygon(pts,Color(0.05,0.20,0.28,0.78))
		var line:=PackedVector2Array(pts); line.append(pts[0])
		c.draw_polyline(line,Color(0.30,0.82,1.0,0.28),1.0,true)

static func _draw_stars(c: CanvasItem, time: float) -> void:
	for i in range(105):
		var x:=float((i*167+43)%950)+5.0
		var y:=float((i*109+23)%1060)+10.0
		var pulse:=0.55+0.45*sin(time*(0.48+float(i%5)*0.07)+float(i)*1.57)
		c.draw_circle(Vector2(x,y),0.55+float(i%4)*0.30,Color(0.65,0.92,1.0,0.13+pulse*0.34))

static func _draw_ice_dust(c: CanvasItem, progress: float, time: float) -> void:
	for i in range(32):
		var x:=float((i*137+61)%940)+sin(time*0.12+float(i))*7.0
		var y:=float((i*73+83)%920)+90.0-fmod(time*(1.4+float(i%4)*0.25)+float(i)*27.0,80.0)
		c.draw_circle(Vector2(x,y),0.65+float(i%3)*0.4,Color(0.42,0.90,1.0,0.07))

static func _draw_blue_star(c: CanvasItem, progress: float, time: float) -> void:
	var p:=Vector2(835-progress*300,120+progress*55)
	var pulse:=0.90+0.10*sin(time*1.18)
	for i in range(9,0,-1): c.draw_circle(p,10+float(i)*10,Color(0.28,0.72,1.0,0.0055*float(i)*pulse))
	for i in range(16):
		var a:=TAU*float(i)/16.0
		var d:=Vector2(cos(a),sin(a))
		var length:=28.0+(38.0 if i%4==0 else 10.0)
		c.draw_line(p+d*8,p+d*length*pulse,Color(0.62,0.92,1.0,0.20),1.1,true)
	c.draw_circle(p,8*pulse,Color(0.82,0.97,1.0,0.94))
	c.draw_circle(p,3.0*pulse,Color.WHITE)
