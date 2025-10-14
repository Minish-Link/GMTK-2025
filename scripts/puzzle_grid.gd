class_name PuzzleGrid
extends Control

@export var container: GridContainer
@export var name_text: RichTextLabel
@export var description_text: RichTextLabel
@export var next_level_button: ColorRect
@export var prev_level_button: ColorRect

var sfx_success = preload("res://audio/sfx/GMTK2025_Success.ogg")
var sfx_failure = preload("res://audio/sfx/GMTK2025_Failure.ogg")
var sfx_switch1 = preload("res://audio/sfx/switch_002.ogg")
var sfx_switch2 = preload("res://audio/sfx/switch_007.ogg")

var puzzle_id: int

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

var next_level: String
var prev_level: String

var played_victory: bool = false

var colorblind_setting

func _init() -> void:
	colorblind_setting = JSON.parse_string(FileAccess.get_file_as_string("user://settings.json"))["color_blind"]

func _input(event):
	if event.is_action_pressed("swap"):
		_swap_color()

func _swap_color():
	if color_count > 1:
		if current_color == 2:
			print("Switching to Blue")
			current_color = 3
			%BrushSprite.modulate = Color.DODGER_BLUE
			%SwapSFXPlayer.stream = sfx_switch2
		else:
			print("Switching to Red")
			current_color = 2
			%BrushSprite.modulate = Color.RED
			%SwapSFXPlayer.stream = sfx_switch1
		%SwapSFXPlayer.play()

func _get_color() -> int:
	return current_color

func _accept_level_data(_data: Dictionary):
	for _node in puzzle_array:
		_node.queue_free()
	puzzle_array.clear()
	rule_array.clear()
	
	name_text.text = _data["name"]
	puzzle_id = _data["id"]
	
	if ("description" in _data):
		description_text.text = _data["description"]
	else:
		description_text.text = ""
	
	prev_level = _data["prev_level"]
	next_level = _data["next_level"]
	if _data["prev_level"] != "":
		prev_level_button.visible = true
	else:
		prev_level_button.visible = false
	if _data["next_level"] != "":
		next_level_button.visible = true
	else:
		next_level_button.visible = false
		
	color_count = _data["color_amount"]
	if color_count > 1:
		%BrushSprite.visible = true
		%BrushSprite.modulate = Color.RED
	else:
		%BrushSprite.visible = false
	
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
	var columns: int = (_width * 2) + 1
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
			(rule_node as PuzzleRule)._set_colorblind(colorblind_setting)
			(rule_node as PuzzleRule)._set_grid_xy((i % columns - 1) / 2, (i / columns - 1) / 2)
			container.add_child(rule_node)
			puzzle_array[i] = rule_node
			rule_array[_rule_count] = rule_node
			_rule_count += 1
	var zoom_x = 1.0 / (puzzle_width / 5.0)
	var zoom_y = 1.0 / (puzzle_height / 5.0)
	var final_zoom = min(zoom_x, zoom_y) * 0.9
	%GridZoom.scale = (Vector2(final_zoom, final_zoom))

func _check_loops() -> bool:
	if not _is_loop_color_valid(2):
		print("Red Loop is not valid")
		return false
	if color_count > 1 and not _is_loop_color_valid(3):
		print("Blue Loop is not valid")
		return false
	
	if not _check_rule_nodes():
		return false
	
	return true

func _is_loop_color_valid(_color: int) -> bool:
	var _neighbor_count: int = 0
	var _loop_vertices: Array[int] = []
	
	# check if all lines form valid loops.
	# if they do, all vertices will have either 0 or 2 neighboring lines
	for x in range(0, array_width, 2): 
		for y in range(0, puzzle_array.size(), array_width * 2):
			_neighbor_count = _get_neighboring_line_count(x,y,_color)
			if not (_neighbor_count == 2 or _neighbor_count == 0):
				print("Loop is not closed or has intersections")
				return false
			if (_neighbor_count == 2):
				_loop_vertices.append(x+y)
	
	if _loop_vertices.size() == 0:
		print("There are no lines of this color")
		return false
		
	if not _has_only_one_loop(_color, _loop_vertices):
		print("There are multiple loops of this color")
		return false
	
	return true

