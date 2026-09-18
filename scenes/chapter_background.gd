extends Node2D

const PlanetStaticLayer = preload("res://scenes/planet_static_layer.gd")
const PlanetDynamicLayer = preload("res://scenes/planet_dynamic_layer.gd")
const RedPlanetStaticLayer = preload("res://scenes/red_planet_static_layer.gd")
const RedPlanetDynamicLayer = preload("res://scenes/red_planet_dynamic_layer.gd")
const IceGiantStaticLayer = preload("res://scenes/ice_giant_static_layer.gd")
const IceGiantDynamicLayer = preload("res://scenes/ice_giant_dynamic_layer.gd")
const ShatteredWorldStaticLayer = preload("res://scenes/shattered_world_static_layer.gd")
const ShatteredWorldDynamicLayer = preload("res://scenes/shattered_world_dynamic_layer.gd")
const BinaryWorldStaticLayer = preload("res://scenes/binary_world_static_layer.gd")
const BinaryWorldDynamicLayer = preload("res://scenes/binary_world_dynamic_layer.gd")
const StormGiantStaticLayer = preload("res://scenes/storm_giant_static_layer.gd")
const StormGiantDynamicLayer = preload("res://scenes/storm_giant_dynamic_layer.gd")
const VoidRiftStaticLayer = preload("res://scenes/void_rift_static_layer.gd")
const VoidRiftDynamicLayer = preload("res://scenes/void_rift_dynamic_layer.gd")
const PrismRelicStaticLayer = preload("res://scenes/prism_relic_static_layer.gd")
const PrismRelicDynamicLayer = preload("res://scenes/prism_relic_dynamic_layer.gd")

var displayed_level: int = -1
var animation_time: float = 0.0
var planet_static_layer: Node2D
var planet_dynamic_layer: Node2D
var red_planet_static_layer: Node2D
var red_planet_dynamic_layer: Node2D
var ice_giant_static_layer: Node2D
var ice_giant_dynamic_layer: Node2D
var shattered_world_static_layer: Node2D
var shattered_world_dynamic_layer: Node2D
var binary_world_static_layer: Node2D
var binary_world_dynamic_layer: Node2D
var storm_giant_static_layer: Node2D
var storm_giant_dynamic_layer: Node2D
var void_rift_static_layer: Node2D
var void_rift_dynamic_layer: Node2D
var prism_relic_static_layer: Node2D
var prism_relic_dynamic_layer: Node2D
var rock_shapes: Array[PackedVector2Array] = []
var mid_rock_shapes: Array[PackedVector2Array] = []
var ember_points: Array[Vector2] = []
var small_cracks: Array[PackedVector2Array] = []

func _ready():
	_build_environment()
	planet_static_layer = Node2D.new()
	planet_static_layer.set_script(PlanetStaticLayer)
	add_child(planet_static_layer)
	planet_dynamic_layer = Node2D.new()
	planet_dynamic_layer.set_script(PlanetDynamicLayer)
	add_child(planet_dynamic_layer)
	red_planet_static_layer = Node2D.new()
	red_planet_static_layer.set_script(RedPlanetStaticLayer)
	add_child(red_planet_static_layer)
	red_planet_dynamic_layer = Node2D.new()
	red_planet_dynamic_layer.set_script(RedPlanetDynamicLayer)
	add_child(red_planet_dynamic_layer)
	ice_giant_static_layer=Node2D.new()
	ice_giant_static_layer.set_script(IceGiantStaticLayer)
	add_child(ice_giant_static_layer)
	ice_giant_dynamic_layer=Node2D.new()
	ice_giant_dynamic_layer.set_script(IceGiantDynamicLayer)
	add_child(ice_giant_dynamic_layer)
	shattered_world_static_layer=Node2D.new()
	shattered_world_static_layer.set_script(ShatteredWorldStaticLayer)
	add_child(shattered_world_static_layer)
	shattered_world_dynamic_layer=Node2D.new()
	shattered_world_dynamic_layer.set_script(ShatteredWorldDynamicLayer)
	add_child(shattered_world_dynamic_layer)
	binary_world_static_layer=Node2D.new()
	binary_world_static_layer.set_script(BinaryWorldStaticLayer)
	add_child(binary_world_static_layer)
	binary_world_dynamic_layer=Node2D.new()
	binary_world_dynamic_layer.set_script(BinaryWorldDynamicLayer)
	add_child(binary_world_dynamic_layer)
	storm_giant_static_layer=Node2D.new()
	storm_giant_static_layer.set_script(StormGiantStaticLayer)
	add_child(storm_giant_static_layer)
	storm_giant_dynamic_layer=Node2D.new()
	storm_giant_dynamic_layer.set_script(StormGiantDynamicLayer)
	add_child(storm_giant_dynamic_layer)
	void_rift_static_layer=Node2D.new()
	void_rift_static_layer.set_script(VoidRiftStaticLayer)
	add_child(void_rift_static_layer)
	void_rift_dynamic_layer=Node2D.new()
	void_rift_dynamic_layer.set_script(VoidRiftDynamicLayer)
	add_child(void_rift_dynamic_layer)
	prism_relic_static_layer=Node2D.new()
	prism_relic_static_layer.set_script(PrismRelicStaticLayer)
	add_child(prism_relic_static_layer)
	prism_relic_dynamic_layer=Node2D.new()
	prism_relic_dynamic_layer.set_script(PrismRelicDynamicLayer)
	add_child(prism_relic_dynamic_layer)
	call_deferred("_sync_level")
	queue_redraw()

