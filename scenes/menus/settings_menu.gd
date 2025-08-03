extends Control

@onready var main_volume = %MainVolumeSlider #$PanelContainer/ScrollContainer/MarginContainer/SettingsContainer/VolumeContainer/VolumeSettingsControlContainer/MainVolumeControlContainer/MarginContainer/HSplitContainer/MainVolumeSlider
@onready var music_volume = %MusicVolumeSlider #$PanelContainer/ScrollContainer/MarginContainer/SettingsContainer/VolumeContainer/VolumeSettingsControlContainer/MusicVolumeControlContainer/MarginContainer/MusicVolumeSlider
@onready var sfx_volume = %SFXVolumeSlider #$PanelContainer/ScrollContainer/MarginContainer/SettingsContainer/VolumeContainer/VolumeSettingsControlContainer/SFXVolumeControlContainer/MarginContainer/SFXSlider
@onready var color_blind_setting = %ColorBlindModeSelection #$PanelContainer/ScrollContainer/MarginContainer/SettingsContainer/HSplitContainer2/AccessibilityControlsContainer/Button

var main_bus_index = AudioServer.get_bus_index("Master")
var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")

var settings_data = JSON.new()
var settings_changed: bool = false

func _ready() -> void:
	var error = settings_data.parse(FileAccess.get_file_as_string("user://settings.json"))
	if error == OK:
		settings_data = settings_data.get_data()
		main_volume.value = settings_data["main_volume"]
		music_volume.value = settings_data["music_volume"]
		sfx_volume.value = settings_data["sfx_volume"]
		
		color_blind_setting.select(settings_data["color_blind"])
	else:
		#settings_data = {}
		_on_reset_button_pressed()
	
func _input(_ev):
	if Input.is_key_pressed(KEY_ESCAPE):
		if settings_changed:
			var settings_file = FileAccess.open("user://settings.json", FileAccess.WRITE)
			settings_file.store_string(JSON.stringify(settings_data))
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func _on_back_button_pressed() -> void:
	%ClickAudio.play()
	if settings_changed:
		var settings_file = FileAccess.open("user://settings.json", FileAccess.WRITE)
		settings_file.store_string(JSON.stringify(settings_data))
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")


func _on_button_item_selected(index: int) -> void:
	#print("Changed Color Blind Setting")
	settings_changed = true
	settings_data["color_blind"] = index
	%ClickAudio.play()

func _on_main_volume_slider_value_changed(value: float) -> void:
	settings_changed = true
	AudioServer.set_bus_volume_linear(main_bus_index,value)
	settings_data["main_volume"] = value
	%ClickAudio.play()

func _on_music_volume_slider_value_changed(value: float) -> void:
	settings_changed = true
	AudioServer.set_bus_volume_linear(music_bus_index,value)
	settings_data["music_volume"] = value
	%ClickAudio.play()

func _on_sfx_slider_value_changed(value: float) -> void:
	settings_changed = true
	AudioServer.set_bus_volume_linear(sfx_bus_index,value)
	settings_data["sfx_volume"] = value
	%ClickAudio.play()


func _on_reset_button_pressed() -> void:
	settings_data["main_volume"] = 0.3
	settings_data["music_volume"] = 0.3
	settings_data["sfx_volume"] = 0.3
	settings_data["color_blind"] = 0
	main_volume.value = settings_data["main_volume"]
	music_volume.value = settings_data["music_volume"]
	sfx_volume.value = settings_data["sfx_volume"]
	color_blind_setting.select(settings_data["color_blind"])
	settings_changed = true
	%ClickAudio.play()
