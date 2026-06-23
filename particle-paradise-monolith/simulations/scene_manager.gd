extends Node

@onready var curScene = $MainMenu

@onready var mainmenu_scene = preload("res://simulations/menu/main_menu.tscn")
@onready var levelselect_scene = preload("res://simulations/menu/level_select.tscn")
@onready var simulationselect_scene = preload("res://simulations/menu/simulation_select.tscn")

@onready var avalanche_scene = preload("res://simulations/avalanche/avalanche_scene.tscn")
@onready var railway_scene = preload("res://simulations/railway/railway_scene.tscn")
@onready var hourglass_scene = preload("res://simulations/hourglass/hourglass.tscn")

@onready var booth_scene = preload("res://people/booth.tscn")

@onready var campaign_scene = preload("res://campaign/game.tscn")


func mainMenu():
	var newScene = mainmenu_scene.instantiate()
	add_child(newScene)
	curScene.queue_free()
	curScene = newScene

func levelSelect():
	var newScene = levelselect_scene.instantiate()
	add_child(newScene)
	curScene.queue_free()
	curScene = newScene

func simulationSelect():
	var newScene = simulationselect_scene.instantiate()
	add_child(newScene)
	curScene.queue_free()
	curScene = newScene

func avalancheScene():
	var newScene = avalanche_scene.instantiate()
	add_child(newScene)
	curScene.queue_free()
	curScene = newScene

func railwayScene():
	var newScene = railway_scene.instantiate()
	add_child(newScene)
	curScene.queue_free()
	curScene = newScene

func hourglassScene():
	var newScene = hourglass_scene.instantiate()
	add_child(newScene)
	curScene.queue_free()
	curScene = newScene

func boothScene():
	var newScene = booth_scene.instantiate()
	add_child(newScene)
	curScene.queue_free()
	curScene = newScene

func campaignScene():
	var newScene = campaign_scene.instantiate()
	add_child(newScene)
	curScene.queue_free()
	curScene = newScene
