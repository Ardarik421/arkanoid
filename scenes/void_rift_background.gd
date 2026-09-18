extends RefCounted

static func draw_static(c: CanvasItem, progress: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_void(c,progress)
	_draw_rift_glow(c,progress)
	_draw_distant_structures(c,progress)
	_draw_silhouettes(c,progress)

static func draw_dynamic(c: CanvasItem, progress: float, time: float) -> void:
	progress=clampf(progress,0.0,1.0)
	_draw_sparse_stars(c,time)
	_draw_rift(c,progress,time)
	_draw_wisps(c,progress,time)

static func _draw_void(c: CanvasItem, progress: float) -> void:
	var top:=Color(0.001,0.002,0.009)
	var bottom:=Color(0.004,0.008,0.020).lerp(Color(0.012,0.004,0.025),progress)
	for y in range(0,1080,18):
		var t:float=float(y)/1080.0
		c.draw_rect(Rect2(0,y,960,19),top.lerp(bottom,t))

static func _rift_center(progress: float) -> Vector2:
	return Vector2(760-progress*500,420+progress*150+sin(progress*PI)*55)

static func _draw_rift_glow(c: CanvasItem, progress: float) -> void:
	var center:=_rift_center(progress)
	for i in range(14,0,-1):
		var rx:=65.0+float(i)*28.0
		var ry:=120.0+float(i)*42.0
		var pts:=PackedVector2Array()
		for j in range(65):
			var a:=TAU*float(j)/64.0
			pts.append(center+Vector2(cos(a)*rx,sin(a)*ry))
		c.draw_polyline(pts,Color(0.34,0.08,0.72,0.0045*float(i)),9.0,true)

static func _draw_distant_structures(c: CanvasItem, progress: float) -> void:
	# Ghostly concentric arcs hint at something artificial or impossible in the void.
	var center:=_rift_center(progress)
	for ring in range(5):
		var radius:=220.0+float(ring)*78.0
		var pts:=PackedVector2Array()
		for j in range(45):
			var a:float=-1.25+2.5*float(j)/44.0
			pts.append(center+Vector2(cos(a)*radius*0.72,sin(a)*radius))
		c.draw_polyline(pts,Color(0.18,0.22,0.52,0.045-float(ring)*0.005),1.2,true)
	for i in range(7):
		var a:=float(i)*TAU/7.0+progress*0.35
		var p:=center+Vector2(cos(a)*330,sin(a)*430)
		c.draw_circle(p,4.0+float(i%3)*2.0,Color(0.22,0.14,0.46,0.25))

static func _draw_silhouettes(c: CanvasItem, progress: float) -> void:
	# Sparse foreground shards make the emptiness feel enormous.
	for i in range(13):
		var x:=float((i*271+83)%1080)-60.0-progress*75.0
		var y:=float((i*157+211)%1180)-50.0
		var r:=10.0+float(i%5)*9.0
		var a:=float(i)*0.91
		var d:=Vector2(cos(a),sin(a)); var side:=Vector2(-d.y,d.x)
		var p:=Vector2(x,y)
		var pts:=PackedVector2Array([p+d*r*1.8,p+side*r*0.65,p-d*r*1.15,p-side*r*0.55])
		c.draw_colored_polygon(pts,Color(0.006,0.008,0.018,0.92))
		var line:=PackedVector2Array(pts); line.append(pts[0])
		c.draw_polyline(line,Color(0.16,0.12,0.32,0.13),1.0,true)

static func _draw_sparse_stars(c: CanvasItem, time: float) -> void:
	for i in range(67):
		var p:=Vector2(float((i*211+53)%950)+5,float((i*137+31)%1060)+10)
		var pulse:=0.48+0.52*sin(time*(0.30+float(i%4)*0.055)+float(i)*1.71)
		c.draw_circle(p,0.45+float(i%3)*0.27,Color(0.52,0.58,0.82,0.07+pulse*0.19))

static func _draw_rift(c: CanvasItem, progress: float, time: float) -> void:
	var center:=_rift_center(progress)
	var pulse:=0.86+0.14*sin(time*0.72)
	# Dark core first: the rift should read as absence, not another planet.
	c.draw_set_transform(center,-0.10+sin(progress*PI)*0.08,Vector2(0.58,1.0))
	for i in range(9,0,-1):
		c.draw_circle(Vector2.ZERO,58.0+float(i)*9.0,Color(0.34,0.10,0.72,0.008*float(i)*pulse))
	c.draw_circle(Vector2.ZERO,62.0,Color(0.001,0.001,0.006,0.98))
	c.draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
	# Broken luminous rim.
	for k in range(9):
		var start:float=-1.45+float(k)*0.34+sin(time*0.16+float(k))*0.035
		var finish:float=start+0.19+float(k%3)*0.035
		var pts:=PackedVector2Array()
		for j in range(14):
			var a:=lerpf(start,finish,float(j)/13.0)
			pts.append(center+Vector2(cos(a)*86.0,sin(a)*148.0))
		c.draw_polyline(pts,Color(0.58,0.30,1.0,0.28+0.20*pulse),2.0,true)
		var mirror:=PackedVector2Array()
		for p in pts: mirror.append(center-(p-center))
		c.draw_polyline(mirror,Color(0.18,0.52,1.0,0.18+0.14*pulse),1.5,true)

static func _draw_wisps(c: CanvasItem, progress: float, time: float) -> void:
	var center:=_rift_center(progress)
	for i in range(32):
		var phase:=float(i)*2.37
		var a:=phase+time*(0.018+float(i%3)*0.004)
		var dist:=115.0+float((i*31)%310)
		var p:=center+Vector2(cos(a)*dist*0.72,sin(a)*dist)
		var alpha:=0.035+0.035*(0.5+0.5*sin(time*0.6+phase))
		c.draw_circle(p,0.8+float(i%3)*0.55,Color(0.40,0.22,0.82,alpha))
