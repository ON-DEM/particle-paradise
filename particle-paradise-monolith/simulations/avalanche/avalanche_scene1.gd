extends Node3D

@export var particle_scene: PackedScene

const AVALANCHE_INITIAL_PARTICLES = "res://simulations/data/avalanche/avalancheInitialParticles.bin"

const BASELINE_G0 = "res://simulations/data/avalanche/BaseLine_g0.bin"
const BASELINE_G30 = "res://simulations/data/avalanche/BaseLine_g30.bin"

const CYLINDER_G0_DZ05 = "res://simulations/data/avalanche/Cylinder_g0_dz0.5.bin"
const CYLINDER_G0_DZ10 = "res://simulations/data/avalanche/Cylinder_g0_dz1.0.bin"
const CYLINDER_G0_DZ15 = "res://simulations/data/avalanche/Cylinder_g0_dz1.5.bin"

const CYLINDER_G30_DZ05 = "res://simulations/data/avalanche/Cylinder_g30_dz0.5.bin"
const CYLINDER_G30_DZ10 = "res://simulations/data/avalanche/Cylinder_g30_dz1.0.bin"
const CYLINDER_G30_DZ15 = "res://simulations/data/avalanche/Cylinder_g30_dz1.5.bin"

const TET_G0_DZ05 = "res://simulations/data/avalanche/Tet_g0_dz0.5.bin"
const TET_G0_DZ10 = "res://simulations/data/avalanche/Tet_g0_dz1.0.bin"
const TET_G0_DZ15 = "res://simulations/data/avalanche/Tet_g0_dz1.5.bin"

const TET_G30_DZ05 = "res://simulations/data/avalanche/Tet_g30_dz0.5.bin"
const TET_G30_DZ10 = "res://simulations/data/avalanche/Tet_g30_dz1.0.bin"
const TET_G30_DZ15 = "res://simulations/data/avalanche/Tet_g30_dz1.5.bin"

const WALL_G0_A0_DZ05 = "res://simulations/data/avalanche/Wall_g0_a0_dz0.5.bin"
const WALL_G0_A0_DZ10 = "res://simulations/data/avalanche/Wall_g0_a0_dz1.0.bin"
const WALL_G0_A0_DZ15 = "res://simulations/data/avalanche/Wall_g0_a0_dz1.5.bin"

const WALL_G0_A45_DZ05 = "res://simulations/data/avalanche/Wall_g0_a45_dz0.5.bin"
const WALL_G0_A45_DZ10 = "res://simulations/data/avalanche/Wall_g0_a45_dz1.0.bin"
const WALL_G0_A45_DZ15 = "res://simulations/data/avalanche/Wall_g0_a45_dz1.5.bin"

const WALL_G30_A0_DZ05 = "res://simulations/data/avalanche/Wall_g30_a0_dz0.5.bin"
const WALL_G30_A0_DZ10 = "res://simulations/data/avalanche/Wall_g30_a0_dz1.0.bin"
const WALL_G30_A0_DZ15 = "res://simulations/data/avalanche/Wall_g30_a0_dz1.5.bin"

const WALL_G30_A45_DZ05 = "res://simulations/data/avalanche/Wall_g30_a45_dz0.5.bin"
const WALL_G30_A45_DZ10 = "res://simulations/data/avalanche/Wall_g30_a45_dz1.0.bin"
const WALL_G30_A45_DZ15 = "res://simulations/data/avalanche/Wall_g30_a45_dz1.5.bin"

