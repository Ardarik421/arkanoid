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
	HORIZONTAL_GAP,
	BARRIER_TEST
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
@export var use_test_level: bool = false

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
var score_at_level_start: int = 0

var balls_lost_this_level: int = 0
var breakable_bricks_left: int = 0

var game_won: bool = false
var game_over: bool = false

var active_balls: Array[CharacterBody2D] = []

const BALL_SCENE = preload("res://scenes/ball.tscn")
const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const LEVEL_AMBIENT_TRACKS: Array[AudioStream] = [
	preload("res://audio/music/ambient_01.wav"),
	preload("res://audio/music/ambient_02.wav"),
	preload("res://audio/music/ambient_03.wav"),
	preload("res://audio/music/ambient_04.wav"),
	preload("res://audio/music/ambient_05.wav"),
	preload("res://audio/music/ambient_06.wav"),
	preload("res://audio/music/ambient_07.wav")
]
const EXPLOSIVE_SOUND: AudioStream = preload("res://audio/sfx/explosive.wav")
const CHAPTER_NAMES: Array[String] = ["ЗОЛОТАЯ ОРБИТА","КРАСНЫЙ МИР","ЛЕДЯНОЙ ГИГАНТ","РАСКОЛОТЫЙ МИР","ДВОЙНАЯ СИСТЕМА","ШТОРМОВОЙ ГИГАНТ","БЕЗМОЛВИЕ","ПРИЗМАТИЧЕСКАЯ РЕЛИКВИЯ","РАЗЛОМ ГРАВИТАЦИИ","ЧЁРНАЯ ДЫРА"]
const BONUS_HINTS: Dictionary = {0:"РАСШИРЕНИЕ — увеличивает платформу",1:"УМЕНЬШЕНИЕ — уменьшает платформу",2:"ЖИЗНЬ — добавляет одну жизнь",3:"ГИПЕРСКОРОСТЬ — сильно ускоряет шар",4:"УСКОРЕНИЕ — ускоряет шар",5:"МУЛЬТИШАР — добавляет дополнительные шары",6:"ПРОБИВАНИЕ — позволяет шару пробивать кирпичи",7:"ВЗРЫВ — разрушает область вокруг кирпича",8:"ЩИТ — возвращает упавший шар в игру",9:"МАГНИТ — ловит шар на платформу перед запуском"}

var explosive_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var last_ambient_index: int = -1
var ambient_restart_pending: bool = false
var chapter_label: Label
var hint_label: Label
var victory_fade: ColorRect
var victory_input_ready: bool = false

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

const MAX_RANDOM_BONUSES_ON_SCREEN: int = 5
const PORTRAIT_ARENA_SIZE := Vector2(960.0, 1080.0)
const LANDSCAPE_ARENA_SIZE := Vector2(1280.0, 800.0)
const WALL_THICKNESS: float = 40.0
const DEATH_ZONE_HEIGHT: float = 80.0
const PADDLE_BOTTOM_MARGIN: float = 80.0
const SHIELD_BOTTOM_MARGIN: float = 120.0
const LANDSCAPE_PADDLE_BOTTOM_MARGIN: float = 80.0
const LANDSCAPE_SHIELD_BOTTOM_MARGIN: float = 88.0
const EFFECTS_BELOW_PADDLE_GAP: float = 9.0
const PADDLE_HALF_HEIGHT: float = 12.0
const EFFECTS_BOTTOM_MARGIN: float = 12.0

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
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_setup_progression_polish()
	_apply_gameplay_layout()
	_setup_ambient()
	_setup_explosive_audio()
	
	set_shield_enabled(false)
	active_balls.append($Ball)

	if use_test_level:
		current_level = test_start_level
	else:
		current_level = SaveManager.selected_level

	score_at_level_start = score

	apply_level_settings()
	generate_bricks()
	apply_test_bonuses()

	update_lives_label()
	update_score_label()
	update_level_label()
	_show_chapter_intro_if_needed()

