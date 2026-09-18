extends RefCounted

static func draw_static(c: CanvasItem, progress: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_space(c,progress)
	_draw_aurora(c,progress)
	_draw_binary_planets(c,progress)
	_draw_orbital_stream(c,progress)
	_draw_moons(c,progress)

static func draw_dynamic(c: CanvasItem, progress: float, time: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_stars(c,time)
	_draw_binary_star(c,progress,time)
	_draw_stream_sparks(c,progress,time)

static func _draw_space(c: CanvasItem, progress: float) -> void:
	var top:=Color(0.002,0.012,0.018)
	var bottom:=Color(0.010,0.060,0.052).lerp(Color(0.018,0.022,0.065),progress)
	for y in range(0,1080,18):
		var t:float=float(y)/1080.0
		c.draw_rect(Rect2(0,y,960,19),top.lerp(bottom,t))

static func _draw_aurora(c: CanvasItem, progress: float) -> void:
	var center:=Vector2(480+progress*90,360-progress*55)
	for i in range(12,0,-1):
		c.draw_circle(center,70+float(i)*42,Color(0.05,0.72,0.48,0.0028*float(i)))
	for i in range(7):
		var p:=center+Vector2(float(i)*115-330,sin(float(i)*1.5)*105)
		c.draw_circle(p,105+float(i%3)*30,Color(0.08,0.32,0.62,0.012))

static func _planet_data(progress: float) -> Array:
	var swing:=sin(progress*PI)
	var midpoint:=Vector2(490-progress*120,760+swing*35)
	var separation:=285.0+swing*70.0
	return [midpoint+Vector2(-separation*0.5,-55),midpoint+Vector2(separation*0.5,55),190.0+swing*35.0,150.0+swing*25.0]

static func _draw_binary_planets(c: CanvasItem, progress: float) -> void:
	var d:=_planet_data(progress)
	_draw_planet(c,d[0],d[2],Color(0.035,0.24,0.20),Color(0.18,1.0,0.68),false)
	_draw_planet(c,d[1],d[3],Color(0.12,0.07,0.24),Color(0.66,0.38,1.0),true)

static func _draw_planet(c: CanvasItem, center: Vector2, radius: float, base: Color, glow: Color, flip: bool) -> void:
	for i in range(9,0,-1):
		c.draw_circle(center,radius+float(i)*11,Color(glow.r,glow.g,glow.b,0.0035*float(i)))
	c.draw_circle(center,radius,base)
	for i in range(8):
		var yy:=center.y-radius*0.55+float(i)*radius*0.14
		var half:=sqrt(maxf(0.0,radius*radius-pow(yy-center.y,2.0)))
		c.draw_line(Vector2(center.x-half*0.72,yy),Vector2(center.x+half*0.68,yy+(8 if flip else -8)),Color(glow.r,glow.g,glow.b,0.045),10.0,true)
	var shade:=Vector2((-0.38 if flip else 0.38)*radius,0.12*radius)
	c.draw_circle(center+shade,radius*0.88,Color(0.002,0.008,0.015,0.58))
	c.draw_arc(center,radius,(-1.45 if flip else 1.70),(1.45 if flip else 4.55),96,Color(glow.r,glow.g,glow.b,0.68),3.0,true)

static func _draw_orbital_stream(c: CanvasItem, progress: float) -> void:
	var d:=_planet_data(progress)
	var a:Vector2=d[0]; var b:Vector2=d[1]
	var mid:Vector2=(a+b)*0.5
	for lane in range(7):
		var pts:=PackedVector2Array()
		for j in range(81):
			var t:=float(j)/80.0
			var x:=lerpf(a.x-d[2]*0.8,b.x+d[3]*0.8,t)
			var wave:=sin(t*PI)*115.0
			var y:=mid.y+cos(t*PI)*75.0+wave*(float(lane)-3.0)*0.055
			pts.append(Vector2(x,y))
		c.draw_polyline(pts,Color(0.30,0.88,0.78,0.075-float(lane)*0.006),1.2,true)

static func _draw_moons(c: CanvasItem, progress: float) -> void:
	var pos:Array[Vector2]=[Vector2(125+progress*170,260),Vector2(820-progress*120,330+progress*80)]
	for k in range(pos.size()):
		var p:=pos[k]; var r:=28.0+float(k)*9.0
		c.draw_circle(p,r+18,Color(0.28,0.72,0.82,0.025))
		c.draw_circle(p,r,Color(0.035,0.075,0.085))
		c.draw_circle(p+Vector2(-r*0.25,r*0.2),r*0.72,Color(0.003,0.012,0.020,0.62))
		c.draw_arc(p,r,-1.5,1.4,48,Color(0.48,0.92,0.88,0.42),1.5,true)

static func _draw_stars(c: CanvasItem, time: float) -> void:
	for i in range(112):
		var p:=Vector2(float((i*173+29)%950)+5,float((i*113+19)%1060)+10)
		var pulse:=0.5+0.5*sin(time*(0.42+float(i%5)*0.07)+float(i)*1.51)
		c.draw_circle(p,0.55+float(i%4)*0.28,Color(0.68,1.0,0.90,0.11+pulse*0.31))

static func _draw_binary_star(c: CanvasItem, progress: float, time: float) -> void:
	var center:=Vector2(770-progress*390,155+progress*95)
	var orbit:=32.0+progress*10.0
	for k in range(2):
		var a:=time*0.32+PI*float(k)
		var p:=center+Vector2(cos(a),sin(a))*orbit
		var col:=Color(0.45,1.0,0.82) if k==0 else Color(0.68,0.48,1.0)
		var pulse:=0.9+0.1*sin(time*1.15+float(k)*PI)
		for i in range(6,0,-1): c.draw_circle(p,8+float(i)*8,Color(col.r,col.g,col.b,0.006*float(i)*pulse))
		c.draw_circle(p,6*pulse,Color(col.r,col.g,col.b,0.94))
	c.draw_line(center+Vector2(-orbit,0),center+Vector2(orbit,0),Color(0.55,0.82,1.0,0.08),1.0,true)

static func _draw_stream_sparks(c: CanvasItem, progress: float, time: float) -> void:
	var d:=_planet_data(progress)
	var a:Vector2=d[0]; var b:Vector2=d[1]
	for i in range(34):
		var t:=fmod(float(i)/34.0+time*(0.012+float(i%3)*0.002),1.0)
		var p:=a.lerp(b,t)
		p.y+=sin(t*PI)*70.0*sin(float(i)*2.1)
		c.draw_circle(p,0.8+float(i%3)*0.5,Color(0.42,1.0,0.82,0.08))
