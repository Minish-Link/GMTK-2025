extends Node2D

@export var PointA: Node2D
@export var PointB: Node2D

func _draw():
	var _state: int = get_node("Button")._get_state()
	match _state:
		-1:
			%Line2D.default_color = Color.MAGENTA
		0:
			%Line2D.default_color = Color(0,0,0,0.05)
		1:
			%Line2D.default_color = Color(0,0,0,0.3)
		2:
			%Line2D.default_color = Color.RED
		3:
			%Line2D.default_color = Color.DODGER_BLUE
		_:
			%Line2D.default_color = Color(0,0,0,0.3)
