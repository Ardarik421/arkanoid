extends Node2D


# =========================
# ПЕРЕЧИСЛЕНИЯ
# =========================

enum LevelPattern {
	VERTICAL_WALL,
	CROSS,
	DOUBLE_VERTICAL,
	HORIZONTAL_WALL,
	DOUBLE_HORIZONTAL,
	HORIZONTAL_PLATFORMS,
	HORIZONTAL_GAP
}

enum LevelDifficulty {
	BEGINNER,
	NORMAL,
	HARD,
	ADVANCED
}

enum LevelStyle {
	BALANCED,
	DENSE,
	SPARSE,
	TOUGH,
	MAZE
}


# =========================
# ССЫЛКИ НА СЦЕНЫ
# =========================

@export var brick_scene: PackedScene
@export var bonus_scene: PackedScene


# =========================
# НАСТРОЙКИ СЕТКИ КИРПИЧЕЙ
# =========================

@export var rows: int = 8
@export var columns: int = 11

@export var start_x: float = 90.0
@export var start_y: float = 100.0

@export var brick_width: float = 70.0
@export var brick_height: float = 30.0

@export var gap_x: float = 8.0
@export var gap_y: float = 8.0


# =========================
# НАСТРОЙКИ ТЕСТИРОВАНИЯ
# =========================

@export_range(1, 100) var test_start_level: int = 1
@export var use_test_level: bool = true

@export var use_test_pattern: bool = false
@export var test_pattern: LevelPattern = LevelPattern.VERTICAL_WALL

@export_group("Bonus Test")

@export var use_test_bonuses: bool = false

@export var test_piercing: bool = false
@export var test_explosive: bool = false
@export var test_shield: bool = false
@export var test_magnet: bool = false
@export var test_fast: bool = false
@export var test_hyper: bool = false

func apply_test_bonuses():
	if not use_test_bonuses:
		return

	if test_piercing:
		set_all_balls_piercing(true)
		piercing_time = PIERCING_DURATION

	if test_explosive:
		set_all_balls_explosive(true)
		explosive_time = EXPLOSIVE_DURATION

	if test_shield:
		set_shield_enabled(true)
		shield_time = SHIELD_DURATION

	if test_magnet:
		set_magnet_enabled(true)
		magnet_time = MAGNET_DURATION

	if test_fast:
		fast_time = FAST_DURATION

	if test_hyper:
		hyper_time = HYPER_DURATION

	update_ball_speed()

# =========================
# СОСТОЯНИЕ ИГРЫ
# =========================

var current_level: int = 1

var lives: int = 3
var score: int = 0

var balls_lost_this_level: int = 0
var breakable_bricks_left: int = 0

var game_won: bool = false
var game_over: bool = false

var active_balls: Array[CharacterBody2D] = []

const BALL_SCENE = preload("res://scenes/ball.tscn")

var shield_active: bool = false
var magnet_active: bool = false

var piercing_time: float = 0.0
var explosive_time: float = 0.0
var shield_time: float = 0.0
var magnet_time: float = 0.0
var fast_time: float = 0.0
var hyper_time: float = 0.0

const PIERCING_DURATION: float = 7.0
const PIERCING_REPEAT_DURATION: float = 4.0
const EXPLOSIVE_DURATION: float = 12.0
const EXPLOSIVE_REPEAT_DURATION: float = 6.0
const SHIELD_DURATION: float = 15.0
const SHIELD_REPEAT_DURATION: float = 7.0
const MAGNET_DURATION: float = 15.0
const MAGNET_REPEAT_DURATION: float = 7.0
const FAST_DURATION: float = 12.0
const FAST_REPEAT_DURATION: float = 6.0
const HYPER_DURATION: float = 6.0
const HYPER_REPEAT_DURATION: float = 3.0

const PADDLE_DEFAULT_WIDTH: float = 160.0
const PADDLE_MIN_WIDTH: float = 40.0
const PADDLE_MAX_WIDTH: float = 280.0
const PADDLE_WIDTH_STEP: float = 40.0

