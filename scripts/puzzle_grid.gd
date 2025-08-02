class_name PuzzleGrid
extends Control

@export var container: GridContainer
@export var name_text: RichTextLabel
@export var description_text: RichTextLabel

var puzzle_array: Array
var rule_array: Array
var puzzle_vertex = preload("res://scenes/objects/PuzzleVertex.tscn")
var puzzle_line = preload("res://scenes/objects/PuzzleLine.tscn")
var puzzle_rule = preload("res://scenes/objects/PuzzleRule.tscn")

var puzzle_width: int
var puzzle_height: int
var right_boundary: int
var bottom_boundary: int
var array_width: int
var array_height: int

var color_count: int
var current_color: int

var next_level_id: int



func _input(event):
	if event.is_action_pressed("swap"):
		_swap_color()

func _swap_color():
	if color_count > 1:
		if current_color == 2:
			print("Switching to Blue")
			current_color = 3
		else:
			print("Switching to Red")
			current_color = 2

func _get_color() -> int:
	return current_color

func _accept_level_data(_data: Dictionary):
	print(_data)
	name_text.text = _data["name"]
	if ("description" in _data):
		description_text.text = _data["description"]
	else:
		description_text.text = ""
	color_count = _data["color_amount"]
	_create_grid(_data["width"], _data["height"])
	for _rule in _data["rules"]:
		(rule_array[_rule["x"] + (puzzle_width * _rule["y"])] as PuzzleRule)._set_rule(_rule["type"], _rule["color"], _rule["number"])


func _create_grid(_width: int, _height: int):
	current_color = 2
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
	rule_array.resize(_width * _height)
	
	container.columns = columns
	var _rule_count: int = 0
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
			(rule_node as PuzzleRule)._set_grid_xy((i % columns - 1) / 2, (i / columns - 1) / 2)
			container.add_child(rule_node)
			puzzle_array[i] = rule_node
			rule_array[_rule_count] = rule_node
			_rule_count += 1
	get_node("Camera")._zoom_camera(_width, _height)

func _check_loops() -> bool:
	var _at_least_one_loop: bool = false
	for x in range(0, array_width, 2):
		for y in range(0,puzzle_array.size(),array_width * 2):
			var _count_red: int = _get_neighboring_line_count(x,y, 2)
			var _count_blue: int = _get_neighboring_line_count(x,y,3)
			if not _at_least_one_loop and (_count_red > 0 or _count_blue > 0):
				_at_least_one_loop = true
			if (_count_red != 2 and _count_red != 0) or (_count_blue != 2 and _count_blue != 0):
				print("Sploosh...")
				return false
	if (_at_least_one_loop):
		print("Kaboom!")
		if _check_rule_nodes():
			print("Success!")
			return true
		else:
			print("Failure...")
			return false
	else:
		print("Sploosh...")
		return false

func _check_rule_nodes() -> bool:
	for i in rule_array.size():
		if (rule_array[i] as PuzzleRule)._check_if_valid() == false:
			return false
	return true

func _get_neighboring_line_count(_x: int, _y: int, _color: int) -> int:
	var _count: int = 0
	if (_x > 0 and puzzle_array[_x+_y-1].get_node("Rotation/Button")._get_state() == _color):
		_count += 1
	if (_x < right_boundary and puzzle_array[_x+_y+1].get_node("Rotation/Button")._get_state() == _color):
		_count += 1
	if (_y > 0 and puzzle_array[_x+_y - array_width].get_node("Rotation/Button")._get_state() == _color):
		_count += 1
	if (_y < bottom_boundary and puzzle_array[_x+_y + array_width].get_node("Rotation/Button")._get_state() == _color):
		_count += 1
	return _count

func _get_rule_index(_x: int, _y: int) -> int:
	return (_x * 2) + 1 + (array_width * ((_y * 2) + 1))

func _get_pip_count(_x: int, _y: int, _color: int) -> int:
	var _count: int = 0
	var _array_index: int = _get_rule_index(_x,_y)
	if (puzzle_array[_array_index - 1].get_node("Rotation/Button")._get_state() == _color):
		_count += 1
	if (puzzle_array[_array_index + 1].get_node("Rotation/Button")._get_state() == _color):
		_count += 1
	if (puzzle_array[_array_index - array_width].get_node("Rotation/Button")._get_state() == _color):
		_count += 1
	if (puzzle_array[_array_index + array_width].get_node("Rotation/Button")._get_state() == _color):
		_count += 1
	return _count

func _get_region(_x: int, _y: int, _color: int) -> Array:
	var _region = Array()
	var _array_index: int = _get_rule_index(_x,_y)
	_connect_cell(_region, _array_index, _x, _y, _color)
	return _region

func _connect_cell(_region: Array, _array_index: int, _x: int, _y: int, _color: int):
	var _cell = puzzle_array[_array_index]
	_region.append(_cell)
	if (_x > 0):
		if (_color == 0): # Black Symbol
			if (puzzle_array[_array_index - 1].get_node("Rotation/Button")._get_state() < 2):
				if not _region.has(puzzle_array[_array_index - 2]):
					_connect_cell(_region, _array_index - 2, _x-1, _y, _color)
		else: # Colored Symbol
			if (puzzle_array[_array_index - 1].get_node("Rotation/Button")._get_state() != _color):
				if not _region.has(puzzle_array[_array_index - 2]):
					_connect_cell(_region, _array_index - 2, _x-1, _y, _color)
	if (_x < (puzzle_width - 1)):
		if (_color == 0): # Black Symbol
			if (puzzle_array[_array_index + 1].get_node("Rotation/Button")._get_state() < 2):
				if not _region.has(puzzle_array[_array_index + 2]):
					_connect_cell(_region, _array_index + 2, _x+1, _y, _color)
		else: # Colored Symbol
			if (puzzle_array[_array_index + 1].get_node("Rotation/Button")._get_state() != _color):
				if not _region.has(puzzle_array[_array_index + 2]):
					_connect_cell(_region, _array_index + 2, _x+1, _y, _color)
	if (_y > 0):
		if (_color == 0): # Black Symbol
			if (puzzle_array[_array_index - array_width].get_node("Rotation/Button")._get_state() < 2):
				if not _region.has(puzzle_array[_array_index - (array_width * 2)]):
					_connect_cell(_region, _array_index - (array_width * 2), _x, _y-1, _color)
		else: # Colored Symbol
			if (puzzle_array[_array_index - array_width].get_node("Rotation/Button")._get_state() != _color):
				if not _region.has(puzzle_array[_array_index - (array_width * 2)]):
					_connect_cell(_region, _array_index - (array_width * 2), _x, _y-1, _color)
	if (_y < (puzzle_height - 1)):
		if (_color == 0): # Black Symbol
			if (puzzle_array[_array_index + array_width].get_node("Rotation/Button")._get_state() < 2):
				if not _region.has(puzzle_array[_array_index + (array_width * 2)]):
					_connect_cell(_region, _array_index + (array_width * 2), _x, _y+1, _color)
		else: # Colored Symbol
			if (puzzle_array[_array_index + array_width].get_node("Rotation/Button")._get_state() != _color):
				if not _region.has(puzzle_array[_array_index + (array_width * 2)]):
					_connect_cell(_region, _array_index + (array_width * 2), _x, _y+1, _color)
