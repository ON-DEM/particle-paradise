extends Node3D

@export var particle_scene: PackedScene

const clean_pit_mfr_15_rs_80 = "res://simulations/data/railway/RailwayTrack_clean_pit_mfr_20_rs_70_size_10mm.bin"
const clean_river_mfr_15_rs_80 = "res://simulations/data/railway/RailwayTrack_clean_river_mfr_20_rs_70_size_10mm.bin"
const clean_sea_mfr_15_rs_80 = "res://simulations/data/railway/RailwayTrack_clean_sea_mfr_20_rs_70_size_10mm.bin"

const wet_pit_mfr_25_rs_40 = "res://simulations/data/railway/RailwayTrack_wet_pit_mfr_30_rs_35_size_10mm.bin"
const wet_river_mfr_25_rs_40 = "res://simulations/data/railway/RailwayTrack_wet_river_mfr_30_rs_35_size_10mm.bin"
const wet_sea_mfr_25_rs_40 = "res://simulations/data/railway/RailwayTrack_wet_sea_mfr_30_rs_35_size_10mm.bin"

const leaves_pit_mfr_100_rs_70 = "res://simulations/data/railway/RailwayTrack_leaves_pit_mfr_95_rs_70_size_10mm.bin"
const leaves_river_mfr_100_rs_70 = "res://simulations/data/railway/RailwayTrack_leaves_river_mfr_95_rs_70_size_10mm.bin"
const leaves_sea_mfr_100_rs_70 = "res://simulations/data/railway/RailwayTrack_leaves_sea_mfr_95_rs_70_size_10mm.bin"

const SIM_CONFIGS = {
	"clean_pit_mfr_15_rs_80": {
		"file": clean_pit_mfr_15_rs_80,
		"geometry": []
	},
	"clean_river_mfr_15_rs_80": {
		"file": clean_river_mfr_15_rs_80,
		"geometry": []
	},
	"clean_sea_mfr_15_rs_80": {
		"file": clean_sea_mfr_15_rs_80,
		"geometry": []
	},
	"wet_pit_mfr_25_rs_40": {
		"file": wet_pit_mfr_25_rs_40,
		"geometry": []
	},
	"wet_river_mfr_25_rs_40": {
		"file": wet_river_mfr_25_rs_40,
		"geometry": []
	},
	"wet_sea_mfr_25_rs_40": {
		"file": wet_sea_mfr_25_rs_40,
		"geometry": []
	},
	"leaves_pit_mfr_100_rs_70": {
		"file": leaves_pit_mfr_100_rs_70,
		"geometry": []
	},
	"leaves_river_mfr_100_rs_70": {
		"file": leaves_river_mfr_100_rs_70,
		"geometry": []
	},
	"leaves_sea_mfr_100_rs_70": {
		"file": leaves_sea_mfr_100_rs_70,
		"geometry": []
	},
}

@onready var geometry_nodes = {
}

@onready var particle_multimesh_instance: MultiMeshInstance3D = $Particles1
@onready var multimesh = $Particles1.multimesh

var pid_to_instance := {}
var instance_to_pid := []
var next_instance_id := 0

func setup_multimesh(max_particles: int):
	multimesh.instance_count = max_particles

func bounce_tween(node: Node3D, duration: float = 0.3, amount: float = 0.3):
	var original_scale: Vector3 = node.scale
	var target = Vector3(original_scale.x * (1 - amount), original_scale.y * (1 - amount), original_scale.z * (1 - amount))
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", target, duration * 0.5).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(node, "scale", original_scale, duration * 0.5).set_trans(Tween.TRANS_BOUNCE)
	return tween

