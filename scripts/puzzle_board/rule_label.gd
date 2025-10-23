class_name RuleLabel
extends Control

const ARROW_SUBSCRIPT_ALIGNMENTS: Array[Vector2] = [
	# First index points up, subsequent indices rotate 45 degrees clockwise
	Vector2(VERTICAL_ALIGNMENT_BOTTOM, HORIZONTAL_ALIGNMENT_CENTER),
	Vector2(VERTICAL_ALIGNMENT_BOTTOM, HORIZONTAL_ALIGNMENT_LEFT),
	Vector2(VERTICAL_ALIGNMENT_CENTER, HORIZONTAL_ALIGNMENT_LEFT),
	Vector2(VERTICAL_ALIGNMENT_TOP, HORIZONTAL_ALIGNMENT_LEFT),
	Vector2(VERTICAL_ALIGNMENT_TOP, HORIZONTAL_ALIGNMENT_CENTER),
	Vector2(VERTICAL_ALIGNMENT_TOP, HORIZONTAL_ALIGNMENT_RIGHT),
	Vector2(VERTICAL_ALIGNMENT_CENTER, HORIZONTAL_ALIGNMENT_RIGHT),
	Vector2(VERTICAL_ALIGNMENT_BOTTOM, HORIZONTAL_ALIGNMENT_RIGHT),
]

func _set_label(_rule: String, _color: String, _number: int, _colorblind: int):
	%Sprite.rotation_degrees = 0
	%Sprite.visible = true
	%TextLabel.visible = false
	%SubscriptLabel.visible = false
	%SubscriptLabel.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	%SubscriptLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	%Sprite.scale = Vector2(1,1)
	%TextLabel.text = str(_number)
	%SubscriptLabel.text = str(_number)
	%TextLabel.add_theme_font_size_override("normal_font_size", 36)
	%TextLabel.add_theme_constant_override("outline_size", 16)
	%SubscriptLabel.add_theme_font_size_override("normal_font_size", 32)
	%SubscriptLabel.add_theme_constant_override("outline_size", 12)
	%Particles.emitting = false
	if _rule == "pips":
		%Sprite.texture = load("res://textures/cell_rules/dice/dice_"+str(_number)+".svg")
	elif _rule == "suit":
		%Sprite.texture = load("res://textures/cell_rules/suits/suit_"+str(_number)+".svg")
	elif _rule == "area":
		%TextLabel.visible = true
		%Sprite.texture = load("res://textures/cell_rules/area.png")
	elif _rule == "eye":
		%Sprite.texture = load("res://textures/cell_rules/eyes/eye_"+str(_number)+".png")
	elif _rule == "triangle":
		%Sprite.texture = load("res://textures/cell_rules/triangles/triangle_"+str(_number)+".png")
	elif _rule == "cross":
		%Sprite.texture = load("res://textures/cell_rules/crosses/cross_"+str(_number)+".png")
	elif _rule == "rook":
		%Sprite.texture = load("res://textures/cell_rules/chess/rook.png")
		%SubscriptLabel.visible = true
	elif _rule == "bishop":
		%Sprite.texture = load("res://textures/cell_rules/chess/bishop.png")
		%SubscriptLabel.visible = true
	elif _rule == "queen":
		%Sprite.texture = load("res://textures/cell_rules/chess/queen.png")
		%SubscriptLabel.visible = true
	elif _rule == "knight":
		%Sprite.texture = load("res://textures/cell_rules/chess/knight.png")
		%SubscriptLabel.visible = true
	elif _rule == "king":
		%Sprite.texture = load("res://textures/cell_rules/chess/king.png")
		%SubscriptLabel.visible = true
	elif _rule == "key":
		%Sprite.texture = load("res://textures/cell_rules/keys/key_"+str(_number)+".png")
		%Particles.emitting = true
	elif _rule == "arrow":
		%Sprite.texture = load("res://textures/cell_rules/arrow.png")
		%SubscriptLabel.visible = true
		var _dir: int = _number % 8
		var _count: int = _number / 8
		%Sprite.rotation_degrees = _dir * 45
		%SubscriptLabel.text = str(_count)
		%SubscriptLabel.vertical_alignment = ARROW_SUBSCRIPT_ALIGNMENTS[_dir].x
		%SubscriptLabel.horizontal_alignment = ARROW_SUBSCRIPT_ALIGNMENTS[_dir].y
	elif _rule == "page":
		%Sprite.texture = load("res://textures/cell_rules/page.png")
		%Particles.emitting = true
	else: # "" or invalid
		%Sprite.visible = false
		%TextLabel.visible = false
	if (_color == "red"):
		%Sprite.modulate = Color.RED
		%TextLabel.modulate = Color.RED
		%SubscriptLabel.modulate = Color.RED
	elif (_color == "blue"):
		%Sprite.modulate = Color.DODGER_BLUE
		%TextLabel.modulate = Color.DODGER_BLUE
		%SubscriptLabel.modulate = Color.DODGER_BLUE
	elif (_color == "purple"):
		#color_id = ColorID.Purple
		if _colorblind == 0:
			%Sprite.modulate = Color.MEDIUM_PURPLE
			%TextLabel.modulate = Color.MEDIUM_PURPLE
			%SubscriptLabel.modulate = Color.MEDIUM_PURPLE
		elif _colorblind == 1:
			%Sprite.modulate = Color(0.67, 1.0, 0.67, 1.0)
			%TextLabel.modulate = Color(0.67, 1.0, 0.67, 1.0)
			%SubscriptLabel.modulate = Color(0.67, 1.0, 0.67, 1.0)
		else:
			%Sprite.modulate = Color.YELLOW
			%TextLabel.modulate = Color.YELLOW
			%SubscriptLabel.modulate = Color.YELLOW
	else:
		%Sprite.modulate = Color.LIGHT_GRAY
		%TextLabel.modulate = Color.LIGHT_GRAY
		%SubscriptLabel.modulate = Color.LIGHT_GRAY