# =========================
# СОСТОЯНИЕ ГЕНЕРАЦИИ УРОВНЯ
# =========================

var current_level_style: LevelStyle = LevelStyle.BALANCED
var previous_level_style: LevelStyle = LevelStyle.BALANCED
var has_previous_style: bool = false

var current_fill_chance: float = 0.8

# =========================
# СОСТОЯНИЕ СТРУКТУР УРОВНЯ
# =========================

var active_patterns: Array[LevelPattern] = []

var pattern_offsets: Dictionary = {}
var pattern_variants: Dictionary = {}
var pattern_sizes: Dictionary = {}

# =========================
# ЗАПУСК И ОСНОВНОЙ ЦИКЛ
# =========================

func _ready():
	
	set_shield_enabled(false)
	active_balls.append($Ball)
	
	if use_test_level:
		current_level = test_start_level
	else:
		current_level = 1
	
	apply_level_settings()
	generate_bricks()
	apply_test_bonuses()
	
	update_lives_label()
	update_score_label()
	update_level_label()

func _process(_delta):
	if game_won:
		if Input.is_action_just_pressed("launch_ball"):
			start_next_level()
		return

	if game_over:
		if Input.is_action_just_pressed("launch_ball"):
			restart_game()
		return
	
	if piercing_time > 0.0:
		piercing_time -= _delta

	if piercing_time <= 0.0:
		piercing_time = 0.0
		set_all_balls_piercing(false)
	
	if explosive_time > 0.0:
		explosive_time -= _delta

	if explosive_time <= 0.0:
		explosive_time = 0.0
		set_all_balls_explosive(false)
	
	if shield_time > 0.0:
		shield_time -= _delta

	if shield_time <= 0.0:
		shield_time = 0.0
		set_shield_enabled(false)

	if magnet_time > 0.0:
		magnet_time -= _delta

	if magnet_time <= 0.0:
		magnet_time = 0.0
		set_magnet_enabled(false)
		
	if fast_time > 0.0:
		fast_time -= _delta

	if fast_time <= 0.0:
		fast_time = 0.0
		update_ball_speed()

	if hyper_time > 0.0:
		hyper_time -= _delta

	if hyper_time <= 0.0:
		hyper_time = 0.0
		update_ball_speed()
	
	if Input.is_action_just_pressed("launch_ball"):
		for ball in active_balls:
			if is_instance_valid(ball) and ball.is_attached:
				ball.launch()

# =========================
# УПРАВЛЕНИЕ ИГРОЙ
# =========================

func reset_ball():
	for ball in active_balls.duplicate():
		if is_instance_valid(ball) and ball != $Ball:
			ball.queue_free()

	active_balls.clear()

	var paddle = $Paddle
	var ball = $Ball

	ball.visible = true
	ball.set_physics_process(true)
	ball.speed = 700.0
	ball.is_piercing = false
	ball.is_explosive = false
	ball.magnet_active = magnet_active
	ball.shield_active = shield_active
	ball.queue_redraw()

	ball.global_position = Vector2(
		paddle.global_position.x,
		paddle.global_position.y - 40
	)

	ball.attach_to_paddle()

	active_balls.append(ball)

func spawn_ball(source_ball: CharacterBody2D) -> CharacterBody2D:
	var new_ball = BALL_SCENE.instantiate()

	add_child(new_ball)

	new_ball.global_position = source_ball.global_position
	new_ball.speed = source_ball.speed
	new_ball.is_piercing = source_ball.is_piercing
	new_ball.is_explosive = source_ball.is_explosive
	new_ball.shield_active = shield_active
	new_ball.magnet_active = magnet_active
	new_ball.is_attached = false

	for ball in active_balls:
		if is_instance_valid(ball):
			ball.add_collision_exception_with(new_ball)
			new_ball.add_collision_exception_with(ball)

	active_balls.append(new_ball)

	return new_ball

