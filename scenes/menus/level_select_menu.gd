class_name LevelSelectMenu
extends Control

# Doritos
#  Determine Number of adjacent lines
# Numbers
#  Determine Number of enclosed Cells in Loop
# Suits
#  Distinct suit symbols are not allowed to be contained within the same loop
# Coloring Previous Symbols
#  The previous symbols must be satisfied by the correct color of loop
#  Secondary colors ( combinations of primary ) must be satisfied by each color of loop *independently*
#  Black does not see the color of the lines ( so can be satisfied by "composite" loops of multiple colors

var completion_data = []

signal LevelComplete(path)
signal Reset(bool)

func _ready() -> void:
	if not FileAccess.file_exists("user://completion.json"):
		var completion_file = FileAccess.open("user://completion.json", FileAccess.WRITE)
		completion_file.store_string("[]")
	else:
		completion_data = JSON.parse_string(FileAccess.get_file_as_string("user://completion.json"))
	for path in completion_data:
		#print(path)
		LevelComplete.emit(path)

func _input(_ev):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func _return_from_puzzle():
	get_node("LevelSelectCanvasLayer").show()
	for child in get_node("LevelCanvasLayer").get_children():
		if is_instance_valid(child):
			child.queue_free()

func _level_completed(path):
	completion_data.append(path)
	LevelComplete.emit(path)
	var completion_file = FileAccess.open("user://completion.json", FileAccess.WRITE)
	completion_file.store_string(JSON.stringify(completion_data))


func _on_reset_completion_button_pressed() -> void:
	%ConfirmationPopup.show()
	


func _on_accept_button_pressed() -> void:
	Reset.emit(true)
	%ConfirmationPopup.hide()


func _on_deny_button_pressed() -> void:
	Reset.emit(false)
	%ConfirmationPopup.hide()



func _on_reset(answer: bool) -> void:
	if answer:
		completion_data = []
		var completion_file = FileAccess.open("user://completion.json", FileAccess.WRITE)
		completion_file.store_string("[]")