func load_simulation(sim_name: String):

	var config = SIM_CONFIGS[sim_name]

	# hide everything
	for node in geometry_nodes.values():
		node.visible = false

	# show required geometry
	for geo_name in config["geometry"]:
		geometry_nodes[geo_name].visible = true
		if geo_name == "G30_SLOPE":
			$G0_SLOPE/StaticBody3D2.collision_layer = 0
		elif geo_name == "G0_SLOPE":
			$G0_SLOPE/StaticBody3D2.collision_layer = 1
		elif geo_name == "HOUSE_G0" or geo_name == "HOUSE_G30":
			continue
		else:
			bounce_tween(geometry_nodes[geo_name]) 

	load_binary(config["file"])
	var wheel_path = config["file"].replace(".bin", "_wheel.bin")
	load_wheel_binary(wheel_path)
	smooth_wheel_frames()

@onready var data_path = "clean_pit_mfr_15_rs_80"

const FPS := 10.0

var frames := []                  # frames[frame][pid] = {pos, size}
var particle_nodes := {}         # pid -> Node3D

var current_frame := 0
var accumulator := 0.0

@onready var cameraPivot = $CameraPivot
@onready var cameraSpring = $CameraPivot/SpringArm3D
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
var cameraInputDirection = Vector2.ZERO
var mouseSensitivity = 0.4

var touches := {}
var last_pinch_distance := -1.0

const PINCH_SENSITIVITY := 0.003

#var wheel_frames = []
var WHEEL_RADIUS = 0.18
var wheel_rotation := 0.0
var last_wheel_pos := Vector3.ZERO

var wheel_frames: Array[float] = []

@onready var wheel = $WHEEL_01/WheelPivot

# ----------------------------
# SPAWN QUEUE SYSTEM (NEW)
# ----------------------------
var spawn_queue: Array = []
var spawn_budget_per_frame := 200   # tweak this (higher = faster load, more hitching)

var active_pids: Array = []

var lastMousePos
var ignore_next_motion = false

func restoreMouse():
	if lastMousePos != null:
		Input.warp_mouse(lastMousePos)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# ----------------------------
# INPUT
# ----------------------------
func _unhandled_input(event: InputEvent) -> void:
	if is_pinching():
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if ignore_next_motion:
			ignore_next_motion = false
			return
		cameraInputDirection = event.screen_relative * mouseSensitivity

func is_pinching() -> bool:
	return touches.size() == 2

func _input(event: InputEvent) -> void:

	
	if event.is_action_pressed("scroll_in"):
		cameraSpring.spring_length = clamp(cameraSpring.spring_length -0.05, 0.05, 8.0)
	if event.is_action_pressed("scroll_out"):
		cameraSpring.spring_length = clamp(cameraSpring.spring_length +0.05, 0.05, 8.0)

	# -------------------
	# Touch handling
	# -------------------

	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
			last_pinch_distance = -1.0

	elif event is InputEventScreenDrag:
		touches[event.index] = event.position

		if touches.size() == 2:
			var positions = touches.values()

			var distance = positions[0].distance_to(positions[1])

			if last_pinch_distance > 0:
				var delta = distance - last_pinch_distance

				cameraSpring.spring_length = clamp(
					cameraSpring.spring_length - delta * PINCH_SENSITIVITY,
					0.05,
					8.0
				)

			last_pinch_distance = distance

# ----------------------------
# READY
# ----------------------------
func _ready():
	$CanvasLayer/VBoxContainer/Options.select(0)
	load_simulation(data_path)
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		mouseSensitivity = 0.04
		scale_ui_fonts($CanvasLayer/VBoxContainer, 1.5)
		scale_ui_fonts($"CanvasLayer/Correct/CenterContainer/HBoxContainer/Next Level", 1.5)
		scale_ui_fonts($CanvasLayer/Correct/CenterContainer/HBoxContainer/Stay, 1.5)
		scale_ui_fonts($"CanvasLayer/You win/CenterContainer/HBoxContainer/Main menu", 1.5)
		scale_ui_fonts($"CanvasLayer/You win/CenterContainer/HBoxContainer/Stay", 1.5)
		scale_ui_fonts($"CanvasLayer/Try again/CenterContainer/Stay", 1.5)
	$Leaves/MultiMeshInstance3D3.multimesh = enable_colors_on_existing_multimesh($Leaves/MultiMeshInstance3D3.multimesh)
	$Leaves/MultiMeshInstance3D2.multimesh = enable_colors_on_existing_multimesh($Leaves/MultiMeshInstance3D2.multimesh)
	$Leaves/MultiMeshInstance3D.multimesh = enable_colors_on_existing_multimesh($Leaves/MultiMeshInstance3D.multimesh)

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