const SIM_CONFIGS = {

	"AVALANCHE_INITIAL_PARTICLES": {
		"file": AVALANCHE_INITIAL_PARTICLES,
		"geometry": ["G0_SLOPE", "HOUSE_G0"]
	},

	"BASELINE_G0": {
		"file": BASELINE_G0,
		"geometry": ["G0_SLOPE", "HOUSE_G0"]
	},

	"BASELINE_G30": {
		"file": BASELINE_G30,
		"geometry": ["G30_SLOPE", "HOUSE_G30"]
	},

	"CYLINDER_G0_DZ05": {
		"file": CYLINDER_G0_DZ05,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "CYLINDER_G0_DZ05"]
	},

	"CYLINDER_G0_DZ10": {
		"file": CYLINDER_G0_DZ10,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "CYLINDER_G0_DZ10"]
	},

	"CYLINDER_G0_DZ15": {
		"file": CYLINDER_G0_DZ15,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "CYLINDER_G0_DZ15"]
	},

	"CYLINDER_G30_DZ05": {
		"file": CYLINDER_G30_DZ05,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "CYLINDER_G30_DZ05"]
	},

	"CYLINDER_G30_DZ10": {
		"file": CYLINDER_G30_DZ10,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "CYLINDER_G30_DZ10"]
	},

	"CYLINDER_G30_DZ15": {
		"file": CYLINDER_G30_DZ15,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "CYLINDER_G30_DZ15"]
	},

	"TET_G0_DZ05": {
		"file": TET_G0_DZ05,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "TET_G0_DZ05"]
	},

	"TET_G0_DZ10": {
		"file": TET_G0_DZ10,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "TET_G0_DZ10"]
	},

	"TET_G0_DZ15": {
		"file": TET_G0_DZ15,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "TET_G0_DZ15"]
	},

	"TET_G30_DZ05": {
		"file": TET_G30_DZ05,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "TET_G30_DZ05"]
	},

	"TET_G30_DZ10": {
		"file": TET_G30_DZ10,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "TET_G30_DZ10"]
	},

	"TET_G30_DZ15": {
		"file": TET_G30_DZ15,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "TET_G30_DZ15"]
	},

	"WALL_G0_A0_DZ05": {
		"file": WALL_G0_A0_DZ05,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "WALL_G0_A0_DZ05"]
	},

	"WALL_G0_A0_DZ10": {
		"file": WALL_G0_A0_DZ10,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "WALL_G0_A0_DZ10"]
	},

	"WALL_G0_A0_DZ15": {
		"file": WALL_G0_A0_DZ15,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "WALL_G0_A0_DZ15"]
	},

	"WALL_G0_A45_DZ05": {
		"file": WALL_G0_A45_DZ05,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "WALL_G0_A45_DZ05"]
	},

	"WALL_G0_A45_DZ10": {
		"file": WALL_G0_A45_DZ10,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "WALL_G0_A45_DZ10"]
	},

	"WALL_G0_A45_DZ15": {
		"file": WALL_G0_A45_DZ15,
		"geometry": ["G0_SLOPE", "HOUSE_G0", "WALL_G0_A45_DZ15"]
	},

	"WALL_G30_A0_DZ05": {
		"file": WALL_G30_A0_DZ05,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "WALL_G30_A0_DZ05"]
	},

	"WALL_G30_A0_DZ10": {
		"file": WALL_G30_A0_DZ10,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "WALL_G30_A0_DZ10"]
	},

	"WALL_G30_A0_DZ15": {
		"file": WALL_G30_A0_DZ15,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "WALL_G30_A0_DZ15"]
	},

	"WALL_G30_A45_DZ05": {
		"file": WALL_G30_A45_DZ05,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "WALL_G30_A45_DZ05"]
	},

	"WALL_G30_A45_DZ10": {
		"file": WALL_G30_A45_DZ10,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "WALL_G30_A45_DZ10"]
	},

	"WALL_G30_A45_DZ15": {
		"file": WALL_G30_A45_DZ15,
		"geometry": ["G30_SLOPE", "HOUSE_G30", "WALL_G30_A45_DZ15"]
	},

}