func _process(delta):
	animation_time += delta
	var main = get_parent()
	if main != null:
		var level_value = int(main.get("current_level"))
		if level_value != displayed_level:
			displayed_level = level_value
	if displayed_level > 10:
		queue_redraw()

func _sync_level():
	var main = get_parent()
	if main != null:
		displayed_level = int(main.get("current_level"))
	_update_planet_layers()
	_update_red_planet_layers()
	_update_ice_giant_layers()
	_update_shattered_world_layers()
	_update_binary_world_layers()
	_update_storm_giant_layers()
	_update_void_rift_layers()
	_update_prism_relic_layers()
	queue_redraw()

func _update_planet_layers() -> void:
	if planet_static_layer == null or planet_dynamic_layer == null:
		return
	var active: bool = displayed_level >= 1 and displayed_level <= 10
	planet_static_layer.visible = active
	planet_dynamic_layer.visible = active
	planet_dynamic_layer.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	if active:
		var progress: float = float(clampi(displayed_level, 1, 10) - 1) / 9.0
		planet_static_layer.call("set_progress", progress)
		planet_dynamic_layer.call("set_progress", progress)

func _update_red_planet_layers() -> void:
	if red_planet_static_layer == null or red_planet_dynamic_layer == null:
		return
	var active: bool = displayed_level >= 11 and displayed_level <= 20
	red_planet_static_layer.visible = active
	red_planet_dynamic_layer.visible = active
	red_planet_dynamic_layer.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	if active:
		var progress: float = float(displayed_level - 11) / 9.0
		red_planet_static_layer.call("set_progress", progress)
		red_planet_dynamic_layer.call("set_progress", progress)

func _update_ice_giant_layers() -> void:
	if ice_giant_static_layer == null or ice_giant_dynamic_layer == null:
		return
	var active: bool = displayed_level >= 21 and displayed_level <= 30
	ice_giant_static_layer.visible = active
	ice_giant_dynamic_layer.visible = active
	ice_giant_dynamic_layer.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	if active:
		var progress: float = float(displayed_level - 21) / 9.0
		ice_giant_static_layer.call("set_progress", progress)
		ice_giant_dynamic_layer.call("set_progress", progress)

func _update_shattered_world_layers() -> void:
	if shattered_world_static_layer == null or shattered_world_dynamic_layer == null:
		return
	var active: bool = displayed_level >= 31 and displayed_level <= 40
	shattered_world_static_layer.visible = active
	shattered_world_dynamic_layer.visible = active
	shattered_world_dynamic_layer.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	if active:
		var progress: float = float(displayed_level - 31) / 9.0
		shattered_world_static_layer.call("set_progress", progress)
		shattered_world_dynamic_layer.call("set_progress", progress)

func _update_binary_world_layers() -> void:
	if binary_world_static_layer == null or binary_world_dynamic_layer == null:
		return
	var active: bool = displayed_level >= 41 and displayed_level <= 50
	binary_world_static_layer.visible = active
	binary_world_dynamic_layer.visible = active
	binary_world_dynamic_layer.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	if active:
		var progress: float = float(displayed_level - 41) / 9.0
		binary_world_static_layer.call("set_progress", progress)
		binary_world_dynamic_layer.call("set_progress", progress)

func _update_storm_giant_layers() -> void:
	if storm_giant_static_layer == null or storm_giant_dynamic_layer == null:
		return
	var active: bool = displayed_level >= 51 and displayed_level <= 60
	storm_giant_static_layer.visible = active
	storm_giant_dynamic_layer.visible = active
	storm_giant_dynamic_layer.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	if active:
		var progress: float = float(displayed_level - 51) / 9.0
		storm_giant_static_layer.call("set_progress", progress)
		storm_giant_dynamic_layer.call("set_progress", progress)

func _update_void_rift_layers() -> void:
	if void_rift_static_layer == null or void_rift_dynamic_layer == null:
		return
	var active: bool = displayed_level >= 61 and displayed_level <= 70
	void_rift_static_layer.visible = active
	void_rift_dynamic_layer.visible = active
	void_rift_dynamic_layer.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	if active:
		var progress: float = float(displayed_level - 61) / 9.0
		void_rift_static_layer.call("set_progress", progress)
		void_rift_dynamic_layer.call("set_progress", progress)