func _setup_progression_polish() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	chapter_label = Label.new()
	chapter_label.set_anchors_preset(Control.PRESET_CENTER)
	chapter_label.position = Vector2(-360,-100)
	chapter_label.size = Vector2(720,200)
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chapter_label.add_theme_font_size_override("font_size",38)
	chapter_label.add_theme_color_override("font_color",Color(1.0,0.90,0.58))
	chapter_label.visible = false
	layer.add_child(chapter_label)
	hint_label = Label.new()
	hint_label.position = Vector2(150,875)
	hint_label.size = Vector2(660,70)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size",19)
	hint_label.add_theme_color_override("font_color",Color(1.0,0.90,0.62))
	hint_label.visible = false
	layer.add_child(hint_label)
	victory_fade = ColorRect.new()
	victory_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	victory_fade.color = Color(0.01,0.005,0.0,0.0)
	victory_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(victory_fade)

func _apply_gameplay_layout() -> void:
	var arena_size := LANDSCAPE_ARENA_SIZE if SettingsManager.display_mode == 1 else PORTRAIT_ARENA_SIZE
	_configure_arena(arena_size)

func _configure_arena(arena_size: Vector2) -> void:
	var center_x := arena_size.x * 0.5
	var center_y := arena_size.y * 0.5
	var landscape := SettingsManager.display_mode == 1
	var paddle_bottom_margin := LANDSCAPE_PADDLE_BOTTOM_MARGIN if landscape else PADDLE_BOTTOM_MARGIN
	var shield_bottom_margin := LANDSCAPE_SHIELD_BOTTOM_MARGIN if landscape else SHIELD_BOTTOM_MARGIN
	var paddle_y := arena_size.y - paddle_bottom_margin
	var shield_y := arena_size.y - shield_bottom_margin

	$Walls/LeftWall.position = Vector2(WALL_THICKNESS * 0.5, center_y)
	$Walls/RightWall2.position = Vector2(arena_size.x - WALL_THICKNESS * 0.5, center_y)
	$Walls/TopWall.position = Vector2(center_x, WALL_THICKNESS * 0.5)

	var left_shape := $Walls/LeftWall/CollisionShape2D.shape as RectangleShape2D
	var right_shape := $Walls/RightWall2/CollisionShape2D.shape as RectangleShape2D
	var top_shape := $Walls/TopWall/CollisionShape2D.shape as RectangleShape2D
	left_shape.size = Vector2(WALL_THICKNESS, arena_size.y)
	right_shape.size = Vector2(WALL_THICKNESS, arena_size.y)
	top_shape.size = Vector2(arena_size.x, WALL_THICKNESS)

	var death_shape := $DeathZone/CollisionShape2D.shape as RectangleShape2D
	death_shape.size = Vector2(arena_size.x, DEATH_ZONE_HEIGHT)
	$DeathZone/CollisionShape2D.position = Vector2(center_x, arena_size.y + DEATH_ZONE_HEIGHT * 0.5)

	$Paddle.configure_horizontal_limits(WALL_THICKNESS * 0.5, arena_size.x - WALL_THICKNESS * 0.5)
	$Paddle.global_position = Vector2(center_x, paddle_y)
	$Paddle.set_fixed_y(paddle_y)
	$Shield.global_position = Vector2(center_x, shield_y)
	$Shield/CollisionShape2D.disabled = not shield_active
	var shield_shape := $Shield/CollisionShape2D.shape as RectangleShape2D
	shield_shape.size.x = arena_size.x - WALL_THICKNESS
	$Shield/ShieldVisual.set_shield_width(arena_size.x - WALL_THICKNESS)

	# Keep the effect cards below the paddle with symmetric breathing room:
	# paddle -> cards == cards -> bottom edge whenever the layout has enough room.
	var effects_height := maxf($EffectsUI.size.y, $EffectsUI.get_combined_minimum_size().y)
	var effects_y := arena_size.y - EFFECTS_BOTTOM_MARGIN - effects_height
	var below_paddle_y := paddle_y + PADDLE_HALF_HEIGHT + EFFECTS_BELOW_PADDLE_GAP
	if below_paddle_y + effects_height + EFFECTS_BOTTOM_MARGIN <= arena_size.y:
		effects_y = below_paddle_y
	$EffectsUI.position = Vector2(
		center_x - $EffectsUI.size.x * 0.5,
		effects_y
	)

	# Keep the established 960 px brick formation intact and center it in wider arenas.
	$Bricks.position.x = (arena_size.x - PORTRAIT_ARENA_SIZE.x) * 0.5

	if is_instance_valid(hint_label):
		hint_label.position.y = arena_size.y - 145.0

