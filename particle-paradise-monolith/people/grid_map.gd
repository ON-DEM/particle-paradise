extends GridMap

@onready var hourglassExhibit = preload("res://people/hourglass_exhibit.tscn")
@onready var gameExhibit = preload("res://people/game_exhibit.tscn")
@onready var liquefactionExhibit = preload("res://people/liquefaction_exhibit.tscn")

@onready var exhibits = [hourglassExhibit, gameExhibit, liquefactionExhibit]

@onready var hourMesh = $Selector/hourglass_exhibit_mesh
@onready var gameMesh = $Selector/game_exhibit_mesh
@onready var liqMesh = $Selector/liquefaction_exhibit_mesh

const RAY_LENGTH = 4444
const GRID_SIZE = 40
const GRID_OFFSET = 20

const CHECK_INTERVAL = 0.01

var current_selection: Vector3i = Vector3i.ZERO
var time_since_last_check: float = 0.0

@onready var selectedExhibit = hourglassExhibit

var selectorVisible = true
var canMakeSelectorVisible = true

var availableExhibits = {"HOURGLASS": 4, "GAME": 4, "LIQUEFACTION": 2}

var tapToDelete = false
var onMobile = false

# GRID NOW STORES NODE REFERENCES
var grid = []

func _ready():
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		canMakeSelectorVisible = false
		onMobile = true

	grid.resize(GRID_SIZE)

	for x in range(GRID_SIZE):
		grid[x] = []
		grid[x].resize(GRID_SIZE)
		for z in range(GRID_SIZE):
			grid[x][z] = null


func _process(delta):
	if onMobile:
		return

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
	if get_parent().boothOpen == true:
		return

	var hit = {}

	# Mouse
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hit = get_mouse_hit(event.position)

			if tapToDelete:
				clear_exhibit_from_hit(hit)
			else:
				make_new_exhibit_from_hit(hit)

		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			hit = get_mouse_hit(event.position)
			clear_exhibit_from_hit(hit)

	# Touch
	elif event is InputEventScreenTouch and event.pressed:
		hit = get_mouse_hit(event.position)

		if tapToDelete:
			clear_exhibit_from_hit(hit)
		else:
			make_new_exhibit_from_hit(hit)


# -----------------------------
# RAYCAST
# -----------------------------
func get_mouse_hit(screen_pos: Vector2 = Vector2(-1, -1)):
	var camera = $".."/CameraPivot/SpringArm3D/Camera3D

	if screen_pos == Vector2(-1, -1):
		screen_pos = get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * RAY_LENGTH

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = (1 << 1)
	query.collide_with_areas = false

	return get_world_3d().direct_space_state.intersect_ray(query)


# -----------------------------
# GRID HELPERS
# -----------------------------
func get_grid_pos(cell: Vector3i) -> Vector2i:
	return Vector2i(cell.x + GRID_OFFSET, cell.z + GRID_OFFSET)


func is_valid_cell(x: int, z: int) -> bool:
	return x >= 0 and x < GRID_SIZE and z >= 0 and z < GRID_SIZE

func is_path_cell(x: int, z: int) -> bool:
	var center = GRID_SIZE / 2

	# vertical path
	if x >= center -1 and x <= center:
		return true

	## horizontal path
	#if z >= center - 1 and z <= center + 1:
		#return true

	return false

func is_cell_occupied(cell_pos: Vector3i) -> bool:
	var p = get_grid_pos(cell_pos)

	if not is_valid_cell(p.x, p.y):
		return false

	if grid[p.x][p.y] != null:
		return true

	# optional physics fallback (kept from your system)
	var world_pos = map_to_local(cell_pos)
	world_pos.y = 0.5

	var shape = BoxShape3D.new()
	shape.size = Vector3(0.95, 0.95, 0.95)

	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), world_pos)
	query.collision_mask = (1 << 0)

	return get_world_3d().direct_space_state.intersect_shape(query).size() > 0


# -----------------------------
# PLACE
# -----------------------------
func make_new_exhibit_from_hit(hit):
	if hit.is_empty():
		return

	var cell = local_to_map(hit.position)
	make_new_exhibit(cell)


func make_new_exhibit(pos: Vector3i):
	var p = get_grid_pos(pos)

	if not is_valid_cell(p.x, p.y):
		return

	if is_path_cell(p.x, p.y):
		return

	if grid[p.x][p.y] != null:
		return

	var world_pos = map_to_local(pos)
	world_pos.y = 0.5

	if is_cell_occupied(pos):
		return

	var new_exhibit = selectedExhibit.instantiate()
	var type = exhibitToString(new_exhibit)

	if availableExhibits[type] <= 0:
		new_exhibit.queue_free()
		return

	availableExhibits[type] -= 1

	add_child(new_exhibit)
	new_exhibit.global_position = world_pos

	grid[p.x][p.y] = new_exhibit


# -----------------------------
# DELETE (FIXED — NO RAYCASTS)
# -----------------------------
func clear_exhibit_from_hit(hit):
	if hit.is_empty():
		return

	var cell = local_to_map(hit.position)
	clear_exhibit(cell)


func clear_exhibit(pos: Vector3):
	var p = get_grid_pos(pos)

	if not is_valid_cell(p.x, p.y):
		return

	var node = grid[p.x][p.y]
	if node == null:
		return

	if not is_instance_valid(node):
		grid[p.x][p.y] = null
		return

	var type = exhibitToString(node)
	if availableExhibits.has(type):
		availableExhibits[type] += 1

	node.queue_free()
	grid[p.x][p.y] = null


# -----------------------------
# SELECTOR (unchanged)
# -----------------------------
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

	var p = get_grid_pos(selection)
	

	if is_valid_cell(p.x, p.y) and grid[p.x][p.y] != null:
		$Selector.get_active_material(0).stencil_color = Color("1485ffff")
		$Selector.get_active_material(0).albedo_color = Color("9bd4ff40")
		return

	if is_path_cell(p.x, p.y):
		$Selector.get_active_material(0).stencil_color = Color("555555")
		$Selector.get_active_material(0).albedo_color = Color("33333340")
		return

	if is_cell_occupied(selection):
		$Selector.get_active_material(0).stencil_color = Color("red")
		$Selector.get_active_material(0).albedo_color = Color("fabab640")
	else:
		$Selector.get_active_material(0).stencil_color = Color("00b900")
		$Selector.get_active_material(0).albedo_color = Color("6ceb9040")


# -----------------------------
# UTIL
# -----------------------------
func revealSelector():
	if selectorVisible and canMakeSelectorVisible:
		$Selector.visible = true


func exhibitToString(exhibit):
	if exhibit.has_method("hourglassID"):
		return "HOURGLASS"
	elif exhibit.has_method("gameID"):
		return "GAME"
	elif exhibit.has_method("liqID"):
		return "LIQUEFACTION"
