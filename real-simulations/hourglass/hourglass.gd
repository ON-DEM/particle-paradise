extends Node3D

func playAnimAtPoint(percentage):
	$AnimationPlayer.set_assigned_animation("ArmatureAction")
	$AnimationPlayer.seek(4.166*percentage/100, true, true)