func _update_prism_relic_layers() -> void:
	if prism_relic_static_layer == null or prism_relic_dynamic_layer == null:
		return
	var active: bool = displayed_level >= 71 and displayed_level <= 80
	prism_relic_static_layer.visible = active
	prism_relic_dynamic_layer.visible = active
	prism_relic_dynamic_layer.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	if active:
		var progress: float = float(displayed_level - 71) / 9.0
		prism_relic_static_layer.call("set_progress", progress)
		prism_relic_dynamic_layer.call("set_progress", progress)

func _build_environment():
	rock_shapes = [
		PackedVector2Array([Vector2(0,1080),Vector2(0,470),Vector2(42,445),Vector2(78,475),Vector2(104,535),Vector2(145,570),Vector2(126,635),Vector2(171,690),Vector2(145,756),Vector2(190,824),Vector2(168,900),Vector2(220,970),Vector2(205,1080)]),
		PackedVector2Array([Vector2(960,1080),Vector2(960,430),Vector2(920,405),Vector2(884,442),Vector2(858,505),Vector2(817,548),Vector2(836,616),Vector2(795,681),Vector2(820,752),Vector2(778,820),Vector2(801,900),Vector2(748,978),Vector2(760,1080)])
	]
	mid_rock_shapes = [
		PackedVector2Array([Vector2(0,790),Vector2(0,600),Vector2(36,577),Vector2(68,610),Vector2(84,663),Vector2(61,715)]),
		PackedVector2Array([Vector2(960,770),Vector2(960,565),Vector2(925,548),Vector2(895,582),Vector2(881,640),Vector2(905,706)])
	]
	ember_points = [Vector2(104,742),Vector2(151,826),Vector2(222,929),Vector2(303,1015),Vector2(683,934),Vector2(748,828),Vector2(849,716),Vector2(902,594),Vector2(70,633),Vector2(880,894),Vector2(394,1032),Vector2(559,1008)]
	small_cracks = [PackedVector2Array([Vector2(18,584),Vector2(48,610),Vector2(39,649),Vector2(67,678)]),PackedVector2Array([Vector2(944,530),Vector2(918,563),Vector2(927,602),Vector2(899,633)])]

func _draw():
	if displayed_level <= 10:
		pass
	elif displayed_level <= 20:
		pass
	elif displayed_level <= 30:
		pass
	elif displayed_level <= 40:
		pass
	elif displayed_level <= 50:
		pass
	elif displayed_level <= 60:
		pass
	elif displayed_level <= 70:
		pass
	elif displayed_level <= 80:
		pass
	elif displayed_level <= 90:
		var progress = float(displayed_level - 81) / 9.0
		FracturedRealityBackground.draw_background(self, progress, animation_time)
	elif displayed_level <= 100:
		var progress = float(displayed_level - 91) / 9.0
		BlackHoleBackground.draw_background(self, progress, animation_time)
	else:
		var progress = 1.0
		BlackHoleBackground.draw_background(self, progress, animation_time)

	_draw_vignette()

func _draw_core():
	var chapter_level = clamp(displayed_level, 1, 10)
	var progress = float(chapter_level - 1) / 9.0
	_draw_cavern_depth(progress)
	_draw_distant_rock(progress)
	_draw_depth_haze(progress)
	_draw_rock_mass(progress)
	_draw_lava_fissures(progress)
	_draw_rock_texture(progress)
	_draw_embres(progress)

func _draw_surface():
	var chapter_level = clamp(displayed_level, 11, 20)
	var progress = float(chapter_level - 11) / 9.0
	_draw_surface_sky(progress)
	_draw_surface_planet(progress)
	_draw_surface_haze(progress)
	_draw_surface_horizon(progress)
	_draw_surface_cliffs(progress)
	_draw_surface_veins(progress)
	_draw_surface_crystals(progress)
	_draw_surface_fragments(progress)
	_draw_surface_dust(progress)

func _draw_biosphere():
	var chapter_level = clamp(displayed_level, 21, 30)
	var progress = float(chapter_level - 21) / 9.0
	_draw_biosphere_sky(progress)
	_draw_biosphere_moon(progress)
	_draw_biosphere_haze(progress)
	_draw_biosphere_horizon(progress)
	_draw_biosphere_growth(progress)
	_draw_biosphere_spores(progress)

func _draw_upper_atmosphere():
	var chapter_level = clamp(displayed_level, 31, 40)
	var progress = float(chapter_level - 31) / 9.0
	_draw_atmosphere_sky(progress)
	_draw_atmosphere_stars(progress)
	_draw_planet_limb(progress)
	_draw_cloud_bands(progress)
	_draw_atmosphere_satellites(progress)
	_draw_atmosphere_star_flares(progress)
	_draw_atmosphere_meteors(progress)
	_draw_high_particles(progress)

