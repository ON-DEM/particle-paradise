extends Area2D

var ball_inside: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.has_method('ballID'):
		#print("some body entered the goal")
		
		ball_inside = body
		$Timer.start()

func _on_body_exited(body: Node2D) -> void:
	if body == ball_inside:
		#print("ball left too early")

		ball_inside = null
		$Timer.stop()

func _on_timer_timeout() -> void:
	if ball_inside != null:
		get_tree().paused = true
		var popup = get_node("../WinPopup")
		popup.popup_centered()

func _on_win_popup_confirmed() -> void:
	#print("confirmation")
	get_tree().paused = false
	get_parent().get_parent().load_next_level()
	

#func _on_intro_popup_confirmed() -> void:
	#$IntroPopup.hide()
	#get_tree().paused = false
	##pass # Replace with function body.
