extends Control

var force = 0
var speed = 0
var angularSpeed = 0

var initial_position = Vector2.ZERO

var stop_timer_running := false
var shot_in_progress := false

@onready var level1 = preload("res://campaign/Levels/level_1.tscn")
@onready var level2 = preload("res://campaign/Levels/level_2.tscn")
@onready var level3 = preload("res://campaign/Levels/level_3.tscn")
@onready var level4 = preload("res://campaign/Levels/level_4.tscn")
@onready var level5 = preload("res://campaign/Levels/level_5.tscn")
#@onready var level6 = preload("res://campaign/Levels/level_6.tscn")
#@onready var level7 = preload("res://campaign/Levels/level_7.tscn")
# add other levels here
@onready var levels = [level1, level2, level3, level4, level5]
#@onready var levels = [level1, level5]


var levelCounter = 0
@onready var current_level2 = levels[levelCounter]
@onready var maxLevelCounter = levels.size()

@onready var current_level = $Level1

var force_level5 := 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_line_edit_text_changed(new_text: String) -> void:
	var filtered := ""
	var cue_ball = current_level.get_node("CueBall/Ball")
	#var lowerLimit = int(cue_ball.sleep_speed)
	var lowerLimit = 0
	var upperLimit = 100
	print('lower limit: ', lowerLimit)
	 
	for c in new_text:
		if c in "0123456789":
			filtered += c

	## Avoid recursion loop
	if filtered != new_text:
		$CanvasLayer/GUI/Numbers/Force/LineEdit.text = filtered
		
	if filtered == "":
		$CanvasLayer/GUI/Numbers/Force/LineEdit.text = ""
		return
		
	force = int(filtered)

	if int(filtered) > upperLimit || int(filtered) < lowerLimit:
		force = clamp(int(filtered), lowerLimit, upperLimit)
		$CanvasLayer/GUI/Numbers/Force/LineEdit.text = str(force)
		$CanvasLayer/GUI/Numbers/Force/LineEdit.caret_column = 3
		
	#$CanvasLayer/GUI/Numbers/Force/Container/TextureProgressBar.value = force
	
	var cue = current_level.get_node("Cue")
	cue.update_cue_drag(force)
	

func _on_button_pressed() -> void:
	# applies lower bound for the force, but only after pressing the hit button
	# this avoids interference with the UI while typing a force value
	print('force when hit button pressed: ', force)
	if force < 1:
		force = 1
		$CanvasLayer/GUI/Numbers/Force/LineEdit.text = str(force)
	
	apply_shot(force)
	$CanvasLayer/GUI/Buttons/Button.disabled = true
	
func apply_shot(force):
	print('force in apply_shot: ', force)
	var cue = current_level.get_node("Cue")
	var cue_ball = current_level.get_node("CueBall/Ball")
	var tip = current_level.get_node("Cue/Tip")

	initial_position = cue_ball.global_position
	print('initial position: ', initial_position)
	var forcePercentage = force / 100.0
	var max_force := 1.0
	
	var effective_force = min(forcePercentage, max_force)
	
	var direction = Vector2(1.0, 0.0).normalized()
	var offset = Vector2.ZERO
	if levelCounter == 0:
		pass
	else:
		var ball_pos = cue_ball.global_position
		var cue_pos = cue.global_position
		var contactNormal = (ball_pos - cue_pos) / (ball_pos - cue_pos).length()
		#offset = Vector2(0.0, 10.0)
		direction = contactNormal
		#print("ball_pos: ", ball_pos)
		#print("cue_pos: ", cue_pos)
		#print("contactNormal: ", contactNormal)
		#print("offset has to be applied")
		var tip_pos = tip.global_position
		#print("tip_pos: ", tip_pos)
	#var direction = drag_vector.normalized()
#
	var impulse = direction * effective_force
#
	shot_in_progress = true
	cue.update_cue_drag(0)
	## Apply to the cue ball (recommended)
	cue_ball.apply_impulse(impulse, offset)
	print("impulse: ", impulse)