func split_balls():
	var balls_to_split = active_balls.duplicate()

	for ball in balls_to_split:
		if not is_instance_valid(ball):
			continue

		var original_direction = ball.direction.normalized()
		var split_angle = randf_range(30.0, 60.0)
		var new_ball = spawn_ball(ball)

		ball.direction = original_direction.rotated(deg_to_rad(-split_angle))
		new_ball.direction = original_direction.rotated(deg_to_rad(split_angle))

func set_all_balls_speed(new_speed: float):
	for ball in active_balls:
		if is_instance_valid(ball):
			ball.speed = new_speed

func set_all_balls_piercing(enabled: bool):
	for ball in active_balls:
		if is_instance_valid(ball):
			ball.is_piercing = enabled
			ball.queue_redraw()

func set_all_balls_explosive(enabled: bool):
	for ball in active_balls:
		if is_instance_valid(ball):
			ball.is_explosive = enabled
			ball.queue_redraw()

func set_shield_enabled(enabled: bool):
	shield_active = enabled
	$Shield.visible = enabled

	for ball in active_balls:
		if is_instance_valid(ball):
			ball.shield_active = enabled

func set_magnet_enabled(enabled: bool):
	magnet_active = enabled

	for ball in active_balls:
		if is_instance_valid(ball):
			ball.magnet_active = enabled

func update_ball_speed():
	if hyper_time > 0.0:
		set_all_balls_speed(1400.0)

	elif fast_time > 0.0:
		set_all_balls_speed(1000.0)

	else:
		set_all_balls_speed(700.0)

func stop_all_balls():
	for ball in active_balls:
		if is_instance_valid(ball):
			ball.is_attached = true

func lose_life():
	lives -= 1
	balls_lost_this_level += 1
	update_lives_label()

	if lives > 0:
		reset_ball()
	else:
		show_game_over()

func restart_game():
	current_level = 1
	reset_level_effects()
	score = 0
	balls_lost_this_level = 0

	update_level_label()
	update_lives_label()
	update_score_label()

	$WinLabel.visible = false
	$GameOverLabel.visible = false

	$Paddle.can_move = true
	$Paddle.global_position = Vector2(480, 980)

	for brick in $Bricks.get_children():
		$Bricks.remove_child(brick)
		brick.queue_free()

	apply_level_settings()
	generate_bricks()
	reset_ball()

	game_won = false
	game_over = false

func start_next_level():
	current_level += 1
	update_level_label()

	reset_level_effects()
	balls_lost_this_level = 0

	update_lives_label()

	$WinLabel.visible = false
	$Paddle.can_move = true
	$Paddle.global_position = Vector2(480, 980)

	for brick in $Bricks.get_children():
		$Bricks.remove_child(brick)
		brick.queue_free()

	apply_level_settings()
	generate_bricks()
	reset_ball()

	game_won = false

	game_won = false

func reset_level_effects():
	lives = 3
	$Paddle.set_width(PADDLE_DEFAULT_WIDTH)
	
	fast_time = 0.0
	hyper_time = 0.0
	update_ball_speed()
	
	piercing_time = 0.0
	set_all_balls_piercing(false)
	
	explosive_time = 0.0
	set_all_balls_explosive(false)
	
	shield_time = 0.0
	set_shield_enabled(false)
	
	magnet_time = 0.0
	set_magnet_enabled(false)
	
	set_shield_enabled(false)
	set_magnet_enabled(false)

# =========================
# ПОБЕДА И ПОРАЖЕНИЕ
# =========================

func show_game_over():
	game_over = true
	$GameOverLabel.visible = true
	$Paddle.can_move = false
	reset_ball()

func show_victory():
	var bonus = get_level_bonus()

	score += bonus
	update_score_label()
	clear_bonuses()

	$WinLabel.text = "ПОБЕДА!\nБонус за сохраненные шары: +" + str(bonus) + "\nSPACE — следующий уровень"
	$WinLabel.visible = true

	stop_all_balls()
	$Paddle.can_move = false

