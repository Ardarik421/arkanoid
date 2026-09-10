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

const MIN_BONUS_BRICKS_PER_LEVEL: int = 2
const MAX_BONUS_BRICKS_PER_LEVEL: int = 4
const POWERFUL_BRICK_CHANCE: float = 0.50
const BONUS_ASSIGNMENT_META: StringName = &"bonus_assignment_scheduled"

var is_destroyed: bool = false

const BARRIER_HITS_TO_DESTROY: int = 5

var barrier_hits: int = 0
var barrier_blink_timer: float = 0.0
var barrier_flash: bool = false

func _ready():
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

	var bonus_count = min(
		randi_range(MIN_BONUS_BRICKS_PER_LEVEL, MAX_BONUS_BRICKS_PER_LEVEL),
		candidates.size()
	)

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
	var half_width = width / 2.0
	var half_height = height / 2.0
	var outer_rect = Rect2(Vector2(-half_width, -half_height), Vector2(width, height))
	var inner_rect = outer_rect.grow(-2.0)

	if indestructible:
		_draw_barrier(outer_rect, inner_rect)
		return

	if powerful_bonus:
		_draw_powerful_brick(outer_rect, inner_rect)
	elif guaranteed_bonus:
		_draw_guaranteed_brick(outer_rect, inner_rect)
	elif max_health >= 3:
		_draw_heavy_brick(outer_rect, inner_rect)
	elif max_health == 2:
		_draw_reinforced_brick(outer_rect, inner_rect)
	else:
		_draw_light_brick(outer_rect, inner_rect)

	var damage = max_health - health
	if damage >= 1:
		_draw_crack_set_one(Color(0.32, 0.68, 1.0))
	if damage >= 2:
		_draw_crack_set_two(Color(0.32, 0.68, 1.0))

func _draw_light_brick(outer_rect: Rect2, inner_rect: Rect2):
	var half_width = width / 2.0
	var half_height = height / 2.0
	draw_rect(outer_rect, Color(0.025, 0.04, 0.065))
	draw_rect(inner_rect, Color(0.11, 0.14, 0.19))

	var panel = PackedVector2Array([
		Vector2(-half_width + 7.0, -half_height + 5.0),
		Vector2(half_width - 11.0, -half_height + 5.0),
		Vector2(half_width - 6.0, 0.0),
		Vector2(half_width - 11.0, half_height - 5.0),
		Vector2(-half_width + 7.0, half_height - 5.0),
		Vector2(-half_width + 4.0, 0.0)
	])
	draw_colored_polygon(panel, Color(0.18, 0.22, 0.28))
	draw_polyline(PackedVector2Array([panel[0], panel[1], panel[2], panel[3], panel[4], panel[5], panel[0]]), Color(0.31, 0.39, 0.48), 1.0, true)
	draw_line(Vector2(-half_width + 3.0, -half_height + 2.0), Vector2(half_width - 3.0, -half_height + 2.0), Color(0.43, 0.52, 0.62), 1.5, true)
	draw_rect(Rect2(Vector2(-13.0, half_height - 5.0), Vector2(26.0, 2.0)), Color(0.32, 0.68, 1.0, 0.70))

func _draw_reinforced_brick(outer_rect: Rect2, inner_rect: Rect2):
	var half_width = width / 2.0
	var half_height = height / 2.0
	draw_rect(outer_rect, Color(0.018, 0.03, 0.05))
	draw_rect(inner_rect, Color(0.075, 0.10, 0.145))
	draw_rect(inner_rect.grow(-1.0), Color(0.22, 0.27, 0.33), false, 1.5)

	var left_plate = PackedVector2Array([
		Vector2(-half_width + 4.0, -half_height + 4.0),
		Vector2(-half_width + 13.0, -half_height + 4.0),
		Vector2(-half_width + 18.0, 0.0),
		Vector2(-half_width + 13.0, half_height - 4.0),
		Vector2(-half_width + 4.0, half_height - 4.0),
		Vector2(-half_width + 8.0, 0.0)
	])
	var right_plate = PackedVector2Array()
	for point in left_plate:
		right_plate.append(Vector2(-point.x, point.y))
	draw_colored_polygon(left_plate, Color(0.17, 0.21, 0.27))
	draw_colored_polygon(right_plate, Color(0.17, 0.21, 0.27))
	draw_polyline(PackedVector2Array([left_plate[0], left_plate[1], left_plate[2], left_plate[3], left_plate[4], left_plate[5], left_plate[0]]), Color(0.46, 0.53, 0.61), 1.0, true)
	draw_polyline(PackedVector2Array([right_plate[0], right_plate[1], right_plate[2], right_plate[3], right_plate[4], right_plate[5], right_plate[0]]), Color(0.46, 0.53, 0.61), 1.0, true)
	draw_line(Vector2(-12.0, -half_height + 4.0), Vector2(12.0, -half_height + 4.0), Color(0.35, 0.72, 1.0), 2.0, true)
	draw_line(Vector2(-12.0, half_height - 4.0), Vector2(12.0, half_height - 4.0), Color(0.18, 0.48, 0.78), 1.5, true)

