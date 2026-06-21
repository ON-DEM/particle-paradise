extends TileMapLayer

func checkArea(area):
	var mouseTile = get_viewport().get_mouse_position()
	var mapPos = local_to_map(mouseTile)
	for i in range(9):
		if area[i] == "y":
			set_cell(Vector2i(mapPos.x + (i % 3 - 1), mapPos.y + (floori(i/3.0)) - 1), 0, Vector2i(0,0))
