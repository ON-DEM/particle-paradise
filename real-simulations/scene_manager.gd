extends Node

@onready var curScene = $MainMenu

@onready var hourglass_scene = preload("res://hourglass/hourglass_scene.tscn")

func levelSelect():
	var newScene = hourglass_scene.instantiate()
	add_child(newScene)
	curScene.queue_free()
	curScene = newScene