func _reset_paddle_position() -> void:
	var arena_size := LANDSCAPE_ARENA_SIZE if SettingsManager.display_mode == 1 else PORTRAIT_ARENA_SIZE
	var paddle_bottom_margin := LANDSCAPE_PADDLE_BOTTOM_MARGIN if SettingsManager.display_mode == 1 else PADDLE_BOTTOM_MARGIN
	var paddle_y := arena_size.y - paddle_bottom_margin
	$Paddle.global_position = Vector2(arena_size.x * 0.5, paddle_y)
	$Paddle.set_fixed_y(paddle_y)

func _show_chapter_intro_if_needed() -> void:
	if (current_level - 1) % 10 != 0:
		return
	var chapter: int = clampi((current_level - 1) / 10,0,CHAPTER_NAMES.size()-1)
	chapter_label.text = "ГЛАВА %d\n%s" % [chapter + 1,CHAPTER_NAMES[chapter]]
	chapter_label.modulate.a = 0.0
	chapter_label.visible = true
	var tween := create_tween()
	tween.tween_property(chapter_label,"modulate:a",1.0,0.35)
	tween.tween_interval(1.15)
	tween.tween_property(chapter_label,"modulate:a",0.0,0.55)
	tween.tween_callback(func(): chapter_label.visible = false)

func _show_bonus_hint(bonus_type: int) -> void:
	if not SettingsManager.should_show_bonus_hint(bonus_type):
		return
	SettingsManager.mark_bonus_hint_seen(bonus_type)
	hint_label.text = str(BONUS_HINTS.get(bonus_type,""))
	hint_label.modulate.a = 0.0
	hint_label.visible = true
	var tween := create_tween()
	tween.tween_property(hint_label,"modulate:a",1.0,0.2)
	tween.tween_interval(1.7)
	tween.tween_property(hint_label,"modulate:a",0.0,0.35)
	tween.tween_callback(func(): hint_label.visible = false)

func _setup_ambient() -> void:
	ambient_player = AudioStreamPlayer.new()
	ambient_player.volume_db = -13.0
	ambient_player.finished.connect(_on_ambient_finished)
	add_child(ambient_player)
	_play_new_ambient()

func _play_new_ambient() -> void:
	if not is_instance_valid(ambient_player) or LEVEL_AMBIENT_TRACKS.is_empty():
		return

	var next_index: int = randi_range(0, LEVEL_AMBIENT_TRACKS.size() - 1)
	if LEVEL_AMBIENT_TRACKS.size() > 1:
		while next_index == last_ambient_index:
			next_index = randi_range(0, LEVEL_AMBIENT_TRACKS.size() - 1)

	last_ambient_index = next_index
	ambient_player.stream = LEVEL_AMBIENT_TRACKS[next_index]
	ambient_player.play()

func _on_ambient_finished() -> void:
	# Keep the selected track for the whole level attempt.
	if is_instance_valid(ambient_player):
		ambient_player.play()

func _setup_explosive_audio():
	explosive_player = AudioStreamPlayer.new()
	explosive_player.stream = EXPLOSIVE_SOUND
	explosive_player.volume_db = -3.0
	add_child(explosive_player)

func _play_explosive_sound():
	if is_instance_valid(explosive_player):
		explosive_player.play()

func _process(_delta):
		
	update_effects_ui()

	if game_won:
		return

	if game_over:
		if Input.is_action_just_pressed("launch_ball"):
			restart_level()
		elif Input.is_action_just_pressed("ui_cancel"):
			return_to_main_menu()
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
	ball.is_piercing = piercing_time > 0.0
	ball.is_explosive = explosive_time > 0.0
	ball.magnet_active = magnet_active
	ball.shield_active = shield_active
	ball.queue_redraw()

	ball.global_position = Vector2(
		paddle.global_position.x,
		paddle.global_position.y - 40
	)

	ball.attach_to_paddle()

	active_balls.append(ball)

	update_ball_speed()

