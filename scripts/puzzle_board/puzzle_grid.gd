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

var puzzle_array: Array[Array]
var puzzle_vertex := preload("res://scenes/objects/PuzzleVertex.tscn")
var puzzle_line := preload("res://scenes/objects/PuzzleLine.tscn")
var puzzle_rule := preload("res://scenes/objects/PuzzleRule.tscn")

var puzzle_width: int
var puzzle_height: int
var puzzle_size: int
var array_width: int
var array_height: int
var array_size: int

var color_count: int
var current_color: int

var next_level: String
var prev_level: String

var played_victory: bool = false

var colorblind_setting

const CARDINAL_DIRECTIONS: Array[Vector2] = [
	Vector2(0,-1),# up
	Vector2(1,0), # right
	Vector2(0,1), # down
	Vector2(-1,0) # left
	]
const ORDINAL_DIRECTIONS: Array[Vector2] = [
	Vector2(1,-1),# NE
	Vector2(1,1), # SE
	Vector2(-1,1),# SW
	Vector2(-1,-1)# NW
]

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
	for _row in puzzle_array:
		for _node in _row:
			_node.queue_free()
	for _row in puzzle_array:
		_row.clear()
	puzzle_array.clear()
	
	if "name" in _data:
		name_text.text = _data["name"]
	else:
		name_text.text = ""
	if "id" in _data:
		puzzle_id = _data["id"]
	else:
		puzzle_id = 0
	if ("description" in _data):
		description_text.text = _data["description"]
	else:
		description_text.text = ""
	if "prev_level" in _data:
		prev_level = _data["prev_level"]
	else:
		prev_level = ""
	if "next_level":
		next_level = _data["next_level"]
	else:
		next_level = ""
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
		(puzzle_array[(_rule["x"] * 2)+1][(_rule["y"] * 2)+1] as PuzzleRule)._set_rule(_rule["type"], _rule["color"], _rule["number"])


func _create_grid(_width: int, _height: int):
	current_color = 2
	puzzle_width = _width
	puzzle_height = _height
	puzzle_size = puzzle_width * puzzle_height
	array_width = (puzzle_width * 2) + 1
	array_height = (puzzle_height * 2) + 1
	array_size = array_width * array_height
	print("Making Puzzle")
	
	for _col in puzzle_array:
		_col.resize(0)
	puzzle_array.resize(0)
	for _col in range(array_width):
		puzzle_array.append(Array())
	container.columns = array_width
	
	for _row in range(array_height):
		for _col in range(array_width):
			var _new_node: Control
			if (_row + _col) % 2 == 1: # line
				_new_node = puzzle_line.instantiate()
				if _row % 2 == 1: # line is vertical
					(_new_node.get_node("Rotation") as Node2D).rotate(deg_to_rad(90))
			elif _row % 2 == 0: # vertex
				_new_node = puzzle_vertex.instantiate()
			else: # rule cell
				_new_node = puzzle_rule.instantiate()
				(_new_node as PuzzleRule)._set_colorblind(colorblind_setting)
				(_new_node as PuzzleRule)._set_grid_xy(_col, _row)
			container.add_child(_new_node)
			puzzle_array[_col].append(_new_node)
	
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
	var _first_loop_vertex := Vector2(-1,-1)
	
	# check if all lines form valid loops.
	# if they do, all vertices will have either 0 or 2 neighboring lines
	for _x in range(0, array_width, 2):
		for _y in range(0, array_height, 2):
			_neighbor_count = _get_neighboring_line_count(_x, _y, _color)
			if not (_neighbor_count == 2 or _neighbor_count == 0):
				print ("Loop is not closed or has intersections")
				return false
			if _neighbor_count == 2 and _first_loop_vertex.x == -1:
				_first_loop_vertex = Vector2(_x,_y)
	
	if _first_loop_vertex.x == -1:
		print("There are no lines of this color")
		return false
		
	if not _has_only_one_loop(_color, _first_loop_vertex):
		print("There are multiple loops of this color")
		return false
	
	return true

func _has_only_one_loop(_color: int, _first_vertex: Vector2) -> bool:
	# if there is only one loop, then there will be only two regions in the puzzle:
	#	a region inside the loop, and a region outside the loop
	
	# get the region within the loop
	# because of how the grid is iterated through,
	# the first vertex pulled will always be going down and to the right,
	# and the cell to the bottom right of it will always be inside the loop
	var _inner_region = _get_region(_first_vertex.x + 1, _first_vertex.y + 1, _color)
	
	# iterate through all the edge cells that
	# aren't separated from the outside of the grid by a line
	# and combine their regions into one large outer region
	var _outer_region := Array()
	for _x in range(1, array_width, 2):
		for _y in range(1, array_height, 2):
			# there's probably a more elegant way to do this, but oh well
			if _x == 1:
				if (puzzle_array[0][_y].get_node("Rotation/Button") as PuzzleLine)._get_state() != _color:
					if puzzle_array[_x][_y] not in _outer_region:
						_outer_region.append_array(_get_region(_x, _y, _color))
			elif _x == array_width - 2:
				if (puzzle_array[array_width - 1][_y].get_node("Rotation/Button") as PuzzleLine)._get_state() != _color:
					if puzzle_array[_x][_y] not in _outer_region:
						_outer_region.append_array(_get_region(_x, _y, _color))
			elif _y == 1:
				if (puzzle_array[_x][0].get_node("Rotation/Button") as PuzzleLine)._get_state() != _color:
					if puzzle_array[_x][_y] not in _outer_region:
						_outer_region.append_array(_get_region(_x, _y, _color))
			elif _y == array_height - 2:
				if (puzzle_array[_x][array_height - 1].get_node("Rotation/Button") as PuzzleLine)._get_state() != _color:
					if puzzle_array[_x][_y] not in _outer_region:
						_outer_region.append_array(_get_region(_x, _y, _color))
	if _inner_region.size() + _outer_region.size() == puzzle_size:
		return true
	else:
		return false