func _draw_atmosphere_sky(progress: float):
	var top = Color(0.008,0.028,0.060).lerp(Color(0.004,0.010,0.028),progress)
	var bottom = Color(0.075,0.22,0.34).lerp(Color(0.025,0.075,0.14),progress)
	for y in range(0,1080,18):
		var t = float(y)/1080.0
		draw_rect(Rect2(0,y,960,18),top.lerp(bottom,pow(t,1.15)))
	var glow_alpha = 0.045*(1.0-progress*0.45)
	for i in range(8):
		var y = 650.0+float(i)*22.0
		draw_line(Vector2(0,y),Vector2(960,y-15.0),Color(0.22,0.60,0.86,glow_alpha*(1.0-float(i)*0.07)),16.0,true)

func _draw_atmosphere_stars(progress: float):
	var count = 18+int(progress*42.0)
	for i in range(count):
		var x = float((i*163+41)%950)+5.0
		var y = 70.0+float((i*91)%610)
		var twinkle = 0.55+0.45*sin(animation_time*(0.7+float(i%4)*0.08)+float(i))
		var alpha = (0.08+progress*0.18)*(0.72+0.28*twinkle)
		draw_circle(Vector2(x,y),0.8+float(i%3)*0.45,Color(0.72,0.88,1.0,alpha))

func _draw_planet_limb(progress: float):
	var center = Vector2(480,1340+progress*110.0)
	var radius = 690.0+progress*95.0
	for i in range(8,0,-1):
		draw_circle(center,radius+float(i)*13.0,Color(0.18,0.55,0.88,0.006*float(i)*(1.0-progress*0.22)))
	draw_circle(center,radius,Color(0.018,0.055,0.082,0.98))
	draw_arc(center,radius,-2.82,-0.32,96,Color(0.38,0.76,1.0,0.55-progress*0.12),3.0,true)
	draw_arc(center,radius-8.0,-2.82,-0.32,96,Color(0.58,0.90,1.0,0.18-progress*0.04),1.2,true)
	for i in range(5):
		var y = 880.0+float(i)*34.0+progress*20.0
		var alpha = (0.045-float(i)*0.006)*(1.0-progress*0.35)
		draw_line(Vector2(90,y),Vector2(870,y-28.0),Color(0.46,0.78,0.92,alpha),9.0,true)

func _draw_cloud_bands(progress: float):
	var remaining = 1.0-progress
	var count = 6-int(progress*3.0)
	for i in range(max(count,2)):
		var phase = animation_time*(0.025+float(i)*0.004)+float(i)*1.8
		var y = 720.0+float(i)*58.0+sin(phase)*7.0+progress*90.0
		var shift = sin(phase*0.7)*34.0
		var alpha = (0.035+float(i%2)*0.015)*remaining
		draw_line(Vector2(-70+shift,y),Vector2(1030+shift,y-35.0),Color(0.72,0.88,0.94,alpha),20.0,true)
		draw_line(Vector2(80+shift,y+24.0),Vector2(760+shift,y+4.0),Color(0.56,0.78,0.90,alpha*0.55),8.0,true)

func _draw_atmosphere_satellites(progress: float):
	var visible = int(progress*3.6)
	var satellites = [Vector2(805,330),Vector2(150,470),Vector2(710,575)]
	for i in range(min(visible,satellites.size())):
		var base = satellites[i]
		var drift = Vector2(sin(animation_time*0.08+i)*8.0,cos(animation_time*0.06+i)*5.0)
		var p = base+drift
		var s = 0.75+float(i)*0.12
		draw_rect(Rect2(p-Vector2(12,5)*s,Vector2(24,10)*s),Color(0.18,0.24,0.30,0.68))
		draw_line(p+Vector2(-13,0)*s,p+Vector2(-30,0)*s,Color(0.34,0.49,0.58,0.48),1.5,true)
		draw_line(p+Vector2(13,0)*s,p+Vector2(30,0)*s,Color(0.34,0.49,0.58,0.48),1.5,true)
		draw_rect(Rect2(p+Vector2(-38,-8)*s,Vector2(12,16)*s),Color(0.09,0.28,0.43,0.48))
		draw_rect(Rect2(p+Vector2(26,-8)*s,Vector2(12,16)*s),Color(0.09,0.28,0.43,0.48))
		draw_circle(p,2.0*s,Color(0.50,0.82,1.0,0.50))