func spawn_ball(source_ball: CharacterBody2D) -> CharacterBody2D:
	var new_ball = BALL_SCENE.instantiate()

	add_child(new_ball)

	new_ball.global_position = source_ball.global_position
	new_ball.speed = source_ball.speed
	new_ball.is_piercing = source_ball.is_piercing
	new_ball.is_explosive = source_ball.is_explosive
	new_ball.shield_active = shield_active
	new_ball.magnet_active = magnet_active
	new_ball.shield_return_boost_active = source_ball.shield_return_boost_active
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
	$Shield/CollisionShape2D.set_deferred("disabled", not enabled)

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
	if $Paddle.has_method("play_life_loss_feedback"):
		$Paddle.play_life_loss_feedback()

	var feedback_script = load("res://scenes/life_loss_feedback.gd")
	if feedback_script != null:
		var feedback = Node2D.new()
		feedback.set_script(feedback_script)
		add_child(feedback)

	lives -= 1
	balls_lost_this_level += 1
	update_lives_label()

	if lives > 0:
		reset_ball()
	else:
		show_game_over()

func restart_level():
	_play_new_ambient()
	reset_level_effects()
	score = score_at_level_start
	balls_lost_this_level = 0

	update_level_label()
	update_lives_label()
	update_score_label()

	$WinLabel.visible = false
	$GameOverLabel.visible = false

	$Paddle.can_move = true
	_reset_paddle_position()

	clear_bonuses()

	for brick in $Bricks.get_children():
		$Bricks.remove_child(brick)
		brick.queue_free()

	apply_level_settings()
	generate_bricks()
	reset_ball()
	apply_test_bonuses()

	game_won = false
	game_over = false

func return_to_main_menu():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func start_next_level():
	if current_level >= 100:
		return_to_main_menu()
		return

	$Paddle.can_move = false
	var transition := create_tween()
	transition.tween_property(victory_fade,"color:a",0.90,0.38)
	await transition.finished

	current_level += 1
	_play_new_ambient()
	score_at_level_start = score
	update_level_label()

	reset_level_effects()
	balls_lost_this_level = 0

	update_lives_label()

	$WinLabel.visible = false
	$Paddle.can_move = true
	_reset_paddle_position()

	for brick in $Bricks.get_children():
		$Bricks.remove_child(brick)
		brick.queue_free()

	apply_level_settings()
	generate_bricks()
	reset_ball()

	game_won = false
	var reveal := create_tween()
	reveal.tween_property(victory_fade,"color:a",0.0,0.62).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_show_chapter_intro_if_needed()

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

# =========================
# ПОБЕДА И ПОРАЖЕНИЕ
# =========================

func _layout_game_over_label() -> void:
	var arena_size := get_viewport_rect().size
	$GameOverLabel.position = Vector2.ZERO
	$GameOverLabel.size = arena_size
	$GameOverLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$GameOverLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func show_game_over():
	game_over = true
	$GameOverLabel.text = "ИГРА ОКОНЧЕНА\nSPACE — повторить уровень\nESC — главное меню"
	$GameOverLabel.visible = true
	_layout_game_over_label()
	$Paddle.can_move = false
	reset_ball()

func _unhandled_input(event: InputEvent) -> void:
	if not game_won or not victory_input_ready:
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventScreenTouch:
		if event.pressed:
			victory_input_ready = false
			start_next_level()
			get_viewport().set_input_as_handled()

func _enable_victory_input() -> void:
	if game_won:
		victory_input_ready = true

