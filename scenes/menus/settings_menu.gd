extends Control

@onready var main_volume = %MainVolumeSlider #$PanelContainer/ScrollContainer/MarginContainer/SettingsContainer/VolumeContainer/VolumeSettingsControlContainer/MainVolumeControlContainer/MarginContainer/HSplitContainer/MainVolumeSlider
@onready var music_volume = %MusicVolumeSlider #$PanelContainer/ScrollContainer/MarginContainer/SettingsContainer/VolumeContainer/VolumeSettingsControlContainer/MusicVolumeControlContainer/MarginContainer/MusicVolumeSlider
@onready var sfx_volume = %SFXVolumeSlider #$PanelContainer/ScrollContainer/MarginContainer/SettingsContainer/VolumeContainer/VolumeSettingsControlContainer/SFXVolumeControlContainer/MarginContainer/SFXSlider
@onready var color_blind_setting = %ColorBlindModeSelection #$PanelContainer/ScrollContainer/MarginContainer/SettingsContainer/HSplitContainer2/AccessibilityControlsContainer/Button

var main_bus_index = AudioServer.get_bus_index("Master")
var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")

var settings_data: Dictionary = TOML.parse("res://player_data/settings.toml")
var settings_changed: bool = false

func _ready() -> void:
	settings_data = TOML.parse("res://player_data/settings.toml")
	
	main_volume.value = settings_data["volume"]["main"]
	music_volume.value = settings_data["volume"]["music"]
	sfx_volume.value = settings_data["volume"]["sfx"]
	
	color_blind_setting.select(settings_data["accessibility"]["color_blind"])
	
func _input(_ev):
	if Input.is_key_pressed(KEY_ESCAPE):
		if settings_changed:
			print("Dumping Settings TOML")
			TOML.dump("user://player_data/settings.toml", settings_data)
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func _on_back_button_pressed() -> void:
	%ClickAudio.play()
	if settings_changed:
		print("Dumping Settings TOML")
		TOML.dump("user://player_data/settings.toml", settings_data)
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")


func _on_button_item_selected(index: int) -> void:
	#print("Changed Color Blind Setting")
	settings_changed = true
	settings_data["accessibility"]["color_blind"] = index
	%ClickAudio.play()

func _on_main_volume_slider_value_changed(value: float) -> void:
	settings_changed = true
	AudioServer.set_bus_volume_linear(main_bus_index,value)
	settings_data["volume"]["main"] = value
	%ClickAudio.play()

func _on_music_volume_slider_value_changed(value: float) -> void:
	settings_changed = true
	AudioServer.set_bus_volume_linear(music_bus_index,value)
	settings_data["volume"]["music"] = value
	%ClickAudio.play()

func _on_sfx_slider_value_changed(value: float) -> void:
	settings_changed = true
	AudioServer.set_bus_volume_linear(sfx_bus_index,value)
	settings_data["volume"]["sfx"] = value
	%ClickAudio.play()


func _on_reset_button_pressed() -> void:
	settings_data["volume"]["main"] = 0.3
	settings_data["volume"]["music"] = 0.3
	settings_data["volume"]["sfx"] = 0.3
	settings_data["accessibility"]["color_blind"] = 0
	main_volume.value = settings_data["volume"]["main"]
	music_volume.value = settings_data["volume"]["music"]
	sfx_volume.value = settings_data["volume"]["sfx"]
	color_blind_setting.select(settings_data["accessibility"]["color_blind"])
	settings_changed = true
	%ClickAudio.play()