func _draw_atmosphere_star_flares(progress: float):
	var flare_count = 3 + int(progress * 5.0)

	for i in range(flare_count):
		var x = 80.0 + float((i * 193 + 71) % 800)
		var y = 120.0 + float((i * 127 + 43) % 470)

		var phase = animation_time * (0.75 + float(i % 3) * 0.18) + float(i) * 2.1
		var brightness = pow(max(0.0, sin(phase)), 8.0)

		if brightness < 0.04:
			continue

		var alpha = brightness * (0.16 + progress * 0.22)
		var radius = 1.2 + brightness * 1.8

		draw_circle(Vector2(x, y), radius + 5.0, Color(0.45, 0.72, 1.0, alpha * 0.08))
		draw_circle(Vector2(x, y), radius, Color(0.82, 0.94, 1.0, alpha))
		draw_line(
			Vector2(x - 8.0 * brightness, y),
			Vector2(x + 8.0 * brightness, y),
			Color(0.72, 0.90, 1.0, alpha * 0.55),
			1.0,
			true
		)
		draw_line(
			Vector2(x, y - 8.0 * brightness),
			Vector2(x, y + 8.0 * brightness),
			Color(0.72, 0.90, 1.0, alpha * 0.55),
			1.0,
			true
		)

func _draw_atmosphere_meteors(progress: float):
	var meteor_count = 1 + int(progress * 2.0)

	for i in range(meteor_count):
		var cycle_length = 8.0 + float(i) * 3.5
		var local_time = fmod(animation_time + float(i) * 4.7, cycle_length)

		var active_time = 0.75 + progress * 0.20
		if local_time > active_time:
			continue

		var t = local_time / active_time

		var start_x = 1050.0 - float(i) * 210.0
		var start_y = 180.0 + float(i) * 145.0
		var end_x = 610.0 - float(i) * 150.0
		var end_y = 430.0 + float(i) * 125.0

		var head = Vector2(
			lerp(start_x, end_x, t),
			lerp(start_y, end_y, t)
		)

		var direction = Vector2(end_x - start_x, end_y - start_y).normalized()
		var tail_length = 55.0 + progress * 30.0
		var tail = head - direction * tail_length

		var fade = sin(t * PI)
		var alpha = fade * (0.20 + progress * 0.16)

		draw_line(
			tail,
			head,
			Color(0.42, 0.68, 1.0, alpha * 0.32),
			4.0,
			true
		)
		draw_line(
			tail + direction * 18.0,
			head,
			Color(0.78, 0.90, 1.0, alpha),
			1.4,
			true
		)
		draw_circle(
			head,
			2.0,
			Color(0.92, 0.97, 1.0, alpha)
		)

func _draw_high_particles(progress: float):
	var count = 10+int(progress*14.0)
	for i in range(count):
		var x = 30.0+float((i*139+29)%900)
		var base_y = 520.0+float((i*83)%470)
		var rise = fmod(animation_time*(2.0+float(i%3))+float(i)*43.0,130.0)
		var drift = sin(animation_time*0.18+i*1.3)*(5.0+progress*5.0)
		draw_circle(Vector2(x+drift,base_y-rise),0.8+float(i%2)*0.45,Color(0.55,0.82,1.0,0.045+progress*0.045))

func _draw_biosphere_sky(progress: float):
	var top = Color(0.008,0.035,0.050).lerp(Color(0.012,0.060,0.075),progress)
	var bottom = Color(0.025,0.105,0.095).lerp(Color(0.035,0.145,0.105),progress)
	for y in range(0,1080,18):
		var t = float(y)/1080.0
		draw_rect(Rect2(0,y,960,18),top.lerp(bottom,pow(t,0.85)))
	for i in range(26):
		var x = float((i*149+37)%930)+15.0
		var y = 80.0+float((i*97)%430)
		var alpha = 0.08+0.08*(0.5+0.5*sin(animation_time*0.55+i))
		draw_circle(Vector2(x,y),1.0+float(i%2)*0.5,Color(0.55,0.88,0.82,alpha))

func _draw_biosphere_moon(progress: float):
	var center = Vector2(770,225)
	var radius = 68.0+progress*12.0
	draw_circle(center,radius+24.0,Color(0.18,0.72,0.64,0.018))
	draw_circle(center,radius,Color(0.035,0.105,0.11,0.72))
	draw_circle(center+Vector2(-18,-12),radius*0.68,Color(0.08,0.19,0.16,0.24))
	draw_arc(center,radius,-2.4,0.7,48,Color(0.38,0.78,0.70,0.25+progress*0.10),1.6,true)

func _draw_biosphere_haze(progress: float):
	var pulse = 0.85+0.15*sin(animation_time*0.18)
	for i in range(6):
		var y = 500.0+float(i)*24.0
		draw_line(Vector2(0,y),Vector2(960,y-12),Color(0.16,0.62,0.48,(0.018+progress*0.025)*pulse),14.0,true)

