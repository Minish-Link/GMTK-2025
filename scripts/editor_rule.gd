extends PuzzleRule

const COLOR_ARRAY: Array[String] = [
	"black",
	"purple",
	"red",
	"blue"
]

var rule_type_int: int = 0

func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var _temp_color: String = COLOR_ARRAY[(get_node("../../..") as LevelEditor).selected_color]
				rule_type_int = (get_node("../../..") as LevelEditor).selected_rule
				var _temp_type: String = LevelEditor.SYMBOL_STRINGS[rule_type_int]
				var _temp_variant: int = (get_node("../../..") as LevelEditor).selected_variant
				_set_rule(_temp_type, _temp_color, _temp_variant)
			MOUSE_BUTTON_RIGHT:
				_set_rule()
			MOUSE_BUTTON_WHEEL_DOWN:
				_add_variant(-1)
			MOUSE_BUTTON_WHEEL_UP:
				_add_variant(1)

func _add_variant(_value: int) -> void:
	pass
