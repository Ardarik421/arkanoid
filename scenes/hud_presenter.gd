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

	last_score = int(main.get("score"))

func _process(_delta):
	var current_level = int(main.get("current_level"))
	var current_score = int(main.get("score"))

	if current_level != last_level:
		last_level = current_level

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
