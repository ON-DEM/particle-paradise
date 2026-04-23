extends RigidBody2D

var stopped = false

func stop():
	process_mode = Node.PROCESS_MODE_DISABLED
	stopped = true

func start():
	process_mode = Node.PROCESS_MODE_INHERIT
	stopped = false