func _on_reset_button_pressed() -> void:
	var mass = $CanvasLayer/GUI/Sliders/MassSlider.value
	for nodes in get_tree().get_nodes_in_group("balls"):
		nodes.remove_from_group("balls")
	stop_timer_running = false
	shot_in_progress = false
	var newLevel = levels[levelCounter].instantiate()
	add_child(newLevel)
	current_level.queue_free()
	current_level = newLevel
	
	$CanvasLayer/GUI/Buttons/Button.disabled = false
	if force != 0:
		$CanvasLayer/GUI/Numbers/Force/LineEdit.text = str(force)
		$CanvasLayer/GUI/Numbers/Force/Container/HSlider.value = force
	else:
		$CanvasLayer/GUI/Numbers/Force/Container/HSlider.value = 1

	# levelCounter dependent on where the level sits in the order of levels
	# find a solution that is independent of this
	if levelCounter == 4:
		load_level_five()
	
	var cue = current_level.get_node("Cue")
	cue.update_cue_drag(force)
	cue.update_cue_central($CanvasLayer/GUI/Sliders/PositionSlider.value)
	cue.update_cue_radial($CanvasLayer/GUI/Sliders/RadialSlider.value)
	
	if levelCounter == 4:
		$CanvasLayer/GUI/Sliders/MassSlider.value = mass
		var second_ball = current_level.get_node("CueBall/Ball2")
		var collision = second_ball.get_node("CollisionShape2D")
		var mesh = second_ball.get_node("MeshInstance2D")
		second_ball.mass = mass
		var mass_slider = get_node("CanvasLayer/GUI/Sliders/MassSlider")
		var min_scale = 1.0
		var max_scale = 4.0
		var scaleValue = remap(mass, mass_slider.min_value, mass_slider.max_value, min_scale, max_scale)
		#second_ball.scale = Vector2(scaleValue, scaleValue)
		collision.scale = Vector2(scaleValue, scaleValue)
		mesh.scale = Vector2(scaleValue, scaleValue)
	
#func prepare_next_try():
	#print('next try is called')
	#$CanvasLayer/GUI/Buttons/Button.disabled = false
	#$CanvasLayer/GUI/Numbers/Force/LineEdit.text = ""
	#
	## levelCounter dependent on where the level sits in the order of levels
	## find a solution that is independent of this
	#if levelCounter == 1:
		##var force_level5 := 100
		#force = force_level5
		#$CanvasLayer/GUI/Numbers/Force/LineEdit.editable = false
		#$CanvasLayer/GUI/Numbers/Force/LineEdit.text = str(force)
		#$CanvasLayer/GUI/Numbers/Force/Container/TextureProgressBar.value = force
	#get_tree().paused = false


func _physics_process(delta):
	#print("shot_in_progress =", shot_in_progress)
	#print("all_balls_stopped =", all_balls_stopped())

	var cue_ball = current_level.get_node("CueBall/Ball")
	# potentially change denominator for speed, currently based on trial and error
	speed = cue_ball.linear_velocity.length() / 10.0
	angularSpeed = cue_ball.angular_velocity

	# display values to velocity bar
	$CanvasLayer/GUI/Numbers/Velocity/TextureProgressBar.value = speed
	$CanvasLayer/GUI/Numbers/Velocity/LineEdit.text = str(int(speed))
	
	
	var balls = get_tree().get_nodes_in_group("balls")
	if balls.size() == 2:
		#print("amount of balls: ", balls.size())
		var second_ball = current_level.get_node("CueBall/Ball2")
		var speed_second_ball = second_ball.linear_velocity.length() / 10.0
		
		$CanvasLayer/GUI/Numbers/VelocityBall2/TextureProgressBar.value = speed_second_ball
		$CanvasLayer/GUI/Numbers/VelocityBall2/LineEdit.text = str(int(speed_second_ball))
	
	# display values on angular velocity bar
	$CanvasLayer/GUI/Numbers/AngularVelocity/TextureProgressBar.value = angularSpeed
	$CanvasLayer/GUI/Numbers/AngularVelocity/LineEdit.text = str(int(angularSpeed))

	# display values on normal force bar
	#$CanvasLayer/VBoxContainer/NormalForce/TextureProgressBar.value = 
	
	# detect if balls are very slow and to insist on stop
	if not shot_in_progress:
		return
	
	#if all_balls_stopped():
#
		#if not stop_timer_running:
			#$ShotFinishedTimer.start()
			#stop_timer_running = true
#
	#else:
		#$ShotFinishedTimer.stop()
		#stop_timer_running = false
		
	if all_balls_stopped():
		if $ShotFinishedTimer.is_stopped():
			$ShotFinishedTimer.start()
	else:
		$ShotFinishedTimer.stop()

func stopTimer():
	$ShotFinishedTimer.stop()

func all_balls_stopped() -> bool:
	var balls = current_level.get_tree().get_nodes_in_group("balls")

	for ball in balls:
		if not ball.is_effectively_stopped():
			return false

	return true
	
	
