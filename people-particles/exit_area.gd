extends Area3D

#func _physics_process(delta: float) -> void:
	#for i in get_overlapping_bodies():
		#if i.has_method("particleID"):
			#if i.canExit == true:
				#var direction = i.global_position.direction_to(global_position)
				#i.apply_central_force(direction.normalized() * (clampf(25/i.global_position.distance_to(global_position), 0.0, 5.0)))
