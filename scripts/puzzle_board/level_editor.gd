class_name LevelEditor
extends PuzzleGrid

enum SymbolType {
	Pips = 0,
	Area = 1,
	Suit = 2,
	Eye = 3,
	Arrow = 4,
	Triangle = 5,
	Cross = 6
}
const HIGHEST_SYMBOL_INDEX: int = SymbolType.Cross
const MIN_SYMBOL_COUNTS: Array[int] = [0,1,0,0,1,0,1]
const MAX_SYMBOL_COUNTS: Array[int] = [4,99,3,3,99,4,4]
const DEFAULT_SYMBOL_COUNTS: Array[int] = [1,4,0,0,5,1,1]
const SYMBOL_STRINGS: Array[String] = [
	"pips",
	"area",
	"suit",
	"eye",
	"arrows",
	"triangle",
	"cross"
]
const MIN_COLOR: int = 0
const MAX_COLOR: int = 3
const COLOR_NAMES: Array[String] = [
	"black",
	"purple",
	"red",
	"blue"
]
const MIN_WIDTH: int = 1
const MIN_HEIGHT: int = 1
const MAX_WIDTH: int = 10
const MAX_HEIGHT: int = 10

var rule_preview = preload("res://scenes/objects/PuzzleRule.tscn")
var editor_rule  = preload("res://scenes/objects/EditorRule.tscn")

var selected_rule_type: int = 0
var selected_rule_variant: int = 1
var selected_rule_color: int = 0

func _init() -> void:
	super()
	puzzle_rule = editor_rule

func _ready() -> void:
	_create_grid(4,4)
	_update_rule_preview()
	_change_color_count(1)

func _resize_grid() -> void:
	for _row in puzzle_array:
		for _cell in _row:
			if is_instance_valid(_cell):
				_cell.queue_free()
	_create_grid(puzzle_width, puzzle_height)

func _create_grid(_width: int, _height: int) -> void:
	super(_width, _height)
	%DimensionLabel.text = str(puzzle_width)+" x "+str(puzzle_height)
	_change_color_count(color_count)

func _on_save_button_pressed() -> void:
	_save_board_to_json()

func _on_load_button_pressed() -> void:
	_load_board_from_json()

func _save_board_to_json() -> void:
	if %FileName.text == "":
		return
	var level_data: Dictionary = {}
	level_data["name"] = %NameEditor.text
	level_data["description"] = %DescriptionEditor.text
	level_data["color_amount"] = color_count
	level_data["width"] = puzzle_width
	level_data["height"] = puzzle_height
	level_data["id"] = 0
	level_data["prev_level"] = ""
	level_data["next_level"] = ""
	var _json_rules: Array = []
	for _x in range(1, array_width, 2):
		for _y in range(1, array_height, 2):
			if (puzzle_array[_x][_y] as PuzzleRule).rule == "":
				continue
			_json_rules.append((puzzle_array[_x][_y] as PuzzleRule)._convert_to_dict())
	level_data["rules"] = _json_rules
	print("res://level_data/editor/"+%FileName.text+".json")
	var _level_file := FileAccess.open("res://level_data/editor/"+%FileName.text+".json", FileAccess.WRITE)
	if _level_file != null:
		_level_file.store_line(JSON.stringify(level_data))
		_level_file.close()

func _load_board_from_json() -> void:
	if %FileName.text == "":
		return
	var level_data: JSON = JSON.new()
	var error = level_data.parse(FileAccess.get_file_as_string("res://level_data/editor/"+%FileName.text+".json"))
	if error == OK:
		_accept_level_data(level_data.data)
		%NameEditor.text = name_text.text
		%DescriptionEditor.text = description_text.text

func _update_rule_preview() -> void:
	%RulePreview._set_rule(SYMBOL_STRINGS[selected_rule_type], COLOR_NAMES[selected_rule_color], selected_rule_variant)
	
# Rule Changer Buttons
func _on_type_left_pressed() -> void:
	if selected_rule_type > 0:
		selected_rule_type -= 1
	else:
		selected_rule_type = HIGHEST_SYMBOL_INDEX
	selected_rule_variant = DEFAULT_SYMBOL_COUNTS[selected_rule_type]
	_update_rule_preview()

func _on_type_right_pressed() -> void:
	if selected_rule_type < HIGHEST_SYMBOL_INDEX:
		selected_rule_type += 1
	else:
		selected_rule_type = 0
	selected_rule_variant = DEFAULT_SYMBOL_COUNTS[selected_rule_type]
	_update_rule_preview()

func _on_variant_left_pressed() -> void:
	if selected_rule_variant > MIN_SYMBOL_COUNTS[selected_rule_type]:
		selected_rule_variant -= 1
	else:
		selected_rule_variant = MAX_SYMBOL_COUNTS[selected_rule_type]
	_update_rule_preview()

func _on_variant_right_pressed() -> void:
	if selected_rule_variant < MAX_SYMBOL_COUNTS[selected_rule_type]:
		selected_rule_variant += 1
	else:
		selected_rule_variant = MIN_SYMBOL_COUNTS[selected_rule_type]
	_update_rule_preview()
	
func _on_color_left_pressed() -> void:
	if selected_rule_color > MIN_COLOR:
		selected_rule_color -= 1
	else:
		selected_rule_color = MAX_COLOR
	_update_rule_preview()

func _on_color_right_pressed() -> void:
	if selected_rule_color < MAX_COLOR:
		selected_rule_color += 1
	else:
		selected_rule_color = MIN_COLOR
	_update_rule_preview()

# Board Changer Buttons
func _on_width_left_pressed() -> void:
	if puzzle_width > MIN_WIDTH:
		puzzle_width -= 1
		_resize_grid()
		
func _on_width_right_pressed() -> void:
	if puzzle_width < MAX_WIDTH:
		puzzle_width += 1
		_resize_grid()
		
func _on_height_left_pressed() -> void:
	if puzzle_height > MIN_HEIGHT:
		puzzle_height -= 1
		_resize_grid()
		
func _on_height_right_pressed() -> void:
	if puzzle_height < MAX_HEIGHT:
		puzzle_height += 1
		_resize_grid()
		
func _on_color_count_left_pressed() -> void:
	_change_color_count(1)
	
func _on_color_count_right_pressed() -> void:
	_change_color_count(2)
	
func _change_color_count(_count: int) -> void:
	color_count = _count
	if color_count == 1:
		%BrushSprite.visible = false
		%BrushSprite.modulate = Color.RED
		current_color = 2
	elif color_count == 2:
		%BrushSprite.visible = true
	%ColorLimitLabel.text = "Colors: "+str(color_count)
