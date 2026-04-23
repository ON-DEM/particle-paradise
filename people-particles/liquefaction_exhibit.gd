extends Node3D

var attracting = {}
var left = {}

func exhibitID():
	pass

var counter = 0
var subCounter = 0

func liqID():
	pass

func _on_attractor_body_entered(body: Node3D) -> void:
	if body.has_method("particleID"):
		if body in left.keys():
			attracting[body] = left[body]
			return
		attracting[body] = 10.0

func _physics_process(delta: float) -> void:
	counter += delta
	if counter > 3:
		for particle in attracting.keys():
			$Attractor.visible = true
			attracting[particle] = clamp(attracting[particle] - 1.0 * delta, 0, 10.0)
			var direction = particle.global_position.direction_to(global_position)
			particle.apply_central_force(direction.normalized() * attracting[particle])
		subCounter += delta
		if subCounter > 3:
			subCounter = 0
			counter = 0
			$Attractor.visible = false
	

func _on_attractor_body_exited(body: Node3D) -> void:
	if body.has_method("particleID"):
		if body in attracting.keys():
			left[body] = attracting[body]
			attracting.erase(body)
			