func get_level_bonus() -> int:
	if balls_lost_this_level == 0:
		return 1000
	elif balls_lost_this_level == 1:
		return 500
	elif balls_lost_this_level == 2:
		return 250
	else:
		return 0

# =========================
# СОБЫТИЯ
# =========================

func _on_death_zone_body_entered(body):
	if not body is CharacterBody2D:
		return
	
	if not body in active_balls:
		return

	active_balls.erase(body)

	if body == $Ball:
		body.is_attached = true
		body.visible = false
		body.set_physics_process(false)
	else:
		body.queue_free()

	if active_balls.is_empty():
		lose_life()

func _on_brick_destroyed(points: int, brick_position: Vector2):
	score += points
	breakable_bricks_left -= 1

	update_score_label()
	
	if randf() < 0.60:
		var bonus = bonus_scene.instantiate()
		add_child(bonus)
		bonus.global_position = brick_position
		bonus.collected.connect(_on_bonus_collected)

	if breakable_bricks_left <= 0 and not game_won:
		game_won = true
		show_victory()

func _on_brick_exploded(explosion_position: Vector2):
	var max_x_distance = brick_width + gap_x + 1.0
	var max_y_distance = brick_height + gap_y + 1.0

	for brick in $Bricks.get_children():
		if not is_instance_valid(brick):
			continue

		if brick.global_position == explosion_position:
			continue

		var distance_x = abs(brick.global_position.x - explosion_position.x)
		var distance_y = abs(brick.global_position.y - explosion_position.y)

		if distance_x <= max_x_distance and distance_y <= max_y_distance:
			brick.hit(false)

func _on_bonus_collected(bonus_type: Bonus.BonusType):
	match bonus_type:

		Bonus.BonusType.EXPAND_PADDLE:
			var new_width = $Paddle.width + PADDLE_WIDTH_STEP
			$Paddle.set_width(min(new_width, PADDLE_MAX_WIDTH))

		Bonus.BonusType.SHRINK_PADDLE:
			var new_width = $Paddle.width - PADDLE_WIDTH_STEP
			$Paddle.set_width(max(new_width, PADDLE_MIN_WIDTH))

		Bonus.BonusType.EXTRA_LIFE:
			lives += 1
			update_lives_label()

		Bonus.BonusType.HYPER_BALL:
			if hyper_time > 0.0:
				hyper_time += HYPER_REPEAT_DURATION
			else:
				hyper_time = HYPER_DURATION

			update_ball_speed()

		Bonus.BonusType.FAST_BALL:
			if fast_time > 0.0:
				fast_time += FAST_REPEAT_DURATION
			else:
				fast_time = FAST_DURATION

			update_ball_speed()

		Bonus.BonusType.SPLIT_BALLS:
			split_balls.call_deferred()

		Bonus.BonusType.PIERCING_BALL:
			if piercing_time > 0.0:
				piercing_time += PIERCING_REPEAT_DURATION
			else:
				piercing_time = PIERCING_DURATION
				set_all_balls_piercing(true)

		Bonus.BonusType.EXPLOSIVE_BALL:
			if explosive_time > 0.0:
				explosive_time += EXPLOSIVE_REPEAT_DURATION
			else:
				explosive_time = EXPLOSIVE_DURATION
				set_all_balls_explosive(true)

		Bonus.BonusType.SHIELD:
			if shield_time > 0.0:
				shield_time += SHIELD_REPEAT_DURATION
			else:
				shield_time = SHIELD_DURATION
				set_shield_enabled(true)

		Bonus.BonusType.MAGNET:
			if magnet_time > 0.0:
				magnet_time += MAGNET_REPEAT_DURATION
			else:
				magnet_time = MAGNET_DURATION
				set_magnet_enabled(true)

