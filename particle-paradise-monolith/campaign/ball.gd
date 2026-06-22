extends RigidBody2D

@export var sleep_speed := 2.0      # pixels/s
@export var sleep_time := 1.0       # seconds

var below_threshold_time := 0.0
var has_moved := false
var reset_state = false

var initial_position: Vector2
var initial_rotation: float
var initial_transform: Transform2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = global_position
	initial_rotation = rotation
	initial_transform = global_transform
	add_to_group("balls")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ballID():
	pass

#func _on_timer_timeout() -> void:	
#func ball_stopped() -> void:	
	#$ShotTimer.stop()
	#linear_velocity = Vector2.ZERO
	#angular_velocity = 0.0
	#get_tree().paused = true
	#var next_try_popup = get_node("../../NextTryPopup")
	#next_try_popup.popup_centered()

#func _physics_process(delta):
	#
	#var speed = linear_velocity.length() / 10.0
#
	## Detect first movement
	#if speed >= sleep_speed:
		#has_moved = true
#
	## Don't do anything before the ball has moved
	#if not has_moved:
		#return
	#if speed < sleep_speed:
		#if $ShotTimer.is_stopped() == true:
			#$ShotTimer.start()
			##print('global position at time start: ', global_position)
#
	#else:
		#below_threshold_time = 0.0
		
func is_effectively_stopped() -> bool:
	return linear_velocity.length() / 10.0 < sleep_speed

func _integrate_forces(state):
	if reset_state:
		state.transform = initial_transform
		
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		
		reset_state = false
		has_moved = false
		
		#var game = get_parent().get_parent().get_parent()
		#state.transform = Transform2D(0.0, game.initial_position)
		#reset_state = false
		
func request_reset():
	reset_state = true

func _on_next_try_popup_confirmed() -> void:
	var game = get_parent().get_parent().get_parent()
	print('popup confirmed')
	reset_state = true
	has_moved = false
	game.prepare_next_try()
