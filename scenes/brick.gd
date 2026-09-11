extends StaticBody2D

signal destroyed(points: int, brick_position: Vector2, guaranteed_bonus: bool, powerful_bonus: bool)
signal exploded(brick_position: Vector2)

@export var width: float = 70.0
@export var height: float = 30.0
@export var health: int = 1
@export var max_health: int = 1
@export var points: int = 100
@export var indestructible: bool = false

var guaranteed_bonus: bool = false
var powerful_bonus: bool = false
var is_destroyed: bool = false

const MIN_BONUS_BRICKS_PER_LEVEL: int = 2
const MAX_BONUS_BRICKS_PER_LEVEL: int = 4
const POWERFUL_BRICK_CHANCE: float = 0.50
const BONUS_ASSIGNMENT_META: StringName = &"bonus_assignment_scheduled"
const BARRIER_HITS_TO_DESTROY: int = 5

const GLASS_PALETTE: Array[Color] = [
	Color(0.18, 0.72, 1.0),
	Color(0.34, 0.42, 1.0),
	Color(0.72, 0.28, 1.0),
	Color(1.0, 0.24, 0.68),
	Color(1.0, 0.48, 0.18),
	Color(0.96, 0.72, 0.18),
	Color(0.24, 0.88, 0.58),
	Color(0.12, 0.82, 0.86)
]

var glass_color: Color
var barrier_hits: int = 0
var barrier_blink_timer: float = 0.0
var barrier_flash: bool = false

func _ready():
	glass_color = GLASS_PALETTE.pick_random()
	queue_redraw()

	var bricks_parent = get_parent()
	if not bricks_parent.has_meta(BONUS_ASSIGNMENT_META):
		bricks_parent.set_meta(BONUS_ASSIGNMENT_META, true)
		call_deferred("_assign_bonus_bricks")

func _process(delta):
	if not indestructible or barrier_hits <= 0 or is_destroyed:
		return

	barrier_blink_timer -= delta
	if barrier_blink_timer > 0.0:
		return

	barrier_flash = not barrier_flash
	if barrier_flash:
		barrier_blink_timer = 0.08
	else:
		barrier_blink_timer = get_barrier_blink_interval()
	queue_redraw()

func get_barrier_blink_interval() -> float:
	match barrier_hits:
		1:
			return 0.90
		2:
			return 0.60
		3:
			return 0.35
		4:
			return 0.18
	return 0.18

func _assign_bonus_bricks():
	var bricks_parent = get_parent()
	if not is_instance_valid(bricks_parent):
		return

	var candidates: Array = []
	for brick in bricks_parent.get_children():
		if not is_instance_valid(brick):
			continue
		if brick.indestructible:
			continue
		brick.guaranteed_bonus = false
		brick.powerful_bonus = false
		candidates.append(brick)

	candidates.shuffle()
	var bonus_count = min(randi_range(MIN_BONUS_BRICKS_PER_LEVEL, MAX_BONUS_BRICKS_PER_LEVEL), candidates.size())
	for index in range(bonus_count):
		candidates[index].guaranteed_bonus = true

	var main = bricks_parent.get_parent()
	var pressure_tier: int = 0
	if main.has_method("get_pressure_tier"):
		pressure_tier = main.get_pressure_tier()

	var powerful_count: int = 0
	if pressure_tier >= 2:
		powerful_count = min(2, bonus_count)
	elif pressure_tier == 1:
		powerful_count = min(1, bonus_count)
	elif bonus_count > 0 and randf() < POWERFUL_BRICK_CHANCE:
		powerful_count = 1

	for index in range(powerful_count):
		candidates[index].powerful_bonus = true

	for brick in candidates:
		brick.queue_redraw()
	bricks_parent.remove_meta(BONUS_ASSIGNMENT_META)

func _draw():
	var rect = Rect2(Vector2(-width * 0.5, -height * 0.5), Vector2(width, height))

	if indestructible:
		_draw_obsidian_barrier(rect)
		return

	var density := 1
	if max_health >= 3:
		density = 3
	elif max_health == 2:
		density = 2

	_draw_glass_brick(rect, density)

	if guaranteed_bonus:
		_draw_bonus_marker(powerful_bonus)

	var damage = max_health - health
	if damage >= 1:
		_draw_crack_set_one(glass_color)
	if damage >= 2:
		_draw_crack_set_two(glass_color)

