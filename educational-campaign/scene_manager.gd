extends Node

@onready var game = preload("res://game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var newGame = game.instantiate()
	add_child(newGame)
	get_tree().paused = true
	var intro_popup = get_node("Game/CanvasLayer/IntroPopup")
	intro_popup.popup_centered()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
