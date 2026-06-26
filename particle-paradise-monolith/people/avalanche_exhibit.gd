extends Node3D

var attracting = {}
var left = {}

func exhibitID():
	pass

var counter = 0
var subCounter = 0

func avaID():
	pass

func _on_attractor_body_entered(body: Node3D) -> void:
	if body.has_method("particleID"):
		if body in left.keys():
			attracting[body] = left[body]
			return
		attracting[body] = 5.0

func _physics_process(delta: float) -> void:
	counter += delta
	if counter > 5:
		$Attractor.visible = true
		for particle in attracting.keys():
			#attracting[particle] = clamp(attracting[particle] - 0.1 * delta, 0, 1.5)
			var direction = particle.global_position.direction_to(global_position)
			particle.apply_central_force(direction.normalized() * (clampf(8.0-particle.boredom, 0, 10)) * clampf(2.5/particle.global_position.distance_to(global_position), 0.0, 1.0))
			particle.boredom += 0.2 * delta
			if !particle.engaged.has(self):
				particle.engaged.append(self)
		subCounter += delta
		if subCounter > 5:
			subCounter = 0
			counter = 0
			$Attractor.visible = false
	

func _on_attractor_body_exited(body: Node3D) -> void:
	if body.has_method("particleID"):
		if body in attracting.keys():
			left[body] = attracting[body]
			attracting.erase(body)
			if body.engaged.has(self):
				body.engaged.erase(self)
			
