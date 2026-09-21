extends RefCounted

static func draw_static(c: CanvasItem, progress: float) -> void:
	progress = clampf(progress, 0.0, 1.0)
	_draw_space(c, progress)
	_draw_nebula(c, progress)
	_draw_planet(c, progress)
	_draw_rings(c, progress)
	_draw_moons(c, progress)
	_draw_rocks(c, progress)

static func draw_dynamic(c: CanvasItem, progress: float, time: float) -> void:
	progress = clampf(progress, 0.0, 1.0)
	_draw_stars(c, time)
	_draw_dust(c, progress, time)
	_draw_distant_sun(c, progress, time)

static func _draw_space(c: CanvasItem, progress: float) -> void:
	var top := Color(0.010, 0.004, 0.018)
	var bottom := Color(0.055, 0.012, 0.030).lerp(Color(0.025, 0.008, 0.045), progress)
	for y in range(0, 1080, 18):
		var t: float = float(y) / 1080.0
		c.draw_rect(Rect2(0, y, c.get_viewport_rect().size.x, 19), top.lerp(bottom, t))

static func _draw_nebula(c: CanvasItem, progress: float) -> void:
	var center := Vector2(250.0 + progress * 150.0, 240.0 - progress * 45.0)
	for i in range(10, 0, -1):
		c.draw_circle(center, 55.0 + float(i) * 38.0, Color(0.48, 0.08, 0.18, 0.0045 * float(i)))
	for i in range(7):
		var p := center + Vector2(float(i) * 82.0 - 180.0, sin(float(i) * 1.7) * 90.0)
		c.draw_circle(p, 95.0 + float(i % 3) * 32.0, Color(0.18, 0.05, 0.30, 0.018))

static func _draw_planet(c: CanvasItem, progress: float) -> void:
	var sweep: float = sin(progress * PI)
	var center := Vector2(760.0 - progress * 350.0, 850.0 + progress * 120.0 - sweep * 90.0)
	var radius: float = 330.0 + sweep * 90.0
	for i in range(11, 0, -1):
		c.draw_circle(center, radius + float(i) * 13.0, Color(1.0, 0.22, 0.06, 0.0035 * float(i)))
	c.draw_circle(center, radius, Color(0.13, 0.018, 0.018))
	for i in range(9):
		var y: float = center.y - radius * 0.62 + float(i) * radius * 0.15
		var half: float = sqrt(maxf(0.0, radius * radius - pow(y - center.y, 2.0)))
		c.draw_line(Vector2(center.x-half*0.76,y),Vector2(center.x+half*0.70,y-10),Color(0.92,0.22,0.07,0.055),18.0,true)
	c.draw_circle(center + Vector2(radius*0.42, radius*0.16), radius*0.90, Color(0.005,0.002,0.008,0.68))
	c.draw_arc(center,radius,-2.82,-0.25,128,Color(1.0,0.40,0.12,0.82),4.0,true)
	c.draw_arc(center,radius+11.0,-2.88,-0.20,128,Color(1.0,0.18,0.05,0.24),13.0,true)

static func _draw_rings(c: CanvasItem, progress: float) -> void:
	var center := Vector2(760.0 - progress * 350.0, 850.0 + progress * 120.0 - sin(progress*PI)*90.0)
	var radius: float = 330.0 + sin(progress*PI)*90.0
	for i in range(8):
		var ry: float = radius * (0.28 + float(i) * 0.018)
		var rx: float = radius * (1.42 + float(i) * 0.035)
		c.draw_arc(center, rx, PI+0.16, TAU-0.16, 128, Color(0.90,0.38,0.14,0.10-float(i)*0.008), 2.0, true)
		# inner bright ring accent
		c.draw_arc(center, rx, 0.18, PI-0.18, 128, Color(0.75,0.26,0.10,0.055), maxf(1.0, ry*0.015), true)

static func _draw_moons(c: CanvasItem, progress: float) -> void:
	var positions: Array[Vector2] = [Vector2(150+progress*110,210+progress*35),Vector2(835-progress*75,300+progress*55)]
	for j in range(positions.size()):
		var p: Vector2 = positions[j]
		var r: float = 42.0 - float(j)*12.0
		for i in range(4,0,-1): c.draw_circle(p,r+float(i)*7.0,Color(0.55,0.20,0.12,0.009*float(i)))
		c.draw_circle(p,r,Color(0.075,0.045,0.055))
		c.draw_circle(p+Vector2(-r*0.28,r*0.18),r*0.76,Color(0.018,0.012,0.020,0.65))
		c.draw_arc(p,r,-1.5,1.45,48,Color(0.92,0.42,0.22,0.52),1.6,true)

static func _draw_rocks(c: CanvasItem, progress: float) -> void:
	for i in range(42):
		var t: float = float(i)/41.0
		var p := Vector2(-40+t*1040+progress*80,420+t*150+sin(float(i)*1.8)*65)
		var r: float = 2.5+float(i%6)*1.6
		var pts:=PackedVector2Array()
		for j in range(7):
			var a:=TAU*float(j)/7.0
			pts.append(p+Vector2(cos(a),sin(a))*r*(0.78+0.18*sin(float(j)*2.9+float(i))))
		c.draw_colored_polygon(pts,Color(0.075,0.045,0.055,0.88))

static func _draw_stars(c: CanvasItem, time: float) -> void:
	for i in range(92):
		var x:=float((i*181+31)%950)+5.0
		var y:=float((i*103+17)%1060)+10.0
		var pulse:=0.55+0.45*sin(time*(0.42+float(i%4)*0.08)+float(i)*1.4)
		c.draw_circle(Vector2(x,y),0.6+float(i%3)*0.35,Color(1.0,0.72,0.65,0.12+pulse*0.30))

static func _draw_dust(c: CanvasItem, progress: float, time: float) -> void:
	for i in range(26):
		var x:=float((i*139+77)%940)+sin(time*0.1+float(i))*6.0
		var y:=float((i*71+95)%900)+120.0-fmod(time*(1.2+float(i%3)*0.3)+float(i)*23.0,70.0)
		c.draw_circle(Vector2(x,y),0.7+float(i%3)*0.35,Color(1.0,0.32,0.12,0.055))

static func _draw_distant_sun(c: CanvasItem, progress: float, time: float) -> void:
	var p:=Vector2(865-progress*180,135+progress*70)
	var pulse:=0.9+0.1*sin(time*1.0)
	for i in range(7,0,-1): c.draw_circle(p,9+float(i)*9,Color(1.0,0.32,0.08,0.006*float(i)*pulse))
	for i in range(12):
		var a:=TAU*float(i)/12.0
		var d:=Vector2(cos(a),sin(a))
		c.draw_line(p+d*7,p+d*(22+float(i%2)*13)*pulse,Color(1.0,0.48,0.18,0.17),1.0,true)
	c.draw_circle(p,7*pulse,Color(1.0,0.76,0.48,0.9))