func clear_bonuses():
	for child in get_children():
		if child is Bonus:
			child.queue_free()

# =========================
# ИНТЕРФЕЙС
# =========================

func update_lives_label():
	$LivesLabel.text = "Жизни: " + str(lives)

func update_score_label():
	$ScoreLabel.text = "Счёт: " + str(score)

func update_level_label():
	$LevelLabel.text = "Уровень: " + str(current_level)

# =========================
# НАСТРОЙКА УРОВНЯ
# =========================

func apply_level_settings():
	active_patterns.clear()
	pattern_offsets.clear()
	pattern_variants.clear()
	pattern_sizes.clear()

	var difficulty = get_level_difficulty()

	var new_style = get_random_level_style()

	if has_previous_style:
		while new_style == previous_level_style:
			new_style = get_random_level_style()

	current_level_style = new_style
	previous_level_style = current_level_style
	has_previous_style = true

	current_fill_chance = get_level_fill_chance()
		
	var available_patterns: Array[LevelPattern] = []

	match difficulty:
		LevelDifficulty.BEGINNER:
			available_patterns = [
				LevelPattern.VERTICAL_WALL,
				LevelPattern.HORIZONTAL_WALL
			]

		LevelDifficulty.NORMAL:
			available_patterns = [
				LevelPattern.VERTICAL_WALL,
				LevelPattern.HORIZONTAL_WALL,
				LevelPattern.DOUBLE_VERTICAL,
				LevelPattern.HORIZONTAL_PLATFORMS
			]

		LevelDifficulty.HARD:
			available_patterns = [
				LevelPattern.VERTICAL_WALL,
				LevelPattern.HORIZONTAL_WALL,
				LevelPattern.DOUBLE_VERTICAL,
				LevelPattern.CROSS,
				LevelPattern.DOUBLE_HORIZONTAL,
				LevelPattern.HORIZONTAL_PLATFORMS,
				LevelPattern.HORIZONTAL_GAP
			]

		LevelDifficulty.ADVANCED:
			available_patterns = [
				LevelPattern.VERTICAL_WALL,
				LevelPattern.HORIZONTAL_WALL,
				LevelPattern.DOUBLE_VERTICAL,
				LevelPattern.CROSS,
				LevelPattern.DOUBLE_HORIZONTAL,
				LevelPattern.HORIZONTAL_PLATFORMS,
				LevelPattern.HORIZONTAL_GAP
			]
	print(
		"Level: ", current_level,
		" | Difficulty: ", LevelDifficulty.keys()[get_level_difficulty()],
		" | Style: ", LevelStyle.keys()[current_level_style],
		" | Fill: ", current_fill_chance
		)

	if use_test_pattern:
		active_patterns.append(test_pattern)

		pattern_offsets[test_pattern] = Vector2i(
			randi_range(-1, 1),
			randi_range(-1, 1)
		)

		pattern_variants[test_pattern] = randi_range(0, 1)
		
		if (
			test_pattern == LevelPattern.HORIZONTAL_WALL
			or test_pattern == LevelPattern.DOUBLE_HORIZONTAL
		):
			pattern_sizes[test_pattern] = randi_range(3, 4)
		else:
			pattern_sizes[test_pattern] = randi_range(3, 5)

	else:
		var structure_count = get_structure_count()
		var max_wall_bricks = get_max_wall_bricks()
		var selected_count = 0

		while selected_count < structure_count and not available_patterns.is_empty():
			var selected_pattern = available_patterns.pick_random()

			available_patterns.erase(selected_pattern)
			active_patterns.append(selected_pattern)

			pattern_offsets[selected_pattern] = Vector2i(
				randi_range(-1, 1),
				randi_range(-1, 1)
			)

			pattern_variants[selected_pattern] = randi_range(0, 1)

			if (
				selected_pattern == LevelPattern.HORIZONTAL_WALL
				or selected_pattern == LevelPattern.DOUBLE_HORIZONTAL
			):
				pattern_sizes[selected_pattern] = randi_range(3, 4)
			else:
				pattern_sizes[selected_pattern] = randi_range(3, 5)

			if (
				count_wall_positions() > max_wall_bricks
				or count_horizontal_patterns() > 1
				or (
					count_horizontal_patterns() > 0
					and active_patterns.size() > 2
				)
			):
				active_patterns.erase(selected_pattern)
				pattern_offsets.erase(selected_pattern)
				pattern_variants.erase(selected_pattern)
				pattern_sizes.erase(selected_pattern)

			else:
				selected_count += 1

				if selected_pattern == LevelPattern.CROSS:
					break

				available_patterns.erase(LevelPattern.CROSS)
					
	var pattern_names: Array[String] = []

	for pattern in active_patterns:
		pattern_names.append(LevelPattern.keys()[pattern])

	print("Patterns: ", ", ".join(pattern_names))