func enable_colors_on_existing_multimesh(multimesh):
	var old_mm = multimesh

	var new_mm = MultiMesh.new()
	new_mm.mesh = old_mm.mesh
	new_mm.transform_format = old_mm.transform_format
	new_mm.use_colors = true
	new_mm.instance_count = old_mm.instance_count

	for i in range(old_mm.instance_count):
		new_mm.set_instance_transform(i, old_mm.get_instance_transform(i))

		var hue = fmod(randf_range(0.0, 0.3) + 0.8, 1.0)
		new_mm.set_instance_color(i,Color.from_hsv(hue, 0.624, 1.898, 1.0))

	return new_mm
#
#func update_wheel(alpha: float):
#
	#if wheel_frames.is_empty():
		#return
#
	#var pos : Vector3
#
	#if current_frame >= wheel_frames.size() - 1:
		#pos = wheel_frames[wheel_frames.size() - 1]
	#else:
		#var a = wheel_frames[current_frame]
		#var b = wheel_frames[current_frame + 1]
		#pos = a.lerp(b, alpha)
#
	## ---- movement delta ----
	#var delta_move = pos - last_wheel_pos
#
	## forward direction assumption:
	## (you may adjust axis if needed)
	#var forward = Vector3(1, 0, 0)
#
	#var distance = delta_move.length()
#
	## accumulate rotation (rolling without slipping)
	#wheel_rotation -= distance / WHEEL_RADIUS
#
	## apply transforms
	#wheel.global_position = pos
#
	## IMPORTANT: choose correct rotation axis
	## most train wheels roll around X axis OR Z axis depending on model
	#wheel.rotation.z = wheel_rotation
#
	#last_wheel_pos = pos
#
#
#func load_wheel_binary(path: String):
#
	#var file = FileAccess.open(path, FileAccess.READ)
#
	#if file == null:
		#push_error("Failed to open wheel file: " + path)
		#return
#
	#var frame_count = file.get_32()
#
	#wheel_frames.clear()
#
	#for i in range(frame_count):
#
		#var x = file.get_float()
		#var y = file.get_float()
		#var z = file.get_float()
#
		#y = 0.0
		#z = 0.35
		## Same coordinate conversion as particles
		#wheel_frames.append(Vector3(x, z, y))
#
	#file.close()
#
	#print("Loaded wheel frames: ", wheel_frames.size())

func load_wheel_binary(path: String):

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("Failed to open wheel file")
		return

	var frame_count = file.get_32()

	wheel_frames.clear()

	for i in range(frame_count):
		wheel_frames.append(file.get_float())

	file.close()


func smooth_wheel_frames():

	if wheel_frames.size() < 3:
		return

	var smoothed: Array[float]

	for i in range(wheel_frames.size()):
		if i > wheel_frames.size() - 3:
			smoothed.append(wheel_frames[i])
			continue
		var prev = wheel_frames[max(i - 1, 0)]
		var curr = wheel_frames[i]
		var next = wheel_frames[min(i + 1, wheel_frames.size() - 1)]

		smoothed.append(
			(prev + curr + next) / 3.0
		)

	wheel_frames = smoothed

var particle_count = 0
# ----------------------------
# LOAD BINARY (UNCHANGED)
# ----------------------------
func load_binary(path: String):

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file")
		return

	particle_count = file.get_32()
	var frame_count = file.get_32()

	var frame_offsets = []
	for i in range(frame_count):
		frame_offsets.append(file.get_32())

	frames = []

	for f in range(frame_count):

		file.seek(frame_offsets[f])

		var entry_count = file.get_32()
		var frame_data = {}

		for i in range(entry_count):

			var pid = file.get_32()

			var x = file.get_float()
			var y = file.get_float()
			var z = file.get_float()
			var size = file.get_float()

			frame_data[pid] = {
				"pos": Vector3(x, z, y),
				"size": size
			}

		frames.append(frame_data)

	# IMPORTANT: initialize multimesh AFTER we know particle_count
		setup_multimesh(particle_count)
		reset_simulation()



