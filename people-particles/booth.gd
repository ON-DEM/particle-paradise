extends Node3D

@onready var cameraPivot = $CameraPivot
@onready var springArm = $CameraPivot/SpringArm3D
@onready var camera = $CameraPivot/SpringArm3D/Camera3D

@onready var spawnArea = $SpawnArea/CollisionShape3D.shape.extents
@onready var origin = $SpawnArea/CollisionShape3D.global_position -  spawnArea
@onready var spawnPos = $SpawnMarker.global_position

@onready var particleObj = preload("res://particle.tscn")

var boothOpen = false

var mouseSensitivity = 0.25
var cameraInputDirection = Vector2.ZERO
var lastMovementDirection = Vector3.BACK
var lastMousePos

var residence = 0

func _ready() -> void:
	$SpawnTimer.paused = true

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	cameraPivot.rotation.x -= cameraInputDirection.y * delta
	cameraPivot.rotation.x = clamp(cameraPivot.rotation.x, -PI / 2.0, PI / 3.0)
	cameraPivot.rotation.y -= cameraInputDirection.x * delta

	cameraInputDirection = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	var isCameraMotion = (event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	if isCameraMotion:
		cameraInputDirection = event.screen_relative * mouseSensitivity

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		call_deferred("restoreMouse")
	if event.is_action_pressed("middle_click"):
		lastMousePos = get_viewport().get_mouse_position()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_released("middle_click"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		call_deferred("restoreMouse")
		
	if event.is_action_pressed("scroll_in"):
		springArm.spring_length = clamp(springArm.spring_length -0.5, 2.0, 18.0)
	if event.is_action_pressed("scroll_out"):
		springArm.spring_length = clamp(springArm.spring_length +0.5, 2.0, 18.0)


func restoreMouse():
	if lastMousePos != null:
		Input.warp_mouse(lastMousePos)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func gen_random_pos():
	var x = randf_range(origin.x, spawnArea.x)
	print(x)
	var y = randf_range(origin.z - 0.5, origin.z)
	
	return Vector2(x, y)


func _on_spawn_timer_timeout() -> void:
	var newParticle = particleObj.instantiate()
	var pos = Vector3(spawnPos.x -0.5 + randf(), 0.55 , spawnPos.z -0.5 + randf())
	var flip = randf()
	if flip < 0.5:
		newParticle.scale = newParticle.scale * 0.75
		newParticle.mass = 0.5
	$Particles.add_child(newParticle)
	newParticle.global_position = pos
	pass

func exitReached():
	pass

func _process(delta: float) -> void:
	var residenceTotal = 0
	for i in $Particles.get_children():
		residenceTotal += i.residenceTime
	residence = residenceTotal/($Particles.get_child_count() + 0.01)
	residence = clamp(residence, 0, 20)
	$CanvasLayer/HBoxContainer/HSlider2.value = residence
	$CanvasLayer/HBoxContainer/HSlider.value = float($GridMap.get_children().size() - 3) / 10.0 * 100.0
	$SpawnTimer.wait_time = 0.5 - ($GridMap.get_children().size() * 0.01)
	for i in $CanvasLayer/ItemList.item_count:
		$CanvasLayer/ItemList.set_item_text(i, str($GridMap.availableExhibits[$GridMap.availableExhibits.keys()[i]]) + " x " + $GridMap.availableExhibits.keys()[i])

func _on_open_close_pressed() -> void:
	if boothOpen == false:
		if $SpawnTimer.paused:
			$SpawnTimer.paused = false
		$SpawnTimer.start()
		boothOpen = true
		$CanvasLayer/OpenClose.text = "CLOSE BOOTH"
		$GridMap.selectorVisible = false
		$GridMap/Selector.visible = false
		for i in $GridMap.get_children():
			if i.has_method("liqID"):
				i.counter = 0
				i.subCounter = 0
	else:
		boothOpen = false
		$SpawnTimer.paused = true
		for i in $Particles.get_children():
			i.queue_free()
		$CanvasLayer/OpenClose.text = "OPEN BOOTH"
		$GridMap.selectorVisible = true
		residence = 0
		$GridMap/Selector.visible = true


func _on_item_list_item_selected(index: int) -> void:
	$GridMap.selectedExhibit = $GridMap.exhibits[index]
	$GridMap.update_selector($GridMap.current_selection)


func _on_speed_slider_value_changed(value: float) -> void:
	Engine.time_scale = value
	mouseSensitivity = 0.25 / value
