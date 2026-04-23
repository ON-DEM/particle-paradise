extends Node2D

var area = ["y", "y", "y",
			"y", "n", "y",
			"y", "y", "y"]

var iterCounter = 1
var example_dict = {}

func _process(delta: float) -> void:
	iterCounter += 1
	if (iterCounter + 1 < example_dict.keys().size()) and (example_dict.keys().size() > 0):
		$PosExample.global_position = Vector2(int(example_dict[iterCounter][1]),int(example_dict[iterCounter][2]))
		print(example_dict[iterCounter][1],example_dict[iterCounter][2])

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			$PlacementGrid.checkArea(area)


func _ready():
	import_resources_data()
	
func import_resources_data():
	var file = FileAccess.open("res://data/example2.csv", FileAccess.READ)

	while !file.eof_reached():
		var data_set = Array(file.get_csv_line())
		example_dict[example_dict.size()] = data_set
	file.close()
	print (example_dict)
