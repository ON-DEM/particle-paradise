extends Node3D

var iterCounter = 1
var particle_dict = {}
var particleObj = preload("res://hourglass/particle_3d.tscn")
var timerFinished = false

var slowCounter = 0
var targetPos: Array[Vector3]
var particleChildren

@onready var cameraPivot = $CameraPivot
var mouseSensitivity = 0.4
var cameraInputDirection = Vector2.ZERO

var playing = false

func _unhandled_input(event: InputEvent) -> void:
	var isCameraMotion = (event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	if isCameraMotion:
		cameraInputDirection = event.screen_relative * mouseSensitivity

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("middle_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_released("middle_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	cameraPivot.rotation.x -= cameraInputDirection.y * delta
	cameraPivot.rotation.x = clamp(cameraPivot.rotation.x, -PI / 3.0, PI / 3.0)
	cameraPivot.rotation.y -= cameraInputDirection.x * delta
	cameraInputDirection = Vector2.ZERO
	
	if playing == true:
		slowCounter += 1
		if slowCounter == 10:
			if timerFinished:
				iterCounter += 1
				
				var keys = particle_dict.keys()
				
				if (iterCounter < particle_dict[keys[0]].size()) and (keys.size() > 0):
					for i in range(particleChildren.size()):
						var key = keys[i]
						var pos = particle_dict[key][iterCounter]
						
						targetPos[i] = Vector3(
							float(pos[0]),
							float(pos[2]),
							float(pos[1])
						)
			slowCounter = 0
		for i in range(particleChildren.size()):
			particleChildren[i].global_position = Vector3(
				lerpf(particleChildren[i].global_position.x, targetPos[i].x, 0.5), #*(abs(particleChildren[i].global_position.x-targetPos[i].x))
				lerpf(particleChildren[i].global_position.y, targetPos[i].y, 0.5),
				lerpf(particleChildren[i].global_position.z, targetPos[i].z, 0.5)
			)

func _ready():
	import_resources_data()
	
func import_resources_data():
	var file = FileAccess.open("res://hourglass/Output.csv", FileAccess.READ)

	while !file.eof_reached():
		var data_set = Array(file.get_csv_line())
		if data_set.size() > 1:
			if not particle_dict.has(data_set[1]):
				particle_dict[data_set[1]] = []
			particle_dict[data_set[1]].append([data_set[2],data_set[3],data_set[4],data_set[5]])
	file.close()
	instantiate_particles()

func instantiate_particles():
	for i in particle_dict.keys():
		var new_particle = particleObj.instantiate()
		$Particles.add_child(new_particle)
		new_particle.global_position = Vector3(float(particle_dict[i][0][0]),float(particle_dict[i][0][2]),float(particle_dict[i][0][1]))
		new_particle.scale = Vector3(float(particle_dict[i][0][3]),float(particle_dict[i][0][3]),float(particle_dict[i][0][3]))
	particleChildren = $Particles.get_children()
	for i in range(particleChildren.size()):
		targetPos.append(Vector3(
						particleChildren[i].global_position.x,
						particleChildren[i].global_position.y,
						particleChildren[i].global_position.z
					))

func _on_timer_timeout() -> void:
	timerFinished = true


func _on_slider_value_changed(value: float) -> void:
	$hourglass.playAnimAtPoint(value)


func _on_play_pressed() -> void:
	playing = true
	iterCounter = 1
	slowCounter = 0
	for i in particle_dict.keys():
		particleChildren[int(i)].global_position = Vector3(float(particle_dict[i][0][0]),float(particle_dict[i][0][2]),float(particle_dict[i][0][1]))