func get_level_difficulty() -> LevelDifficulty:
	if current_level <= 3:
		return LevelDifficulty.BEGINNER
	elif current_level <= 7:
		return LevelDifficulty.NORMAL
	elif current_level <= 12:
		return LevelDifficulty.HARD
	else:
		return LevelDifficulty.ADVANCED

func get_random_level_style() -> LevelStyle:
	var difficulty = get_level_difficulty()
	var roll = randf()

	match difficulty:
		LevelDifficulty.BEGINNER:
			if roll < 0.45:
				return LevelStyle.BALANCED
			elif roll < 0.75:
				return LevelStyle.DENSE
			else:
				return LevelStyle.SPARSE

		LevelDifficulty.NORMAL:
			if roll < 0.35:
				return LevelStyle.BALANCED
			elif roll < 0.60:
				return LevelStyle.DENSE
			elif roll < 0.85:
				return LevelStyle.SPARSE
			else:
				return LevelStyle.TOUGH

		LevelDifficulty.HARD:
			if roll < 0.30:
				return LevelStyle.BALANCED
			elif roll < 0.50:
				return LevelStyle.DENSE
			elif roll < 0.70:
				return LevelStyle.SPARSE
			elif roll < 0.85:
				return LevelStyle.TOUGH
			else:
				return LevelStyle.MAZE

		LevelDifficulty.ADVANCED:
			if roll < 0.25:
				return LevelStyle.BALANCED
			elif roll < 0.45:
				return LevelStyle.DENSE
			elif roll < 0.65:
				return LevelStyle.SPARSE
			elif roll < 0.82:
				return LevelStyle.TOUGH
			else:
				return LevelStyle.MAZE

	return LevelStyle.BALANCED

func get_level_fill_chance() -> float:
	match current_level_style:
		LevelStyle.DENSE:
			return randf_range(0.85, 0.95)

		LevelStyle.SPARSE:
			return randf_range(0.55, 0.68)

		LevelStyle.TOUGH:
			return randf_range(0.72, 0.82)

		LevelStyle.MAZE:
			return randf_range(0.65, 0.78)

		LevelStyle.BALANCED:
			var difficulty = get_level_difficulty()

			match difficulty:
				LevelDifficulty.BEGINNER:
					return randf_range(0.65, 0.75)

				LevelDifficulty.NORMAL:
					return randf_range(0.70, 0.82)

				LevelDifficulty.HARD:
					return randf_range(0.72, 0.88)

				LevelDifficulty.ADVANCED:
					return randf_range(0.68, 0.90)

	return 0.75

# =========================
# НАСТРОЙКА ПРОЧНОСТИ КИРПИЧЕЙ
# =========================

func get_three_hit_chance() -> float:
	var difficulty = get_level_difficulty()
	var chance: float = 0.03

	match difficulty:
		LevelDifficulty.BEGINNER:
			chance = 0.03

		LevelDifficulty.NORMAL:
			chance = 0.07

		LevelDifficulty.HARD:
			chance = 0.12

		LevelDifficulty.ADVANCED:
			chance = 0.15

	if current_level_style == LevelStyle.TOUGH:
		chance += 0.10

	return chance

