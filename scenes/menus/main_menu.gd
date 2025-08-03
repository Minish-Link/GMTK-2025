extends Control

func _ready() -> void:
	var main_bus_index = AudioServer.get_bus_index("Master")
	var music_bus_index = AudioServer.get_bus_index("Music")
	var sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	var settings_data = TOML.parse("res://player_data/settings.toml")
	
	
	AudioServer.set_bus_volume_linear(main_bus_index,settings_data["volume"]["main"])
	AudioServer.set_bus_volume_linear(music_bus_index,settings_data["volume"]["music"]) 
	AudioServer.set_bus_volume_linear(sfx_bus_index,settings_data["volume"]["sfx"]) 
	
	#color_blind_setting.select(settings_data["accessibility"]["color_blind"])

func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/level_select_menu.tscn")

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/settings_menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
