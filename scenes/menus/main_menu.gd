extends Control

var settings_data = JSON.new()

var main_bus_index = AudioServer.get_bus_index("Master")
var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	
	var error = settings_data.parse(FileAccess.get_file_as_string("user://settings.json"))
	if error == OK:
		settings_data = settings_data.get_data()
	
	
		AudioServer.set_bus_volume_linear(main_bus_index,settings_data["main_volume"])
		AudioServer.set_bus_volume_linear(music_bus_index,settings_data["music_volume"]) 
		AudioServer.set_bus_volume_linear(sfx_bus_index,settings_data["sfx_volume"]) 
	
	#color_blind_setting.select(settings_data["accessibility"]["color_blind"])

func _on_level_select_button_pressed() -> void:
	%ClickAudio.play()
	get_tree().change_scene_to_file("res://scenes/menus/level_select_menu.tscn")

func _on_settings_button_pressed() -> void:
	%ClickAudio.play()
	get_tree().change_scene_to_file("res://scenes/menus/settings_menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