@onready var geometry_nodes = {
	"G0_SLOPE": $G0_SLOPE,
	"G30_SLOPE": $G30_SLOPE,
	"HOUSE_G0": $HOUSE_G0,
	"HOUSE_G30": $HOUSE_G30,
	"CYLINDER_G0_DZ05": $CYLINDER_G0_DZ05,
	"CYLINDER_G0_DZ10": $CYLINDER_G0_DZ10,
	"CYLINDER_G0_DZ15": $CYLINDER_G0_DZ15,
	"CYLINDER_G30_DZ05": $CYLINDER_G30_DZ05,
	"CYLINDER_G30_DZ10": $CYLINDER_G30_DZ10,
	"CYLINDER_G30_DZ15": $CYLINDER_G30_DZ15,
	"TET_G0_DZ05": $TET_G0_DZ05,
	"TET_G0_DZ10": $TET_G0_DZ10,
	"TET_G0_DZ15": $TET_G0_DZ15,
	"TET_G30_DZ05": $TET_G30_DZ05,
	"TET_G30_DZ10": $TET_G30_DZ10,
	"TET_G30_DZ15": $TET_G30_DZ15,
	"WALL_G0_A0_DZ05": $WALL_G0_A0_DZ05,
	"WALL_G0_A0_DZ10": $WALL_G0_A0_DZ10,
	"WALL_G0_A0_DZ15": $WALL_G0_A0_DZ15,
	"WALL_G0_A45_DZ05": $WALL_G0_A45_DZ05,
	"WALL_G0_A45_DZ10": $WALL_G0_A45_DZ10,
	"WALL_G0_A45_DZ15": $WALL_G0_A45_DZ15,
	"WALL_G30_A0_DZ05": $WALL_G30_A0_DZ05,
	"WALL_G30_A0_DZ10": $WALL_G30_A0_DZ10,
	"WALL_G30_A0_DZ15": $WALL_G30_A0_DZ15,
	"WALL_G30_A45_DZ05": $WALL_G30_A45_DZ05,
	"WALL_G30_A45_DZ10": $WALL_G30_A45_DZ10,
	"WALL_G30_A45_DZ15": $WALL_G30_A45_DZ15,
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

@export var data_path = "BASELINE_G0"

const FPS := 5.0 

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
		$DirectionalLight3D.shadow_enabled = false

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

func end_reached():
	var cur_sim = data_path
	
	#Update to check for correct
	match level:
		0:
			if cur_sim == "CYLINDER_G0_DZ05":
				$CanvasLayer/Correct.visible = true
		1:
			if cur_sim == "CYLINDER_G0_DZ10":
				$CanvasLayer/Correct.visible = true
		2:
			if cur_sim == "CYLINDER_G0_DZ15":
				$CanvasLayer/Correct.visible = true
		3:
			if cur_sim == "TET_G30_DZ05":
				$CanvasLayer/Correct.visible = true
		4:
			if cur_sim == "WALL_G30_A45_DZ10":
				$CanvasLayer/Correct.visible = true
		5:
			if cur_sim == "WALL_G30_A0_DZ15":
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


# ----------------------------
# DEBUG
# ----------------------------
func debug_particle(pid):
	for f in range(frames.size()):
		if frames[f].has(pid):
			print(f, " -> ", frames[f][pid]["pos"])

func reset_simulation():

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
	playing = true

var selected = 0

func _on_options_item_selected(index: int) -> void:
	playing = false
	
	selected = index
	
	update_cur_sim()

var level = 0

func _on_next_level_pressed() -> void:
	$CanvasLayer/Correct.visible = false
	reset_simulation()
	level += 1
	match level:
		1:
			load_simulation("BASELINE_G0")
		2:
			load_simulation("BASELINE_G0")
		3:
			load_simulation("BASELINE_G30")
		4:
			load_simulation("BASELINE_G30")
		5:
			load_simulation("BASELINE_G30")
	$CanvasLayer/VBoxContainer/Options.select(0)

func _on_stay_pressed() -> void:
	if $CanvasLayer/Correct.visible == true or $"CanvasLayer/Try again".visible == true or $"CanvasLayer/You win".visible == true:
		$CanvasLayer/Correct.visible = false
		$"CanvasLayer/Try again".visible = false
		$"CanvasLayer/You win".visible = false


func _on_main_menu_pressed() -> void:
	get_parent().mainMenu()


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
	get_parent().simulationSelect()


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
	if flat_plane:
		match level:
			0:
				match selected:
					0:
						data_path = "BASELINE_G0"

					1: # Cylinders
						data_path = "CYLINDER_G0_DZ05"

					2: # Tetrahedron
						data_path = "TET_G0_DZ05"

					3: # Deflecting Wall
						data_path = "WALL_G0_A0_DZ05"

					4: # Angled Deflecting Wall
						data_path = "WALL_G0_A45_DZ05"
			1:
				match selected:
					0:
						data_path = "BASELINE_G0"

					1: # Cylinders
						data_path = "CYLINDER_G0_DZ10"

					2: # Tetrahedron
						data_path = "TET_G0_DZ10"

					3: # Deflecting Wall
						data_path = "WALL_G0_A0_DZ10"

					4: # Angled Deflecting Wall
						data_path = "WALL_G0_A45_DZ10"
			2:
				match selected:
					0:
						data_path = "BASELINE_G0"

					1: # Cylinders
						data_path = "CYLINDER_G0_DZ15"

					2: # Tetrahedron
						data_path = "TET_G0_DZ15"

					3: # Deflecting Wall
						data_path = "WALL_G0_A0_DZ15"

					4: # Angled Deflecting Wall
						data_path = "WALL_G0_A45_DZ15"
	else:
		match level:
			0:
				match selected:
					0:
						data_path = "BASELINE_G30"

					1: # Cylinders
						data_path = "CYLINDER_G30_DZ05"

					2: # Tetrahedron
						data_path = "TET_G30_DZ05"

					3: # Deflecting Wall
						data_path = "WALL_G30_A0_DZ05"

					4: # Angled Deflecting Wall
						data_path = "WALL_G30_A45_DZ05"
			1:
				match selected:
					0:
						data_path = "BASELINE_G30"

					1: # Cylinders
						data_path = "CYLINDER_G30_DZ10"

					2: # Tetrahedron
						data_path = "TET_G30_DZ10"

					3: # Deflecting Wall
						data_path = "WALL_G30_A0_DZ10"

					4: # Angled Deflecting Wall
						data_path = "WALL_G30_A45_DZ10"
			2:
				match selected:
					0:
						data_path = "BASELINE_G30"

					1: # Cylinders
						data_path = "CYLINDER_G30_DZ15"

					2: # Tetrahedron
						data_path = "TET_G30_DZ15"

					3: # Deflecting Wall
						data_path = "WALL_G30_A0_DZ15"

					4: # Angled Deflecting Wall
						data_path = "WALL_G30_A45_DZ15"
	
	reset_simulation()
	load_simulation(data_path)

var flat_plane = true

func _on_check_box_toggled(toggled_on: bool) -> void:
	flat_plane = toggled_on
	update_cur_sim()
