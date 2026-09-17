extends CharacterBody2D

@export var speed: float = 450.0
@export var radius: float = 12.0
@export var max_bounce_angle: float = 50.0
@export var aim_turn_speed: float = 75.0
@export var aim_line_length: float = 560.0
@export var min_vertical_direction: float = 0.22

const BRICK_HIT_SOUND: AudioStream = preload("res://audio/sfx/brick_hit.wav")
const PADDLE_HIT_SOUND: AudioStream = preload("res://audio/sfx/paddle_hit.wav")
const WALL_HIT_SOUND: AudioStream = preload("res://audio/sfx/wall_hit.wav")
const PIERCING_SOUND: AudioStream = preload("res://audio/sfx/piercing.wav")
const SHIELD_RETURN_SPEED_MULTIPLIER: float = 2.0
const MAGNET_SHORT_AIM_LENGTH: float = 280.0

var brick_hit_player: AudioStreamPlayer
var paddle_hit_player: AudioStreamPlayer
var wall_hit_player: AudioStreamPlayer
var piercing_player: AudioStreamPlayer
var piercing_sound_cooldown: float = 0.0
var direction := Vector2(0.7, -1.0).normalized()
var is_attached: bool = true
var is_piercing: bool = false
var is_explosive: bool = false
var shield_active: bool = false
var magnet_active: bool = false
var magnet_captured: bool = false
var shield_return_boost_active: bool = false
var shield_y: float = 1040.0
var attached_offset_x: float = 0.0
var visual_time: float = 0.0
var launch_aim_angle: float = 0.0

var trail_points: Array[Vector2] = []
var trail_max_points: int = 10
var trail_min_distance: float = 10.0

func _ready():
	_setup_audio()
	set_collision_mask_value(1, true)
	trail_points.append(global_position)
	queue_redraw()

func _setup_audio():
	brick_hit_player = AudioStreamPlayer.new()
	brick_hit_player.stream = BRICK_HIT_SOUND
	brick_hit_player.volume_db = -4.0
	add_child(brick_hit_player)
	paddle_hit_player = AudioStreamPlayer.new()
	paddle_hit_player.stream = PADDLE_HIT_SOUND
	paddle_hit_player.volume_db = -3.0
	add_child(paddle_hit_player)
	wall_hit_player = AudioStreamPlayer.new()
	wall_hit_player.stream = WALL_HIT_SOUND
	wall_hit_player.volume_db = -7.0
	add_child(wall_hit_player)
	piercing_player = AudioStreamPlayer.new()
	piercing_player.stream = PIERCING_SOUND
	piercing_player.volume_db = -6.0
	add_child(piercing_player)

func _play_brick_hit_sound():
	if is_instance_valid(brick_hit_player): brick_hit_player.play()
func _play_paddle_hit_sound():
	if is_instance_valid(paddle_hit_player): paddle_hit_player.play()
func _play_wall_hit_sound():
	if is_instance_valid(wall_hit_player): wall_hit_player.play()
func _play_piercing_sound():
	if piercing_sound_cooldown > 0.0: return
	if is_instance_valid(piercing_player):
		piercing_player.play()
		piercing_sound_cooldown = 0.08

