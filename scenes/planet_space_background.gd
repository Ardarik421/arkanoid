extends RefCounted

static func draw_static(canvas: CanvasItem, progress: float) -> void:
	progress = clampf(progress, 0.0, 1.0)
	_draw_space(canvas, progress)
	_draw_nebula(canvas, progress, 0.0)
	_draw_moon(canvas, progress, 0.0)
	_draw_asteroid_belt(canvas, progress, 0.0)
	_draw_planet(canvas, progress, 0.0)

static func draw_dynamic(canvas: CanvasItem, progress: float, time: float) -> void:
	progress = clampf(progress, 0.0, 1.0)
	_draw_stars(canvas, progress, time)
	_draw_sun(canvas, progress, time)
	_draw_dust(canvas, progress, time)

static func draw_background(canvas: CanvasItem, progress: float, time: float) -> void:
	draw_static(canvas, progress)
	draw_dynamic(canvas, progress, time)

static func _draw_space(c: CanvasItem, progress: float) -> void:
	var top: Color = Color(0.002, 0.008, 0.022)
	var bottom: Color = Color(0.030, 0.026, 0.018).lerp(Color(0.012, 0.018, 0.040), progress)
	for y in range(0, 1080, 12):
		var t: float = float(y) / 1080.0
		c.draw_rect(Rect2(0, y, 960, 13), top.lerp(bottom, t))

static func _draw_nebula(c: CanvasItem, progress: float, time: float) -> void:
	var drift: float = sin(time * 0.035) * 12.0 - progress * 105.0
	var centers: Array[Vector2] = [
		Vector2(600 + drift, 95), Vector2(710 + drift, 165), Vector2(525 + drift, 225),
		Vector2(805 + drift, 300), Vector2(665 + drift, 375), Vector2(865 + drift, 470)
	]
	for j in range(centers.size()):
		var p: Vector2 = centers[j]
		for i in range(7, 0, -1):
			var r: float = 34.0 + float(i) * 24.0
			var a: float = (0.006 + float(8 - i) * 0.004) * (0.85 + 0.15 * sin(time * 0.12 + j))
			var col: Color = Color(0.95, 0.58, 0.10, a) if j % 2 == 0 else Color(0.72, 0.34, 0.08, a * 0.75)
			c.draw_circle(p, r, col)
	for i in range(9):
		var y: float = 80.0 + float(i) * 47.0
		var x1: float = 360.0 + sin(time * 0.025 + i) * 25.0
		c.draw_line(Vector2(x1, y), Vector2(1010, y + 160), Color(1.0, 0.66, 0.18, 0.022), 22.0, true)

static func _draw_stars(c: CanvasItem, progress: float, time: float) -> void:
	for i in range(115):
		var x: float = float((i * 173 + 47) % 950) + 5.0
		var y: float = float((i * 97 + 29) % 1060) + 10.0
		var pulse: float = 0.55 + 0.45 * sin(time * (0.45 + float(i % 5) * 0.09) + float(i) * 1.71)
		var radius: float = 0.55 + float(i % 4) * 0.32
		var alpha: float = 0.14 + pulse * 0.38
		c.draw_circle(Vector2(x, y), radius, Color(1.0, 0.94, 0.72, alpha))
		if i % 19 == 0:
			var flare: float = 5.0 + pulse * 7.0
			c.draw_line(Vector2(x - flare, y), Vector2(x + flare, y), Color(1.0, 0.86, 0.48, 0.14 + pulse * 0.20), 1.0, true)
			c.draw_line(Vector2(x, y - flare), Vector2(x, y + flare), Color(1.0, 0.86, 0.48, 0.14 + pulse * 0.20), 1.0, true)

static func _draw_sun(c: CanvasItem, progress: float, time: float) -> void:
	var arc: float = sin(progress * PI)
	var center: Vector2 = Vector2(900.0 - progress * 205.0, 430.0 - arc * 105.0 + progress * 95.0)
	var pulse: float = 0.90 + 0.10 * sin(time * 1.15)
	for i in range(9, 0, -1):
		c.draw_circle(center, 12.0 + float(i) * 11.0, Color(1.0, 0.72, 0.16, 0.007 * float(i) * pulse))
	for i in range(16):
		var a: float = TAU * float(i) / 16.0
		var length: float = (42.0 if i % 2 == 0 else 24.0) * pulse
		var direction: Vector2 = Vector2(cos(a), sin(a))
		c.draw_line(center + direction * 9.0, center + direction * length, Color(1.0, 0.86, 0.42, 0.22 * pulse), 1.2, true)
	c.draw_circle(center, 9.0 * pulse, Color(1.0, 0.95, 0.72, 0.92))
	c.draw_circle(center, 3.5 * pulse, Color(1.0, 1.0, 0.94, 0.96))

static func _draw_moon(c: CanvasItem, progress: float, time: float) -> void:
	var arc: float = sin(progress * PI)
	var center: Vector2 = Vector2(735.0 - progress * 430.0 + sin(time * 0.035) * 5.0, 245.0 + arc * 105.0 + progress * 55.0)
	var radius: float = 67.0 - progress * 18.0
	for i in range(5, 0, -1):
		c.draw_circle(center, radius + float(i) * 10.0, Color(0.92, 0.62, 0.16, 0.008 * float(i)))
	c.draw_circle(center, radius, Color(0.035, 0.065, 0.105, 0.98))
	c.draw_circle(center + Vector2(-15, 8), radius * 0.74, Color(0.018, 0.030, 0.052, 0.74))
	for i in range(8):
		var a: float = float(i) * 2.21
		var p: Vector2 = center + Vector2(cos(a), sin(a)) * (14.0 + float((i * 13) % 38))
		var r: float = 3.0 + float(i % 3) * 2.0
		c.draw_circle(p, r, Color(0.08, 0.11, 0.15, 0.50))
	c.draw_arc(center, radius, -1.42, 1.72, 64, Color(1.0, 0.82, 0.40, 0.68), 2.2, true)

