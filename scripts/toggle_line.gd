class_name PuzzleLine
extends Button

enum LineState {
	Pink = -1,
	Erased = 0,
	Blank = 1,
	Red = 2,
	Blue = 3
}

func _enter_tree():
	state = LineState.Blank
	_set_color()

var state: LineState
var in_editor: bool = false

func _on_Button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var _new_color: int
				if in_editor:
					_new_color = (get_node("../../../../..") as LevelEditor)._get_color()
				else:
					_new_color = (get_node("../../../../..") as PuzzleGrid)._get_color()
				if state == LineState.Pink:
					state = _new_color as LineState
				elif state == LineState.Red and _new_color == LineState.Blue:
					state = _new_color as LineState
				elif state == LineState.Blue and _new_color == LineState.Red:
					state = _new_color as LineState
				elif state == LineState.Blank or state == LineState.Erased:
					state = _new_color as LineState
				else:
					state = LineState.Blank
				if not in_editor:
					(get_node("../../../../..") as PuzzleGrid)._play_line_toggle()
			MOUSE_BUTTON_RIGHT:
				if state == LineState.Erased:
					state = LineState.Blank
				else:
					state = LineState.Erased
				if not in_editor:
					(get_node("../../../../..") as PuzzleGrid)._play_line_toggle()
			MOUSE_BUTTON_MIDDLE:
				if state == LineState.Pink:
					state = LineState.Blank
				else:
					state = LineState.Pink
				if not in_editor:
					(get_node("../../../../..") as PuzzleGrid)._play_line_toggle()
		_set_color()

func _set_color():
	match state:
			LineState.Pink:
				%Line2D.width = 8
				%Line2D.default_color = Color(1,1,1,1)
				%Line2D.z_index = 3
				%Line2DGlow.default_color = Color(0.5,0.5,0.5,1)
				%Line2DGlow2.default_color = Color(0.25,0.25,0.25,1)
				%Line2DGlow.visible = true
				%Line2DGlow2.visible = true
			LineState.Erased:
				%Line2D.width = 5
				%Line2D.z_index = 0
				%Line2D.default_color = Color(0.05,0.05,0.05,1)
				%Line2DGlow.visible = false
				%Line2DGlow2.visible = false
			LineState.Blank:
				%Line2D.width = 5
				%Line2D.z_index = 0
				%Line2D.default_color = Color(0.3,0.3,0.3,1)
				%Line2DGlow.visible = false
				%Line2DGlow2.visible = false
			LineState.Red:
				%Line2D.width = 8
				%Line2D.z_index = 3
				%Line2D.default_color = Color.RED
				%Line2DGlow.default_color = Color(0.5,0,0,1)
				%Line2DGlow2.default_color = Color(0.25,0,0,1)
				%Line2DGlow.visible = true
				%Line2DGlow2.visible = true
			LineState.Blue:
				%Line2D.width = 8
				%Line2D.z_index = 3
				%Line2D.default_color = Color.DODGER_BLUE
				%Line2DGlow.default_color = Color(0.06, 0.28, 0.5, 1)
				%Line2DGlow2.default_color = Color(0.03, 0.14, 0.25, 1)
				%Line2DGlow.visible = true
				%Line2DGlow2.visible = true

func _get_state() -> int:
	return state as int

func _set_state(_new_state: int):
	state = _new_state as LineState
	_set_color()
