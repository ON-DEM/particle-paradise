extends GridMap

@onready var hourglassExhibit = preload("res://people/hourglass_exhibit.tscn")
@onready var gameExhibit = preload("res://people/game_exhibit.tscn")
@onready var liquefactionExhibit = preload("res://people/liquefaction_exhibit.tscn")

@onready var exhibits = [hourglassExhibit, gameExhibit, liquefactionExhibit]

@onready var hourMesh = $Selector/hourglass_exhibit_mesh
@onready var gameMesh = $Selector/game_exhibit_mesh
@onready var liqMesh = $Selector/liquefaction_exhibit_mesh

const RAY_LENGTH = 4444
const CELL_SIZE = 1.0
const CHECK_INTERVAL = 0.01 # seconds between selector updates

var current_selection: Vector3i = Vector3i.ZERO
var time_since_last_check: float = 0.0

@onready var selectedExhibit = hourglassExhibit

var selectorVisible = true

var availableExhibits = {"HOURGLASS": 4, "GAME": 4, "LIQUEFACTION": 2}


var grid = [[]]

func _ready():
	for i in range(0,40):
		grid.append([])
		for j in range(0,40):
			grid[i].append([0])

func _process(delta):
	# Update the selector periodically
	time_since_last_check += delta
	if time_since_last_check >= CHECK_INTERVAL:
		time_since_last_check = 0.0
		
		var hit = get_mouse_hit()
		if hit:
			var selection = local_to_map(hit.position)
			current_selection = selection
			update_selector(selection)
		else:
			$Selector.visible = false

func _input(event):
	if get_parent().boothOpen == false:
		if Input.is_action_just_pressed("left_click"):
			# Place a block at the last known selection
			if current_selection != null:
				make_new_exhibit(current_selection)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			# Place a block at the last known selection
			if current_selection != null:
				clear_exhibit(current_selection)

# 🔹 Handles the raycast from the mouse
func get_mouse_hit():
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = $".."/CameraPivot/SpringArm3D/Camera3D
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = (1 << 1) # layer 2
	query.collide_with_areas = false
	
	return get_world_3d().direct_space_state.intersect_ray(query)

func prettyPrintGrid():
	var string = ""
	for i in range(0,40):
		string = string + "\n"
		for j in range(0,40):
			string = string + str(grid[i][j][0])
	print(string)


# 🔹 Box + top-to-bottom ray check
func is_cell_occupied(cell_pos: Vector3i) -> bool:
	
	var space_state = get_world_3d().direct_space_state
	
	# ----- BOX CHECK (slightly smaller for adjacency) -----
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.95, 0.95, 0.95)
	
	var world_pos = map_to_local(cell_pos)
	world_pos.y = 0.5
	
	if grid[int(floor(world_pos.x))+20][int(floor(world_pos.z))+20][0] == 1:
		return true
	
	var box_query = PhysicsShapeQueryParameters3D.new()
	box_query.shape = shape
	box_query.transform = Transform3D(Basis(), world_pos)
	box_query.collision_mask = (1 << 0) # layer 1
	box_query.collide_with_areas = false
	
	if space_state.intersect_shape(box_query).size() > 0:
		return true
	
	# ----- RAYCHECK TOP -> BOTTOM (catch fully contained objects) -----
	var ray_from = world_pos + Vector3(0, 0.5, 0)
	var ray_to   = world_pos + Vector3(0, -0.5, 0)
	
	var ray_query = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	ray_query.collision_mask = (1 << 0)
	ray_query.collide_with_areas = false
	
	if space_state.intersect_ray(ray_query):
		return true
	
	return false

# 🔹 Visual selector logic
func update_selector(selection: Vector3i):
	revealSelector()
	var world_pos = map_to_local(selection)
	world_pos.y = 0.5
	
	for i in $Selector.get_children():
		i.visible = false
	
	match selectedExhibit:
		hourglassExhibit:
			hourMesh.visible = true
		gameExhibit:
			gameMesh.visible = true
		liquefactionExhibit:
			liqMesh.visible = true
	
	$Selector.global_position = world_pos
	
	if grid[int(floor(world_pos.x))+20][int(floor(world_pos.z))+20][0] == 1:
		$Selector.get_active_material(0).stencil_color = Color("1485ffff")
		$Selector.get_active_material(0).albedo_color = Color("9bd4ff40")
		return
	
	if is_cell_occupied(selection):
		$Selector.get_active_material(0).stencil_color = Color("red")
		$Selector.get_active_material(0).albedo_color = Color("fabab640")
	else:
		$Selector.get_active_material(0).stencil_color = Color("00b900")
		$Selector.get_active_material(0).albedo_color = Color("6ceb9040")

# 🔹 Placement logic
func make_new_exhibit(pos: Vector3i):
	var hit = get_mouse_hit()
	if hit.size() == 0:
		return
	
	var world_pos = map_to_local(pos)
	world_pos.y = 0.5
	
	if grid[int(floor(world_pos.x))+20][int(floor(world_pos.z))+20][0] == 1:
		return
	
	var new_exhibit = selectedExhibit.instantiate()
	
	if availableExhibits[exhibitToString(new_exhibit)] == 0:
		new_exhibit.queue_free()
		return
	

	
	if is_cell_occupied(pos):
		new_exhibit.queue_free()
		return

	availableExhibits[exhibitToString(new_exhibit)] -= 1
	grid[int(floor(world_pos.x))+20][int(floor(world_pos.z))+20][0] = 1
	
	add_child(new_exhibit)
	new_exhibit.global_position = world_pos



func clear_exhibit(pos: Vector3):
	var hit = get_mouse_hit()
	if hit.size() == 0:
		return
	
	if !is_cell_occupied(pos):
		return
	
	var world_pos = map_to_local(pos)
	
	if !grid[int(floor(world_pos.x))+20][int(floor(world_pos.z))+20][0] == 1:
		return
	
	for i in get_children():
		if i.global_position == Vector3(pos.x + 0.5, pos.y + 0.5, pos.z + 0.5):
			if i.has_method("exhibitID"):
				if i.is_queued_for_deletion():
					continue
				availableExhibits[exhibitToString(i)] += 1
				i.queue_free()
				grid[int(floor(world_pos.x))+20][int(floor(world_pos.z))+20][0] = 0

# 🔹 Debug visualisation
func debug_draw_box(cell_pos: Vector3i):
	var box = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.95, 0.95, 0.95)
	box.mesh = mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0, 0, 0.2)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	box.material_override = mat
	
	var world_pos = map_to_local(cell_pos)
	world_pos.y = 0.5
	
	add_child(box)
	box.global_position = world_pos
	await get_tree().create_timer(0.1).timeout
	box.queue_free()


func revealSelector():
	if selectorVisible == true:
		$Selector.visible = true
	else:
		return

func exhibitToString(exhibit):
	if exhibit.has_method("hourglassID"):
		return "HOURGLASS"
	elif exhibit.has_method("gameID"):
		return "GAME"
	elif exhibit.has_method("liqID"):
		return "LIQUEFACTION"
