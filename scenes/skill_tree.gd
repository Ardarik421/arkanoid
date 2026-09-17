extends Control

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"

@onready var sp_label: Label = $Margin/VBox/Header/SPLabel
@onready var status_label: Label = $Margin/VBox/StatusLabel

func _ready():
	_setup_style()
	_refresh()
	$Margin/VBox/Branches/Piercing/Gameplay.grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_back_to_menu()

func _setup_style():
	$Margin/VBox/Title.add_theme_font_size_override("font_size", 42)
	$Margin/VBox/Title.add_theme_color_override("font_color", Color(0.82, 0.96, 1.0))
	sp_label.add_theme_font_size_override("font_size", 24)
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color(0.58, 0.78, 0.88))
	for branch in $Margin/VBox/Branches.get_children():
		branch.add_theme_constant_override("separation", 10)
		for child in branch.get_children():
			if child is Label:
				child.add_theme_font_size_override("font_size", 22)
			if child is Button:
				child.custom_minimum_size = Vector2(0, 56)
				child.add_theme_font_size_override("font_size", 17)
	$Margin/VBox/BackButton.custom_minimum_size = Vector2(0, 56)
	$Margin/VBox/BackButton.add_theme_font_size_override("font_size", 20)

func _refresh():
	sp_label.text = "SP: %d   |   Цена улучшения: %d SP" % [SaveManager.skill_points, SaveManager.SKILL_COST]
	_set_gameplay_button($Margin/VBox/Branches/Piercing/Gameplay, SaveManager.piercing_gameplay, 1, "Тёмные стены ×5")
	_set_duration_button($Margin/VBox/Branches/Piercing/Duration, SaveManager.piercing_duration, SaveManager.piercing_gameplay >= 1)

	_set_gameplay_button($Margin/VBox/Branches/Explosive/Gameplay, SaveManager.explosive_gameplay, 3, _explosive_text())
	_set_duration_button($Margin/VBox/Branches/Explosive/Duration, SaveManager.explosive_duration, SaveManager.explosive_gameplay >= 3)

	_set_gameplay_button($Margin/VBox/Branches/Shield/Gameplay, SaveManager.shield_gameplay, 1, "Возврат от щита ×2")
	_set_duration_button($Margin/VBox/Branches/Shield/Duration, SaveManager.shield_duration, SaveManager.shield_gameplay >= 1)

	_set_gameplay_button($Margin/VBox/Branches/Magnet/Gameplay, SaveManager.magnet_gameplay, 2, _magnet_text())
	_set_duration_button($Margin/VBox/Branches/Magnet/Duration, SaveManager.magnet_duration, SaveManager.magnet_gameplay >= 2)

func _set_gameplay_button(button: Button, rank: int, max_rank: int, description: String):
	if rank >= max_rank:
		button.text = description + "   [MAX]"
		button.disabled = true
		return
	button.text = description + "   %d/%d   —   5 SP" % [rank, max_rank]
	button.disabled = not SaveManager.can_afford_skill()

func _set_duration_button(button: Button, rank: int, prerequisite_met: bool):
	var stars := ""
	for i in range(SaveManager.MAX_DURATION_RANK):
		stars += "★" if i < rank else "☆"
	if rank >= SaveManager.MAX_DURATION_RANK:
		button.text = "Длительность  %s   +%.1f сек   [MAX]" % [stars, rank * 0.5]
		button.disabled = true
		return
	button.text = "Длительность  %s   +%.1f сек   | след. +0.5 сек — 5 SP" % [stars, rank * 0.5]
	button.disabled = not prerequisite_met or not SaveManager.can_afford_skill()

func _explosive_text() -> String:
	match SaveManager.explosive_gameplay:
		0: return "I  Мгновенно ×2"
		1: return "II  Мгновенно ×3"
		_: return "III  Мгновенно ×5"

func _magnet_text() -> String:
	if SaveManager.magnet_gameplay == 0:
		return "I  Короткий прицел"
	return "II  Дальний прицел"

func _purchase(callable: Callable, success_text: String):
	if callable.call():
		status_label.text = success_text
	else:
		status_label.text = "Улучшение сейчас недоступно."
	_refresh()

func _on_piercing_gameplay_pressed():
	_purchase(SaveManager.purchase_piercing_gameplay, "PIERCING улучшен.")
func _on_piercing_duration_pressed():
	_purchase(SaveManager.purchase_piercing_duration, "PIERCING: длительность увеличена.")
func _on_explosive_gameplay_pressed():
	_purchase(SaveManager.purchase_explosive_gameplay, "EXPLOSIVE улучшен.")
func _on_explosive_duration_pressed():
	_purchase(SaveManager.purchase_explosive_duration, "EXPLOSIVE: длительность увеличена.")
func _on_shield_gameplay_pressed():
	_purchase(SaveManager.purchase_shield_gameplay, "SHIELD улучшен.")
func _on_shield_duration_pressed():
	_purchase(SaveManager.purchase_shield_duration, "SHIELD: длительность увеличена.")
func _on_magnet_gameplay_pressed():
	_purchase(SaveManager.purchase_magnet_gameplay, "MAGNET улучшен.")
func _on_magnet_duration_pressed():
	_purchase(SaveManager.purchase_magnet_duration, "MAGNET: длительность увеличена.")

func _on_back_pressed():
	_back_to_menu()

func _back_to_menu():
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