func _has_only_one_loop(_color: int, _vertex_array: Array[int]) -> bool:
	# if there is only one loop, then there will be only two regions:
	#	a region inside the loop, and a region outside the loop
	# first iterate through the lines along the edges of the puzzle to check if the loop touches the edge
	# 	if it does not touch the edge, take any line segment and get the regions on both sides of the line
	# 	if the sum of the regions is equal to the puzzle, then there are only two regions
	#	and therefore only one loop
	#
	#	if it does touch the edge, get the region inside the loop, and
	#	get all regions outside the loop that border the edge of the puzzle
	#	if the sum of the inside region and those outside regions is equal to the puzzle,
	#	then there is only one loop
	
	var _edge_rules_outside_loop = Array()
	var _edge_rules_inside_loop = Array()
	
	# iterate through top row of lines and rules
	for _line_index in range(1, array_width, 2):
		if puzzle_array[_line_index].get_node("Rotation/Button")._get_state() == _color:
			_edge_rules_inside_loop.append(puzzle_array[_line_index + array_width])
		else:
			_edge_rules_outside_loop.append(puzzle_array[_line_index + array_width])
			
	# iterate through bottom row of lines and rules
	for _line_index in range(puzzle_array.size() - array_width + 1, puzzle_array.size(), 2):
		if puzzle_array[_line_index].get_node("Rotation/Button")._get_state() == _color:
			_edge_rules_inside_loop.append(puzzle_array[_line_index - array_width])
		else:
			_edge_rules_outside_loop.append(puzzle_array[_line_index - array_width])
			
	# iterate through left column of lines and rules
	for _line_index in range(array_width, puzzle_array.size(), 2 * array_width):
		if puzzle_array[_line_index].get_node("Rotation/Button")._get_state() == _color:
			_edge_rules_inside_loop.append(puzzle_array[_line_index + 1])
		else:
			_edge_rules_outside_loop.append(puzzle_array[_line_index + 1])
			
	# iterate through right column of lines and rules
	for _line_index in range((array_width * 2) - 1, puzzle_array.size(), 2 * array_width):
		if puzzle_array[_line_index].get_node("Rotation/Button")._get_state() == _color:
			_edge_rules_inside_loop.append(puzzle_array[_line_index - 1])
		else:
			_edge_rules_outside_loop.append(puzzle_array[_line_index - 1])
	
	# if the loop does not border the edge of the puzzle
	if (_edge_rules_inside_loop).size() == 0:
		# get any line segment from the loop, and get the regions on both sides of it
		var _first_line_index
		var _line_is_vertical: bool = false
		var _first_vertex: Vector2 = _get_coords_from_array_index(_vertex_array[0])
		var _vx: int = _first_vertex.x
		var _vy: int = _first_vertex.y * array_width
		
		if puzzle_array[_vx + _vy - 1].get_node("Rotation/Button")._get_state() == _color:
			_first_line_index = _vx + _vy - 1
		elif puzzle_array[_vx + _vy + 1].get_node("Rotation/Button")._get_state() == _color:
			_first_line_index = _vx + _vy + 1
		else:
			_first_line_index = _vx + _vy - array_width
			_line_is_vertical = true
		
		var _cell1
		var _cell2
		
		if _line_is_vertical:
			_cell1 = puzzle_array[_first_line_index - 1]
			_cell2 = puzzle_array[_first_line_index + 1]
		else:
			_cell1 = puzzle_array[_first_line_index - array_width]
			_cell2 = puzzle_array[_first_line_index + array_width]
		
		var _region1 = _get_region(_cell1._get_grid_x(), _cell1._get_grid_y(), _color)
		var _region2 = _get_region(_cell2._get_grid_x(), _cell2._get_grid_y(), _color)
		if (_region1.size() + _region2.size()) == (puzzle_width * puzzle_height):
			return true
	
	# if the loop does border at least one edge of the puzzle
	else:
		var _tempx = _edge_rules_inside_loop[0]._get_grid_x()
		var _tempy = _edge_rules_inside_loop[0]._get_grid_y()
		var _region1: Array = _get_region(_tempx, _tempy, _color)
		var _region2: Array = Array()
		
		for _cell in _edge_rules_outside_loop:
			if _cell not in _region2:
				_tempx = _cell._get_grid_x()
				_tempy = _cell._get_grid_y()
				_region2.append_array(_get_region(_tempx, _tempy, _color))
		
		if (_region1.size() + _region2.size()) == (puzzle_width * puzzle_height):
			return true
	
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

func _get_coords_from_array_index(_array_index: int) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2(_array_index % array_width, _array_index / array_width)

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

func _play_line_toggle():
	%LineSFXPlayer.play()

func _play_victory_jingle(_success: bool):
	if (_success):
		%VictoryJinglePlayer.stream = sfx_success
	else:
		%VictoryJinglePlayer.stream = sfx_failure
	%VictoryJinglePlayer.play()

func _on_submit_button_pressed() -> void:
	if _check_loops():
		
		(get_node("../../..") as LevelSelectMenu)._level_completed("res://level_data/final/"+str(puzzle_id)+".json")
		%Particles.emitting = true
		_play_victory_jingle(true)
	else:
		_play_victory_jingle(false)


func _on_prev_button_pressed() -> void:
	var level_data: JSON = JSON.new()
	var error = level_data.parse(FileAccess.get_file_as_string("res://level_data/"+prev_level+".json"))
	if error == OK:
		_accept_level_data(level_data.data)


func _on_next_button_pressed() -> void:
	var level_data: JSON = JSON.new()
	var error = level_data.parse(FileAccess.get_file_as_string("res://level_data/"+next_level+".json"))
	if error == OK:
		_accept_level_data(level_data.data)


func _on_reset_button_pressed() -> void:
	for i in range(1, puzzle_array.size(), 2):
		puzzle_array[i].get_node("Rotation/Button")._set_state(1)


func _on_menu_button_pressed() -> void:
	(get_node("../../..") as LevelSelectMenu)._return_from_puzzle()
	
