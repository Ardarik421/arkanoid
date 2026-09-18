extends Node

const MENU_MUSIC: AudioStream = preload("res://audio/music/menu_theme.wav")
var menu_player: AudioStreamPlayer

func _ready() -> void:
	menu_player = AudioStreamPlayer.new()
	menu_player.stream = MENU_MUSIC
	menu_player.volume_db = -5.0
	menu_player.finished.connect(_on_menu_music_finished)
	add_child(menu_player)

func play_menu_music() -> void:
	if not SettingsManager.music_enabled:
		stop_menu_music()
		return
	if not menu_player.playing:
		menu_player.play()

func stop_menu_music() -> void:
	menu_player.stop()

func _on_menu_music_finished() -> void:
	if SettingsManager.music_enabled:
		menu_player.play()
