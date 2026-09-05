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

var lives: int = 3
var score: int = 0
var balls_lost_this_level: int = 0

var game_won: bool = false
var game_over: bool = false


func _ready():
	generate_bricks()
	update_lives_label()
	update_score_label()

func generate_bricks():
	for row in range(rows):
		for column in range(columns):

			if randf() > fill_chance:
				continue

			var brick = brick_scene.instantiate()
			if randf() < 0.25:
				brick.health = 2
				brick.max_health = 2
				brick.points = 250

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

	if game_won or game_over:
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

	if not game_won and $Bricks.get_child_count() == 0:
		game_won = true
		show_victory()

func update_lives_label():
	$LivesLabel.text = "Жизни: " + str(lives)

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
	print("GAME OVER сработал")
	print("Visible: ", $GameOverLabel.visible)
	print("Position: ", $GameOverLabel.global_position)
	reset_ball()
	
func show_victory():
	var bonus = get_level_bonus()

	score += bonus
	update_score_label()

	$WinLabel.text = "ПОБЕДА!\nБонус за сохраненные шары: +" + str(bonus) + "\nSPACE — начать заново"
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
	lives = 3
	score = 0
	balls_lost_this_level = 0

	update_lives_label()
	update_score_label()

	$WinLabel.visible = false
	$GameOverLabel.visible = false

	$Paddle.can_move = true
	$Paddle.global_position = Vector2(480, 980)

	for brick in $Bricks.get_children():
		$Bricks.remove_child(brick)
		brick.queue_free()

	generate_bricks()
	reset_ball()

	game_won = false
	game_over = false

func _on_brick_destroyed(points: int):
	score += points
	update_score_label()
	
func update_score_label():
	$ScoreLabel.text = "Счёт: " + str(score)