# ----------------------------
# QUEUE PARTICLES (NEW)
# ----------------------------
func ensure_particle(pid: int, frame_data: Dictionary) -> int:
	if pid_to_instance.has(pid):
		return pid_to_instance[pid]

	if next_instance_id >= multimesh.instance_count:
		return -1 # safety

	var id = next_instance_id
	next_instance_id += 1

	pid_to_instance[pid] = id
	instance_to_pid.append(pid)

	# initialize transform once
	var data = frame_data[pid]

	var t := Transform3D()
	t.origin = data["pos"]
	t.basis = Basis().scaled(Vector3.ONE * clampf(data["size"], 0.004, 1.0))

	multimesh.set_instance_transform(id, t)

	return id


# ----------------------------
# PROCESS SPAWN QUEUE (NEW)
# ----------------------------
func process_spawn_queue(frame_data: Dictionary):

	var spawned := 0

	while spawn_queue.size() > 0 and spawned < spawn_budget_per_frame:

		var pid = spawn_queue.pop_front()

		if not frame_data.has(pid):
			continue

		var p = particle_scene.instantiate()
		add_child(p)

		particle_nodes[pid] = p
		active_pids.append(pid)

		var data = frame_data[pid]

		p.global_position = data["pos"]

		var s = data["size"]
		p.scale = Vector3.ONE * clampf(s, 0.004, 1.0)

		spawned += 1


var playing := false

# ----------------------------
# MAIN LOOP
# ----------------------------
func _process(delta):

	cameraPivot.rotation.x -= cameraInputDirection.y * delta
	cameraPivot.rotation.x = clamp(cameraPivot.rotation.x, -PI / 3.0, PI / 3.0)
	cameraPivot.rotation.y -= cameraInputDirection.x * delta
	cameraInputDirection = Vector2.ZERO

	if frames.is_empty():
		return

	var frame_time = 1.0 / FPS
	
	if playing:
		$CanvasLayer/VBoxContainer/Play.disabled = true

		accumulator += delta

		while accumulator >= frame_time:
			accumulator -= frame_time
			current_frame += 1

			if current_frame >= frames.size() - 1:
				current_frame = frames.size() - 1
				accumulator = 0.0
				playing = false
				end_reached()
				break
	else:
		$CanvasLayer/VBoxContainer/Play.disabled = false

	var frame_a = frames[current_frame]

	# ensure all particles exist for this frame
	for pid in frame_a.keys():
		ensure_particle(pid, frame_a)
	
	update_interpolated(accumulator / frame_time)


# ----------------------------
# INTERPOLATION
# ----------------------------
func update_interpolated(alpha: float):

	if current_frame >= frames.size() - 1:
		if current_frame < wheel_frames.size():
			wheel.position.x = wheel_frames[current_frame]
		
		var final_frame = frames[frames.size() - 1]

		for pid in final_frame.keys():
			if not pid_to_instance.has(pid):
				continue

			var id = pid_to_instance[pid]
			var data = final_frame[pid]

			var t := Transform3D()
			t.origin = data["pos"]
			t.basis = Basis().scaled(Vector3.ONE * data["size"])

			multimesh.set_instance_transform(id, t)

		return
	
	if current_frame + 1 < wheel_frames.size():

		var x_a = wheel_frames[current_frame]
		var x_b = wheel_frames[current_frame + 1]

		wheel.position.x = lerpf(x_a, x_b, alpha)
	
	var frame_a = frames[current_frame]
	var frame_b = frames[current_frame + 1]

	for pid in pid_to_instance.keys():

		if not frame_a.has(pid):
			continue

		var id = pid_to_instance[pid]

		var a = frame_a[pid]
		var b = frame_b.get(pid, a)

		var pos = a["pos"].lerp(b["pos"], alpha)
		var size = lerp(a["size"], b["size"], alpha)

		var t := Transform3D()
		t.origin = pos
		t.basis = Basis().scaled(Vector3.ONE * size)

		multimesh.set_instance_transform(id, t)
	
	var delta_move = wheel.position - last_wheel_pos
	
	var forward = Vector3(1, 0, 0)
	
	var distance = delta_move.length()
	
	wheel_rotation -= distance / WHEEL_RADIUS

	wheel.rotation.z = wheel_rotation

	last_wheel_pos = wheel.position
	
	for pid in pid_to_instance.keys():
		
		if not frame_b.has(pid):

			var id = pid_to_instance[pid]

			var hidden := Transform3D()
			hidden.origin = Vector3(999999, 999999, 999999)

			multimesh.set_instance_transform(id, hidden)

			continue


