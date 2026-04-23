extends Control

func _on_start_pressed() -> void:
	get_parent().levelSelect()

func _ready() -> void:
	for i in $HBoxContainer.get_children():
		i.modulate.a = 1.0
		TweenFX.drop_in(i, 1.0, 200.0)
		await get_tree().create_timer(0.1).timeout
	#TweenFX.color_cycle($VBoxContainer/Title)



func _on_start_focus_entered() -> void:
	pass



func _on_start_focus_exited() -> void:
	pass


func _on_start_mouse_entered() -> void:
	TweenFX.snap($Start, 0.1, Vector2(1.3,1.3), TweenFX.PlayState.ENTER)


func _on_start_mouse_exited() -> void:
	TweenFX.snap($Start, 0.1, Vector2(1.0,1.0), TweenFX.PlayState.EXIT)
