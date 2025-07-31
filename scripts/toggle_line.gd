extends Button

signal left_click
signal right_click
	
func _on_Button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				left_click.emit()
			MOUSE_BUTTON_RIGHT:
				right_click.emit()