func show_victory():
	var bonus = get_level_bonus()
	var first_completion: bool = current_level > SaveManager.highest_completed_level

	score += bonus

	if not use_test_level:
		SaveManager.unlock_level(current_level + 1)

	update_score_label()
	clear_bonuses()

	var reward_text: String = "\n★ +1" if first_completion and not use_test_level else ""
	var score_reward_text: String = "\nСЧЁТ +" + str(bonus) if bonus > 0 else ""
	if current_level >= 100:
		$WinLabel.text = "ОСНОВНОЙ МАРШРУТ ПРОЙДЕН!" + reward_text + score_reward_text + "\nБОНУСНЫЕ УРОВНИ — СКОРО"
	else:
		$WinLabel.text = "УРОВЕНЬ ПРОЙДЕН" + reward_text + score_reward_text
	victory_fade.color = Color(0.05,0.025,0.0,0.0)
	create_tween().tween_property(victory_fade,"color:a",0.55,0.55)

	$WinLabel.visible = true
	victory_input_ready = false
	get_tree().create_timer(0.5).timeout.connect(_enable_victory_input)

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

func get_active_bonus_count() -> int:
	var count: int = 0

	for child in get_children():
		if child is Bonus and not child.is_queued_for_deletion():
			count += 1

	return count

func _on_brick_destroyed(points: int, brick_position: Vector2, guaranteed_bonus: bool, powerful_bonus: bool):
	score += points
	breakable_bricks_left -= 1

	update_score_label()

	var can_spawn_random_bonus = (
		guaranteed_bonus
		or get_active_bonus_count() < MAX_RANDOM_BONUSES_ON_SCREEN
	)

	if can_spawn_random_bonus and (
		guaranteed_bonus
		or randf() < get_bonus_drop_chance()
	):
		var bonus = bonus_scene.instantiate()

		if powerful_bonus:
			var powerful_pool = [
				Bonus.BonusType.PIERCING_BALL,
				Bonus.BonusType.EXPLOSIVE_BALL
			]

			if get_pressure_tier() == 0:
				powerful_pool.append(Bonus.BonusType.SPLIT_BALLS)

			bonus.forced_bonus_type = powerful_pool.pick_random()

		elif guaranteed_bonus:
			var guaranteed_pool = [
				Bonus.BonusType.EXPAND_PADDLE,
				Bonus.BonusType.EXTRA_LIFE,
				Bonus.BonusType.HYPER_BALL,
				Bonus.BonusType.FAST_BALL,
				Bonus.BonusType.SHIELD,
				Bonus.BonusType.MAGNET
			]
			bonus.forced_bonus_type = guaranteed_pool.pick_random()

		add_child(bonus)
		bonus.global_position = brick_position
		bonus.collected.connect(_on_bonus_collected)

	if breakable_bricks_left <= 0 and not game_won:
		game_won = true
		show_victory()

func _on_brick_exploded(explosion_position: Vector2):
	_play_explosive_sound()
	
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
			brick.hit_by_explosion()

func _on_bonus_collected(bonus_type: Bonus.BonusType):
	_show_bonus_hint(int(bonus_type))
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
				piercing_time = SaveManager.get_piercing_duration(PIERCING_DURATION)
				set_all_balls_piercing(true)

		Bonus.BonusType.EXPLOSIVE_BALL:
			if explosive_time > 0.0:
				explosive_time += EXPLOSIVE_REPEAT_DURATION
			else:
				explosive_time = SaveManager.get_explosive_duration(EXPLOSIVE_DURATION)
				set_all_balls_explosive(true)

		Bonus.BonusType.SHIELD:
			if shield_time > 0.0:
				shield_time += SHIELD_REPEAT_DURATION
			else:
				shield_time = SaveManager.get_shield_duration(SHIELD_DURATION)
				set_shield_enabled(true)

		Bonus.BonusType.MAGNET:
			if magnet_time > 0.0:
				magnet_time += MAGNET_REPEAT_DURATION
			else:
				magnet_time = SaveManager.get_magnet_duration(MAGNET_DURATION)
				set_magnet_enabled(true)

func clear_bonuses():
	for child in get_children():
		if child is Bonus:
			child.queue_free()

# =========================
# ИНТЕРФЕЙС
# =========================

func update_lives_label():
	$LivesLabel.text = "HP " + str(lives)

func update_score_label():
	$ScoreLabel.text = str(score)

