class_name LevelEditor
extends Control

enum SymbolType {
	Pips = 0,
	Area = 1,
	Suit = 2,
	Eye = 3,
	Cross = 4,
	X = 5
}
const HIGHEST_SYMBOL_INDEX: int = SymbolType.Suit
const MIN_SYMBOL_COUNTS: Array[int] = [0,1,0,0,1,0]
const MAX_SYMBOL_COUNTS: Array[int] = [4,99,3,3,99,0]
const DEFAULT_SYMBOL_COUNTS: Array[int] = [1,4,0,0,5,0]
const SYMBOL_STRINGS: Array[String] = [
	"pips",
	"area",
	"suit",
	"eye",
	"cross",
	"x"
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

var puzzle_width: int = 4
var puzzle_height: int = 4
var array_width: int
var array_height: int

var puzzle_array: Array
var rule_array: Array

var color_count: int = 1
var current_color: int = 2

var selected_rule: int = SymbolType.Pips
#var selected_rule_str: String = "pips"
var selected_variant: int = 1
var selected_color: int = 0

var puzzle_vertex = preload("res://scenes/objects/PuzzleVertex.tscn")
var puzzle_line = preload("res://scenes/objects/PuzzleLine.tscn")
var puzzle_rule = preload("res://scenes/objects/EditorRule.tscn")

var sfx_switch1 = preload("res://audio/sfx/switch_002.ogg")
var sfx_switch2 = preload("res://audio/sfx/switch_007.ogg")

@export var container: GridContainer

func _ready():
	_create_grid()
	_update_rule_preview()
	%BrushSprite.modulate = Color.RED

func _input(event):
	if event.is_action_pressed("swap"):
		_swap_color()

func _swap_color():
	if color_count > 1:
		if current_color == 2:
			print("Switching to Blue")
			current_color = 3
			%BrushSprite.modulate = Color.DODGER_BLUE
			%SwapSFXPlayer.stream = sfx_switch2
		else:
			print("Switching to Red")
			current_color = 2
			%BrushSprite.modulate = Color.RED
			%SwapSFXPlayer.stream = sfx_switch1
		%SwapSFXPlayer.play()

func _resize_grid():
	for _cell in puzzle_array:
		if is_instance_valid(_cell):
			_cell.queue_free()
	_create_grid()

func _create_grid():
	%DimensionLabel.text = str(puzzle_width) + " x " + str(puzzle_height)
	current_color = 2
	array_width = (puzzle_width * 2) + 1
	array_height = (puzzle_height * 2) + 1
	
	puzzle_array = Array()
	rule_array = Array()
	
	puzzle_array.resize(array_width * array_height)
	rule_array.resize(puzzle_width * puzzle_height)
	container.columns = array_width
	
	var _rule_count: int = 0
	for i in puzzle_array.size():
		if i % 2 == 1:
			var line_node = puzzle_line.instantiate()
			(line_node.get_node("Rotation/Button") as PuzzleLine).in_editor = true
			container.add_child(line_node)
			puzzle_array[i] = line_node
			if (i / array_width) % 2 == 1:
				(line_node.get_node("Rotation") as Node2D).rotate(deg_to_rad(90))
		elif i / ((array_width)) % 2 == 0:
			var vert_node = puzzle_vertex.instantiate()
			container.add_child(vert_node)
			puzzle_array[i] = vert_node
		else:
			var rule_node = puzzle_rule.instantiate()
			(rule_node as PuzzleRule)._set_grid_xy((i % array_width - 1) / 2, (i / array_width - 1) / 2)
			container.add_child(rule_node)
			puzzle_array[i] = rule_node
			rule_array[_rule_count] = rule_node
			_rule_count += 1
	var zoom_x = 1.0 / (puzzle_width / 5.0)
	var zoom_y = 1.0 / (puzzle_height / 5.0)
	var final_zoom = min(zoom_x, zoom_y) * 0.9
	%GridZoom.scale = (Vector2(final_zoom, final_zoom))

func _get_color() -> int:
	return current_color

func _save_board_to_json():
	#TODO
	pass

func _load_board_from_json():
	#TODO
	pass

func _clear_grid() -> void:
	_resize_grid()

func _on_save_pressed() -> void:
	_save_board_to_json()

func _on_menu_button_pressed() -> void:
	(get_node("../..") as LevelSelectMenu)._return_from_puzzle()

func _on_board_width_increase_pressed() -> void:
	if puzzle_width < MAX_WIDTH:
		puzzle_width += 1
		_resize_grid()

func _on_board_width_decrease_pressed() -> void:
	if puzzle_width > MIN_WIDTH:
		puzzle_width -= 1
		_resize_grid()

func _on_board_height_increase_pressed() -> void:
	if puzzle_height < MAX_HEIGHT:
		puzzle_height += 1
		_resize_grid()

func _on_board_height_decrease_pressed() -> void:
	if puzzle_height > MIN_HEIGHT:
		puzzle_height -= 1
		_resize_grid()

func _on_board_color_count_pressed() -> void:
	if color_count == 1:
		color_count = 2
		%ColorLimitLabel.text = "Colors: 2"
	else:
		color_count = 1
		%ColorLimitLabel.text = "Colors: 1"

func _update_rule_preview() -> void:
	%RulePreview._set_rule(SYMBOL_STRINGS[selected_rule], COLOR_NAMES[selected_color], selected_variant)

func _on_rule_type_left_pressed() -> void:
	if selected_rule > 0:
		selected_rule -= 1
	else:
		selected_rule = HIGHEST_SYMBOL_INDEX
	selected_variant = DEFAULT_SYMBOL_COUNTS[selected_rule]
	_update_rule_preview()

func _on_rule_type_right_pressed() -> void:
	if selected_rule < HIGHEST_SYMBOL_INDEX:
		selected_rule += 1
	else:
		selected_rule = 0
	selected_variant = DEFAULT_SYMBOL_COUNTS[selected_rule]
	_update_rule_preview()

func _on_rule_variant_decrease_pressed() -> void:
	if selected_variant > MIN_SYMBOL_COUNTS[selected_rule]:
		selected_variant -= 1
	else:
		selected_variant = MAX_SYMBOL_COUNTS[selected_rule]
	_update_rule_preview()

func _on_rule_variant_increase_pressed() -> void:
	if selected_variant < MAX_SYMBOL_COUNTS[selected_rule]:
		selected_variant += 1
	else:
		selected_variant = MIN_SYMBOL_COUNTS[selected_rule]
	_update_rule_preview()
	
func _on_rule_color_left_pressed() -> void:
	if selected_color > MIN_COLOR:
		selected_color -= 1
	else:
		selected_color = MAX_COLOR
	_update_rule_preview()

func _on_rule_color_right_pressed() -> void:
	if selected_color < MAX_COLOR:
		selected_color += 1
	else:
		selected_color = MIN_COLOR
	_update_rule_preview()
