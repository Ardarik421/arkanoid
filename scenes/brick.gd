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
		_draw_crack_set_one(Color(0.38, 0.76, 1.0))
	if damage >= 2:
		_draw_crack_set_two(Color(0.46, 0.84, 1.0))

func _draw_light_brick(outer_rect: Rect2, inner_rect: Rect2):
	var hw = width / 2.0
	var hh = height / 2.0
	draw_rect(outer_rect, Color(0.015, 0.025, 0.045))
	draw_rect(inner_rect, Color(0.10, 0.13, 0.18))
	draw_rect(inner_rect.grow(-1.0), Color(0.32, 0.40, 0.50), false, 1.0)

	var stone = PackedVector2Array([
		Vector2(-hw + 6.0, -hh + 5.0),
		Vector2(hw - 10.0, -hh + 5.0),
		Vector2(hw - 5.0, 0.0),
		Vector2(hw - 10.0, hh - 5.0),
		Vector2(-hw + 7.0, hh - 5.0),
		Vector2(-hw + 4.0, 1.0)
	])
	draw_colored_polygon(stone, Color(0.18, 0.22, 0.28))
	draw_polyline(PackedVector2Array([stone[0], stone[1], stone[2], stone[3], stone[4], stone[5], stone[0]]), Color(0.42, 0.48, 0.56), 1.0, true)
	draw_line(Vector2(-hw + 8.0, -4.0), Vector2(-8.0, -2.0), Color(0.24, 0.29, 0.36), 1.0, true)
	draw_line(Vector2(6.0, 4.0), Vector2(hw - 10.0, 2.0), Color(0.24, 0.29, 0.36), 1.0, true)
	draw_rect(Rect2(Vector2(-14.0, hh - 5.0), Vector2(28.0, 2.0)), Color(0.30, 0.70, 1.0, 0.9))

func _draw_reinforced_brick(outer_rect: Rect2, inner_rect: Rect2):
	var hw = width / 2.0
	var hh = height / 2.0
	draw_rect(outer_rect, Color(0.01, 0.02, 0.035))
	draw_rect(inner_rect, Color(0.055, 0.075, 0.11))
	draw_rect(inner_rect.grow(-1.0), Color(0.42, 0.50, 0.58), false, 1.2)

	var center_plate = PackedVector2Array([
		Vector2(-22.0, -hh + 5.0),
		Vector2(22.0, -hh + 5.0),
		Vector2(27.0, 0.0),
		Vector2(22.0, hh - 5.0),
		Vector2(-22.0, hh - 5.0),
		Vector2(-27.0, 0.0)
	])
	draw_colored_polygon(center_plate, Color(0.16, 0.20, 0.26))
	draw_polyline(PackedVector2Array([center_plate[0], center_plate[1], center_plate[2], center_plate[3], center_plate[4], center_plate[5], center_plate[0]]), Color(0.30, 0.38, 0.47), 1.0, true)

	for side in [-1.0, 1.0]:
		var x = side * (hw - 8.0)
		var plate = PackedVector2Array([
			Vector2(x - 4.0 * side, -hh + 4.0),
			Vector2(x + 3.0 * side, -hh + 4.0),
			Vector2(x + 7.0 * side, 0.0),
			Vector2(x + 3.0 * side, hh - 4.0),
			Vector2(x - 4.0 * side, hh - 4.0),
			Vector2(x - 7.0 * side, 0.0)
		])
		draw_colored_polygon(plate, Color(0.19, 0.24, 0.30))
		draw_polyline(PackedVector2Array([plate[0], plate[1], plate[2], plate[3], plate[4], plate[5], plate[0]]), Color(0.58, 0.65, 0.72), 1.0, true)

	draw_rect(Rect2(Vector2(-15.0, -hh + 4.0), Vector2(30.0, 2.5)), Color(0.40, 0.78, 1.0))
	draw_rect(Rect2(Vector2(-11.0, hh - 5.0), Vector2(22.0, 2.0)), Color(0.18, 0.50, 0.82))
	draw_circle(Vector2(-27.0, 0.0), 1.4, Color(0.44, 0.80, 1.0))
	draw_circle(Vector2(27.0, 0.0), 1.4, Color(0.44, 0.80, 1.0))

