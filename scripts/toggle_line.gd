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

var state: LineState

func _on_Button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var _new_color: int = (get_node("../../../../..") as PuzzleGrid)._get_color()
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
				get_node("../../../../..")._check_loops()
				get_parent()._draw()
			MOUSE_BUTTON_RIGHT:
				if state == LineState.Erased:
					state = LineState.Blank
				else:
					state = LineState.Erased
				get_node("../../../../..")._check_loops()
				get_parent()._draw()
			MOUSE_BUTTON_MIDDLE:
				if state == LineState.Pink:
					state = LineState.Blank
				else:
					state = LineState.Pink
				get_parent()._draw()

func _get_state() -> int:
	return int(state)
