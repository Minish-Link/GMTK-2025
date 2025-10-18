class_name PuzzleRule
extends Control

var grid_x: int
var grid_y: int
var rule: String = ""
var color_name: String
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
	color_name = _color
	rule_number = _rule_number
	%Sprite.visible = true
	%Sprite.scale = Vector2(0.75,0.75)
	%TextLabel.add_theme_font_size_override("normal_font_size", 32)
	%TextLabel.add_theme_constant_override("outline_size", 0)
	if rule == "pips":
		%TextLabel.visible = false
		%Sprite.texture = load("res://textures/cell_rules/dice/dice_"+str(rule_number)+".svg")
	elif rule == "suit":
		%TextLabel.visible = false
		%Sprite.texture = load("res://textures/cell_rules/suits/suit_"+str(rule_number)+".svg")
	elif rule == "area":
		%TextLabel.visible = true
		%Sprite.texture = load("res://textures/cell_rules/area.png")
		%TextLabel.text = str(rule_number)
		if rule_number >= 10:
			%TextLabel.add_theme_font_size_override("normal_font_size", 22)
		%Sprite.scale = Vector2(1.1, 1.1)
	elif rule == "eye":
		%TextLabel.visible = false
		%Sprite.texture = load("res://textures/cell_rules/eyes/eye_"+str(rule_number)+".png")
	elif rule == "triangle":
		%TextLabel.visible = false
		%Sprite.texture = load("res://textures/cell_rules/triangles/triangle_"+str(rule_number)+".png")
	elif rule == "cross":
		%TextLabel.visible = false
		%Sprite.texture = load("res://textures/cell_rules/crosses/cross_"+str(rule_number)+".png")
	elif rule == "arrows":
		%TextLabel.visible = true
		%Sprite.texture = load("res://textures/cell_rules/arrows.png")
		%TextLabel.text = str(rule_number)
		%Sprite.scale = Vector2(1.2, 1.2)
		%TextLabel.add_theme_constant_override("outline_size", 10)
		if rule_number >= 10:
			%TextLabel.add_theme_font_size_override("normal_font_size", 18)
		else:
			%TextLabel.add_theme_font_size_override("normal_font_size", 22)
	elif rule == "key":
		%TextLabel.visible = false
		%Sprite.texture = load("res://textures/cell_rules/keys/key_"+str(rule_number)+".png")
			
	else: # "" or invalid
		%Sprite.visible = false
		%TextLabel.visible = false
		if rule != "":
			print("rule at "+str(grid_x)+","+str(grid_y)+" is invalid")
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

func _get_crosses() -> int:
	if rule == "cross":
		return rule_number
	else:
		return -1

func _check_if_valid() -> bool:
	if color_id == 1: # purple
		return _check_purple_rule()
		
	if rule == "":
		return true
		
	elif rule == "pips":
		if (color_id == 0): # Black
			var _red: int = (get_node("../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 2)
			var _blue: int = (get_node("../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, 3)
			if (_red + _blue) == rule_number:
				return true
			else:
				print(str("failure!"))
				print(str(grid_x)+","+str(grid_y)+": "+str(_red + _blue))
				return false
		else: # Red or Blue
			if (get_node("../../..") as PuzzleGrid)._get_pip_count(grid_x, grid_y, color_id) == rule_number:
				return true
			else:
				return false
	
	elif rule == "area":
		if (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id).size() == rule_number:
			return true
		else:
			return false
				
	elif rule == "suit":
		var _region = (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id)
		for i in _region.size():
			var _other_suit: int = (_region[i] as PuzzleRule)._get_suit()
			if _other_suit >= 0 and _other_suit != rule_number:
				return false
		
	elif rule == "triangle":
		if (get_node("../../..") as PuzzleGrid)._get_neighboring_vertices(grid_x, grid_y, color_id) != rule_number:
			return false
		
	elif rule == "cross":
		var _cross_count: int = 0
		var _region = (get_node("../../..") as PuzzleGrid)._get_region(grid_x, grid_y, color_id)
		for _cell in _region:
			var _other_cross: int = (_cell as PuzzleRule)._get_crosses()
			if _other_cross >= 0:
				if _other_cross != rule_number:
					return false
				else:
					_cross_count += 1
		if _cross_count != rule_number:
			return false
		
	elif rule == "arrows":
		if (get_node("../../..") as PuzzleGrid)._get_arrows_count(grid_x, grid_y, color_id) != rule_number:
			return false
	
	elif rule == "key":
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
		if _key_sum != 7:
			return false
	
	return true

func _check_purple_rule() -> bool:
	var _success: bool
	var _og_color: int = color_id
	color_id = 2
	_success = _check_if_valid()
	if _success:
		color_id = 3
		_success = _check_if_valid()
	color_id = _og_color
	return _success

func _get_grid_x() -> int:
	return grid_x

func _get_grid_y() -> int:
	return grid_y

func _convert_to_dict() -> Dictionary:
	return {
		"x": ((grid_x - 1) / 2) as int,
		"y": ((grid_y - 1) / 2) as int,
		"type": rule,
		"color": color_name,
		"number": rule_number
	}
