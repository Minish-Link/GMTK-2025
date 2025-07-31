extends Camera2D

func _zoom_camera(_puzzle_width: int, _puzzle_height: int):
	var zoom_x = 1.0 / (_puzzle_width / 9.0)
	var zoom_y = 1.0 / (_puzzle_height / 5.0)
	var final_zoom = min(zoom_x, zoom_y)
	zoom = Vector2(final_zoom, final_zoom)
