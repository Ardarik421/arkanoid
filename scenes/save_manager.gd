extends Node

const SAVE_PATH: String = "user://progress.save"

var highest_unlocked_level: int = 1

func _ready():
	load_progress()
	print("Загружен прогресс. Последний открытый уровень: ", highest_unlocked_level)

func save_progress():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		return

	var data = {
		"highest_unlocked_level": highest_unlocked_level
	}

	file.store_string(JSON.stringify(data))

func load_progress():
	if not FileAccess.file_exists(SAVE_PATH):
		highest_unlocked_level = 1
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		highest_unlocked_level = 1
		return

	var data = JSON.parse_string(file.get_as_text())

	if not data is Dictionary:
		highest_unlocked_level = 1
		return

	highest_unlocked_level = max(
		int(data.get("highest_unlocked_level", 1)),
		1
	)

func unlock_level(level: int):
	if level <= highest_unlocked_level:
		return

	highest_unlocked_level = level
	save_progress()

func reset_progress():
	highest_unlocked_level = 1
	save_progress()