func update_level_label():
	$LevelLabel.text = "LVL " + str(current_level)

func update_effects_ui():
	update_effect_label($EffectsUI/Piercing, "P", piercing_time)
	update_effect_label($EffectsUI/Explosive, "E", explosive_time)
	update_effect_label($EffectsUI/Shield, "B", shield_time)
	update_effect_label($EffectsUI/Magnet, "M", magnet_time)
	update_effect_label($EffectsUI/Fast, "F", fast_time)
	update_effect_label($EffectsUI/Hyper, "H", hyper_time)

func update_effect_label(label: Label, prefix: String, time_left: float):
	if label.has_method("set_effect_time"):
		label.set_effect_time(time_left)
		return

	if time_left > 0.0:
		label.visible = true
		label.text = "%.1f" % time_left
	else:
		label.visible = false

# =========================
# НАСТРОЙКА УРОВНЯ
# =========================


func apply_level_settings():
	active_patterns.clear()
	pattern_offsets.clear()
	pattern_variants.clear()
	pattern_sizes.clear()

	var new_style = get_random_level_style()

	if has_previous_style:
		while new_style == previous_level_style:
			new_style = get_random_level_style()

	current_level_style = new_style
	previous_level_style = current_level_style
	has_previous_style = true

	current_fill_chance = get_level_fill_chance()

	var available_patterns: Array[LevelPattern] = [
		LevelPattern.VERTICAL_WALL
	]

	if current_level >= 4:
		available_patterns.append(LevelPattern.DOUBLE_VERTICAL)

	if current_level >= 8:
		available_patterns.append(LevelPattern.HORIZONTAL_WALL)

	if current_level >= 13:
		available_patterns.append(LevelPattern.HORIZONTAL_PLATFORMS)

	if current_level >= 20:
		available_patterns.append(LevelPattern.DOUBLE_HORIZONTAL)
		available_patterns.append(LevelPattern.CROSS)

	if current_level >= 30:
		available_patterns.append(LevelPattern.HORIZONTAL_GAP)


	if use_test_pattern:
		active_patterns.append(test_pattern)

		pattern_offsets[test_pattern] = Vector2i(
			randi_range(-1, 1),
			get_pattern_vertical_offset(test_pattern)
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
				get_pattern_vertical_offset(selected_pattern)
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


func get_pattern_vertical_offset(pattern: LevelPattern) -> int:
	if (
		pattern == LevelPattern.HORIZONTAL_WALL
		or pattern == LevelPattern.DOUBLE_HORIZONTAL
		or pattern == LevelPattern.HORIZONTAL_PLATFORMS
		or pattern == LevelPattern.HORIZONTAL_GAP
		or pattern == LevelPattern.CROSS
	):
		if current_level < 40:
			return randi_range(0, 1)

	return randi_range(-1, 1)

func get_random_level_style() -> LevelStyle:
	var progress = clamp(
		float(current_level - 1) / 99.0,
		0.0,
		1.0
	)

	var tough_chance: float = 0.0

	if current_level >= 4:
		var tough_progress = clamp(
			float(current_level - 4) / 96.0,
			0.0,
			1.0
		)

		tough_chance = lerp(0.05, 0.18, tough_progress)

	var maze_chance: float = 0.0

	if current_level >= 8:
		var maze_progress = clamp(
			float(current_level - 8) / 92.0,
			0.0,
			1.0
		)

		maze_chance = lerp(0.03, 0.20, maze_progress)

	var basic_share = 1.0 - tough_chance - maze_chance

	var balanced_ratio = lerp(0.45, 0.38, progress)
	var dense_ratio = lerp(0.30, 0.32, progress)
	var sparse_ratio = 1.0 - balanced_ratio - dense_ratio

	var balanced_chance = basic_share * balanced_ratio
	var dense_chance = basic_share * dense_ratio
	var sparse_chance = basic_share * sparse_ratio

	var roll = randf()

	if roll < balanced_chance:
		return LevelStyle.BALANCED

	roll -= balanced_chance

	if roll < dense_chance:
		return LevelStyle.DENSE

	roll -= dense_chance

	if roll < sparse_chance:
		return LevelStyle.SPARSE

	roll -= sparse_chance

	if roll < tough_chance:
		return LevelStyle.TOUGH

	return LevelStyle.MAZE

func get_level_fill_chance() -> float:
	var progress = clamp(
		float(current_level - 1) / 99.0,
		0.0,
		1.0
	)

	var base_fill = lerp(0.70, 0.82, progress)
	var variation: float = 0.0

	match current_level_style:
		LevelStyle.DENSE:
			base_fill += 0.14
			variation = 0.03

		LevelStyle.SPARSE:
			base_fill -= 0.14
			variation = 0.04

		LevelStyle.TOUGH:
			base_fill -= 0.02
			variation = 0.04

		LevelStyle.MAZE:
			base_fill -= 0.07
			variation = 0.04

		LevelStyle.BALANCED:
			variation = 0.05

	return clamp(
		base_fill + randf_range(-variation, variation),
		0.50,
		0.97
	)

func get_bonus_drop_chance() -> float:
	var progress = clamp(
		float(current_level - 1) / 99.0,
		0.0,
		1.0
	)

	return lerp(0.45, 0.25, progress)

# =========================
# НАСТРОЙКА ПРОЧНОСТИ КИРПИЧЕЙ
# =========================

func get_three_hit_chance() -> float:
	var progress = clamp(
		float(current_level - 1) / 99.0,
		0.0,
		1.0
	)

	var chance = lerp(0.01, 0.20, progress)

	match current_level_style:
		LevelStyle.TOUGH:
			chance += 0.05

		LevelStyle.MAZE:
			chance -= 0.03

		LevelStyle.DENSE:
			chance -= 0.01

		LevelStyle.SPARSE:
			chance += 0.02

	return clamp(chance, 0.0, 0.25)

func get_two_hit_chance() -> float:
	var progress = clamp(
		float(current_level - 1) / 99.0,
		0.0,
		1.0
	)

	var chance = lerp(0.10, 0.34, progress)

	match current_level_style:
		LevelStyle.TOUGH:
			chance += 0.08

		LevelStyle.MAZE:
			chance -= 0.05

		LevelStyle.DENSE:
			chance -= 0.02

		LevelStyle.SPARSE:
			chance += 0.03

	return clamp(chance, 0.05, 0.42)

# =========================
# НАСТРОЙКА СТРУКТУР УРОВНЯ
# =========================

func get_structure_count() -> int:
	var minimum_structures: int = 0
	var maximum_structures: int = 1

	if current_level >= 10:
		minimum_structures = 1
		maximum_structures = 2

	if current_level >= 30:
		maximum_structures = 3

	if current_level >= 60:
		minimum_structures = 2

	if current_level_style == LevelStyle.MAZE:
		minimum_structures += 1
		maximum_structures += 1

	minimum_structures = min(minimum_structures, 3)
	maximum_structures = min(maximum_structures, 3)

	return randi_range(
		minimum_structures,
		max(maximum_structures, minimum_structures)
	)

func get_max_wall_bricks() -> int:
	var progress = clamp(
		float(current_level - 1) / 99.0,
		0.0,
		1.0
	)

	return roundi(lerp(7.0, 24.0, progress))

func get_pressure_tier() -> int:
	var pressure_factors: int = 0

	var dense_pressure = current_fill_chance >= 0.82
	var armored_pressure = (
		get_two_hit_chance() + get_three_hit_chance()
	) >= 0.38
	var barrier_pressure = count_wall_positions() >= 8
	var difficult_style = (
		current_level_style == LevelStyle.TOUGH
		or current_level_style == LevelStyle.MAZE
	)

	if dense_pressure:
		pressure_factors += 1

	if armored_pressure:
		pressure_factors += 1

	if barrier_pressure:
		pressure_factors += 1

	if difficult_style:
		pressure_factors += 1

	if pressure_factors >= 3:
		return 2

	if pressure_factors >= 2:
		return 1

	return 0

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
		elif pattern == LevelPattern.BARRIER_TEST:
			if (
				row == 4
				and column >= 3
				and column <= 7
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