func get_two_hit_chance() -> float:
	var difficulty = get_level_difficulty()
	var chance: float = 0.12

	match difficulty:
		LevelDifficulty.BEGINNER:
			chance = 0.12

		LevelDifficulty.NORMAL:
			chance = 0.20

		LevelDifficulty.HARD:
			chance = 0.28

		LevelDifficulty.ADVANCED:
			chance = 0.32

	if current_level_style == LevelStyle.TOUGH:
		chance += 0.15

	return chance

# =========================
# НАСТРОЙКА СТРУКТУР УРОВНЯ
# =========================

func get_structure_count() -> int:
	var difficulty = get_level_difficulty()

	if current_level_style == LevelStyle.MAZE:
		match difficulty:
			LevelDifficulty.BEGINNER:
				return 1

			LevelDifficulty.NORMAL:
				return randi_range(1, 2)

			LevelDifficulty.HARD:
				return randi_range(2, 3)

			LevelDifficulty.ADVANCED:
				return randi_range(2, 3)

	match difficulty:
		LevelDifficulty.BEGINNER:
			return randi_range(0, 1)

		LevelDifficulty.NORMAL:
			return 1

		LevelDifficulty.HARD:
			return randi_range(1, 2)

		LevelDifficulty.ADVANCED:
			return randi_range(1, 3)

	return 0

func get_max_wall_bricks() -> int:
	var difficulty = get_level_difficulty()

	match difficulty:
		LevelDifficulty.BEGINNER:
			return 7

		LevelDifficulty.NORMAL:
			return 12

		LevelDifficulty.HARD:
			return 18

		LevelDifficulty.ADVANCED:
			return 24

	return 7

func is_horizontal_pattern(pattern: LevelPattern) -> bool:
	return (
		pattern == LevelPattern.HORIZONTAL_WALL
		or pattern == LevelPattern.DOUBLE_HORIZONTAL
		or pattern == LevelPattern.HORIZONTAL_PLATFORMS
		or pattern == LevelPattern.HORIZONTAL_GAP
		or pattern == LevelPattern.CROSS
	)

func count_horizontal_patterns() -> int:
	var count: int = 0

	for pattern in active_patterns:
		if is_horizontal_pattern(pattern):
			count += 1

	return count

# =========================
# ГЕОМЕТРИЯ НЕРУШИМЫХ КИРПИЧЕЙ
# =========================

