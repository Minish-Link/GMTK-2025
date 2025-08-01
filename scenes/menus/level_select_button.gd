extends Button

var level_id: int = 0

var level_data: Dictionary = {}

func _on_pressed() -> void:
	level_data = TOML.parse("res://level_data/level" + str(level_id) + ".toml")
	var puzzle_scene = load("res://scenes/levels/main_puzzle_scene.tscn").instantiate()
	puzzle_scene._accept_level_data(level_data)
	get_node("../../LevelCanvasLayer").add_child(puzzle_scene)
	process_mode = Node.PROCESS_MODE_DISABLED
	
