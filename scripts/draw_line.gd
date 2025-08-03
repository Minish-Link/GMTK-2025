extends Node2D

var colorblind: int

func _set_colorblind(_setting: int):
	colorblind = _setting

func _draw():
	var _state: int = get_node("Button")._get_state()
	match _state:
		-1:
			%Line2D.default_color = Color.WHITE
		0:
			%Line2D.default_color = Color(1,1,1,0.05)
		1:
			%Line2D.default_color = Color(1,1,1,0.3)
		2:
			%Line2D.default_color = Color.RED
		3:
			%Line2D.default_color = Color.DODGER_BLUE
		_:
			%Line2D.default_color = Color(1,1,1,0.3)