# ----------------------------
# DEBUG
# ----------------------------
func debug_particle(pid):
	for f in range(frames.size()):
		if frames[f].has(pid):
			print(f, " -> ", frames[f][pid]["pos"])

func reset_simulation():
	$Crash_Notif.visible = false
	playing = false
	current_frame = 0
	accumulator = 0.0

	pid_to_instance.clear()
	instance_to_pid.clear()
	next_instance_id = 0

	if multimesh:
		for i in range(multimesh.instance_count):
			multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(99999,99999,99999)))

	if not frames.is_empty():
		var frame0 = frames[0]
		for pid in frame0.keys():
			ensure_particle(pid, frame0)

	update_interpolated(0.0)
	
	#if not wheel_frames.is_empty():
		#wheel.global_position = wheel_frames[0]
		#last_wheel_pos = wheel_frames[0]
		#wheel_rotation = 0.0

func end_reached():
	var cur_sim = data_path
	
	#Update to check for correct
	match level:
		0:
			if cur_sim == "clean_pit_mfr_15_rs_80":
				$CanvasLayer/Correct.visible = true
			#else: $Crash_Notif.visible = true
		1:
			if cur_sim == "wet_sea_mfr_25_rs_40":
				$CanvasLayer/Correct.visible = true
		2:
			if cur_sim == "leaves_river_mfr_100_rs_70":
				$"CanvasLayer/You win".visible = true
			#else: $Crash_Notif.visible = true

	if $CanvasLayer/Correct.visible == false and $"CanvasLayer/You win".visible == false:
		$"CanvasLayer/Try again".visible = true




func _on_play_pressed() -> void:
	reset_simulation()
	playing = true
	if $CanvasLayer/Correct.visible == true or $"CanvasLayer/Try again".visible == true or $"CanvasLayer/You win".visible == true:
		$CanvasLayer/Correct.visible = false
		$"CanvasLayer/Try again".visible = false
		$"CanvasLayer/You win".visible = false


func _on_options_item_selected(index: int) -> void:
	playing = false
	if $CanvasLayer/Correct.visible == true or $"CanvasLayer/Try again".visible == true or $"CanvasLayer/You win".visible == true:
		$CanvasLayer/Correct.visible = false
		$"CanvasLayer/Try again".visible = false
		$"CanvasLayer/You win".visible = false

	match level:
		0:
			match index:
				0:
					data_path = "clean_pit_mfr_15_rs_80"
					$Particles1.multimesh.mesh.material.albedo_color = Color("d59947")

				1: # Cylinders
					data_path = "clean_river_mfr_15_rs_80"
					$Particles1.multimesh.mesh.material.albedo_color = Color("9b8565ff")

				2: # Tetrahedron
					data_path = "clean_sea_mfr_15_rs_80"
					$Particles1.multimesh.mesh.material.albedo_color = Color("efc189ff")

		1:
			match index:
				0:
					data_path = "wet_pit_mfr_25_rs_40"
					$Particles1.multimesh.mesh.material.albedo_color = Color("d59947")

				1: # Cylinders
					data_path = "wet_river_mfr_25_rs_40"
					$Particles1.multimesh.mesh.material.albedo_color = Color("9b8565ff")

				2: # Tetrahedron
					data_path = "wet_sea_mfr_25_rs_40"
					$Particles1.multimesh.mesh.material.albedo_color = Color("efc189ff")

		2:
			match index:
				0:
					data_path = "leaves_pit_mfr_100_rs_70"
					$Particles1.multimesh.mesh.material.albedo_color = Color("d59947")

				1: # Cylinders
					data_path = "leaves_river_mfr_100_rs_70"
					$Particles1.multimesh.mesh.material.albedo_color = Color("9b8565ff")

				2: # Tetrahedron
					data_path = "leaves_sea_mfr_100_rs_70"
					$Particles1.multimesh.mesh.material.albedo_color = Color("efc189ff")

	reset_simulation()
	load_simulation(data_path)

