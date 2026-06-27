extends Node3D

@export var particle_scene: PackedScene

const AVALANCHE_INITIAL_PARTICLES = "res://simulations/data/avalanche/avalancheInitialParticles.bin"

const HourGlass_pit_03 = "res://simulations/data/hourglass/HourGlass_pit_0.03.bin"
const HourGlass_pit_04 = "res://simulations/data/hourglass/HourGlass_pit_0.04.bin"
const HourGlass_pit_05 = "res://simulations/data/hourglass/HourGlass_pit_0.05_extended.bin"
const HourGlass_pit_06 = "res://simulations/data/hourglass/HourGlass_pit_0.06.bin"
const HourGlass_pit_07 = "res://simulations/data/hourglass/HourGlass_pit_0.07.bin"

const HourGlass_river_03 = "res://simulations/data/hourglass/HourGlass_river_0.03.bin"
const HourGlass_river_04 = "res://simulations/data/hourglass/HourGlass_river_0.04.bin"
const HourGlass_river_05 = "res://simulations/data/hourglass/HourGlass_river_0.05.bin"
const HourGlass_river_06 = "res://simulations/data/hourglass/HourGlass_river_0.06.bin"
const HourGlass_river_07 = "res://simulations/data/hourglass/HourGlass_river_0.07.bin"

const HourGlass_sea_03 = "res://simulations/data/hourglass/HourGlass_sea_0.03.bin"
const HourGlass_sea_04 = "res://simulations/data/hourglass/HourGlass_sea_0.04.bin"
const HourGlass_sea_05 = "res://simulations/data/hourglass/HourGlass_sea_0.05_extended.bin"
const HourGlass_sea_06 = "res://simulations/data/hourglass/HourGlass_sea_0.06.bin"
const HourGlass_sea_07 = "res://simulations/data/hourglass/HourGlass_sea_0.07.bin"


const SIM_CONFIGS = {
	"HourGlass_pit_03": {
		"file": HourGlass_pit_03,
		"geometry": ["HourGlass_pit_003"]
	},
	"HourGlass_pit_04": {
		"file": HourGlass_pit_04,
		"geometry": ["HourGlass_pit_004"]
	},
	"HourGlass_pit_05": {
		"file": HourGlass_pit_05,
		"geometry": ["HourGlass_pit_005"]
	},
	"HourGlass_pit_06": {
		"file": HourGlass_pit_06,
		"geometry": ["HourGlass_pit_006"]
	},
	"HourGlass_pit_07": {
		"file": HourGlass_pit_07,
		"geometry": ["HourGlass_pit_007"]
	},
	"HourGlass_river_03": {
		"file": HourGlass_river_03,
		"geometry": ["HourGlass_pit_003"]
	},
	"HourGlass_river_04": {
		"file": HourGlass_river_04,
		"geometry": ["HourGlass_pit_004"]
	},
	"HourGlass_river_05": {
		"file": HourGlass_river_05,
		"geometry": ["HourGlass_pit_005"]
	},
	"HourGlass_river_06": {
		"file": HourGlass_river_06,
		"geometry": ["HourGlass_pit_006"]
	},
	"HourGlass_river_07": {
		"file": HourGlass_river_07,
		"geometry": ["HourGlass_pit_007"]
	},
	"HourGlass_sea_03": {
		"file": HourGlass_sea_03,
		"geometry": ["HourGlass_pit_003"]
	},
	"HourGlass_sea_04": {
		"file": HourGlass_sea_04,
		"geometry": ["HourGlass_pit_004"]
	},
	"HourGlass_sea_05": {
		"file": HourGlass_sea_05,
		"geometry": ["HourGlass_pit_005"]
	},
	"HourGlass_sea_06": {
		"file": HourGlass_sea_06,
		"geometry": ["HourGlass_pit_006"]
	},
	"HourGlass_sea_07": {
		"file": HourGlass_sea_07,
		"geometry": ["HourGlass_pit_007"]
	},
}