func _rounded_box(rect: Rect2, fill: Color, border: Color, border_width: float, radius: int):
	var box = StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(int(border_width))
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	draw_style_box(box, rect)

func _draw_glass_brick(rect: Rect2, density: int):
	var fill_alpha = 0.075
	var edge_alpha = 0.72
	var inner_alpha = 0.10

	if density == 2:
		fill_alpha = 0.20
		edge_alpha = 0.86
		inner_alpha = 0.18
	elif density >= 3:
		fill_alpha = 0.42
		edge_alpha = 0.96
		inner_alpha = 0.30

	var dark_base = Color(glass_color.r * 0.22, glass_color.g * 0.22, glass_color.b * 0.27, fill_alpha)
	if density >= 3:
		dark_base = Color(glass_color.r * 0.10, glass_color.g * 0.10, glass_color.b * 0.14, fill_alpha + 0.18)

	_rounded_box(rect.grow(2.5), Color(0, 0, 0, 0), Color(glass_color, 0.08 + 0.035 * density), 2.0, 8)
	_rounded_box(rect, dark_base, Color(glass_color, edge_alpha), 1.0 + density * 0.35, 7)
	_rounded_box(rect.grow(-2.0), Color(glass_color, inner_alpha * 0.34), Color(1.0, 1.0, 1.0, 0.16 + density * 0.035), 1.0, 5)

	var hw = width * 0.5
	var hh = height * 0.5
	draw_line(Vector2(-hw + 8.0, -hh + 3.5), Vector2(hw - 8.0, -hh + 3.5), Color(0.92, 0.98, 1.0, 0.34 + density * 0.08), 1.0, true)
	draw_line(Vector2(-hw + 10.0, hh - 4.0), Vector2(hw - 10.0, hh - 4.0), Color(glass_color, 0.18 + density * 0.08), 1.0, true)

	if density >= 2:
		draw_line(Vector2(-hw + 11.0, -4.0), Vector2(-5.0, 5.0), Color(glass_color, 0.12), 1.0, true)
		draw_line(Vector2(8.0, -5.0), Vector2(hw - 13.0, 3.0), Color(1.0, 1.0, 1.0, 0.08), 1.0, true)

	if density >= 3:
		_rounded_box(rect.grow(-6.0), Color(0.005, 0.008, 0.018, 0.30), Color(glass_color, 0.18), 1.0, 3)
		draw_circle(Vector2.ZERO, 2.0, Color(glass_color, 0.32))

func _draw_bonus_marker(powerful: bool):
	var marker = Color(1.0, 0.22, 0.07) if powerful else Color(1.0, 0.72, 0.12)
	var core = PackedVector2Array([
		Vector2(0.0, -7.0),
		Vector2(6.0, 0.0),
		Vector2(0.0, 7.0),
		Vector2(-6.0, 0.0)
	])
	draw_colored_polygon(core, Color(marker, 0.24))
	draw_polyline(PackedVector2Array([core[0], core[1], core[2], core[3], core[0]]), Color(marker, 0.96), 1.4, true)
	draw_circle(Vector2.ZERO, 1.8, Color(1.0, 0.94, 0.72) if not powerful else Color(1.0, 0.72, 0.42))

func _draw_crack_set_one(energy_color: Color):
	var crack_color = Color(0.90, 0.96, 1.0, 0.78)
	draw_polyline(PackedVector2Array([
		Vector2(-6.0, -14.0), Vector2(-3.0, -7.0), Vector2(-7.0, -2.0),
		Vector2(-2.0, 3.0), Vector2(-5.0, 10.0), Vector2(-2.0, 14.0)
	]), crack_color, 1.0, true)
	draw_line(Vector2(-3.0, -7.0), Vector2(5.0, -10.0), crack_color, 0.8, true)
	draw_line(Vector2(-7.0, -2.0), Vector2(-14.0, 2.0), crack_color, 0.8, true)
	draw_circle(Vector2(-2.0, 3.0), 1.2, Color(energy_color, 0.65))

func _draw_crack_set_two(energy_color: Color):
	var crack_color = Color(0.94, 0.98, 1.0, 0.88)
	draw_polyline(PackedVector2Array([
		Vector2(18.0, -14.0), Vector2(13.0, -7.0), Vector2(17.0, -1.0),
		Vector2(10.0, 5.0), Vector2(14.0, 14.0)
	]), crack_color, 1.0, true)
	draw_line(Vector2(13.0, -7.0), Vector2(5.0, -4.0), crack_color, 0.8, true)
	draw_line(Vector2(17.0, -1.0), Vector2(25.0, 3.0), crack_color, 0.8, true)
	draw_line(Vector2(10.0, 5.0), Vector2(3.0, 10.0), crack_color, 0.8, true)
	draw_circle(Vector2(10.0, 5.0), 1.2, Color(energy_color, 0.72))

