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
	var rect = Rect2(
		Vector2(-width / 2.0, -height / 2.0),
		Vector2(width, height)
	)

	if indestructible:
		if barrier_flash:
			draw_rect(rect, Color(0.55, 0.80, 1.0))
		else:
			draw_rect(rect, Color(0.10, 0.18, 0.24))

		return

	if max_health == 1:
		draw_rect(rect, Color.WHITE)

	elif max_health == 2:
		if health == 2:
			draw_rect(rect, Color(0.45, 0.45, 0.45))
		else:
			draw_rect(rect, Color(0.75, 0.75, 0.75))

	elif max_health == 3:
		if health == 3:
			draw_rect(rect, Color(0.25, 0.25, 0.25))
		elif health == 2:
			draw_rect(rect, Color(0.50, 0.50, 0.50))
		else:
			draw_rect(rect, Color(0.80, 0.80, 0.80))

	if powerful_bonus:
		draw_rect(rect, Color(1.0, 0.25, 0.05), false, 4.0)
	elif guaranteed_bonus:
		draw_rect(rect, Color(1.0, 0.75, 0.15), false, 4.0)

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