@onready var geometry_nodes = {
	"HourGlass_pit_003": $HourGlass_pit_003,
	"HourGlass_pit_004": $HourGlass_pit_004,
	"HourGlass_pit_005": $HourGlass_pit_005,
	"HourGlass_pit_006": $HourGlass_pit_006,
	"HourGlass_pit_007": $HourGlass_pit_007,
}

@onready var particle_multimesh_instance: MultiMeshInstance3D = $Particles1
@onready var multimesh = $Particles1.multimesh

var pid_to_instance := {}
var instance_to_pid := []
var next_instance_id := 0

func setup_multimesh(max_particles: int):
	multimesh.instance_count = max_particles




func bounce_tween(node: Node3D, duration: float = 0.3, amount: float = 0.2):
	var original_scale: Vector3 = node.scale
	var target = Vector3(original_scale.x * (1 + amount), original_scale.y * (1), original_scale.z * (1 + amount))
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

@export var data_path = "HourGlass_pit_03"

const FPS := 12.5

var frames := []                  # frames[frame][pid] = {pos, size}
var particle_nodes := {}         # pid -> Node3D

var current_frame := 0
var accumulator := 0.0

@onready var cameraPivot = $CameraPivot
@onready var cameraSpring = $CameraPivot/SpringArm3D
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
var cameraInputDirection = Vector2.ZERO
var mouseSensitivity = 0.4

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
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if ignore_next_motion:
			ignore_next_motion = false
			return
		cameraInputDirection = event.screen_relative * mouseSensitivity

func _input(event: InputEvent) -> void:

	
	if event.is_action_pressed("scroll_in"):
		cameraSpring.spring_length = clamp(cameraSpring.spring_length -0.05, 0.05, 4.0)
	if event.is_action_pressed("scroll_out"):
		cameraSpring.spring_length = clamp(cameraSpring.spring_length +0.05, 0.05, 4.0)


# ----------------------------
# READY
# ----------------------------
func _ready():
	$CanvasLayer/VBoxContainer/Options.select(0)
	$CanvasLayer/VBoxContainer2/HBoxContainer/ConcreteOptions.select(0)
	load_simulation(data_path)
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		mouseSensitivity = 0.04
		scale_ui_fonts($CanvasLayer, 1.5)


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
var update_time := false
var time = 0.00
# ----------------------------
# MAIN LOOP
# ----------------------------
func _process(delta):
	if update_time:
		time = snappedf(10.0 - $CanvasLayer/VBoxContainer3/PanelContainer/HourglassTimer.time_left, 0.01)
		if time > 3.0 and time < 4.0:
			$CanvasLayer/VBoxContainer3/PanelContainer/TimerLabel.modulate = Color("Green")
		if time > 4.0 or time < 3.0:
			$CanvasLayer/VBoxContainer3/PanelContainer/TimerLabel.modulate = Color("White")
		if str(time).length() < 4:
			$CanvasLayer/VBoxContainer3/PanelContainer/TimerLabel.text = str(time) + "0"
		else:
			$CanvasLayer/VBoxContainer3/PanelContainer/TimerLabel.text = str(time)

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

func end_reached():
	#for pid in pid_to_instance.keys():
		#if frames[current_frame][pid]["pos"].y > 0.2:
			#print(pid)
	update_time = false
	var cur_sim = data_path
	
	#Update to check for correct
	if flat_plane:
		match level:
			0:
				if cur_sim == "HourGlass_pit_06":
					$CanvasLayer/Correct.visible = true
			1:
				if cur_sim == "HourGlass_river_04" or cur_sim == "HourGlass_river_05":
					$CanvasLayer/Correct.visible = true
			2:
				if cur_sim == "HourGlass_sea_04" or cur_sim == "HourGlass_sea_05":
					$"CanvasLayer/You win".visible = true

	if $CanvasLayer/Correct.visible == false and $"CanvasLayer/You win".visible == false:
		$"CanvasLayer/Try again".visible = true



