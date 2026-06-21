extends RigidBody3D

var residenceTime = 0
var engaged = []

var boredom = 0.0
var canExit = false

func particleID():
	pass

func _on_timer_timeout() -> void:
	residenceTime += 0.2

func _ready():
	$MeshInstance3D.set_surface_override_material(0, $MeshInstance3D.mesh.material.duplicate())
	$Hat.make_random_visible()

func _process(delta):
	boredom = clampf(boredom, 0.0, 10)
	if engaged.size() > 0:
		if boredom < 0.5:
			$MeshInstance3D.get_active_material(0).albedo_color = $MeshInstance3D.get_active_material(0).albedo_color.lerp(Color("Green"), 1*delta)
		else:
			$MeshInstance3D.get_active_material(0).albedo_color = Color("Green").lerp(Color("496cff"), boredom/10)
	else:
		$MeshInstance3D.get_active_material(0).albedo_color = $MeshInstance3D.get_active_material(0).albedo_color.lerp(Color("496cff"),delta)
	if boredom >= 10.0:
		canExit = true
