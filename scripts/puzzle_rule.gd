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

func _check_if_valid() -> bool:
	if rule == "":
		return true
	elif rule == "pips":
		pass
	elif rule == "area":
		pass
	elif rule == "suit":
		pass
	return true
