extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body.has_method("particleID"):
		get_parent().exitReached()
		body.queue_free()
