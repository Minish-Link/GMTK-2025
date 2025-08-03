extends Control
var default_settings: Dictionary = {
	"main_volume": 0.3,
	"music_volume": 0.3,
	"sfx_volume": 0.3,
	"color_blind": 0
}
var settings_data = default_settings

var main_bus_index = AudioServer.get_bus_index("Master")
var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	if not FileAccess.file_exists("user://settings.json"):
		var settings_file = FileAccess.open("user://settings.json", FileAccess.WRITE)
		settings_file.store_string(JSON.stringify(settings_data))
	else:
		settings_data = JSON.parse_string(FileAccess.get_file_as_string("user://settings.json"))
	
	
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
