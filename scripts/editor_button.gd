extends Button

func _on_pressed() -> void:
	var _puzzle_scene = load("res://scenes/levels/level_editor.tscn").instantiate()
	get_node("../../LevelSelectCanvasLayer").hide()
	get_node("../../LevelCanvasLayer").add_child(_puzzle_scene)
	#%ClickAudio.play()