# ----------------------------
# INTERPOLATION
# ----------------------------
func update_interpolated(alpha: float):

	if current_frame >= frames.size() - 1:
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
	update_time = false
	$CanvasLayer/VBoxContainer3/PanelContainer/TimerLabel.modulate = Color("White")
	$CanvasLayer/VBoxContainer3/PanelContainer/HourglassTimer.stop()
	$CanvasLayer/VBoxContainer3/PanelContainer/TimerLabel.text = "0.00"
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

func _on_play_pressed() -> void:
	reset_simulation()
	if level == 0:
		$AnimationPlayer.play("HourglassFlip")
	elif level == 1:
		$AnimationPlayer.play("HourglassFlip_2")
	elif level == 2:
		$AnimationPlayer.play("HourglassFlip_3")
	playing = true
	if $CanvasLayer/Correct.visible == true or $"CanvasLayer/Try again".visible == true or $"CanvasLayer/You win".visible == true:
		$CanvasLayer/Correct.visible = false
		$"CanvasLayer/Try again".visible = false
		$"CanvasLayer/You win".visible = false

var selected = 0

func _on_options_item_selected(index: int) -> void:
	playing = false
	
	selected = index
	
	update_cur_sim()

var level = 0

func _on_next_level_pressed() -> void:
	$CanvasLayer/Correct.visible = false
	update_cur_sim()
	level += 1
	match level:
		1:
			load_simulation("HourGlass_river_03")
			$Particles1.multimesh.mesh.material.albedo_color = Color("9b8565ff")
			$CanvasLayer/CurSand.text = "CURRENT SAND: RIVER SAND"
		2:
			load_simulation("HourGlass_sea_03")
			$Particles1.multimesh.mesh.material.albedo_color = Color("efc189ff")
			$CanvasLayer/CurSand.text = "CURRENT SAND: SEA SAND"

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


func _on_concrete_options_item_selected(index: int) -> void:
	match index:
		0:
			level = 0

		1:
			level = 1

		2:
			level = 2
	
	update_cur_sim()

func update_cur_sim():
	$AnimationPlayer.play("RESET")
	if $CanvasLayer/Correct.visible == true or $"CanvasLayer/Try again".visible == true or $"CanvasLayer/You win".visible == true:
		$CanvasLayer/Correct.visible = false
		$"CanvasLayer/Try again".visible = false
		$"CanvasLayer/You win".visible = false
	if flat_plane:
		match level:
			0:
				match selected:
					0:
						data_path = "HourGlass_pit_03"

					1:
						data_path = "HourGlass_pit_04"

					2:
						data_path = "HourGlass_pit_05"

					3:
						data_path = "HourGlass_pit_06"

					4:
						data_path = "HourGlass_pit_07"
			1:
				match selected:
					0:
						data_path = "HourGlass_river_03"

					1:
						data_path = "HourGlass_river_04"

					2:
						data_path = "HourGlass_river_05"

					3:
						data_path = "HourGlass_river_06"

					4:
						data_path = "HourGlass_river_07"
			2:
				match selected:
					0:
						data_path = "HourGlass_sea_03"

					1:
						data_path = "HourGlass_sea_04"

					2:
						data_path = "HourGlass_sea_05"

					3:
						data_path = "HourGlass_sea_06"

					4:
						data_path = "HourGlass_sea_07"
	
	reset_simulation()
	load_simulation(data_path)

var flat_plane = true

func _on_check_box_toggled(toggled_on: bool) -> void:
	flat_plane = toggled_on
	update_cur_sim()


func _on_okay_pressed() -> void:
	$Welcome.visible = false
	$CanvasLayer.visible = true

func timer_start():
	$CanvasLayer/VBoxContainer3/PanelContainer/HourglassTimer.start()
	update_time = true
