class_name PuzzleLine
extends Button

@export var PointA: Node2D
@export var PointB: Node2D

enum LineState {
	Erased = 0b00,
	Blank = 0b01,
	Red = 0b10,
	Blue = 0b11
}

func _enter_tree():
	state = LineState.Erased

var state: LineState

func _on_Button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				print("Boop")
				if state == LineState.Blank:
					state = LineState.Red
				else:
					state = LineState.Blank
				get_parent()._draw()
			MOUSE_BUTTON_RIGHT:
				print("Bap")
				if state == LineState.Erased:
					state = LineState.Blank
				else:
					state = LineState.Erased
				get_parent()._draw()

#func _draw():
#	get_parent()._draw()

func _get_state() -> int:
	return int(state)
