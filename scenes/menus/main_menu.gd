extends Control

func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/level_select_menu.tscn")

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/settings_menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
