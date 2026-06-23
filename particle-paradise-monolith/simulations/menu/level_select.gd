extends Control


func _on_edu_pressed() -> void:
	get_parent().campaignScene()


func _on_peo_pressed() -> void:
	get_parent().boothScene()

func _on_rea_pressed() -> void:
	get_parent().avalancheScene()

func _on_sta_pressed() -> void:
	get_parent().railwayScene()

func _on_hou_pressed() -> void:
	get_parent().hourglassScene()



func _on_edu_mouse_entered() -> void:
	TweenFX.snap($Edu, 0.1, Vector2(1.3,1.3), TweenFX.PlayState.ENTER)


func _on_edu_mouse_exited() -> void:
	TweenFX.snap($Edu, 0.1, Vector2(1.0,1.0), TweenFX.PlayState.EXIT)


func _on_peo_mouse_entered() -> void:
	TweenFX.snap($Peo, 0.1, Vector2(1.3,1.3), TweenFX.PlayState.ENTER)


func _on_peo_mouse_exited() -> void:
	TweenFX.snap($Peo, 0.1, Vector2(1.0,1.0), TweenFX.PlayState.EXIT)


func _on_rea_mouse_entered() -> void:
	TweenFX.snap($Rea, 0.1, Vector2(1.3,1.3), TweenFX.PlayState.ENTER)


func _on_rea_mouse_exited() -> void:
	TweenFX.snap($Rea, 0.1, Vector2(1.0,1.0), TweenFX.PlayState.EXIT)


func _on_back_pressed() -> void:
	get_parent().mainMenu()


func _on_sta_mouse_entered() -> void:
	TweenFX.snap($Sta, 0.1, Vector2(1.3,1.3), TweenFX.PlayState.ENTER)


func _on_sta_mouse_exited() -> void:
	TweenFX.snap($Sta, 0.1, Vector2(1.0,1.0), TweenFX.PlayState.EXIT)


func _on_hou_mouse_entered() -> void:
	TweenFX.snap($Hou, 0.1, Vector2(1.3,1.3), TweenFX.PlayState.ENTER)


func _on_hou_mouse_exited() -> void:
	TweenFX.snap($Hou, 0.1, Vector2(1.0,1.0), TweenFX.PlayState.EXIT)