func _draw_biosphere_horizon(progress: float):
	var far = PackedVector2Array([Vector2(0,650),Vector2(95,610),Vector2(180,625),Vector2(270,575),Vector2(355,610),Vector2(455,560),Vector2(550,605),Vector2(650,570),Vector2(745,615),Vector2(850,565),Vector2(960,600),Vector2(960,1080),Vector2(0,1080)])
	draw_colored_polygon(far,Color(0.018,0.075+progress*0.018,0.068,0.96))
	var ridge = PackedVector2Array([Vector2(0,650),Vector2(95,610),Vector2(180,625),Vector2(270,575),Vector2(355,610),Vector2(455,560),Vector2(550,605),Vector2(650,570),Vector2(745,615),Vector2(850,565),Vector2(960,600)])
	draw_polyline(ridge,Color(0.18,0.50,0.39,0.22+progress*0.12),2.0,true)
	for i in range(5):
		var y = 675.0+float(i)*35.0
		draw_line(Vector2(0,y),Vector2(960,y-20),Color(0.08,0.23,0.18,0.10),1.0,true)

func _draw_biosphere_growth(progress: float):
	var count = 7+int(progress*9.0)
	for i in range(count):
		var side = -1.0 if i%2==0 else 1.0
		var base_x = 45.0+float((i*73)%145) if side<0 else 915.0-float((i*61)%145)
		var base_y = 760.0+float((i*67)%300)
		var h = 38.0+float(i%5)*14.0+progress*18.0
		var sway = sin(animation_time*0.35+i)*3.0
		var stem_top = Vector2(base_x+sway,base_y-h)
		draw_line(Vector2(base_x,base_y),stem_top,Color(0.12,0.38,0.27,0.24+progress*0.10),2.0,true)
		var leaf_size = 8.0+float(i%3)*3.0
		var leaf = PackedVector2Array([stem_top+Vector2(0,-leaf_size),stem_top+Vector2(leaf_size*0.7,0),stem_top+Vector2(0,leaf_size*0.45),stem_top+Vector2(-leaf_size*0.7,0)])
		draw_colored_polygon(leaf,Color(0.08,0.31,0.23,0.30+progress*0.12))
		draw_polyline(PackedVector2Array([leaf[0],leaf[1],leaf[2],leaf[3],leaf[0]]),Color(0.28,0.65,0.48,0.18+progress*0.10),1.0,true)
	for i in range(4+int(progress*4.0)):
		var p = Vector2(95.0+float((i*211)%760),930.0+float((i*43)%120))
		var r = 10.0+float(i%3)*5.0
		draw_circle(p,r,Color(0.06,0.26,0.20,0.18+progress*0.08))
		draw_circle(p,r*0.45,Color(0.22,0.62,0.42,0.08+progress*0.05))

func _draw_biosphere_spores(progress: float):
	var count = 16+int(progress*24.0)
	for i in range(count):
		var x = 25.0+float((i*127+53)%910)
		var base_y = 610.0+float((i*73)%450)
		var rise = fmod(animation_time*(4.0+float(i%4)*1.4)+float(i)*31.0,150.0)
		var drift = sin(animation_time*0.28+i*1.4)*(7.0+progress*4.0)
		var alpha = 0.055+progress*0.065
		draw_circle(Vector2(x+drift,base_y-rise),1.0+float(i%3)*0.45,Color(0.38,0.82,0.57,alpha))

func _draw_surface_sky(progress: float):
	var top = Color(0.012,0.027,0.042).lerp(Color(0.020,0.085,0.13), progress)
	var bottom = Color(0.038,0.065,0.075).lerp(Color(0.075,0.19,0.20), progress)
	for y in range(0,1080,18):
		var t = float(y) / 1080.0
		draw_rect(Rect2(0,y,960,18), top.lerp(bottom,pow(t,0.9)))
	var star_count = 42 - int(progress * 24.0)
	for i in range(star_count):
		var x = float((i*137+61)%960)
		var y = 80.0 + float((i*83)%430)
		var twinkle = 0.12 + 0.13 * (0.5 + 0.5 * sin(animation_time*0.7+i))
		draw_circle(Vector2(x,y),1.0+float(i%3)*0.35,Color(0.68,0.88,1.0,twinkle*(1.0-progress*0.35)))

func _draw_surface_planet(progress: float):
	if progress < 0.18:
		return
	var appear = clamp((progress - 0.18) / 0.82, 0.0, 1.0)
	var center = Vector2(755.0 + sin(animation_time*0.05)*5.0, 205.0)
	var radius = 58.0 + appear*34.0
	for i in range(5,0,-1):
		draw_circle(center,radius+float(i)*14.0,Color(0.12,0.42,0.58,0.010*appear*float(i)))
	draw_circle(center,radius,Color(0.07,0.13,0.16,0.88*appear))
	draw_circle(center+Vector2(-radius*0.26,-radius*0.18),radius*0.72,Color(0.13,0.25,0.27,0.32*appear))
	draw_arc(center,radius,-2.3,0.8,48,Color(0.45,0.86,0.92,0.44*appear),2.0,true)