func _draw():
	var pulse = 0.88 + 0.12 * sin(visual_time * 5.0)
	var accent = Color(0.20, 0.72, 1.0)
	var shell = Color(0.36, 0.82, 1.0)
	var energy = Color(0.72, 0.95, 1.0)
	var core = Color(1.0, 1.0, 1.0)
	var trail_accent = accent
	var trail_core = Color(accent, 0.0)
	var trail_length_scale = 1.0
	var trail_alpha_scale = 1.0
	if is_piercing:
		accent = Color(1.0, 0.78, 0.28); shell = Color(1.0, 0.91, 0.62); energy = Color(1.0, 0.97, 0.84); core = Color.WHITE
		trail_accent = Color(1.0, 0.69, 0.18); trail_core = Color(1.0, 0.99, 0.92); trail_length_scale = 1.75; trail_alpha_scale = 1.35
	if is_explosive:
		accent = Color(1.0, 0.18, 0.06); shell = Color(1.0, 0.42, 0.10); energy = Color(1.0, 0.76, 0.30); core = Color(1.0, 0.96, 0.82)
		trail_accent = accent; trail_core = Color(1.0, 0.66, 0.22); trail_length_scale = 1.35; trail_alpha_scale = 1.12
	if trail_points.size() >= 2:
		for i in range(trail_points.size() - 1):
			var local_a = to_local(trail_points[i]); var local_b = to_local(trail_points[i + 1]); var segment = local_b - local_a; local_a = local_b - segment * trail_length_scale
			var t = float(i + 1) / float(trail_points.size()); var alpha = lerp(0.015, 0.25, t) * trail_alpha_scale; var width = lerp(0.8, 3.8, t)
			draw_line(local_a, local_b, Color(trail_accent, alpha), width, true)
			if is_piercing: draw_line(local_a, local_b, Color(trail_core, alpha * 0.88), max(0.8, width * 0.46), true)
			elif is_explosive: draw_line(local_a, local_b, Color(trail_core, alpha * 0.34), max(0.6, width * 0.28), true)
	if is_attached:
		var current_aim_length := aim_line_length
		if magnet_captured:
			var magnet_aim_level := SaveManager.get_magnet_aim_level()
			if magnet_aim_level <= 0:
				current_aim_length = 0.0
			elif magnet_aim_level == 1:
				current_aim_length = MAGNET_SHORT_AIM_LENGTH
		if current_aim_length > 0.0:
			var aim_angle = deg_to_rad(launch_aim_angle); var aim_direction = Vector2(sin(aim_angle), -cos(aim_angle)).normalized(); var aim_start_distance = radius + 8.0
			var dash_length = 13.0; var gap_length = 17.0; var aim_alpha = 0.22 + 0.04 * sin(visual_time * 4.0); var distance = aim_start_distance
			while distance < current_aim_length:
				var segment_end = min(distance + dash_length, current_aim_length); var fade = 1.0 - 0.55 * (distance / current_aim_length); var dash_start = aim_direction * distance; var dash_end = aim_direction * segment_end
				draw_line(dash_start, dash_end, Color(0.12, 0.66, 1.0, 0.055 * fade), 4.0, true); draw_line(dash_start, dash_end, Color(0.72, 0.95, 1.0, aim_alpha * fade), 1.0, true); distance += dash_length + gap_length
	draw_circle(Vector2.ZERO, radius + 9.0, Color(accent, 0.045 * pulse)); draw_circle(Vector2.ZERO, radius + 5.0, Color(accent, 0.10 * pulse)); draw_circle(Vector2.ZERO, radius + 2.0, Color(shell, 0.18))
	draw_circle(Vector2.ZERO, radius, Color(0.008, 0.025, 0.045, 0.96)); draw_circle(Vector2.ZERO, radius - 1.2, Color(shell, 0.34)); draw_circle(Vector2(1.2, 1.6), radius - 3.0, Color(0.015, 0.10, 0.16, 0.58))
	draw_circle(Vector2.ZERO, radius * 0.53, Color(energy, 0.22 * pulse)); draw_circle(Vector2.ZERO, radius * 0.35, Color(energy, 0.62)); draw_circle(Vector2.ZERO, radius * 0.19, core)
	draw_arc(Vector2.ZERO, radius - 1.0, deg_to_rad(205.0), deg_to_rad(335.0), 20, Color(accent, 0.68), 1.25, true); draw_arc(Vector2.ZERO, radius - 2.0, deg_to_rad(25.0), deg_to_rad(112.0), 16, Color(1.0, 1.0, 1.0, 0.72), 1.05, true)
	draw_circle(Vector2(-3.7, -4.1), 1.7, Color(1.0, 1.0, 1.0, 0.92)); draw_circle(Vector2(-5.1, -5.4), 0.75, Color(1.0, 1.0, 1.0, 0.72))
	if is_piercing:
		draw_circle(Vector2.ZERO, radius * 0.78, Color(1.0, 0.98, 0.88, 0.18 * pulse)); draw_circle(Vector2.ZERO, radius * 0.58, Color(1.0, 1.0, 1.0, 0.13 * pulse))
		for side in [-1.0, 1.0]:
			var x = side * (radius + 2.5); draw_line(Vector2(x, -4.5), Vector2(x, 4.5), Color(accent, 0.68 * pulse), 1.5, true)
		draw_line(Vector2(-radius - 4.0, 0.0), Vector2(radius + 4.0, 0.0), Color(1.0, 0.99, 0.90, 0.58 * pulse), 1.2, true)
	if is_explosive:
		for i in range(4):
			var angle = visual_time * 1.8 + TAU * float(i) / 4.0; var p1 = Vector2(cos(angle), sin(angle)) * (radius + 1.5); var p2 = Vector2(cos(angle), sin(angle)) * (radius + 5.0 + 1.5 * pulse); draw_line(p1, p2, Color(accent, 0.68), 1.4, true)

