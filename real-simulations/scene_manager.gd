extends Node

@onready var curScene = $MainMenu

@onready var avalanche_scene = preload("res://avalanche/avalanche_scene.tscn")
#@onready var avalanche_scene = preload("res://node_3d.tscn")
@onready var mainmenu_scene = preload("res://menu/main_menu.tscn")

func levelSelect():
	var newScene = avalanche_scene.instantiate()
	add_child(newScene)
	curScene.queue_free()
	curScene = newScene

func mainMenu():
	var newScene = mainmenu_scene.instantiate()
	add_child(newScene)
	curScene.queue_free()
	curScene = newScene