func _draw_heavy_brick(outer_rect: Rect2, inner_rect: Rect2):
	var hw = width / 2.0
	var hh = height / 2.0
	draw_rect(outer_rect, Color(0.008, 0.016, 0.03))
	draw_rect(inner_rect, Color(0.035, 0.055, 0.09))
	draw_rect(inner_rect.grow(-1.0), Color(0.25, 0.55, 0.78), false, 1.2)

	for side in [-1.0, 1.0]:
		var armor = PackedVector2Array([
			Vector2(side * 4.0, -hh + 4.0),
			Vector2(side * (hw - 5.0), -hh + 4.0),
			Vector2(side * (hw - 10.0), -3.0),
			Vector2(side * 11.0, 0.0),
			Vector2(side * (hw - 10.0), 3.0),
			Vector2(side * (hw - 5.0), hh - 4.0),
			Vector2(side * 4.0, hh - 4.0),
			Vector2(side * 9.0, 0.0)
		])
		draw_colored_polygon(armor, Color(0.08, 0.13, 0.20))
		draw_polyline(PackedVector2Array([armor[0], armor[1], armor[2], armor[3], armor[4], armor[5], armor[6], armor[7], armor[0]]), Color(0.26, 0.56, 0.78), 1.0, true)

	var crystal = PackedVector2Array([
		Vector2(0.0, -11.0),
		Vector2(9.0, -3.0),
		Vector2(7.0, 6.0),
		Vector2(0.0, 11.0),
		Vector2(-7.0, 6.0),
		Vector2(-9.0, -3.0)
	])
	draw_colored_polygon(crystal, Color(0.06, 0.37, 0.66))
	draw_polyline(PackedVector2Array([crystal[0], crystal[1], crystal[2], crystal[3], crystal[4], crystal[5], crystal[0]]), Color(0.45, 0.90, 1.0), 1.6, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, -8.0),
		Vector2(5.0, -2.0),
		Vector2(0.0, 7.0),
		Vector2(-5.0, -2.0)
	]), Color(0.20, 0.70, 1.0, 0.55))
	draw_line(Vector2(0.0, -7.0), Vector2(0.0, 8.0), Color(0.80, 0.97, 1.0), 1.0, true)
	draw_line(Vector2(-4.0, -2.0), Vector2(4.0, -2.0), Color(0.68, 0.94, 1.0), 1.0, true)
	draw_circle(Vector2.ZERO, 2.0, Color(0.82, 0.98, 1.0))

func _draw_guaranteed_brick(outer_rect: Rect2, inner_rect: Rect2):
	var hw = width / 2.0
	var hh = height / 2.0
	draw_rect(outer_rect, Color(0.12, 0.065, 0.005))
	draw_rect(inner_rect, Color(0.32, 0.17, 0.025))
	draw_rect(inner_rect.grow(-1.0), Color(1.0, 0.70, 0.10), false, 1.5)
	draw_rect(Rect2(Vector2(-hw + 5.0, -hh + 4.0), Vector2(width - 10.0, 3.0)), Color(1.0, 0.76, 0.14))
	draw_rect(Rect2(Vector2(-14.0, hh - 6.0), Vector2(28.0, 3.0)), Color(1.0, 0.60, 0.04))
	draw_line(Vector2(-24.0, -6.0), Vector2(-10.0, 5.0), Color(0.70, 0.36, 0.03), 1.0, true)
	draw_line(Vector2(18.0, -7.0), Vector2(6.0, 6.0), Color(0.70, 0.36, 0.03), 1.0, true)
	draw_circle(Vector2.ZERO, 3.0, Color(1.0, 0.90, 0.52))

func _draw_powerful_brick(outer_rect: Rect2, inner_rect: Rect2):
	var hw = width / 2.0
	var hh = height / 2.0
	draw_rect(outer_rect, Color(0.11, 0.006, 0.004))
	draw_rect(inner_rect, Color(0.28, 0.025, 0.018))
	draw_rect(inner_rect.grow(-1.0), Color(1.0, 0.22, 0.08), false, 1.5)

	for side in [-1.0, 1.0]:
		var plate = PackedVector2Array([
			Vector2(side * 6.0, -hh + 4.0),
			Vector2(side * (hw - 5.0), -hh + 4.0),
			Vector2(side * (hw - 9.0), -2.0),
			Vector2(side * 12.0, 0.0),
			Vector2(side * (hw - 9.0), 2.0),
			Vector2(side * (hw - 5.0), hh - 4.0),
			Vector2(side * 6.0, hh - 4.0),
			Vector2(side * 10.0, 0.0)
		])
		draw_colored_polygon(plate, Color(0.34, 0.035, 0.02))
		draw_polyline(PackedVector2Array([plate[0], plate[1], plate[2], plate[3], plate[4], plate[5], plate[6], plate[7], plate[0]]), Color(0.95, 0.20, 0.06), 1.0, true)

	var core = PackedVector2Array([
		Vector2(0.0, -10.0),
		Vector2(8.0, 0.0),
		Vector2(0.0, 10.0),
		Vector2(-8.0, 0.0)
	])
	draw_colored_polygon(core, Color(0.75, 0.05, 0.02))
	draw_polyline(PackedVector2Array([core[0], core[1], core[2], core[3], core[0]]), Color(1.0, 0.48, 0.14), 1.7, true)
	draw_line(Vector2(0.0, -8.0), Vector2(0.0, 8.0), Color(1.0, 0.86, 0.55), 1.0, true)
	draw_line(Vector2(-5.0, 0.0), Vector2(5.0, 0.0), Color(1.0, 0.52, 0.16), 1.0, true)
	draw_circle(Vector2.ZERO, 2.2, Color(1.0, 0.94, 0.74))

