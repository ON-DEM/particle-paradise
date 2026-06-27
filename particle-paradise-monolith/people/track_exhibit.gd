extends Node3D

var attracting = {}
var left = {}

func exhibitID():
	pass

func trackID():
	pass

func _on_attractor_body_entered(body: Node3D) -> void:
	if body.has_method("particleID"):
		if body in left.keys():
			attracting[body] = left[body]
			return
		attracting[body] = 1.5
		body.engaged.append(self)

func _physics_process(delta: float) -> void:
	for particle in attracting.keys():
		#attracting[particle] = clamp(attracting[particle] - 0.1 * delta, 0, 1.5)
		var direction = particle.global_position.direction_to(global_position)
		particle.apply_central_force(direction.normalized() * (clampf(2.5-particle.boredom, 0, 10)) * clampf(5.0/particle.global_position.distance_to(global_position), 0.0, 3.0))
		particle.boredom += 0.2 * delta

func _on_attractor_body_exited(body: Node3D) -> void:
	if body.has_method("particleID"):
		if body in attracting.keys():
			left[body] = attracting[body]
			attracting.erase(body)
		if self in body.engaged:
			body.engaged.erase(self)