func _draw_heavy_brick(outer_rect: Rect2, inner_rect: Rect2):
	var half_width = width / 2.0
	var half_height = height / 2.0
	draw_rect(outer_rect, Color(0.012, 0.025, 0.045))
	draw_rect(inner_rect, Color(0.055, 0.085, 0.13))
	draw_rect(inner_rect.grow(-1.0), Color(0.25, 0.38, 0.50), false, 1.5)

	var left_armor = PackedVector2Array([
		Vector2(-half_width + 4.0, -half_height + 4.0),
		Vector2(-13.0, -half_height + 4.0),
		Vector2(-7.0, -5.0),
		Vector2(-10.0, 0.0),
		Vector2(-7.0, 5.0),
		Vector2(-13.0, half_height - 4.0),
		Vector2(-half_width + 4.0, half_height - 4.0),
		Vector2(-half_width + 10.0, 0.0)
	])
	var right_armor = PackedVector2Array()
	for point in left_armor:
		right_armor.append(Vector2(-point.x, point.y))
	draw_colored_polygon(left_armor, Color(0.10, 0.15, 0.22))
	draw_colored_polygon(right_armor, Color(0.10, 0.15, 0.22))
	draw_polyline(PackedVector2Array([left_armor[0], left_armor[1], left_armor[2], left_armor[3], left_armor[4], left_armor[5], left_armor[6], left_armor[7], left_armor[0]]), Color(0.27, 0.51, 0.72), 1.0, true)
	draw_polyline(PackedVector2Array([right_armor[0], right_armor[1], right_armor[2], right_armor[3], right_armor[4], right_armor[5], right_armor[6], right_armor[7], right_armor[0]]), Color(0.27, 0.51, 0.72), 1.0, true)

	var crystal = PackedVector2Array([
		Vector2(0.0, -10.0),
		Vector2(8.0, -4.0),
		Vector2(7.0, 5.0),
		Vector2(0.0, 10.0),
		Vector2(-7.0, 5.0),
		Vector2(-8.0, -4.0)
	])
	draw_colored_polygon(crystal, Color(0.08, 0.35, 0.62))
	draw_polyline(PackedVector2Array([crystal[0], crystal[1], crystal[2], crystal[3], crystal[4], crystal[5], crystal[0]]), Color(0.35, 0.82, 1.0), 1.5, true)
	draw_line(Vector2(0.0, -8.0), Vector2(0.0, 8.0), Color(0.68, 0.94, 1.0), 1.0, true)
	draw_line(Vector2(-5.0, -2.0), Vector2(5.0, -2.0), Color(0.22, 0.68, 1.0), 1.0, true)

func _draw_guaranteed_brick(outer_rect: Rect2, inner_rect: Rect2):
	_draw_light_brick(outer_rect, inner_rect)
	_draw_bonus_frame(Color(1.0, 0.70, 0.10), Color(0.32, 0.18, 0.025))

func _draw_powerful_brick(outer_rect: Rect2, inner_rect: Rect2):
	_draw_heavy_brick(outer_rect, inner_rect)
	_draw_bonus_frame(Color(1.0, 0.20, 0.06), Color(0.30, 0.035, 0.02))

func _draw_bonus_frame(frame_color: Color, fill_color: Color):
	var half_width = width / 2.0
	var half_height = height / 2.0
	var frame_rect = Rect2(Vector2(-half_width + 1.5, -half_height + 1.5), Vector2(width - 3.0, height - 3.0))
	draw_rect(frame_rect, Color(fill_color, 0.38))
	draw_rect(frame_rect, frame_color, false, 2.5)
	draw_line(Vector2(-half_width + 7.0, -half_height + 4.0), Vector2(-half_width + 18.0, -half_height + 4.0), Color(frame_color, 0.95), 2.0, true)
	draw_line(Vector2(half_width - 18.0, -half_height + 4.0), Vector2(half_width - 7.0, -half_height + 4.0), Color(frame_color, 0.95), 2.0, true)