func _draw_surface_haze(progress: float):
	var pulse = 0.88 + 0.12*sin(animation_time*0.22)
	var alpha = (0.018 + progress*0.045)*pulse
	for i in range(7):
		var y = 470.0 + float(i)*18.0
		draw_line(Vector2(0,y),Vector2(960,y-8.0),Color(0.20,0.62,0.66,alpha*(1.0-float(i)*0.08)),10.0,true)

func _draw_surface_horizon(progress: float):
	var distant = PackedVector2Array([Vector2(0,610),Vector2(90,570),Vector2(165,590),Vector2(250,530),Vector2(340,575),Vector2(430,545),Vector2(520,585),Vector2(610,520),Vector2(700,565),Vector2(805,505),Vector2(960,555),Vector2(960,1080),Vector2(0,1080)])
	draw_colored_polygon(distant,Color(0.027,0.057+progress*0.02,0.067+progress*0.03,0.94))
	var rim = PackedVector2Array([Vector2(0,610),Vector2(90,570),Vector2(165,590),Vector2(250,530),Vector2(340,575),Vector2(430,545),Vector2(520,585),Vector2(610,520),Vector2(700,565),Vector2(805,505),Vector2(960,555)])
	draw_polyline(rim,Color(0.20,0.62,0.65,0.34+progress*0.25),2.4,true)
	for i in range(4):
		var offset = float(i)*22.0
		draw_polyline(PackedVector2Array([Vector2(0,635+offset),Vector2(190,600+offset),Vector2(390,620+offset),Vector2(600,590+offset),Vector2(780,610+offset),Vector2(960,580+offset)]),Color(0.12,0.27,0.29,0.08+progress*0.035),1.0,true)

func _draw_surface_cliffs(progress: float):
	var left = PackedVector2Array([Vector2(0,1080),Vector2(0,650),Vector2(55,620),Vector2(105,665),Vector2(145,740),Vector2(122,815),Vector2(185,900),Vector2(220,1080)])
	var right = PackedVector2Array([Vector2(960,1080),Vector2(960,620),Vector2(900,595),Vector2(850,650),Vector2(820,730),Vector2(842,805),Vector2(780,900),Vector2(742,1080)])
	for cliff in [left,right]:
		draw_colored_polygon(cliff,Color(0.035,0.050,0.052,0.98))
		var outline = PackedVector2Array(cliff)
		outline.append(cliff[0])
		draw_polyline(outline,Color(0.18,0.42,0.43,0.30+progress*0.12),2.0,true)
	for i in range(9):
		var y = 675.0 + i*43.0
		draw_line(Vector2(18,y),Vector2(92+i*5,y-18),Color(0.17,0.28,0.28,0.22),1.0,true)
		draw_line(Vector2(942,y-25),Vector2(868-i*4,y),Color(0.17,0.28,0.28,0.22),1.0,true)

func _draw_surface_veins(progress: float):
	var visible = 2 + int(progress*6.0)
	var pulse = 0.72 + 0.28*sin(animation_time*0.65)
	var veins = [PackedVector2Array([Vector2(40,1045),Vector2(66,990),Vector2(58,930),Vector2(88,875)]),PackedVector2Array([Vector2(150,1070),Vector2(135,1018),Vector2(160,962),Vector2(145,905)]),PackedVector2Array([Vector2(918,1040),Vector2(892,986),Vector2(902,932),Vector2(875,880)]),PackedVector2Array([Vector2(805,1060),Vector2(824,1010),Vector2(810,955),Vector2(835,902)]),PackedVector2Array([Vector2(290,1065),Vector2(315,1030),Vector2(306,990)]),PackedVector2Array([Vector2(670,1068),Vector2(645,1032),Vector2(655,990)]),PackedVector2Array([Vector2(105,800),Vector2(125,770),Vector2(118,735)]),PackedVector2Array([Vector2(855,810),Vector2(840,775),Vector2(848,740)])]
	for i in range(min(visible,veins.size())):
		draw_polyline(veins[i],Color(0.10,0.45,0.48,0.18+progress*0.15),4.0,true)
		draw_polyline(veins[i],Color(0.36,0.92,0.90,(0.18+progress*0.28)*pulse),1.2,true)

func _draw_surface_crystals(progress: float):
	var pulse = 0.82 + 0.18*sin(animation_time*0.8)
	var positions = [Vector2(72,850),Vector2(135,930),Vector2(825,875),Vector2(900,790),Vector2(270,1025),Vector2(690,1015),Vector2(185,990),Vector2(770,970),Vector2(105,760),Vector2(865,720)]
	var visible_count = 3 + int(progress*7.0)
	for i in range(min(visible_count,positions.size())):
		var p = positions[i]
		var h = 30.0 + float((i*17)%42) + progress*10.0
		var w = 8.0 + float(i%3)*3.0
		var crystal = PackedVector2Array([p+Vector2(-w,0),p+Vector2(-w*0.55,-h*0.65),p+Vector2(0,-h),p+Vector2(w*0.55,-h*0.65),p+Vector2(w,0)])
		draw_colored_polygon(crystal,Color(0.055,0.19+progress*0.06,0.22+progress*0.08,0.46))
		draw_polyline(PackedVector2Array([crystal[0],crystal[1],crystal[2],crystal[3],crystal[4]]),Color(0.24,0.52,0.56,(0.24+progress*0.10)*pulse),1.2,true)
		draw_line(p+Vector2(0,-h+4),p+Vector2(0,-5),Color(0.44,0.70,0.72,(0.09+progress*0.06)*pulse),1.0,true)