var level = 0

func _on_next_level_pressed() -> void:
	$CanvasLayer/Correct.visible = false
	reset_simulation()
	level += 1
	match level:
		0:
			load_simulation(data_path)
			$Particles1.multimesh.mesh.material.albedo_color = Color("d59947")
		1:
			load_simulation("wet_pit_mfr_25_rs_40")
			$Particles1.multimesh.mesh.material.albedo_color = Color("d59947")
			$WorldEnvironment.environment = load("res://simulations/railway/rain.tres")
			var tween = get_tree().create_tween()
			tween.tween_property($DirectionalLight3D, "light_energy", 0.5, 0.5).set_trans(Tween.TRANS_SINE)
			await tween.finished
			$RAIL_02.visible = true
		2:
			load_simulation("leaves_pit_mfr_100_rs_70")
			$Particles1.multimesh.mesh.material.albedo_color = Color("d59947")
			$WorldEnvironment.environment = load("res://simulations/railway/leaves.tres")
			var tween = get_tree().create_tween()
			tween.tween_property($DirectionalLight3D, "light_energy", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
			await tween.finished
			$RAIL_02.visible = false
			$DirectionalLight3D.visible = false
			#$Leaves/MultiMeshInstance3D.material_override = load("res://simulations/railway/fade_in.tres")
			#$Leaves/MultiMeshInstance3D2.material_override = load("res://simulations/railway/fade_in.tres")
			#$Leaves/MultiMeshInstance3D3.material_override = load("res://simulations/railway/fade_in.tres")
			$Leaves.visible = true
			#var tween2 = get_tree().create_tween()
			#tween2.tween_property($Leaves/MultiMeshInstance3D, "material_override:albedo_color", Color("5a330056"), 0.3).set_trans(Tween.TRANS_SINE)
			#await tween2.finished
			#$Leaves/MultiMeshInstance3D.material_override = null
			#$Leaves/MultiMeshInstance3D2.material_override = null
			#$Leaves/MultiMeshInstance3D3.material_override = null
			
			
	$CanvasLayer/VBoxContainer/Options.select(0)

func _on_stay_pressed() -> void:
	if $CanvasLayer/Correct.visible == true or $"CanvasLayer/Try again".visible == true or $"CanvasLayer/You win".visible == true:
		$CanvasLayer/Correct.visible = false
		$"CanvasLayer/Try again".visible = false
		$"CanvasLayer/You win".visible = false


func _on_main_menu_pressed() -> void:
	get_parent().levelSelect()


func _on_container_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		call_deferred("restoreMouse")
	if event.is_action_pressed("middle_click"):
		ignore_next_motion = true
		lastMousePos = get_viewport().get_mouse_position()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_released("middle_click"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		call_deferred("restoreMouse")
	if event.is_action_pressed("left_click"):
		ignore_next_motion = true
		lastMousePos = get_viewport().get_mouse_position()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_released("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		call_deferred("restoreMouse")


func _on_back_pressed() -> void:
	get_parent().levelSelect()


func _on_okay_pressed() -> void:
	$Welcome.visible = false
	$CanvasLayer.visible = true


func _on_buffer_area_area_entered(area: Area3D) -> void:
	$Crash_Notif.visible = true
