extends Node2D

@export var brick_scene: PackedScene

@export var rows: int = 8
@export var columns: int = 11

@export var start_x: float = 90.0
@export var start_y: float = 100.0

@export var brick_width: float = 70.0
@export var brick_height: float = 30.0

@export var gap_x: float = 8.0
@export var gap_y: float = 8.0

@export_range(1, 100) var test_start_level: int = 1
@export var use_test_level: bool = true
@export var use_test_pattern: bool = false
@export var test_pattern: LevelPattern = LevelPattern.VERTICAL_WALL

enum LevelPattern {
	RANDOM,
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

var lives: int = 3
var score: int = 0
var balls_lost_this_level: int = 0
var breakable_bricks_left: int = 0

var game_won: bool = false
var game_over: bool = false

var current_level: int = 1

var active_patterns: Array[LevelPattern] = []
var pattern_offsets: Dictionary = {}
var pattern_variants: Dictionary = {}
var pattern_sizes: Dictionary = {}

var current_fill_chance: float = 0.8

var current_level_style: LevelStyle = LevelStyle.BALANCED
var previous_level_style: LevelStyle = LevelStyle.BALANCED
var has_previous_style: bool = false

func _ready():
	if use_test_level:
		current_level = test_start_level
	else:
		current_level = 1
	
	apply_level_settings()
	generate_bricks()
	
	update_lives_label()
	update_score_label()
	update_level_label()

func generate_bricks():
	breakable_bricks_left = 0

	for row in range(rows):
		for column in range(columns):

			var is_wall_brick = is_wall_position(row, column)

			if not is_wall_brick and randf() > current_fill_chance:
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

			if not brick.indestructible:
				breakable_bricks_left += 1

			brick.position = Vector2(
				start_x + column * (brick_width + gap_x),
				start_y + row * (brick_height + gap_y)
			)

			$Bricks.add_child(brick)
			brick.destroyed.connect(_on_brick_destroyed)

func _on_death_zone_body_entered(body):
	if body.name == "Ball":
		lose_life()

func reset_ball():
	var paddle = $Paddle
	var ball = $Ball

	ball.global_position = Vector2(
		paddle.global_position.x,
		paddle.global_position.y - 40
	)

	ball.attach_to_paddle()

func _process(delta):
	var ball = $Ball
	var paddle = $Paddle

	if game_won:
		if Input.is_action_just_pressed("launch_ball"):
			start_next_level()
		return

	if game_over:
		if Input.is_action_just_pressed("launch_ball"):
			restart_game()
		return

	if ball.is_attached:
		ball.global_position = Vector2(
			paddle.global_position.x,
			paddle.global_position.y - 40
		)

		if Input.is_action_just_pressed("launch_ball"):
			ball.launch()

func lose_life():
	lives -= 1
	balls_lost_this_level += 1
	update_lives_label()

	if lives > 0:
		reset_ball()
	else:
		show_game_over()

func show_game_over():
	game_over = true
	$GameOverLabel.visible = true
	$Paddle.can_move = false
	reset_ball()
	
func show_victory():
	var bonus = get_level_bonus()

	score += bonus
	update_score_label()

	$WinLabel.text = "ПОБЕДА!\nБонус за сохраненные шары: +" + str(bonus) + "\nSPACE — следующий уровень"
	$WinLabel.visible = true

	$Ball.is_attached = true
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
	
func restart_game():
	current_level = 1
	lives = 3
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

func _on_brick_destroyed(points: int):
	score += points
	breakable_bricks_left -= 1

	update_score_label()

	if breakable_bricks_left <= 0 and not game_won:
		game_won = true
		show_victory()

func update_lives_label():
	$LivesLabel.text = "Жизни: " + str(lives)

func update_score_label():
	$ScoreLabel.text = "Счёт: " + str(score)
	
func update_level_label():
	$LevelLabel.text = "Уровень: " + str(current_level)
	
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
			
			pattern_sizes.erase(selected_pattern)

			if count_wall_positions() > max_wall_bricks:
				active_patterns.erase(selected_pattern)
				pattern_offsets.erase(selected_pattern)
				pattern_variants.erase(selected_pattern)
				pattern_sizes.erase(selected_pattern)
			else:
				selected_count += 1
	var pattern_names: Array[String] = []

	for pattern in active_patterns:
		pattern_names.append(LevelPattern.keys()[pattern])

	print("Patterns: ", ", ".join(pattern_names))

func start_next_level():
	
	current_level += 1
	update_level_label()

	lives = 3
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