func _draw_crack_set_one(energy_color: Color):
	var crack_color = Color(0.60, 0.78, 0.95, 0.88)
	draw_polyline(PackedVector2Array([
		Vector2(-6.0, -14.0),
		Vector2(-3.0, -7.0),
		Vector2(-7.0, -2.0),
		Vector2(-2.0, 3.0),
		Vector2(-5.0, 10.0),
		Vector2(-2.0, 14.0)
	]), crack_color, 1.25, true)
	draw_line(Vector2(-3.0, -7.0), Vector2(5.0, -10.0), crack_color, 1.0, true)
	draw_line(Vector2(-7.0, -2.0), Vector2(-14.0, 2.0), crack_color, 1.0, true)
	draw_circle(Vector2(-2.0, 3.0), 1.5, Color(energy_color, 0.75))

func _draw_crack_set_two(energy_color: Color):
	var crack_color = Color(0.72, 0.86, 1.0, 0.92)
	draw_polyline(PackedVector2Array([
		Vector2(18.0, -14.0),
		Vector2(13.0, -7.0),
		Vector2(17.0, -1.0),
		Vector2(10.0, 5.0),
		Vector2(14.0, 14.0)
	]), crack_color, 1.25, true)
	draw_line(Vector2(13.0, -7.0), Vector2(5.0, -4.0), crack_color, 1.0, true)
	draw_line(Vector2(17.0, -1.0), Vector2(25.0, 3.0), crack_color, 1.0, true)
	draw_line(Vector2(10.0, 5.0), Vector2(3.0, 10.0), crack_color, 1.0, true)
	draw_circle(Vector2(10.0, 5.0), 1.5, Color(energy_color, 0.85))

func _draw_barrier(outer_rect: Rect2, inner_rect: Rect2):
	var half_width = width / 2.0
	var half_height = height / 2.0
	var flash_strength = 1.0 if barrier_flash else 0.0
	var body_color = Color(0.025, 0.045, 0.07).lerp(Color(0.16, 0.36, 0.54), flash_strength * 0.55)

	draw_rect(outer_rect, Color(0.01, 0.02, 0.035))
	draw_rect(inner_rect, body_color)
	draw_rect(inner_rect, Color(0.31, 0.43, 0.55), false, 2.0)

	var left_plate = PackedVector2Array([
		Vector2(-half_width + 4.0, -half_height + 4.0),
		Vector2(-9.0, -half_height + 4.0),
		Vector2(-4.0, -5.0),
		Vector2(-8.0, 0.0),
		Vector2(-4.0, 5.0),
		Vector2(-9.0, half_height - 4.0),
		Vector2(-half_width + 4.0, half_height - 4.0),
		Vector2(-half_width + 10.0, 0.0)
	])
	var right_plate = PackedVector2Array()
	for point in left_plate:
		right_plate.append(Vector2(-point.x, point.y))

	draw_colored_polygon(left_plate, Color(0.09, 0.14, 0.20))
	draw_colored_polygon(right_plate, Color(0.09, 0.14, 0.20))
	draw_polyline(PackedVector2Array([left_plate[0], left_plate[1], left_plate[2], left_plate[3], left_plate[4], left_plate[5], left_plate[6], left_plate[7], left_plate[0]]), Color(0.25, 0.42, 0.57), 1.0, true)
	draw_polyline(PackedVector2Array([right_plate[0], right_plate[1], right_plate[2], right_plate[3], right_plate[4], right_plate[5], right_plate[6], right_plate[7], right_plate[0]]), Color(0.25, 0.42, 0.57), 1.0, true)
	draw_circle(Vector2.ZERO, 7.0, Color(0.025, 0.07, 0.11))
	draw_circle(Vector2.ZERO, 5.0, Color(0.08, 0.24, 0.38))
	draw_circle(Vector2.ZERO, 3.0, Color(0.42, 0.82, 1.0) if barrier_flash else Color(0.16, 0.48, 0.72))
	draw_line(Vector2(-half_width + 7.0, -half_height + 3.0), Vector2(-15.0, -half_height + 3.0), Color(0.30, 0.68, 1.0), 1.5, true)
	draw_line(Vector2(15.0, -half_height + 3.0), Vector2(half_width - 7.0, -half_height + 3.0), Color(0.30, 0.68, 1.0), 1.5, true)

	if barrier_hits >= 1:
		_draw_crack_set_one(Color(0.32, 0.70, 1.0))
	if barrier_hits >= 3:
		_draw_crack_set_two(Color(0.32, 0.70, 1.0))
	if barrier_hits >= 4:
		draw_rect(Rect2(Vector2(-half_width - 2.0, -half_height - 2.0), Vector2(width + 4.0, height + 4.0)), Color(0.35, 0.75, 1.0, 0.30), false, 2.0)

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