func _draw_crack_set_one(energy_color: Color):
	var crack_color = Color(0.67, 0.86, 1.0, 0.96)
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
	draw_circle(Vector2(-2.0, 3.0), 1.5, Color(energy_color, 0.80))

func _draw_crack_set_two(energy_color: Color):
	var crack_color = Color(0.76, 0.91, 1.0, 0.98)
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
	draw_circle(Vector2(10.0, 5.0), 1.5, Color(energy_color, 0.90))

func _draw_barrier(outer_rect: Rect2, inner_rect: Rect2):
	var hw = width / 2.0
	var hh = height / 2.0
	var flash_strength = 1.0 if barrier_flash else 0.0
	var body_color = Color(0.025, 0.045, 0.07).lerp(Color(0.16, 0.36, 0.54), flash_strength * 0.55)

	draw_rect(outer_rect, Color(0.008, 0.015, 0.028))
	draw_rect(inner_rect, body_color)
	draw_rect(inner_rect.grow(-1.0), Color(0.30, 0.54, 0.72), false, 1.3)

	for side in [-1.0, 1.0]:
		var frame = PackedVector2Array([
			Vector2(side * 7.0, -hh + 4.0),
			Vector2(side * (hw - 5.0), -hh + 4.0),
			Vector2(side * (hw - 10.0), -2.0),
			Vector2(side * 12.0, 0.0),
			Vector2(side * (hw - 10.0), 2.0),
			Vector2(side * (hw - 5.0), hh - 4.0),
			Vector2(side * 7.0, hh - 4.0),
			Vector2(side * 11.0, 0.0)
		])
		draw_colored_polygon(frame, Color(0.08, 0.13, 0.20))
		draw_polyline(PackedVector2Array([frame[0], frame[1], frame[2], frame[3], frame[4], frame[5], frame[6], frame[7], frame[0]]), Color(0.30, 0.52, 0.70), 1.0, true)

	draw_circle(Vector2.ZERO, 7.0, Color(0.02, 0.07, 0.12))
	draw_circle(Vector2.ZERO, 5.0, Color(0.08, 0.25, 0.40))
	draw_circle(Vector2.ZERO, 3.0, Color(0.52, 0.90, 1.0) if barrier_flash else Color(0.20, 0.58, 0.82))
	draw_line(Vector2(-hw + 8.0, -hh + 3.0), Vector2(-15.0, -hh + 3.0), Color(0.32, 0.72, 1.0), 1.5, true)
	draw_line(Vector2(15.0, -hh + 3.0), Vector2(hw - 8.0, -hh + 3.0), Color(0.32, 0.72, 1.0), 1.5, true)
	draw_line(Vector2(-hw + 8.0, hh - 3.0), Vector2(-15.0, hh - 3.0), Color(0.18, 0.46, 0.72), 1.0, true)
	draw_line(Vector2(15.0, hh - 3.0), Vector2(hw - 8.0, hh - 3.0), Color(0.18, 0.46, 0.72), 1.0, true)

	if barrier_hits >= 1:
		_draw_crack_set_one(Color(0.32, 0.70, 1.0))
	if barrier_hits >= 3:
		_draw_crack_set_two(Color(0.32, 0.70, 1.0))
	if barrier_hits >= 4:
		draw_rect(Rect2(Vector2(-hw - 2.0, -hh - 2.0), Vector2(width + 4.0, height + 4.0)), Color(0.35, 0.75, 1.0, 0.30), false, 2.0)

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
