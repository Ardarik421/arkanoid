extends RefCounted

static func draw_static(c: CanvasItem, progress: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_space(c,progress)
	_draw_nebula(c,progress)
	_draw_fragments(c,progress)
	_draw_world(c,progress)

static func draw_dynamic(c: CanvasItem, progress: float, time: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_stars(c,time)
	_draw_energy(c,progress,time)
	_draw_embers(c,progress,time)

static func _draw_space(c: CanvasItem, progress: float) -> void:
	var top:=Color(0.006,0.003,0.022)
	var bottom:=Color(0.025,0.008,0.060).lerp(Color(0.008,0.035,0.065),progress)
	for y in range(0,1080,18):
		var t:float=float(y)/1080.0
		c.draw_rect(Rect2(0, y, c.get_viewport_rect().size.x, 19),top.lerp(bottom,t))

static func _draw_nebula(c: CanvasItem, progress: float) -> void:
	var center:=Vector2(580-progress*210,420-progress*80)
	for i in range(12,0,-1):
		c.draw_circle(center,55+float(i)*39,Color(0.26,0.08,0.58,0.0038*float(i)))
	for i in range(8):
		var p:=center+Vector2(sin(float(i)*1.61)*260,float(i)*70-240)
		c.draw_circle(p,90+float(i%3)*34,Color(0.04,0.34,0.58,0.014))

static func _world_data(progress: float) -> Array:
	var arc:=sin(progress*PI)
	return [Vector2(720-progress*480,790+progress*145-arc*95),315.0+arc*95.0]

static func _draw_world(c: CanvasItem, progress: float) -> void:
	var data:=_world_data(progress)
	var center:Vector2=data[0]
	var radius:float=data[1]
	for i in range(10,0,-1):
		c.draw_circle(center,radius+float(i)*13,Color(0.28,0.24,0.78,0.003*float(i)))
	c.draw_circle(center,radius,Color(0.020,0.025,0.055))
	# Massive missing wedges make the planet visibly broken.
	var cuts:Array[float]=[-2.45,-1.35,-0.35,0.62,1.72,2.55]
	for k in range(cuts.size()):
		var a:float=cuts[k]
		var dir:=Vector2(cos(a),sin(a))
		var side:=Vector2(-dir.y,dir.x)
		var p0:=center+dir*radius*0.12
		var p1:=center+dir*radius*1.05+side*radius*(0.10+0.025*float(k%2))
		var p2:=center+dir*radius*1.05-side*radius*(0.08+0.03*float((k+1)%2))
		c.draw_colored_polygon(PackedVector2Array([p0,p1,p2]),Color(0.002,0.004,0.014))
	# Surface plates.
	for i in range(18):
		var a:=float(i)*2.31
		var rr:=radius*(0.22+float((i*19)%64)/100.0)
		var p:=center+Vector2(cos(a),sin(a))*rr
		c.draw_circle(p,12+float(i%4)*6,Color(0.06,0.08,0.13,0.24))
	c.draw_circle(center+Vector2(radius*0.40,radius*0.20),radius*0.88,Color(0.001,0.004,0.012,0.62))
	c.draw_arc(center,radius,-2.95,-0.15,128,Color(0.30,0.72,1.0,0.48),2.5,true)

static func _draw_fragments(c: CanvasItem, progress: float) -> void:
	var data:=_world_data(progress)
	var center:Vector2=data[0]
	var radius:float=data[1]
	for i in range(54):
		var a:=float(i)*2.173+0.25
		var dist:=radius*(1.08+float((i*17)%72)/100.0)
		var p:=center+Vector2(cos(a),sin(a))*dist+Vector2(progress*35,-progress*20)
		var r:=3.0+float(i%8)*2.0
		var pts:=PackedVector2Array()
		for j in range(7):
			var aa:=TAU*float(j)/7.0+float(i)*0.11
			var rough:=0.72+0.24*sin(float(j)*3.3+float(i))
			pts.append(p+Vector2(cos(aa),sin(aa))*r*rough)
		c.draw_colored_polygon(pts,Color(0.035,0.045,0.075,0.92))
		var line:=PackedVector2Array(pts); line.append(pts[0])
		c.draw_polyline(line,Color(0.24,0.48,0.72,0.20),1.0,true)

static func _draw_energy(c: CanvasItem, progress: float, time: float) -> void:
	var data:=_world_data(progress)
	var center:Vector2=data[0]
	var radius:float=data[1]
	var pulse:=0.82+0.18*sin(time*1.35)
	for i in range(9,0,-1):
		c.draw_circle(center,18+float(i)*13,Color(0.28,0.58,1.0,0.006*float(i)*pulse))
	c.draw_circle(center,18*pulse,Color(0.48,0.82,1.0,0.24))
	c.draw_circle(center,7*pulse,Color(0.82,0.96,1.0,0.90))
	# Pulsating fissures radiating from the exposed core.
	for i in range(12):
		var a:=float(i)*TAU/12.0+0.12*sin(time*0.18+float(i))
		var d:=Vector2(cos(a),sin(a))
		var side:=Vector2(-d.y,d.x)
		var start:=center+d*24.0
		var mid:=center+d*(radius*0.45)+side*sin(float(i)*2.4)*18.0
		var end:=center+d*(radius*0.92)+side*cos(float(i)*1.7)*26.0
		c.draw_polyline(PackedVector2Array([start,mid,end]),Color(0.30,0.72,1.0,0.18+0.20*pulse),1.5,true)
		if i%3==0:
			c.draw_line(mid,mid+side*(18+float(i)),Color(0.48,0.28,1.0,0.16*pulse),1.0,true)

static func _draw_stars(c: CanvasItem, time: float) -> void:
	for i in range(104):
		var x:=float((i*179+37)%950)+5.0
		var y:=float((i*101+41)%1060)+10.0
		var pulse:=0.52+0.48*sin(time*(0.44+float(i%5)*0.08)+float(i)*1.63)
		c.draw_circle(Vector2(x,y),0.55+float(i%4)*0.31,Color(0.62,0.80,1.0,0.12+pulse*0.34))

static func _draw_embers(c: CanvasItem, progress: float, time: float) -> void:
	var data:=_world_data(progress)
	var center:Vector2=data[0]
	for i in range(38):
		var a:=float(i)*2.47+time*(0.025+float(i%3)*0.008)
		var dist:=100.0+float((i*29)%330)
		var p:=center+Vector2(cos(a),sin(a))*dist
		var pulse:=0.5+0.5*sin(time*0.9+float(i))
		c.draw_circle(p,0.8+float(i%3)*0.55,Color(0.38,0.66,1.0,0.06+pulse*0.10))