func _draw_surface_fragments(progress: float):
	var count = 4 + int(progress*7.0)
	for i in range(count):
		var base = Vector2(80.0+float((i*139)%800),650.0+float((i*91)%380))
		var bob = sin(animation_time*(0.20+float(i%3)*0.05)+i)*2.5
		var p = base+Vector2(0,bob)
		var r = 4.0+float(i%4)*2.0
		var shard = PackedVector2Array([p+Vector2(-r,2),p+Vector2(-r*0.3,-r),p+Vector2(r,0),p+Vector2(0,r*0.8)])
		draw_colored_polygon(shard,Color(0.08,0.12,0.13,0.55))
		draw_polyline(PackedVector2Array([shard[0],shard[1],shard[2],shard[3],shard[0]]),Color(0.20,0.48,0.50,0.16+progress*0.08),1.0,true)

func _draw_surface_dust(progress: float):
	var count = 14+int(progress*20.0)
	for i in range(count):
		var x = float((i*113+47)%900)+30.0
		var base_y = 540.0+float((i*71)%500)
		var rise = fmod(animation_time*(3.0+float(i%4))+i*29.0,110.0)
		var drift = sin(animation_time*0.35+i*1.7)*(5.0+progress*4.0)
		draw_circle(Vector2(x+drift,base_y-rise),1.0+float(i%3)*0.45,Color(0.40,0.86,0.82,0.07+progress*0.10))

func _draw_cavern_depth(progress: float):
	var top_color = Color(0.010,0.012,0.016).lerp(Color(0.026,0.015,0.014),progress)
	var bottom_color = Color(0.020,0.012,0.014).lerp(Color(0.075,0.023,0.012),progress)
	for y in range(0,1080,18):
		var t = float(y)/1080.0
		draw_rect(Rect2(0,y,960,18),top_color.lerp(bottom_color,pow(t,1.55)))

func _draw_distant_rock(progress: float):
	for shape in mid_rock_shapes:
		draw_colored_polygon(shape,Color(0.025,0.025,0.028,0.86))

func _draw_depth_haze(progress: float):
	var pulse = 0.5+0.5*sin(animation_time*0.42)
	for radius in range(520,80,-44):
		var depth = 1.0-float(radius)/560.0
		draw_circle(Vector2(480,965),radius,Color(0.72,0.11,0.018,(0.004+progress*0.009)*depth*(0.82+pulse*0.3)))

func _draw_rock_mass(progress: float):
	for shape in rock_shapes:
		draw_colored_polygon(shape,Color(0.035+progress*0.01,0.032,0.031,1.0))

func _draw_lava_fissures(progress: float):
	var pulse = 0.82+0.18*sin(animation_time*1.15)
	var cracks = [PackedVector2Array([Vector2(35,1075),Vector2(68,1018),Vector2(57,960),Vector2(91,914),Vector2(78,858),Vector2(112,811),Vector2(102,756),Vector2(132,711)]),PackedVector2Array([Vector2(925,1070),Vector2(892,1014),Vector2(903,955),Vector2(870,909),Vector2(882,852),Vector2(849,804),Vector2(860,748),Vector2(830,703)])]
	for crack in cracks:
		draw_polyline(crack,Color(0.45,0.06,0.01,0.45),8.0,true)
		draw_polyline(crack,Color(1.0,0.30,0.03,0.75*pulse),2.8,true)

func _draw_rock_texture(progress: float):
	for i in range(8):
		var x = 35.0+float((i*117)%870)
		var y = 650.0+float((i*83)%390)
		draw_line(Vector2(x,y),Vector2(x+35,y-20),Color(0.25,0.12,0.07,0.10),1.0,true)

func _draw_embres(progress: float):
	var visible_count = 6+int(progress*6.0)
	for i in range(visible_count):
		var p = ember_points[i]
		var travel = fmod(animation_time*(7.0+float(i%5)*2.4)+float(i)*37.0,190.0)
		draw_circle(Vector2(p.x+sin(animation_time*0.6+i)*4.0,p.y-travel),1.2,Color(1.0,0.36,0.045,0.22+progress*0.25))

func _draw_vignette():
	for i in range(12):
		var inset = float(i)*9.0
		draw_rect(Rect2(inset,inset,960.0-inset*2.0,1080.0-inset*2.0),Color(0,0,0,0.014+float(i)*0.004),false,18.0)
