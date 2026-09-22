extends Node

const SETTINGS_PATH := "user://settings.cfg"

var music_enabled: bool = true
var sounds_enabled: bool = true
var tutorial_hints_enabled: bool = true
var seen_bonus_hints: Dictionary = {}
var keyboard_sensitivity: float = 1.0
var mouse_sensitivity: float = 1.0
var gamepad_sensitivity: float = 1.0
var display_mode: int = 0
var fullscreen_enabled: bool = false

var _scan_timer: float = 0.0

func _ready():
	_ensure_audio_bus("Music")
	_ensure_audio_bus("SFX")
	load_settings()
	apply_audio_settings()
	apply_display_settings()
	get_tree().node_added.connect(_on_node_added)

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

func _on_node_added(node: Node):
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
		_route_single_audio_player(node)

func _route_single_audio_player(player: Node):
	var stream = player.stream
	if stream == null:
		return
	var path = stream.resource_path
	if path.begins_with("res://audio/music/"):
		player.bus = "Music"
	elif path.begins_with("res://audio/sfx/"):
		player.bus = "SFX"

func _route_audio_players(node: Node):
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
		_route_single_audio_player(node)
	for child in node.get_children():
		_route_audio_players(child)

func _apply_paddle_settings():
	var paddle = get_tree().root.find_child("Paddle", true, false)
	if paddle == null:
		return

	if not paddle.has_meta("base_keyboard_speed"):
		paddle.set_meta("base_keyboard_speed", paddle.speed)

	var gamepad_input = 0.0
	if Input.get_connected_joypads().size() > 0:
		gamepad_input = abs(Input.get_joy_axis(Input.get_connected_joypads()[0], JOY_AXIS_LEFT_X))
	var input_multiplier = gamepad_sensitivity if gamepad_input > 0.05 else keyboard_sensitivity

	paddle.speed = float(paddle.get_meta("base_keyboard_speed")) * input_multiplier

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_enabled", music_enabled)
	config.set_value("audio", "sounds_enabled", sounds_enabled)
	config.set_value("tutorial", "hints_enabled", tutorial_hints_enabled)
	config.set_value("tutorial", "seen_bonus_hints", seen_bonus_hints)
	config.set_value("controls", "keyboard_sensitivity", keyboard_sensitivity)
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("controls", "gamepad_sensitivity", gamepad_sensitivity)
	config.set_value("display", "mode", display_mode)
	config.set_value("display", "fullscreen", fullscreen_enabled)
	config.save(SETTINGS_PATH)
	apply_audio_settings()

func load_settings():
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return

	music_enabled = bool(config.get_value("audio", "music_enabled", true))
	sounds_enabled = bool(config.get_value("audio", "sounds_enabled", true))
	tutorial_hints_enabled = bool(config.get_value("tutorial", "hints_enabled", true))
	seen_bonus_hints = config.get_value("tutorial", "seen_bonus_hints", {}) as Dictionary
	keyboard_sensitivity = float(config.get_value("controls", "keyboard_sensitivity", 1.0))
	mouse_sensitivity = float(config.get_value("controls", "mouse_sensitivity", 1.0))
	gamepad_sensitivity = float(config.get_value("controls", "gamepad_sensitivity", 1.0))
	display_mode = int(config.get_value("display", "mode", 0))
	fullscreen_enabled = bool(config.get_value("display", "fullscreen", false))

func apply_display_settings() -> void:
	var size := Vector2i(960, 1080) if display_mode == 0 else Vector2i(1280, 800)
	var window := get_window()
	# The selected mode is a real window/viewport size, not a virtual canvas
	# squeezed into the old portrait window.
	window.content_scale_size = Vector2i.ZERO
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	if fullscreen_enabled:
		window.mode = Window.MODE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
		window.size = size

func set_display_mode(mode: int) -> void:
	display_mode = clampi(mode, 0, 1)
	apply_display_settings()
	save_settings()

func set_fullscreen(enabled: bool) -> void:
	fullscreen_enabled = enabled
	apply_display_settings()
	save_settings()

func should_show_bonus_hint(bonus_type: int) -> bool:
	return tutorial_hints_enabled and not seen_bonus_hints.has(str(bonus_type))

func mark_bonus_hint_seen(bonus_type: int) -> void:
	seen_bonus_hints[str(bonus_type)] = true
	save_settings()
