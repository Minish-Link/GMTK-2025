class_name PuzzleRule
extends Control

var grid_x: int
var grid_y: int
var rule: String
var rule_number: int
var color_id: int

var colorblind: int

enum ColorID {
	Black = 0,
	Purple = 1,
	Red = 2,
	Blue = 3,
}

enum SuitID {
	Heart = 0,
	Spade = 1,
	Club = 2,
	Diamond = 3
}

func _set_colorblind(_setting: int):
	colorblind = _setting

func _set_grid_xy(_x: int, _y: int):
	grid_x = _x
	grid_y = _y

func _set_rule(_rule: String = "", _color: String = "black", _rule_number: int = 0):
	rule = _rule
	rule_number = _rule_number
	if rule == "":
		%Sprite.visible = false
		%TextLabel.visible = false
	elif rule == "pips":
		%TextLabel.visible = false
		%Sprite.visible = true
		match rule_number:
			0:
				%Sprite.texture = load("res://textures/dice_empty.svg")
			1:
				%Sprite.texture = load("res://textures/dice_1.svg")
			2:
				%Sprite.texture = load("res://textures/dice_2.svg")
			3:
				%Sprite.texture = load("res://textures/dice_3.svg")
			4:
				%Sprite.texture = load("res://textures/dice_4.svg")
			_:
				print("pip rule invalid")
				rule = ""
				rule_number = 0
	elif rule == "suit":
		%TextLabel.visible = false
		%Sprite.visible = true
		match rule_number:
			0:
				%Sprite.texture = load("res://textures/suit_hearts.svg")
			1:
				%Sprite.texture = load("res://textures/suit_spades.svg")
			2:
				%Sprite.texture = load("res://textures/suit_clubs.svg")
			3:
				%Sprite.texture = load("res://textures/suit_diamonds.svg")
			_:
				print("suit rule invalid")
				rule = ""
				rule_number = 0
	elif rule == "area":
		%TextLabel.visible = true
		%Sprite.visible = false
		%TextLabel.text = str(rule_number)
			
	if (_color == "red"):
		%Sprite.modulate = Color.RED
		%TextLabel.modulate = Color.RED
		color_id = ColorID.Red
	elif (_color == "blue"):
		%Sprite.modulate = Color.DODGER_BLUE
		%TextLabel.modulate = Color.DODGER_BLUE
		color_id = ColorID.Blue
	elif (_color == "purple"):
		color_id = ColorID.Purple
		if colorblind == 0:
			%Sprite.modulate = Color.MEDIUM_PURPLE
			%TextLabel.modulate = Color.MEDIUM_PURPLE
		elif colorblind == 1:
			%Sprite.modulate = Color(0.67, 1.0, 0.67, 1.0)
			%TextLabel.modulate = Color(0.67, 1.0, 0.67, 1.0)
		else:
			%Sprite.modulate = Color.YELLOW
			%TextLabel.modulate = Color.YELLOW
	else:
		%Sprite.modulate = Color.LIGHT_GRAY
		%TextLabel.modulate = Color.LIGHT_GRAY
		color_id = ColorID.Black

func _get_suit() -> int:
	if rule == "suit":
		return rule_number
	else:
		return -1

func _check_if_valid() -> bool:
	if rule == "":
		return true
	elif rule == "pips":
		if (color_id == 0): # Black
			var _red: int = (get_node("../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 2)
			var _blue: int = (get_node("../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 3)
			if (_red + _blue) == rule_number:
				return true
			else:
				return false
		elif (color_id == 1): # Purple
			var _red: int = (get_node("../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 2)
			var _blue: int = (get_node("../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 3)
			if _red == rule_number and _blue == rule_number:
				return true
			else:
				return false
		else: # Red or Blue
			if (get_node("../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, color_id) == rule_number:
				return true
			else:
				return false
	elif rule == "area":
		if color_id == 1: # Purple
			if (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, 2).size() == rule_number:
				if (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, 3).size() == rule_number:
					return true
			return false
		else:
			if (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id).size() == rule_number:
				return true
			else:
				return false
	elif rule == "suit":
		if (color_id == 1): # Purple
			var _region = (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, 2)
			for i in _region.size():
				var _other_suit: int = (_region[i] as PuzzleRule)._get_suit()
				if _other_suit > 0 and _other_suit != rule_number:
					return false
			_region = (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, 3)
			for i in _region.size():
				var _other_suit: int = (_region[i] as PuzzleRule)._get_suit()
				if _other_suit >= 0 and _other_suit != rule_number:
					return false
			
			return true
		else:
			var _region = (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id)
			for i in _region.size():
				var _other_suit: int = (_region[i] as PuzzleRule)._get_suit()
				if _other_suit > 0 and _other_suit != rule_number:
					return false
			
			return true
	
	return true

func _get_grid_x() -> int:
	return grid_x

func _get_grid_y() -> int:
	return grid_y