func _physics_process(delta):
	piercing_sound_cooldown = max(piercing_sound_cooldown - delta, 0.0); visual_time += delta
	if is_attached:
		var paddle = get_parent().get_node("Paddle"); var movement = paddle.velocity.x
		if abs(movement) > 20.0:
			launch_aim_angle += sign(movement) * aim_turn_speed * delta; launch_aim_angle = clamp(launch_aim_angle, -max_bounce_angle, max_bounce_angle)
		global_position.x = paddle.global_position.x + attached_offset_x; global_position.y = paddle.global_position.y - 40; _update_trail(true); return
	if shield_active and direction.y > 0.0 and global_position.y + radius >= shield_y:
		_play_paddle_hit_sound(); global_position.y = shield_y - radius; direction.y = -abs(direction.y); _prevent_horizontal_lock()
		if SaveManager.has_shield_return_boost(): shield_return_boost_active = true
	var movement_speed := speed * (SHIELD_RETURN_SPEED_MULTIPLIER if shield_return_boost_active else 1.0)
	var collision = move_and_collide(direction * movement_speed * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.name == "Paddle":
			_play_paddle_hit_sound()
			if collider.has_method("play_hit_feedback"): collider.play_hit_feedback()
			if magnet_active: attach_to_paddle(true)
			else: bounce_from_paddle(collider)
		elif collider.has_method("hit"):
			shield_return_boost_active = false
			var can_pierce := is_piercing and (not collider.indestructible or SaveManager.has_piercing_wall_break())
			if can_pierce:
				_play_piercing_sound(); collider.destroy(_can_explosive_instant_destroy(collider))
			else:
				_play_brick_hit_sound(); direction = direction.bounce(collision.get_normal()); _prevent_horizontal_lock()
				if _can_explosive_instant_destroy(collider): collider.destroy(true)
				else: collider.hit(false)
		else:
			_play_wall_hit_sound(); direction = direction.bounce(collision.get_normal()); _prevent_horizontal_lock()
	_update_trail(false)

func _can_explosive_instant_destroy(collider) -> bool:
	if not is_explosive: return false
	var explosive_power := SaveManager.get_explosive_power()
	if collider.indestructible: return explosive_power >= 3
	if collider.max_health >= 3: return explosive_power >= 2
	if collider.max_health == 2: return explosive_power >= 1
	return true

func _prevent_horizontal_lock():
	if abs(direction.y) >= min_vertical_direction: return
	var vertical_sign = sign(direction.y)
	if vertical_sign == 0.0: vertical_sign = -1.0
	direction.y = min_vertical_direction * vertical_sign; direction = direction.normalized()

func _update_trail(reset_trail: bool):
	if reset_trail:
		trail_points.clear(); trail_points.append(global_position); queue_redraw(); return
	if trail_points.is_empty() or trail_points.back().distance_to(global_position) >= trail_min_distance: trail_points.append(global_position)
	while trail_points.size() > trail_max_points: trail_points.pop_front()
	queue_redraw()

func bounce_from_paddle(paddle):
	var offset = global_position.x - paddle.global_position.x; var half_width = paddle.width / 2.0; var normalized_offset = clamp(offset / half_width, -1.0, 1.0); var angle = deg_to_rad(normalized_offset * max_bounce_angle)
	direction = Vector2(sin(angle), -cos(angle)).normalized(); _prevent_horizontal_lock(); is_attached = false; magnet_captured = false

func attach_to_paddle(from_magnet: bool = false):
	is_attached = true; magnet_captured = from_magnet; shield_return_boost_active = false
	var paddle = get_parent().get_node("Paddle")
	attached_offset_x = global_position.x - paddle.global_position.x; global_position.y = paddle.global_position.y - 40; _update_trail(true); queue_redraw()

func launch():
	is_attached = false; magnet_captured = false; shield_return_boost_active = false; trail_points.clear(); trail_points.append(global_position)
	var aim_angle = deg_to_rad(launch_aim_angle); direction = Vector2(sin(aim_angle), -cos(aim_angle)).normalized(); _prevent_horizontal_lock(); queue_redraw()
