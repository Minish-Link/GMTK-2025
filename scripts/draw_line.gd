extends Node2D

@export var PointA: Node2D
@export var PointB: Node2D

func _draw():
	var _state: int = get_node("Button")._get_state()
	match _state:
		0:
			%Line2D.default_color = Color(0,0,0,0.1)
		1:
			%Line2D.default_color = Color(1,1,1,0.25)
		2:
			%Line2D.default_color = Color.FIREBRICK
		3:
			%Line2D.default_color = Color.BLUE
		_:
			%Line2D.default_color = Color(0,0,0,0.25)