func _check_rule_nodes() -> bool:
	for _x in range(1, array_width, 2):
		for _y in range(1, array_height, 2):
			if (puzzle_array[_x][_y] as PuzzleRule)._check_if_valid() == false:
				return false
	return true

func _get_neighboring_line_count(_x: int, _y: int, _color: int) -> int:
	var _count: int = 0
	var _temp_x: int
	var _temp_y: int
	
	for _dir in CARDINAL_DIRECTIONS:
		_temp_x = _x + _dir.x
		_temp_y = _y + _dir.y
		if _temp_x >= 0 and _temp_x < array_width and _temp_y >= 0 and _temp_y < array_height:
			if (puzzle_array[_temp_x][_temp_y].get_node("Rotation/Button") as PuzzleLine)._get_state() == _color:
				_count += 1
	return _count

func _get_neighboring_vertices(_x: int, _y: int, _color: int) -> int:
	var _count: int = 0
	for _dir in ORDINAL_DIRECTIONS:
		if _color == 0:# Black
			if _get_neighboring_line_count(_x + _dir.x, _y + _dir.y, 2) >= 1:
				_count += 1
			elif _get_neighboring_line_count(_x + _dir.x, _y + _dir.y, 3) >= 1:
				_count += 1
		elif _get_neighboring_line_count(_x + _dir.x, _y + _dir.y, _color) >= 1:
			_count += 1
	return _count

func _get_arrows_count(_x: int, _y: int, _color: int) -> int:
	# counts only cells extending in the orthogonal directions from the cell
	# counts its own cell as well
	var _count: int = 1
	for _dir in CARDINAL_DIRECTIONS:
		var _temp_x: int = _x
		var _temp_y: int = _y
		while true:
			_temp_x += _dir.x
			_temp_y += _dir.y
			if _temp_x <= 0 or _temp_y <= 0 or _temp_x >= array_width - 1 or _temp_y >= array_height - 1:
				break
			var _line_state: int = (puzzle_array[_temp_x][_temp_y].get_node("Rotation/Button") as PuzzleLine)._get_state()
			if _color == 0: # Black
				if _line_state >= 2:
					break
			elif _line_state == _color:
				break
			
			_count += 1
			_temp_x += _dir.x
			_temp_y += _dir.y
			
			assert(_count < puzzle_width + puzzle_height,
			"arrows rule at (x: "+str((_x - 1) / 2)+",y: "+str((_y - 1) / 2)+") counted more cells than possible")
	
	return _count

func _erase_line_from_eye(_x: int, _y: int, _dir: int, _color: int) -> bool:
	# returns true if a line was erased, or false if none were erased
	# TODO
	return false

func _get_pip_count(_x: int, _y: int, _color: int) -> int:
	var _count: int = 0
	for _dir in CARDINAL_DIRECTIONS:
		if (puzzle_array[_x+_dir.x][_y+_dir.y].get_node("Rotation/Button") as PuzzleLine)._get_state() == _color:
			_count += 1
	return _count

func _get_region(_x: int, _y: int, _color: int) -> Array:
	var _region = Array()
	_connect_cell(_region, _x, _y, _color)
	return _region

func _connect_cell(_region: Array, _x: int, _y: int, _color: int):
	var _cell = puzzle_array[_x][_y]
	_region.append(_cell)
	for _dir in CARDINAL_DIRECTIONS:
		var _temp_x: int = _x + _dir.x
		var _temp_y: int = _y + _dir.y
		if _temp_x <= 0 or _temp_x >= array_width - 1 or _temp_y <= 0 or _temp_y >= array_height - 1:
			continue
		if _color == 0: # Black symbol
			if (puzzle_array[_temp_x][_temp_y].get_node("Rotation/Button") as PuzzleLine)._get_state() >= 2:
				continue
		else: # Colored symbol
			if (puzzle_array[_temp_x][_temp_y].get_node("Rotation/Button") as PuzzleLine)._get_state() == _color:
				continue
		_temp_x += _dir.x
		_temp_y += _dir.y
		if puzzle_array[_temp_x][_temp_y] not in _region:
			_connect_cell(_region, _temp_x, _temp_y, _color)

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
	for _x in range(0, array_height, 2):
		for _y in range(1, array_width, 2):
			(puzzle_array[_x][_y].get_node("Rotation/Button") as PuzzleLine)._set_state(1)
	for _x in range(1, array_height, 2):
		for _y in range(0, array_width, 2):
			(puzzle_array[_x][_y].get_node("Rotation/Button") as PuzzleLine)._set_state(1)
	#for _row in puzzle_array:
	#	for _cell in _row:
	#		(_cell.get_node("Rotation/Button") as PuzzleLine)._set_state(1)


func _on_menu_button_pressed() -> void:
	(get_node("../../..") as LevelSelectMenu)._return_from_puzzle()
	
