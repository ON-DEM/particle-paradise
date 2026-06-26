extends Node3D

@onready var cameraPivot = $CameraPivot
@onready var springArm = $CameraPivot/SpringArm3D
@onready var camera = $CameraPivot/SpringArm3D/Camera3D

@onready var spawnArea = $SpawnArea/CollisionShape3D.shape.extents
@onready var origin = $SpawnArea/CollisionShape3D.global_position -  spawnArea
@onready var spawnPos = $SpawnMarker.global_position

@onready var particleObj = preload("res://people/particle.tscn")

var boothOpen = false

var mouseSensitivity = 0.25
var cameraInputDirection = Vector2.ZERO
var lastMovementDirection = Vector3.BACK
var lastMousePos
var ignoreFirstInput = true

var residence = 0

var levels = [
	{
		"exhibits": {
			"HOURGLASS": 4
		},
		"particles": 16
	},
	{
		"exhibits": {
			"HOURGLASS": 2,
			"GAME": 2
		},
		"particles": 24
	},
	{
		"exhibits": {
			"HOURGLASS": 2,
			"GAME": 2,
			"LIQUEFACTION": 2
		},
		"particles": 32
	},
	{
		"exhibits": {
			"HOURGLASS": 2,
			"GAME": 2,
			"LIQUEFACTION": 2,
			"TRACK": 2
		},
		"particles": 40
	},
	{
		"exhibits": {
			"HOURGLASS": 1,
			"GAME": 1,
			"LIQUEFACTION": 1,
			"TRACK": 1,
			"AVALANCHE": 1
		},
		"particles": 48
	}
]

var current_level := 0

func apply_level(level_index: int):
	current_level = level_index

	var level_data = levels[current_level]

	$GridMap.availableExhibits = level_data["exhibits"].duplicate(true)

	$GridMap.rebuild_item_list()

	$CanvasLayer/HBoxContainer/HSlider.max_value = level_data["particles"]
	$CanvasLayer/HBoxContainer/Label.text = "PEOPLE GOAL: " + str(level_data["particles"])

	if boothOpen == true:
		boothOpen = false
		$SpawnTimer.paused = true
		for i in $Particles.get_children():
			i.queue_free()
		$CanvasLayer/VBoxContainer/OpenClose.text = "OPEN BOOTH"
		$GridMap.selectorVisible = true
		$GridMap/Selector.visible = true
	# reset UI if needed
	update_exhibit_ui()

func update_exhibit_ui():
	var keys = $GridMap.availableExhibits.keys()

	for i in range($CanvasLayer/VBoxContainer/ItemList.item_count):
		if i < keys.size():
			var k = keys[i]
			$CanvasLayer/VBoxContainer/ItemList.set_item_text(
				i,
				str($GridMap.availableExhibits[k]) + " x " + k
			)


func _ready() -> void:
	$SpawnTimer.paused = true
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		$CanvasLayer/MobileControls.visible = true
		$CanvasLayer/PCControls/FoldableContainer/Label.text = "TAP: PLACE EXHIBIT
TAP AFTER TOGGLE: DELETE EXHIBIT
TWO FINGER SWIPE: ROTATE CAMERA"
	get_tree().paused = true
	apply_level(current_level)

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
		
		if ignoreFirstInput:
			ignoreFirstInput = false
			return
			
		cameraInputDirection = event.screen_relative * mouseSensitivity

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		call_deferred("restoreMouse")
	if event.is_action_pressed("middle_click"):
		lastMousePos = get_viewport().get_mouse_position()
		ignoreFirstInput = true
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

func check_level_complete():
	var target = levels[current_level]["particles"]

	if $Particles.get_child_count() >= target:
		match current_level:
			0:
				get_tree().paused = true
				$Level1Complete.visible = true

func advance_level():
	if current_level + 1 >= levels.size():
		print("GAME COMPLETE")
		return

	# clear world
	for p in $Particles.get_children():
		p.queue_free()

	for e in $GridMap.get_children():
		if e != $GridMap/Selector:
			e.queue_free()

	apply_level(current_level + 1)

func _process(delta: float) -> void:
	var residenceTotal = 0
	$CanvasLayer/HBoxContainer/HSlider.value = $Particles.get_child_count()
	$SpawnTimer.wait_time = 0.5 - ($GridMap.get_children().size() * 0.01)
	update_exhibit_ui()
	check_level_complete()

func _on_open_close_pressed() -> void:
	if boothOpen == false:
		if $SpawnTimer.paused:
			$SpawnTimer.paused = false
		$SpawnTimer.start()
		boothOpen = true
		$CanvasLayer/VBoxContainer/OpenClose.text = "CLOSE BOOTH"
		$GridMap.selectorVisible = false
		$GridMap/Selector.visible = false
		for i in $GridMap.get_children():
			if i.has_method("liqID") or i.has_method("avaID"):
				i.counter = 0
				i.subCounter = 0
	else:
		boothOpen = false
		$SpawnTimer.paused = true
		for i in $Particles.get_children():
			i.queue_free()
		$CanvasLayer/VBoxContainer/OpenClose.text = "OPEN BOOTH"
		$GridMap.selectorVisible = true
		residence = 0
		$GridMap/Selector.visible = true


func _on_item_list_item_selected(index: int) -> void:
	var item_list = $CanvasLayer/VBoxContainer/ItemList

	# convert string back to scene
	match index:
		0:
			$GridMap.selectedExhibit = $GridMap.hourglassExhibit
		1:
			$GridMap.selectedExhibit = $GridMap.gameExhibit
		2:
			$GridMap.selectedExhibit = $GridMap.liquefactionExhibit
		3:
			$GridMap.selectedExhibit = $GridMap.trackExhibit
		4:
			$GridMap.selectedExhibit = $GridMap.avalancheExhibit


func _on_speed_slider_value_changed(value: float) -> void:
	Engine.time_scale = value
	mouseSensitivity = 0.25 / value


func _on_back_pressed() -> void:
	Engine.time_scale = 1
	get_parent().levelSelect()


func _on_check_box_toggled(toggled_on: bool) -> void:
	$GridMap.tapToDelete = toggled_on


func _on_foldable_container_folding_changed(is_folded: bool) -> void:
	if is_folded:
		$CanvasLayer/PCControls/FoldableContainer.title = "SHOW CONTROLS"
	else:
		$CanvasLayer/PCControls/FoldableContainer.title = "HIDE CONTROLS"


func _on_okay_pressed() -> void:
	$Welcome.visible = false
	get_tree().paused = false
	$CanvasLayer.visible = true


func _on_level_1_go_pressed() -> void:
	advance_level()
	get_tree().paused = false
	$Level1Complete.visible = false
