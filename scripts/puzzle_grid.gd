extends GridContainer
@warning_ignore("integer_division")

var puzzle_array: Array
var puzzle_vertex = preload("res://scenes/objects/PuzzleVertex.tscn")
var puzzle_line = preload("res://scenes/objects/PuzzleLine.tscn")
var puzzle_rule = preload("res://scenes/objects/PuzzleRule.tscn")

var puzzle_width: int
var puzzle_height: int

func _enter_tree():
	_create_grid(7,7)

func _create_grid(_width: int, _height: int):
	puzzle_width = _width
	puzzle_height = _height
	print("Making Puzzle")
	
	puzzle_array = Array()
	columns = (_width * 2) + 1
	var rows: int = (_height * 2) + 1
	puzzle_array.resize(columns * rows)
	
	for i in puzzle_array.size():
		if i % 2 == 1:
			var line_node = puzzle_line.instantiate()
			add_child(line_node)
			puzzle_array[i] = line_node
			if (i / columns) % 2 == 1:
				(line_node.get_node("Rotation") as Node2D).rotate(deg_to_rad(90))
		elif (i / ((_width * 2) + 1)) % 2 == 0:
			var vert_node = puzzle_vertex.instantiate()
			add_child(vert_node)
			puzzle_array[i] = vert_node
		else:
			var rule_node = puzzle_rule.instantiate()
			add_child(rule_node)
			puzzle_array[i] = rule_node
	get_parent()._zoom_camera(_width, _height)
				