func _draw_obsidian_barrier(rect: Rect2):
	var flash_strength = 1.0 if barrier_flash else 0.0
	var edge = Color(0.34, 0.10, 0.055).lerp(Color(1.0, 0.42, 0.10), flash_strength)
	_rounded_box(rect.grow(2.0), Color(0, 0, 0, 0), Color(1.0, 0.20, 0.04, 0.10 + flash_strength * 0.18), 2.0, 8)
	_rounded_box(rect, Color(0.012, 0.009, 0.014, 0.98), edge, 1.4, 7)
	_rounded_box(rect.grow(-3.0), Color(0.025, 0.018, 0.026, 0.98), Color(0.18, 0.08, 0.06, 0.80), 1.0, 5)

	var lava = Color(1.0, 0.24, 0.025, 0.88 + flash_strength * 0.12)
	var hot = Color(1.0, 0.72, 0.12, 0.94)
	var crack_sets = min(4, barrier_hits + 1)

	if crack_sets >= 1:
		_draw_lava_crack(PackedVector2Array([Vector2(-31,-8), Vector2(-20,-5), Vector2(-14,1), Vector2(-5,-2), Vector2(1,4)]), lava, hot)
	if crack_sets >= 2:
		_draw_lava_crack(PackedVector2Array([Vector2(31,-9), Vector2(21,-5), Vector2(16,2), Vector2(8,5), Vector2(1,4)]), lava, hot)
	if crack_sets >= 3:
		_draw_lava_crack(PackedVector2Array([Vector2(-24,12), Vector2(-17,6), Vector2(-8,8), Vector2(1,4), Vector2(6,-4)]), lava, hot)
	if crack_sets >= 4:
		_draw_lava_crack(PackedVector2Array([Vector2(27,12), Vector2(19,7), Vector2(12,9), Vector2(6,3), Vector2(9,-7)]), lava, hot)

	draw_circle(Vector2(1.0, 4.0), 2.4 + flash_strength, Color(hot, 0.82))

func _draw_lava_crack(points_array: PackedVector2Array, lava: Color, hot: Color):
	draw_polyline(points_array, Color(lava, 0.26), 3.2, true)
	draw_polyline(points_array, lava, 1.5, true)
	draw_polyline(points_array, Color(hot, 0.80), 0.55, true)

func prepare_bonus_drop():
	if powerful_bonus:
		Bonus.next_drop_pool = Bonus.DropPool.POWERFUL
	elif guaranteed_bonus:
		Bonus.next_drop_pool = Bonus.DropPool.UTILITY
	else:
		Bonus.next_drop_pool = Bonus.DropPool.ANY

func hit(explosive_hit: bool = false):
	if is_destroyed:
		return

	if indestructible:
		if explosive_hit:
			destroy_barrier(true)
			return

		barrier_hits += 1
		if barrier_hits >= BARRIER_HITS_TO_DESTROY:
			destroy_barrier()
			return

		barrier_flash = true
		barrier_blink_timer = 0.08
		queue_redraw()
		return

	health -= 1
	if health <= 0:
		is_destroyed = true
		prepare_bonus_drop()
		destroyed.emit(points, global_position, guaranteed_bonus, powerful_bonus)
		if explosive_hit:
			exploded.emit(global_position)
		queue_free()
	else:
		queue_redraw()

func destroy(explosive_hit: bool = false):
	if is_destroyed:
		return
	if indestructible:
		destroy_barrier(explosive_hit)
		return

	is_destroyed = true
	prepare_bonus_drop()
	destroyed.emit(points, global_position, guaranteed_bonus, powerful_bonus)
	if explosive_hit:
		exploded.emit(global_position)
	queue_free()

func destroy_barrier(trigger_explosion: bool = false):
	if is_destroyed:
		return
	is_destroyed = true
	if trigger_explosion:
		exploded.emit(global_position)
	queue_free()

func hit_by_explosion():
	if is_destroyed:
		return
	if indestructible:
		destroy_barrier()
	else:
		hit(false)
