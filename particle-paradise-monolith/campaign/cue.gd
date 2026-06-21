extends StaticBody2D

@onready var start_pos = global_position

var dragOffset := 0.0
var verticalOffset := 0.0
var cueRotation := 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func update_cue_central(centralPosition):
	verticalOffset = centralPosition
	update_cue_transform()

func update_cue_radial(radialPosition):
	cueRotation = radialPosition * PI / 180
	update_cue_transform()
	
func update_cue_drag(force):
	dragOffset = force
	update_cue_transform()
	
func update_cue_transform():
	rotation = cueRotation
	
	var tip_vector = $Tip.global_position - global_position
	var tipVecNormalized = tip_vector.normalized()
	var tangent = tipVecNormalized.orthogonal().normalized()
	
	var drag_vec = dragOffset * tipVecNormalized
	var vertical_vec = tangent * verticalOffset

	global_position = start_pos + drag_vec + vertical_vec
