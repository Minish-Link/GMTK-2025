class_name PuzzleRule
extends Control

var grid_x: int
var grid_y: int
var rule: String
var rule_number: int
var color_id: int
@export var sprite: Sprite2D

enum ColorID {
	Black = 0,
	Purple = 1,
	Red = 2,
	Blue = 3,
}

enum SuitID {
	Heart = 1,
	Spade = 2,
	Diamond = 3,
	Club = 4
}

func _set_grid_xy(_x: int, _y: int):
	grid_x = _x
	grid_y = _y

func _set_rule(_rule: String = "", _color: String = "black", _rule_number: int = 0):
	rule = _rule
	rule_number = _rule_number
	if (_color == "red"):
		color_id = ColorID.Red
	elif (_color == "blue"):
		color_id = ColorID.Blue
	elif (_color == "purple"):
		color_id = ColorID.Purple
	else:
		color_id = ColorID.Black

func _get_suit() -> int:
	if rule == "suit":
		return rule_number
	else:
		return 0

func _check_if_valid() -> bool:
	if rule == "":
		return true
	elif rule == "pips":
		if (color_id == 0): # Black
			var _red: int = (get_node("../../../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 2)
			var _blue: int = (get_node("../../../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 3)
			if (_red + _blue) == rule_number:
				return true
			else:
				return false
		elif (color_id == 1): # Purple
			var _red: int = (get_node("../../../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 2)
			var _blue: int = (get_node("../../../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 3)
			if _red == rule_number and _blue == rule_number:
				return true
			else:
				return false
		else: # Red or Blue
			if (get_node("../../../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, color_id) == rule_number:
				return true
			else:
				return false
	elif rule == "area":
		if color_id == 1: # Purple
			if (get_node("../../../../..") as PuzzleGrid)._get_region(grid_x, grid_y, 2).size() == rule_number:
				if (get_node("../../../../..") as PuzzleGrid)._get_region(grid_x, grid_y, 3).size() == rule_number:
					return true
			return false
		else:
			if (get_node("../../../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id):
				return true
			else:
				return false
	elif rule == "suit":
		if (color_id == 1): # Purple
			var _region = (get_node("../../../../..") as PuzzleGrid)._get_region(grid_x, grid_y, 2)
			for i in _region.size():
				var _other_suit: int = (_region[i] as PuzzleRule)._get_suit()
				if _other_suit > 0 and _other_suit != rule_number:
					return false
			_region = (get_node("../../../../..") as PuzzleGrid)._get_region(grid_x, grid_y, 3)
			for i in _region.size():
				var _other_suit: int = (_region[i] as PuzzleRule)._get_suit()
				if _other_suit > 0 and _other_suit != rule_number:
					return false
			
			return true
		else:
			var _region = (get_node("../../../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id)
			for i in _region.size():
				var _other_suit: int = (_region[i] as PuzzleRule)._get_suit()
				if _other_suit > 0 and _other_suit != rule_number:
					return false
			
			return true
	
	return true
