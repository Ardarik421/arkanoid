extends Node

const SETTINGS_PATH := "user://settings.cfg"

var music_enabled: bool = true
var sounds_enabled: bool = true
var keyboard_sensitivity: float = 1.0
var mouse_sensitivity: float = 1.0
var gamepad_sensitivity: float = 1.0

var _scan_timer: float = 0.0

func _ready():
	_ensure_audio_bus("Music")
	_ensure_audio_bus("SFX")
	load_settings()
	apply_audio_settings()

func _process(delta):
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = 0.25
		_route_audio_players(get_tree().root)
		_apply_paddle_settings()

func _ensure_audio_bus(bus_name: String):
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

func apply_audio_settings():
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if music_bus != -1:
		AudioServer.set_bus_mute(music_bus, not music_enabled)
	if sfx_bus != -1:
		AudioServer.set_bus_mute(sfx_bus, not sounds_enabled)

func _route_audio_players(node: Node):
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
		var stream = node.stream
		if stream != null:
			var path = stream.resource_path
			if path.begins_with("res://audio/music/"):
				node.bus = "Music"
			elif path.begins_with("res://audio/sfx/"):
				node.bus = "SFX"

	for child in node.get_children():
		_route_audio_players(child)

func _apply_paddle_settings():
	var paddle = get_tree().root.find_child("Paddle", true, false)
	if paddle == null:
		return

	if not paddle.has_meta("base_keyboard_speed"):
		paddle.set_meta("base_keyboard_speed", paddle.speed)
	if not paddle.has_meta("base_mouse_speed"):
		paddle.set_meta("base_mouse_speed", paddle.mouse_speed)

	var keyboard_input = abs(Input.get_axis("move_left", "move_right"))
	var gamepad_input = abs(Input.get_joy_axis(0, JOY_AXIS_LEFT_X)) if Input.get_connected_joypads().size() > 0 else 0.0
	var input_multiplier = gamepad_sensitivity if gamepad_input > keyboard_input else keyboard_sensitivity

	paddle.speed = float(paddle.get_meta("base_keyboard_speed")) * input_multiplier
	paddle.mouse_speed = float(paddle.get_meta("base_mouse_speed")) * mouse_sensitivity

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_enabled", music_enabled)
	config.set_value("audio", "sounds_enabled", sounds_enabled)
	config.set_value("controls", "keyboard_sensitivity", keyboard_sensitivity)
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("controls", "gamepad_sensitivity", gamepad_sensitivity)
	config.save(SETTINGS_PATH)
	apply_audio_settings()

func load_settings():
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return

	music_enabled = bool(config.get_value("audio", "music_enabled", true))
	sounds_enabled = bool(config.get_value("audio", "sounds_enabled", true))
	keyboard_sensitivity = float(config.get_value("controls", "keyboard_sensitivity", 1.0))
	mouse_sensitivity = float(config.get_value("controls", "mouse_sensitivity", 1.0))
	gamepad_sensitivity = float(config.get_value("controls", "gamepad_sensitivity", 1.0))
