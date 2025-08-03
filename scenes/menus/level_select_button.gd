#class_name LevelSelectButton
extends Button

@export var level_path: String = "res://level_data/testing_level.json"

var level_data: JSON = JSON.new()

func _ready() -> void:
	#print("Trying to Connect")
	get_node("../../../../LevelSelectMenu").connect("LevelComplete", _is_completed)
	get_node("../../../../LevelSelectMenu").connect("Reset", _is_reset)

func _on_pressed() -> void:
	var puzzle_scene = load("res://scenes/levels/main_puzzle_scene.tscn").instantiate()
	var error = level_data.parse(FileAccess.get_file_as_string(level_path))
	if error == OK:
		#color_count = 2
		#_create_grid(7,7)
		puzzle_scene.get_node("PuzzleGrid")._accept_level_data(level_data.data)
		get_node("../../../LevelSelectCanvasLayer").hide()
		get_node("../../../LevelCanvasLayer").add_child(puzzle_scene)
		#process_mode = Node.PROCESS_MODE_DISABLED
	else:
		print("Couldn't load JSON")
	%ClickAudio.play()

func _is_completed(path: String) -> void:
	#print("Entered _is_completed")
	if path == level_path:
		set("theme_override_colors/font_color",Color.GREEN)

func _is_reset(answer: bool) -> void:
	if answer:
		set("theme_override_colors/font_color",Color(1,1,1,0.9))