func highlight(node, color1, color2, repeats):
	var tween = get_tree().create_tween()
	for i in repeats:
		tween.tween_property(node, "theme_override_colors/font_color", color1, 0.2).set_trans(Tween.TRANS_SINE)
		tween.tween_property(node, "theme_override_colors/font_color", color2, 0.2).set_trans(Tween.TRANS_SINE)


func load_next_level(force = 0):
	shot_in_progress = false
	for nodes in get_tree().get_nodes_in_group("balls"):
		nodes.remove_from_group("balls")
	
	levelCounter = levelCounter + 1
	if levelCounter == 5:
		levelCounter = 4
	
	var newLevel = levels[levelCounter].instantiate()
	#print(newLevel)
	add_child(newLevel)
	current_level.queue_free()
	current_level = newLevel
	
	if levelCounter == 1:
		load_level_two()
		# for debugging
		#load_level_five()
	elif levelCounter == 2:
		load_level_three()
	elif levelCounter == 3:
		load_level_four()
	elif levelCounter == 4:
		load_level_five()
	elif levelCounter == 5:
		load_level_six()
	elif levelCounter == 6:
		load_level_seven()
	elif levelCounter > maxLevelCounter:
		# traps game in last level --> to be changed to a final pop up
		levelCounter = levelCounter - 1
		
	
	$CanvasLayer/GUI/Buttons/Button.disabled = false
	$CanvasLayer/GUI/Numbers/Velocity/TextureProgressBar.value = force
	$CanvasLayer/GUI/Numbers/Force/Container/HSlider.value = force
	if levelCounter == 4:
		force = 100
		$CanvasLayer/GUI/Numbers/Velocity/TextureProgressBar.value = force
		$CanvasLayer/GUI/Numbers/Force/Container/HSlider.value = force
	#$CanvasLayer/GUI/Numbers/Force/LineEdit.text = ""
	#$CanvasLayer/GUI/Numbers/Force/Container/TextureProgressBar.value = 0
	$CanvasLayer/GUI/Sliders/RadialSlider.value = 0
	$CanvasLayer/GUI/Sliders/PositionSlider.value = 0
	
	#var cue_ball = current_level.get_node("CueBall/Ball")
	#initial_position = cue_ball.global_position
	
func load_level_two():
	$CanvasLayer/GUI/Sliders/PositionSlider.visible = false
	$CanvasLayer/GUI/SliderLabels/PosLabel.visible = false
	$CanvasLayer/GUI/Sliders/RadialSlider.visible = true
	$CanvasLayer/GUI/SliderLabels/RadialLabel.visible = true
	
	$CanvasLayer/GUI/Numbers/Force/LineEdit.text = ""
	$CanvasLayer/GUI/Numbers/Force/Container/TextureProgressBar.value = 0
	
	highlight($CanvasLayer/GUI/SliderLabels/RadialLabel, Color(0.961, 0.0, 0.063, 1.0), Color(1.0, 1.0, 1.0, 1.0), 4)
	
func load_level_three():
	$CanvasLayer/GUI/Numbers/Force/LineEdit.text = ""
	$CanvasLayer/GUI/Numbers/Force/Container/TextureProgressBar.value = 0
	
func load_level_four():
	$CanvasLayer/GUI/Numbers/Force/LineEdit.text = ""
	$CanvasLayer/GUI/Numbers/Force/Container/TextureProgressBar.value = 0
	
	$CanvasLayer/GUI/Numbers/VelocityBall2/TextureProgressBar.visible = true
	$CanvasLayer/GUI/Numbers/VelocityBall2.visible = true
	$CanvasLayer/GUI/Labels/VelocityLabel2.visible = true
	$CanvasLayer/GUI/SliderLabels/RadialLabel.visible = false
	$CanvasLayer/GUI/Sliders/RadialSlider.visible = false
	
func load_level_five():
	force = force_level5
	$CanvasLayer/GUI/Numbers/Force/LineEdit.editable = false
	$CanvasLayer/GUI/Numbers/Force/LineEdit.text = str(force)
	$CanvasLayer/GUI/Numbers/Force/Container/TextureProgressBar.value = force
	$CanvasLayer/GUI/Numbers/Force/Container/HSlider.value = force
	$CanvasLayer/GUI/SliderLabels/MassLabel.visible = true
	$CanvasLayer/GUI/Sliders/MassSlider.visible = true
	print('force: ', force)
	
	var cue = current_level.get_node("Cue")
	cue.update_cue_drag(force)
	
	
func load_level_six():
	pass
	
func load_level_seven():
	pass

