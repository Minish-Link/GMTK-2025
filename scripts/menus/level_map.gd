class_name LevelMap
extends GridContainer

var empty_tile := preload("res://scenes/menus/MapTile.tscn")

var map_width: int = 10
var map_height: int = 10

var map_array: Array[Array]

func _ready() -> void:
	_initialize_grid()

func _clear_map() -> void:
	for _row in map_array: for _cell in _row:
		if is_instance_valid(_cell):
			(_cell as MapTile).queue_free()
	pass

func _initialize_grid() -> void:
	for _row in range(map_height):
		map_array.append(Array())
	columns = map_width
	
	for _row in range(map_height):
		for _col in range(map_width):
			var _new_node = empty_tile.instantiate()
			map_array[_col].append(_new_node)
			add_child(_new_node)
	