static func _draw_asteroid_belt(c: CanvasItem, progress: float, time: float) -> void:
	for i in range(62):
		var t: float = float(i) / 61.0
		var x: float = -80.0 + t * 1120.0 + progress * 75.0
		var y: float = 255.0 + t * 360.0 + progress * 120.0 + sin(t * 10.0 + time * 0.045) * (26.0 + progress * 18.0)
		var depth: float = 0.45 + 0.55 * (0.5 + 0.5 * sin(float(i) * 1.91))
		var radius: float = 2.0 + depth * (3.0 + float(i % 7) * 1.45)
		_draw_asteroid(c, Vector2(x, y), radius, float(i) * 0.73 + time * 0.012, depth)
	for i in range(18):
		var t: float = float(i) / 17.0
		var p: Vector2 = Vector2(-90.0 + t * 1130.0 + progress * 75.0, 295.0 + t * 350.0 + progress * 120.0 + sin(float(i) * 2.3) * 58.0)
		_draw_asteroid(c, p, 9.0 + float(i % 5) * 3.5, float(i), 0.78)

static func _draw_asteroid(c: CanvasItem, center: Vector2, radius: float, phase: float, depth: float) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for j in range(8):
		var a: float = TAU * float(j) / 8.0 + phase * 0.08
		var rough: float = 0.76 + 0.22 * sin(float(j) * 3.7 + phase)
		points.append(center + Vector2(cos(a), sin(a)) * radius * rough)
	c.draw_colored_polygon(points, Color(0.035, 0.045, 0.058, 0.78 + depth * 0.18))
	var outline: PackedVector2Array = PackedVector2Array(points)
	outline.append(points[0])
	c.draw_polyline(outline, Color(0.72, 0.50, 0.22, 0.20 + depth * 0.22), 1.0, true)
	c.draw_circle(center - Vector2(radius * 0.22, radius * 0.18), maxf(0.8, radius * 0.16), Color(0.52, 0.39, 0.22, 0.25))

static func _draw_planet(c: CanvasItem, progress: float, time: float) -> void:
	# Chapter 1 is a fly-by: approach the planet, skim its limb, then leave it behind.
	var approach: float = sin(progress * PI)
	var center: Vector2 = Vector2(175.0 - progress * 360.0, 890.0 + progress * 150.0 - approach * 55.0)
	var radius: float = 385.0 + approach * 105.0 - progress * 38.0
	for i in range(12, 0, -1):
		var r: float = radius + float(i) * 12.0
		c.draw_circle(center, r, Color(1.0, 0.68, 0.16, 0.0040 * float(i)))
	c.draw_circle(center, radius, Color(0.035, 0.095, 0.090, 1.0))
	for i in range(8):
		var band_y: float = center.y - radius * 0.58 + float(i) * radius * 0.15
		var half_width: float = sqrt(maxf(0.0, radius * radius - pow(band_y - center.y, 2.0)))
		var shift: float = sin(time * 0.018 + float(i) * 1.4) * 20.0
		c.draw_line(Vector2(center.x - half_width * 0.78 + shift, band_y), Vector2(center.x + half_width * 0.72 + shift, band_y - 12.0), Color(0.64, 0.68, 0.44, 0.060), 18.0, true)
	for i in range(15):
		var a: float = float(i) * 2.37
		var rr: float = radius * (0.20 + float((i * 17) % 65) / 100.0)
		var p: Vector2 = center + Vector2(cos(a) * rr, sin(a) * rr * 0.72)
		c.draw_circle(p, 18.0 + float(i % 4) * 8.0, Color(0.12, 0.25, 0.19, 0.14))
	c.draw_circle(center + Vector2(-radius * 0.48, radius * 0.28), radius * 0.88, Color(0.001, 0.006, 0.014, 0.62))
	c.draw_arc(center, radius, -1.58, 1.05, 128, Color(1.0, 0.88, 0.46, 0.90), 4.0, true)
	c.draw_arc(center, radius + 8.0, -1.64, 1.12, 128, Color(1.0, 0.70, 0.20, 0.34), 10.0, true)
	c.draw_arc(center, radius + 23.0, -1.68, 1.15, 128, Color(0.94, 0.52, 0.12, 0.12), 18.0, true)

static func _draw_dust(c: CanvasItem, progress: float, time: float) -> void:
	for i in range(38):
		var x: float = float((i * 131 + 71) % 940) + 10.0
		var base_y: float = 220.0 + float((i * 67) % 800)
		var drift: float = sin(time * 0.12 + float(i)) * 8.0
		var rise: float = fmod(time * (1.5 + float(i % 4) * 0.35) + float(i) * 29.0, 85.0)
		c.draw_circle(Vector2(x + drift, base_y - rise), 0.6 + float(i % 3) * 0.4, Color(1.0, 0.82, 0.38, 0.07 + float(i % 4) * 0.018))
