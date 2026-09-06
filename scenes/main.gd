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

@export_range(0.0, 1.0) var fill_chance: float = 0.8

@export_range(1, 100) var test_start_level: int = 1
@export var use_test_level: bool = true

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

@export var level_pattern: LevelPattern = LevelPattern.RANDOM

var lives: int = 3
var score: int = 0
var balls_lost_this_level: int = 0
var breakable_bricks_left: int = 0

var game_won: bool = false
var game_over: bool = false

var current_level: int = 1

var active_patterns: Array[LevelPattern] = []


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

			if not is_wall_brick and randf() > fill_chance:
				continue

			var brick = brick_scene.instantiate()

			if is_wall_brick:
				brick.indestructible = true
				brick.points = 0

			else:
				var roll = randf()

				if roll < 0.10:
					brick.health = 3
					brick.max_health = 3
					brick.points = 500

				elif roll < 0.35:
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

	var difficulty = get_level_difficulty()
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

	var structure_count = get_structure_count()

	for i in range(structure_count):
		if available_patterns.is_empty():
			break

		var selected_pattern = available_patterns.pick_random()
		active_patterns.append(selected_pattern)
		available_patterns.erase(selected_pattern)

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
	
func get_structure_count() -> int:
	var difficulty = get_level_difficulty()

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

func is_wall_position(row: int, column: int) -> bool:
	for pattern in active_patterns:
		if pattern == LevelPattern.VERTICAL_WALL:
			if column == 5 and row >= 2 and row <= 5:
				return true

		elif pattern == LevelPattern.CROSS:
			if (
				(column == 5 and row >= 1 and row <= 6)
				or
				(row == 3 and column >= 3 and column <= 7)
			):
				return true

		elif pattern == LevelPattern.DOUBLE_VERTICAL:
			if (
				(column == 3 and row >= 1 and row <= 6)
				or
				(column == 7 and row >= 1 and row <= 6)
			):
				return true

		elif pattern == LevelPattern.HORIZONTAL_WALL:
			if row == 3 and column >= 2 and column <= 8:
				return true

		elif pattern == LevelPattern.DOUBLE_HORIZONTAL:
			if (
				(row == 2 and column >= 1 and column <= 9)
				or
				(row == 5 and column >= 1 and column <= 9)
			):
				return true

		elif pattern == LevelPattern.HORIZONTAL_PLATFORMS:
			if (
				(row == 2 and column >= 1 and column <= 4)
				or
				(row == 4 and column >= 6 and column <= 9)
			):
				return true

		elif pattern == LevelPattern.HORIZONTAL_GAP:
			if (
				row == 3
				and column >= 1
				and column <= 9
				and column != 5
			):
				return true

	return false	
	