func _on_position_slider_value_changed(value: float) -> void:
	var cue = current_level.get_node("Cue")
	cue.update_cue_central(value)

func _on_radial_slider_value_changed(value: float) -> void:
	var cue = current_level.get_node("Cue")
	cue.update_cue_radial(value)

func _on_mass_slider_value_changed(value: float) -> void:
	var second_ball = current_level.get_node("CueBall/Ball2")
	var collision = second_ball.get_node("CollisionShape2D")
	var mesh = second_ball.get_node("MeshInstance2D")
	second_ball.mass = value
	var mass_slider = get_node("CanvasLayer/GUI/Sliders/MassSlider")
	var min_scale = 1.0
	var max_scale = 4.0
	var scaleValue = remap(value, mass_slider.min_value, mass_slider.max_value, min_scale, max_scale)
	#second_ball.scale = Vector2(scaleValue, scaleValue)
	collision.scale = Vector2(scaleValue, scaleValue)
	mesh.scale = Vector2(scaleValue, scaleValue)
	print("mass second ball: ", second_ball.mass)
	print("scale of ball: ", second_ball.scale)

func _on_intro_popup_confirmed() -> void:
	print('confirmed intro popup')
	get_tree().paused = false
	#var intro_popup = get_node('../IntroPopup')
	#intro_popup.hide()
	##pass # Replace with function body.


func _on_shot_finished_timer_timeout() -> void:

	#for ball in get_tree().get_nodes_in_group("balls"):
		##ball.linear_velocity = Vector2.ZERO
		##ball.angular_velocity = 0.0
		##ball.reset_state = true
		#ball.request_reset()

	#ball_stopped()
	stop_timer_running = false
	shot_in_progress = false
	print('shot timer timeout')
	get_tree().paused = true
	$CanvasLayer/TryAgain.visible = true
	#prepare_next_try()




func _on_next_try_popup_confirmed() -> void:
	for nodes in get_tree().get_nodes_in_group("balls"):
		nodes.remove_from_group("balls")
	stop_timer_running = false
	shot_in_progress = false
	var newLevel = levels[levelCounter].instantiate()
	add_child(newLevel)
	current_level.queue_free()
	current_level = newLevel
	
	$CanvasLayer/GUI/Buttons/Button.disabled = false
	
	if force != 0:
		$CanvasLayer/GUI/Numbers/Force/LineEdit.text = str(force)
	else:
		$CanvasLayer/GUI/Numbers/Force/LineEdit.text = ""

	# levelCounter dependent on where the level sits in the order of levels
	# find a solution that is independent of this
	if levelCounter == 4:
		load_level_five()
	
	var cue = current_level.get_node("Cue")
	cue.update_cue_drag(force)
	cue.update_cue_central($CanvasLayer/GUI/Sliders/PositionSlider.value)
	cue.update_cue_radial($CanvasLayer/GUI/Sliders/RadialSlider.value)
	get_tree().paused = false



func _on_back_pressed() -> void:
	get_parent().levelSelect()


func _on_h_slider_value_changed(value: float) -> void:
	$CanvasLayer/GUI/Numbers/Force/LineEdit.text = str(int(value))
		
	force = int(value)
		
	$CanvasLayer/GUI/Numbers/Force/Container/TextureProgressBar.value = force
	
	var cue = current_level.get_node("Cue")
	cue.update_cue_drag(force)


func _on_try_again_pressed() -> void:
	$CanvasLayer/TryAgain.visible = false
	for nodes in get_tree().get_nodes_in_group("balls"):
		nodes.remove_from_group("balls")
	stop_timer_running = false
	shot_in_progress = false
	var newLevel = levels[levelCounter].instantiate()
	add_child(newLevel)
	current_level.queue_free()
	current_level = newLevel
	
	$CanvasLayer/GUI/Buttons/Button.disabled = false
	
	if force != 0:
		$CanvasLayer/GUI/Numbers/Force/LineEdit.text = str(force)
	else:
		$CanvasLayer/GUI/Numbers/Force/LineEdit.text = ""

	# levelCounter dependent on where the level sits in the order of levels
	# find a solution that is independent of this
	if levelCounter == 4:
		load_level_five()
	
	var cue = current_level.get_node("Cue")
	cue.update_cue_drag(force)
	cue.update_cue_central($CanvasLayer/GUI/Sliders/PositionSlider.value)
	cue.update_cue_radial($CanvasLayer/GUI/Sliders/RadialSlider.value)
	get_tree().paused = false


func _on_okay_pressed() -> void:
	$Welcome.visible = false