func is_wall_position(row: int, column: int) -> bool:
	for pattern in active_patterns:
		
		var offset: Vector2i = pattern_offsets.get(
			pattern,
			Vector2i.ZERO
		)
			
		var variant: int = pattern_variants.get(pattern, 0)
		var size: int = pattern_sizes.get(pattern, 4)
		
		if pattern == LevelPattern.VERTICAL_WALL:
			if (
				column == 5 + offset.x
				and row >= 2 + offset.y
				and row < 2 + offset.y + size
			):
				return true

		elif pattern == LevelPattern.CROSS:
			if variant == 0:
				if (
					(column == 5 + offset.x
					and row >= 1 + offset.y
					and row <= 6 + offset.y)
					or
					(row == 3 + offset.y
					and column >= 3 + offset.x
					and column <= 7 + offset.x)
				):
					return true

			else:
				if (
					(column == 5 + offset.x
					and row >= 1 + offset.y
					and row <= 6 + offset.y)
					or
					(row == 4 + offset.y
					and column >= 3 + offset.x
					and column <= 7 + offset.x)
				):
					return true

		elif pattern == LevelPattern.DOUBLE_VERTICAL:
			if (
				(column == 3 + offset.x
				and row >= 1 + offset.y
				and row < 1 + offset.y + size)
				or
				(column == 7 + offset.x
				and row >= 1 + offset.y
				and row < 1 + offset.y + size)
			):
				return true

		elif pattern == LevelPattern.HORIZONTAL_WALL:
			if (
				row == 3 + offset.y
				and column >= 2 + offset.x
				and column < 2 + offset.x + size
			):
				return true

		elif pattern == LevelPattern.DOUBLE_HORIZONTAL:
			var start_column = 1 + offset.x

			if variant == 1:
				start_column += 4

			if (
				(row == 2 + offset.y
				and column >= start_column
				and column < start_column + size)
				or
				(row == 5 + offset.y
				and column >= start_column
				and column < start_column + size)
			):
				return true

		elif pattern == LevelPattern.HORIZONTAL_PLATFORMS:
			if variant == 0:
				if (
					(row == 2 + offset.y
					and column >= 1 + offset.x
					and column <= 4 + offset.x)
					or
					(row == 4 + offset.y
					and column >= 6 + offset.x
					and column <= 9 + offset.x)
				):
					return true

			else:
				if (
					(row == 4 + offset.y
					and column >= 1 + offset.x
					and column <= 4 + offset.x)
					or
					(row == 2 + offset.y
					and column >= 6 + offset.x
					and column <= 9 + offset.x)
				):
					return true

		elif pattern == LevelPattern.HORIZONTAL_GAP:
			if (
				row == 3 + offset.y
				and column >= 1 + offset.x
				and column <= 9 + offset.x
				and column != 5 + offset.x
			):
				return true

	return false	

func count_wall_positions() -> int:
	var count = 0

	for row in range(rows):
		for column in range(columns):
			if is_wall_position(row, column):
				count += 1

	return count

# =========================
# СОЗДАНИЕ КИРПИЧЕЙ
# =========================

func generate_bricks():
	breakable_bricks_left = 0

	var minimum_breakable_bricks: int = 10
	var max_generation_attempts: int = 100
	var generation_attempts: int = 0

	var breakable_cells: Array[Vector2i] = []
	var wall_cells: Array[Vector2i] = []

	while breakable_cells.size() < minimum_breakable_bricks and generation_attempts < max_generation_attempts:
		generation_attempts += 1

		breakable_cells.clear()
		wall_cells.clear()

		for row in range(rows):
			for column in range(columns):
				var cell = Vector2i(column, row)
				var is_wall_brick = is_wall_position(row, column)

				if is_wall_brick:
					wall_cells.append(cell)

				elif randf() <= current_fill_chance:
					breakable_cells.append(cell)

		if breakable_cells.size() < minimum_breakable_bricks:
			breakable_cells.clear()

			for row in range(rows):
				for column in range(columns):
					var cell = Vector2i(column, row)

					if cell not in wall_cells:
						breakable_cells.append(cell)

			print(
				"Использована запасная генерация. Разрушаемых кирпичей: ",
				breakable_cells.size()
			)

	for row in range(rows):
		for column in range(columns):
			var cell = Vector2i(column, row)

			var is_wall_brick = cell in wall_cells
			var is_breakable_brick = cell in breakable_cells

			if not is_wall_brick and not is_breakable_brick:
				continue

			var brick = brick_scene.instantiate()

			if is_wall_brick:
				brick.indestructible = true
				brick.points = 0

			else:
				var roll = randf()
				var three_hit_chance = get_three_hit_chance()
				var two_hit_chance = get_two_hit_chance()

				if roll < three_hit_chance:
					brick.health = 3
					brick.max_health = 3
					brick.points = 500

				elif roll < three_hit_chance + two_hit_chance:
					brick.health = 2
					brick.max_health = 2
					brick.points = 250

				breakable_bricks_left += 1

			brick.position = Vector2(
				start_x + column * (brick_width + gap_x),
				start_y + row * (brick_height + gap_y)
			)

			$Bricks.add_child(brick)
			brick.destroyed.connect(_on_brick_destroyed)
			brick.exploded.connect(_on_brick_exploded)
