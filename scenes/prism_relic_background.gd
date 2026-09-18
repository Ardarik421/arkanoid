extends RefCounted

static func draw_static(c: CanvasItem, progress: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_space(c,progress)
	_draw_prism_nebula(c,progress)
	_draw_crystal_megastructure(c,progress)
	_draw_shards(c,progress)

static func draw_dynamic(c: CanvasItem, progress: float, time: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_stars(c,time)
	_draw_prism_core(c,progress,time)
	_draw_light_streams(c,progress,time)

static func _draw_space(c: CanvasItem, progress: float) -> void:
	var top:=Color(0.004,0.002,0.016)
	var bottom:=Color(0.020,0.006,0.040).lerp(Color(0.006,0.030,0.046),progress)
	for y in range(0,1080,18):
		var t:float=float(y)/1080.0
		c.draw_rect(Rect2(0,y,960,19),top.lerp(bottom,t))

static func _center(progress: float) -> Vector2:
	return Vector2(500+sin(progress*PI)*80-progress*145,560-progress*65)

static func _draw_prism_nebula(c: CanvasItem, progress: float) -> void:
	var center:=_center(progress)+Vector2(120,-160)
	var cols:Array[Color]=[Color(0.65,0.10,0.78,0.020),Color(0.08,0.58,0.72,0.018),Color(0.72,0.22,0.46,0.014)]
	for i in range(11):
		var p:=center+Vector2(sin(float(i)*1.71)*250,float(i)*68-300)
		c.draw_circle(p,105+float(i%4)*34,cols[i%3])

static func _draw_crystal_megastructure(c: CanvasItem, progress: float) -> void:
	var center:=_center(progress)
	var scale_factor:=0.86+sin(progress*PI)*0.22
	# Huge nested diamond structure, unlike any planetary silhouette before it.
	for ring in range(7,0,-1):
		var rx:float=(95.0+float(ring)*42.0)*scale_factor
		var ry:float=(145.0+float(ring)*57.0)*scale_factor
		var pts:=PackedVector2Array([center+Vector2(0,-ry),center+Vector2(rx,0),center+Vector2(0,ry),center+Vector2(-rx,0),center+Vector2(0,-ry)])
		c.draw_polyline(pts,Color(0.34+float(ring)*0.035,0.18,0.72,0.055+float(8-ring)*0.012),2.0,true)
	# Faceted inner crystal.
	var r:=170.0*scale_factor
	var outer:=PackedVector2Array([center+Vector2(0,-r*1.55),center+Vector2(r,0),center+Vector2(0,r*1.55),center+Vector2(-r,0)])
	c.draw_colored_polygon(outer,Color(0.025,0.018,0.070,0.88))
	for i in range(4):
		var p1:Vector2=outer[i]
		var p2:Vector2=outer[(i+1)%4]
		c.draw_colored_polygon(PackedVector2Array([center,p1,p2]),Color(0.10+float(i%2)*0.06,0.08,0.25+float(i)*0.035,0.26))
	c.draw_polyline(PackedVector2Array([outer[0],outer[1],outer[2],outer[3],outer[0]]),Color(0.52,0.34,0.94,0.52),2.4,true)

static func _draw_shards(c: CanvasItem, progress: float) -> void:
	var center:=_center(progress)
	for i in range(42):
		var a:=float(i)*2.117
		var dist:=270.0+float((i*37)%370)
		var p:=center+Vector2(cos(a)*dist,sin(a)*dist*0.72)+Vector2(progress*35,0)
		var len:=9.0+float(i%7)*5.0
		var dir:=Vector2(cos(a+0.8),sin(a+0.8))
		var side:=Vector2(-dir.y,dir.x)
		var pts:=PackedVector2Array([p+dir*len,p+side*len*0.30,p-dir*len*0.75,p-side*len*0.30])
		c.draw_colored_polygon(pts,Color(0.035,0.025,0.090,0.82))
		var line:=PackedVector2Array(pts); line.append(pts[0])
		c.draw_polyline(line,Color(0.42,0.28,0.78,0.20),1.0,true)

static func _draw_stars(c: CanvasItem, time: float) -> void:
	for i in range(88):
		var p:=Vector2(float((i*197+41)%950)+5,float((i*127+59)%1060)+10)
		var pulse:=0.5+0.5*sin(time*(0.34+float(i%5)*0.06)+float(i)*1.57)
		var col:=Color(0.82,0.62,1.0,0.08+pulse*0.24) if i%3==0 else Color(0.52,0.86,1.0,0.07+pulse*0.20)
		c.draw_circle(p,0.55+float(i%4)*0.30,col)

static func _draw_prism_core(c: CanvasItem, progress: float, time: float) -> void:
	var center:=_center(progress)
	var pulse:=0.88+0.12*sin(time*0.92)
	for i in range(10,0,-1):
		c.draw_circle(center,15+float(i)*12,Color(0.48,0.20,1.0,0.0055*float(i)*pulse))
	for ray in range(12):
		var a:=TAU*float(ray)/12.0+time*0.025
		var d:=Vector2(cos(a),sin(a))
		var length:=48.0+(42.0 if ray%3==0 else 10.0)
		var col:=Color(0.78,0.36,1.0,0.18) if ray%2==0 else Color(0.24,0.82,1.0,0.16)
		c.draw_line(center+d*12,center+d*length*pulse,col,1.3,true)
	c.draw_circle(center,12*pulse,Color(0.78,0.68,1.0,0.86))
	c.draw_circle(center,4*pulse,Color.WHITE)

static func _draw_light_streams(c: CanvasItem, progress: float, time: float) -> void:
	var center:=_center(progress)
	for i in range(38):
		var base:=float(i)/38.0
		var t:=fmod(base+time*(0.010+float(i%4)*0.0015),1.0)
		var a:=TAU*base*3.0+time*0.04
		var dist:=90.0+t*520.0
		var p:=center+Vector2(cos(a)*dist,sin(a)*dist*0.68)
		var col:=Color(0.70,0.28,1.0,0.09) if i%2==0 else Color(0.20,0.82,1.0,0.08)
		c.draw_circle(p,0.8+float(i%3)*0.55,col)
