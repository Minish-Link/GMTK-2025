class_name PuzzleRule
extends Control

var grid_x: int
var grid_y: int
var rule: String = ""
var color_name: String
var rule_number: int
var color_id: int

# for arrows specifically
var arrow_dir: int = 0
var arrow_count: int = 0

var colorblind: int

func _set_colorblind(_setting: int):
	colorblind = _setting

func _set_grid_xy(_x: int, _y: int):
	grid_x = _x
	grid_y = _y

func _set_rule(_rule: String = "", _color: String = "black", _rule_number: int = 0):
	rule = _rule
	color_name = _color
	rule_number = _rule_number
	if rule == "arrow":
		arrow_dir = rule_number % 8
		arrow_count = rule_number / 8
	color_id = PuzzleConst.ColorDict[color_name]
	(%RuleLabel as RuleLabel)._set_label(_rule, _color, _rule_number, colorblind)

func _check_if_valid() -> bool:
	if color_id == 1: # purple
		return _is_purple_rule_valid()
		
	if rule == "":
		return true
		
	elif rule == "pips":
		return _get_pip_count() == rule_number
	elif rule == "area":
		return (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id).size() == rule_number
	elif rule == "suit":
		return _is_suit_valid()
	elif rule == "eye":
		return true
	elif rule == "triangle":
		return (get_node("../../..") as PuzzleGrid)._get_neighboring_vertices(grid_x, grid_y, color_id) == rule_number
	elif rule == "cross":
		return _is_cross_valid()
	elif rule == "rook":
		return _get_rook_count() == rule_number
	elif rule == "bishop":
		return _get_bishop_count() == rule_number
	elif rule == "queen":
		return _get_queen_count() == rule_number
	elif rule == "knight":
		return _get_knight_count() == rule_number
	elif rule == "king":
		return _get_king_count() == rule_number
	elif rule == "key":
		return _is_key_valid()
	elif rule == "arrow":
		return (get_node("../../..") as PuzzleGrid)._get_arrow_count(grid_x, grid_y, color_id, arrow_dir) == arrow_count
	elif rule == "page":
		return _is_page_valid()
	
	return true

func _is_purple_rule_valid() -> bool:
	var _success: bool
	var _og_color: int = color_id
	color_id = 2
	_success = _check_if_valid()
	if _success:
		color_id = 3
		_success = _check_if_valid()
	color_id = _og_color
	return _success

func _get_pip_count() -> int:
	if (color_id == PuzzleConst.ColorID.Black):
		var _red: int = (get_node("../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 2)
		var _blue: int = (get_node("../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 3)
		return _red + _blue
	else: # Red or Blue
		return (get_node("../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, color_id)

func _is_suit_valid() -> bool:
	for _cell in (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id):
		var _other_suit: int = (_cell as PuzzleRule)._get_suit()
		if _other_suit >= 0 and _other_suit != rule_number:
			return false
	return true

func _is_cross_valid() -> bool:
	var _cross_count: int = 0
	var _region = (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id)
	for _cell in _region:
		var _other_cross: int = (_cell as PuzzleRule)._get_crosses()
		if _other_cross >= 0:
			if _other_cross != rule_number:
				return false
			else:
				_cross_count += 1
	return _cross_count == rule_number

func _get_rook_count(_limit: int = 0) -> int:
	return (get_node("../../..") as PuzzleGrid)._get_rook_count(grid_x, grid_y, color_id, _limit)

func _get_bishop_count(_limit: int = 0) -> int:
	return (get_node("../../..") as PuzzleGrid)._get_bishop_count(grid_x, grid_y, color_id, _limit)

func _get_queen_count() -> int:
	return _get_rook_count() + _get_bishop_count()

func _get_knight_count() -> int:
	return (get_node("../../..") as PuzzleGrid)._get_knight_count(grid_x, grid_y, color_id)

func _get_king_count() -> int:
	return _get_rook_count(1) + _get_bishop_count(1)

func _is_key_valid() -> bool:
	var _region = (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id)
	var _key_count: int = 0
	var _key_sum: int = 0
	for _cell in _region:
		if (_cell as PuzzleRule).rule == "":
			continue
		if (_cell as PuzzleRule).rule != "key":
			return false
		else:
			_key_count += 1
			_key_sum += (_cell as PuzzleRule).rule_number
			if _key_count > 2:
				return false
	return _key_sum == 7

func _is_page_valid() -> bool:
	var _region = (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id)
	return (get_node("../../..") as PuzzleGrid)._is_region_outside(_region, color_id)

func _get_grid_x() -> int:
	return grid_x

func _get_grid_y() -> int:
	return grid_y
	
func _get_suit() -> int:
	if rule == "suit":
		return rule_number
	else:
		return -1

func _get_crosses() -> int:
	if rule == "cross":
		return rule_number
	else:
		return -1

func _convert_to_dict() -> Dictionary:
	return {
		"x": ((grid_x - 1) / 2) as int,
		"y": ((grid_y - 1) / 2) as int,
		"type": rule,
		"color": color_name,
		"number": rule_number
	}
