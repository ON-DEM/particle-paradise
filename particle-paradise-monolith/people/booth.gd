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
		"particles": 12
	},
	{
		"exhibits": {
			"HOURGLASS": 2,
			"GAME": 2
		},
		"particles": 20
	},
	{
		"exhibits": {
			"HOURGLASS": 2,
			"GAME": 2,
			"LIQUEFACTION": 2
		},
		"particles": 28
	},
	{
		"exhibits": {
			"HOURGLASS": 2,
			"GAME": 2,
			"LIQUEFACTION": 2,
			"TRACK": 2
		},
		"particles": 32
	},
	{
		"exhibits": {
			"HOURGLASS": 1,
			"GAME": 2,
			"LIQUEFACTION": 1,
			"TRACK": 1,
			"AVALANCHE": 1
		},
		"particles": 36
	},
	{
		"exhibits": {
			"HOURGLASS": 80,
			"GAME": 80,
			"LIQUEFACTION": 80,
			"TRACK": 80,
			"AVALANCHE": 80
		},
		"particles": 1000
	}
]

var tooltipList = ["Range+++\nAttraction++", "Range+\nAttraction+++", "Attraction+++/3s", "Range+++=Attraction+\nRange+=Attraction+++", "Attraction++/5s"]

var current_level := 0

var people_count := 0

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
		if onMobile == false:
			$GridMap.selectorVisible = true
			$GridMap/Selector.visible = true
	# reset UI if needed
	update_exhibit_ui()
	$CanvasLayer/VBoxContainer/ItemList.select(0)
	$GridMap.selectedExhibit = $GridMap.hourglassExhibit

func update_exhibit_ui():
	var keys = $GridMap.availableExhibits.keys()

	for i in range($CanvasLayer/VBoxContainer/ItemList.item_count):
		if i < keys.size():
			var k = keys[i]
			$CanvasLayer/VBoxContainer/ItemList.set_item_text(
				i,
				str($GridMap.availableExhibits[k]) + " x " + k
			)
			$CanvasLayer/VBoxContainer/ItemList.set_item_tooltip(i, tooltipList[i])
			$CanvasLayer/VBoxContainer/ItemList.set_item_tooltip_enabled(i, true)




var onMobile = false

func _ready() -> void:
	$SpawnTimer.paused = true
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		onMobile = true
		$CanvasLayer/MobileControls.visible = true
		scale_ui_fonts($CanvasLayer, 1.5)
		$CanvasLayer/PCControls/FoldableContainer/Label.text = "TAP: PLACE EXHIBIT
TAP AFTER TOGGLE: DELETE EXHIBIT"
	get_tree().paused = true
	apply_level(current_level)


func scale_ui_fonts(node: Node, scale: float) -> void:
	# If this node is a Control, check for a font size override
	if node is Control:
		var control := node as Control

		# Get the current override (0 means no override)
		var font_size := control.get_theme_font_size("font_size")

		if font_size > 0:
			control.add_theme_font_size_override(
				"font_size",
				roundi(font_size * scale)
			)

	# Recurse through children
	for child in node.get_children():
		scale_ui_fonts(child, scale)

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

	
	#if $Particles.get_child_count() >= target:
	if people_count >= target:
		get_tree().paused = true
		people_count = 0
		var trans_time = Engine.time_scale * 0.8
		match current_level:
			0:
				$Level1Complete.visible = true
				var tween = get_tree().create_tween()
				tween.set_parallel(true)
				tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tween.tween_property($Level1Complete/TextureRect, "modulate", Color("White"), trans_time).set_trans(Tween.TRANS_LINEAR)
				tween.tween_property($Level1Complete/NextLevel, "modulate", Color("White"), trans_time).set_trans(Tween.TRANS_LINEAR)
				await tween.finished
				if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
					call_deferred("restoreMouse")
			1:
				$Level2Complete.visible = true
				var tween = get_tree().create_tween()
				tween.set_parallel(true)
				tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tween.tween_property($Level2Complete/TextureRect, "modulate", Color("White"), trans_time).set_trans(Tween.TRANS_LINEAR)
				tween.tween_property($Level2Complete/NextLevel, "modulate", Color("White"), trans_time).set_trans(Tween.TRANS_LINEAR)
				await tween.finished
				if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
					call_deferred("restoreMouse")
			2:
				$Level3Complete.visible = true
				var tween = get_tree().create_tween()
				tween.set_parallel(true)
				tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tween.tween_property($Level3Complete/TextureRect, "modulate", Color("White"), trans_time).set_trans(Tween.TRANS_LINEAR)
				tween.tween_property($Level3Complete/NextLevel, "modulate", Color("White"), trans_time).set_trans(Tween.TRANS_LINEAR)
				await tween.finished
				if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
					call_deferred("restoreMouse")
			3:
				$Level4Complete.visible = true
				var tween = get_tree().create_tween()
				tween.set_parallel(true)
				tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tween.tween_property($Level4Complete/TextureRect, "modulate", Color("White"), trans_time).set_trans(Tween.TRANS_LINEAR)
				tween.tween_property($Level4Complete/NextLevel, "modulate", Color("White"), trans_time).set_trans(Tween.TRANS_LINEAR)
				await tween.finished
				if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
					call_deferred("restoreMouse")
			4:
				$Level5Complete.visible = true
				var tween = get_tree().create_tween()
				tween.set_parallel(true)
				tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tween.tween_property($Level5Complete/TextureRect, "modulate", Color("White"), trans_time).set_trans(Tween.TRANS_LINEAR)
				tween.tween_property($Level5Complete/NextLevel, "modulate", Color("White"), trans_time).set_trans(Tween.TRANS_LINEAR)
				await tween.finished
				if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
					call_deferred("restoreMouse")
			5:
				if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
					call_deferred("restoreMouse")
				get_parent().levelSelect()

func advance_level():
	if current_level + 1 >= levels.size():
		return

	# clear world
	for p in $Particles.get_children():
		p.queue_free()

	for e in $GridMap.get_children():
		if e != $GridMap/Selector:
			e.queue_free()

	apply_level(current_level + 1)

func _process(delta: float) -> void:
	#$CanvasLayer/HBoxContainer/HSlider.value = $Particles.get_child_count()
	$CanvasLayer/HBoxContainer/HSlider.value = people_count
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
		if onMobile == false:
			$GridMap.selectorVisible = true
			$GridMap/Selector.visible = true


func _on_item_list_item_selected(index: int) -> void:
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
	$Level0LetsGo.visible = true

func _on_level_0_go_pressed() -> void:
	$Level0LetsGo.visible = false
	get_tree().paused = false
	$CanvasLayer.visible = true

func _on_level_1_go_pressed() -> void:
	advance_level()
	get_tree().paused = false
	$Level1Complete.visible = false


func _on_level_2_go_pressed() -> void:
	advance_level()
	get_tree().paused = false
	$Level2Complete.visible = false


func _on_level_3_go_pressed() -> void:
	advance_level()
	get_tree().paused = false
	$Level3Complete.visible = false


func _on_level_4_go_pressed() -> void:
	advance_level()
	get_tree().paused = false
	$Level4Complete.visible = false


func _on_level_5_go_pressed() -> void:
	advance_level()
	get_tree().paused = false
	$Level5Complete.visible = false


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_parent().levelSelect()


func _on_people_counter_body_entered(body: Node3D) -> void:
	if body.has_method("particleID"):
		people_count += 1


func _on_people_counter_body_exited(body: Node3D) -> void:
	if body.has_method("particleID"):
		people_count = clamp(people_count - 1, 0, 1001)
