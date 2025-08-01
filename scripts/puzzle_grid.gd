class_name PuzzleGrid
extends Control

@export var container: GridContainer

var puzzle_array: Array
var puzzle_vertex = preload("res://scenes/objects/PuzzleVertex.tscn")
var puzzle_line = preload("res://scenes/objects/PuzzleLine.tscn")
var puzzle_rule = preload("res://scenes/objects/PuzzleRule.tscn")

var puzzle_width: int
var puzzle_height: int
var right_boundary: int
var bottom_boundary: int
var array_width: int
var array_height: int

func _init() -> void:
	pass

func _enter_tree():
	_create_grid(2,2)

func _accept_level_data(_data: Dictionary):
	pass

func _create_grid(_width: int, _height: int):
	puzzle_width = _width
	puzzle_height = _height
	right_boundary = puzzle_width * 2
	array_width = right_boundary + 1
	bottom_boundary = array_width * 2 * puzzle_height
	array_height = (puzzle_height * 2) + 1
	print("Making Puzzle")
	
	puzzle_array = Array()
	var columns = (_width * 2) + 1
	var rows: int = (_height * 2) + 1
	puzzle_array.resize(columns * rows)
	
	container.columns = columns
	
	for i in puzzle_array.size():
		if i % 2 == 1:
			var line_node = puzzle_line.instantiate()
			container.add_child(line_node)
			puzzle_array[i] = line_node
			@warning_ignore("integer_division")
			if (i / columns) % 2 == 1:
				(line_node.get_node("Rotation") as Node2D).rotate(deg_to_rad(90))
		elif (i / ((_width * 2) + 1)) % 2 == 0:
			var vert_node = puzzle_vertex.instantiate()
			container.add_child(vert_node)
			puzzle_array[i] = vert_node
		else:
			var rule_node = puzzle_rule.instantiate()
			#(rule_node as PuzzleRule)._set_rule("",0)
			(rule_node as PuzzleRule)._set_grid_xy(0,0)
			container.add_child(rule_node)
			puzzle_array[i] = rule_node
	get_node("Camera")._zoom_camera(_width, _height)

func _check_loops() -> bool:
	var _at_least_one_loop: bool = false
	for x in range(0, array_width, 2):
		for y in range(0,puzzle_array.size(),array_width * 2):
			var _count: int = _get_neighboring_line_count(x,y)
			if _count > 0:
				_at_least_one_loop = true
			if (_count != 2 and _count != 0):
				print("Sploosh...")
				return false
	if (_at_least_one_loop):
		print("Kaboom!")
		return true
	else:
		print("Sploosh...")
		return false

func _get_neighboring_line_count(_x: int, _y: int, _color: int = 0) -> int:
	var _count: int = 0
	if (_color == 0):
		if (_x > 0 and puzzle_array[_x+_y-1].get_node("Rotation/Button")._get_state() == 2):
			_count += 1
		if (_x < right_boundary and puzzle_array[_x+_y+1].get_node("Rotation/Button")._get_state() == 2):
			_count += 1
		if (_y > 0 and puzzle_array[_x+_y - array_width].get_node("Rotation/Button")._get_state() == 2):
			_count += 1
		if (_y < bottom_boundary and puzzle_array[_x+_y + array_width].get_node("Rotation/Button")._get_state() == 2):
			_count += 1
	else:
		if (_x > 0 and puzzle_array[_x+_y-1].get_node("Rotation/Button")._get_state() == _color):
			_count += 1
		if (_x < right_boundary and puzzle_array[_x+_y+1].get_node("Rotation/Button")._get_state() == _color):
			_count += 1
		if (_y > 0 and puzzle_array[_x+_y - array_width].get_node("Rotation/Button")._get_state() == _color):
			_count += 1
		if (_y < bottom_boundary and puzzle_array[_x+_y + array_width].get_node("Rotation/Button")._get_state() == _color):
			_count += 1
	return _count

func _get_region(_x: int, _y: int) -> Array:
	var _region = Array()
	return _region
