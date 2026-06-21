extends Node3D

func make_random_visible():
	var x = randi_range(0, get_children().size() -1)
	get_children()[x].visible = true
