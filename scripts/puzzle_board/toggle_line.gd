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
var locked: bool = false

func _on_Button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var _new_color: int
				_new_color = (get_node("../../../../..") as PuzzleGrid)._get_color()
				if locked:
					if in_editor:
						_set_lock_state(false)
						state = LineState.Blank
					else:
						return
				elif state == LineState.Pink:
					state = _new_color as LineState
				elif state == LineState.Red and _new_color == LineState.Blue:
					state = _new_color as LineState
				elif state == LineState.Blue and _new_color == LineState.Red:
					state = _new_color as LineState
				elif state == LineState.Blank or state == LineState.Erased:
					state = _new_color as LineState
				else:
					state = LineState.Blank
				(get_node("../../../../..") as PuzzleGrid)._play_line_toggle()
			MOUSE_BUTTON_RIGHT:
				if in_editor:
					if locked:
						_set_lock_state(false)
					elif state == LineState.Erased:
						_set_lock_state(true)
					else:
						state = LineState.Erased
				else:
					if state == LineState.Erased:
						state = LineState.Blank
					else:
						state = LineState.Erased
				(get_node("../../../../..") as PuzzleGrid)._play_line_toggle()
			MOUSE_BUTTON_MIDDLE:
				if locked:
					return
				if state == LineState.Pink:
					state = LineState.Blank
				else:
					state = LineState.Pink
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

func _reset_state():
	if locked:
		if in_editor:
			_set_state(LineState.Blank)
			_set_lock_state(false)
	else:
		_set_state(LineState.Blank)

func _set_lock_state(_new_state: bool) -> void:
	locked = _new_state
	%Lock.visible = _new_state
	if locked:
		_set_state(LineState.Erased)
		if not in_editor:
			%Button.visible = false
