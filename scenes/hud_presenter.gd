extends Node

var main: Node
var score_label: Label
var level_label: Label
var level_intro: Label
var last_level: int = -1
var last_score: int = -1
var level_tween: Tween
var score_tween: Tween

func _ready():
	main = get_parent()
	score_label = main.get_node_or_null("ScoreLabel")
	level_label = main.get_node_or_null("LevelLabel")

	_setup_score()
	_setup_level_intro()

	last_score = int(main.get("score"))

func _process(_delta):
	var current_level = int(main.get("current_level"))
	var current_score = int(main.get("score"))

	if current_level != last_level:
		last_level = current_level
		_show_level_intro(current_level)

	if current_score != last_score:
		last_score = current_score
		_pulse_score()

func _setup_score():
	if score_label == null:
		return

	score_label.offset_left = 390.0
	score_label.offset_top = 14.0
	score_label.offset_right = 570.0
	score_label.offset_bottom = 54.0
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.remove_theme_stylebox_override("normal")
	score_label.add_theme_font_size_override("font_size", 23)
	score_label.add_theme_color_override("font_color", Color(0.82, 0.92, 1.0, 0.82))
	score_label.add_theme_color_override("font_outline_color", Color(0.015, 0.035, 0.055, 0.92))
	score_label.add_theme_constant_override("outline_size", 3)
	score_label.pivot_offset = Vector2(90.0, 20.0)
	score_label.z_index = 20

func _setup_level_intro():
	if level_label != null:
		level_label.visible = false

	level_intro = Label.new()
	level_intro.name = "LevelIntro"
	level_intro.offset_left = 0.0
	level_intro.offset_top = 420.0
	level_intro.offset_right = 960.0
	level_intro.offset_bottom = 540.0
	level_intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_intro.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_intro.add_theme_font_size_override("font_size", 34)
	level_intro.add_theme_color_override("font_color", Color(0.78, 0.94, 1.0, 1.0))
	level_intro.add_theme_color_override("font_outline_color", Color(0.015, 0.045, 0.075, 0.96))
	level_intro.add_theme_constant_override("outline_size", 5)
	level_intro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_intro.z_index = 30
	level_intro.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.add_child(level_intro)

func _show_level_intro(level: int):
	if level_intro == null:
		return

	if level_tween != null and level_tween.is_valid():
		level_tween.kill()

	level_intro.text = "УРОВЕНЬ %d\n%s" % [level, _get_chapter_name(level)]
	level_intro.modulate = Color(1.0, 1.0, 1.0, 0.0)
	level_intro.scale = Vector2(0.96, 0.96)
	level_intro.pivot_offset = Vector2(480.0, 60.0)

	level_tween = create_tween()
	level_tween.set_parallel(true)
	level_tween.tween_property(level_intro, "modulate:a", 1.0, 0.18)
	level_tween.tween_property(level_intro, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	level_tween.set_parallel(false)
	level_tween.tween_interval(0.85)
	level_tween.tween_property(level_intro, "modulate:a", 0.0, 0.42)

func _pulse_score():
	if score_label == null:
		return

	if score_tween != null and score_tween.is_valid():
		score_tween.kill()

	score_label.scale = Vector2(1.08, 1.08)
	score_label.modulate = Color(0.82, 0.96, 1.0, 1.0)

	score_tween = create_tween()
	score_tween.set_parallel(true)
	score_tween.tween_property(score_label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	score_tween.tween_property(score_label, "modulate", Color(1.0, 1.0, 1.0, 0.82), 0.24)

func _get_chapter_name(level: int) -> String:
	if level <= 10:
		return "ЯДРО"
	if level <= 20:
		return "ПОВЕРХНОСТЬ"
	if level <= 30:
		return "БИОСФЕРА"
	if level <= 40:
		return "ВЕРХНЯЯ АТМОСФЕРА"
	if level <= 50:
		return "ОРБИТА"
	if level <= 60:
		return "ГЛУБОКИЙ КОСМОС"
	if level <= 70:
		return "ТУМАННОСТЬ"
	if level <= 80:
		return "ИСКАЖЁННОЕ ПРОСТРАНСТВО"
	if level <= 90:
		return "РАЗЛОМ РЕАЛЬНОСТИ"
	return "ЧЁРНАЯ ДЫРА"
