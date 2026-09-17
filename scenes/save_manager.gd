extends Node

const SAVE_PATH: String = "user://progress.save"
const SKILL_COST: int = 5
const MAX_DURATION_RANK: int = 5

var highest_unlocked_level: int = 1
var highest_completed_level: int = 0
var selected_level: int = 1
var skill_points: int = 0

var piercing_gameplay: int = 0
var piercing_duration: int = 0
var explosive_gameplay: int = 0
var explosive_duration: int = 0
var shield_gameplay: int = 0
var shield_duration: int = 0
var magnet_gameplay: int = 0
var magnet_duration: int = 0

func _ready():
	load_progress()
	selected_level = highest_unlocked_level

func save_progress():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		return

	var data = {
		"highest_unlocked_level": highest_unlocked_level,
		"highest_completed_level": highest_completed_level,
		"skill_points": skill_points,
		"piercing_gameplay": piercing_gameplay,
		"piercing_duration": piercing_duration,
		"explosive_gameplay": explosive_gameplay,
		"explosive_duration": explosive_duration,
		"shield_gameplay": shield_gameplay,
		"shield_duration": shield_duration,
		"magnet_gameplay": magnet_gameplay,
		"magnet_duration": magnet_duration
	}

	file.store_string(JSON.stringify(data))

func load_progress():
	_reset_progress_values()

	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		return

	var data = JSON.parse_string(file.get_as_text())

	if not data is Dictionary:
		return

	highest_unlocked_level = max(int(data.get("highest_unlocked_level", 1)), 1)

	# Saves created before skill progression only contain highest_unlocked_level.
	# Treat every level before it as completed and grant the SP that would have
	# been earned by progressing normally.
	var is_legacy_save := not data.has("highest_completed_level")
	if is_legacy_save:
		highest_completed_level = max(highest_unlocked_level - 1, 0)
		skill_points = highest_completed_level
	else:
		highest_completed_level = max(int(data.get("highest_completed_level", 0)), 0)
		skill_points = max(int(data.get("skill_points", 0)), 0)

	piercing_gameplay = clampi(int(data.get("piercing_gameplay", 0)), 0, 1)
	piercing_duration = clampi(int(data.get("piercing_duration", 0)), 0, MAX_DURATION_RANK)
	explosive_gameplay = clampi(int(data.get("explosive_gameplay", 0)), 0, 3)
	explosive_duration = clampi(int(data.get("explosive_duration", 0)), 0, MAX_DURATION_RANK)
	shield_gameplay = clampi(int(data.get("shield_gameplay", 0)), 0, 1)
	shield_duration = clampi(int(data.get("shield_duration", 0)), 0, MAX_DURATION_RANK)
	magnet_gameplay = clampi(int(data.get("magnet_gameplay", 0)), 0, 2)
	magnet_duration = clampi(int(data.get("magnet_duration", 0)), 0, MAX_DURATION_RANK)

	if is_legacy_save:
		save_progress()

func complete_level(level: int) -> bool:
	if level <= highest_completed_level:
		return false

	highest_completed_level = level
	skill_points += 1
	save_progress()
	return true

func unlock_level(level: int):
	if level <= highest_unlocked_level:
		return

	highest_unlocked_level = level
	save_progress()

func can_afford_skill() -> bool:
	return skill_points >= SKILL_COST

func purchase_piercing_gameplay() -> bool:
	return _purchase_rank("piercing_gameplay", 1)

func purchase_piercing_duration() -> bool:
	if piercing_gameplay < 1:
		return false
	return _purchase_rank("piercing_duration", MAX_DURATION_RANK)

func purchase_explosive_gameplay() -> bool:
	return _purchase_rank("explosive_gameplay", 3)

func purchase_explosive_duration() -> bool:
	if explosive_gameplay < 3:
		return false
	return _purchase_rank("explosive_duration", MAX_DURATION_RANK)

func purchase_shield_gameplay() -> bool:
	return _purchase_rank("shield_gameplay", 1)

func purchase_shield_duration() -> bool:
	if shield_gameplay < 1:
		return false
	return _purchase_rank("shield_duration", MAX_DURATION_RANK)

func purchase_magnet_gameplay() -> bool:
	return _purchase_rank("magnet_gameplay", 2)

func purchase_magnet_duration() -> bool:
	if magnet_gameplay < 2:
		return false
	return _purchase_rank("magnet_duration", MAX_DURATION_RANK)

func get_piercing_duration(base_duration: float) -> float:
	return base_duration + piercing_duration * 0.5

func get_explosive_duration(base_duration: float) -> float:
	return base_duration + explosive_duration * 0.5

func get_shield_duration(base_duration: float) -> float:
	return base_duration + shield_duration * 0.5

func get_magnet_duration(base_duration: float) -> float:
	return base_duration + magnet_duration * 0.5

func has_piercing_wall_break() -> bool:
	return piercing_gameplay >= 1

func get_explosive_power() -> int:
	return explosive_gameplay

func has_shield_return_boost() -> bool:
	return shield_gameplay >= 1

func get_magnet_aim_level() -> int:
	return magnet_gameplay

func reset_progress():
	_reset_progress_values()
	selected_level = 1
	save_progress()

func _purchase_rank(property_name: StringName, max_rank: int) -> bool:
	var current_rank := int(get(property_name))
	if current_rank >= max_rank or skill_points < SKILL_COST:
		return false

	set(property_name, current_rank + 1)
	skill_points -= SKILL_COST
	save_progress()
	return true

func _reset_progress_values():
	highest_unlocked_level = 1
	highest_completed_level = 0
	skill_points = 0
	piercing_gameplay = 0
	piercing_duration = 0
	explosive_gameplay = 0
	explosive_duration = 0
	shield_gameplay = 0
	shield_duration = 0
	magnet_gameplay = 0
	magnet_duration = 0
