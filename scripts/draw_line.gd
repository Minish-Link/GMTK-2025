extends Node2D

@export var PointA: Node2D
@export var PointB: Node2D

enum LineState {
	Erased = 0b00,
	Blank = 0b01,
	Red = 0b10,
	Blue = 0b11
}

func _draw():
	var _state: int = get_node("Button")._get_state()
	match _state:
		0:
			%Line2D.default_color = Color(0,0,0,0.1)
		1:
			%Line2D.default_color = Color.DARK_GRAY
			#draw_line(PointA.position, PointB.position, Color.CADET_BLUE, 5.0)
			#_color = Color.CADET_BLUE
		2:
			%Line2D.default_color = Color.CRIMSON
			#draw_line(PointA.position, PointB.position, Color.CRIMSON, 5.0)
			#_color = Color.CRIMSON
		3:
			%Line2D.default_color = Color.BLUE
			#draw_line(PointA.position, PointB.position, Color.BLUE, 5.0)
			#_color = Color.BLUE
		_:
			%Line2D.default_color = Color.DARK_GRAY
			#draw_line(PointA.position, PointB.position, Color.DARK_GRAY, 5.0)
			#_color = Color.PURPLE
		#draw_line(PointA.position, PointB.position, _color, 5.0)
