extends "addons/extended_kinematic_body/extended_kinematic_body.gd"

var velocity = Vector3()
var view_sensitivity = 0.3
var yaw = 0
var pitch = 0
var is_moving = false

const JUMP_HEIGHT = 400
const MAX_SPEED = 200
const ACCEL= 8
const DEACCEL= 16 
const GRAVITY = (-9.8 * 3) * 60

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(p_event):
	if p_event is InputEventMouseMotion:
		yaw = fmod(yaw - p_event.relative.x * view_sensitivity, 360)
		pitch = max(min(pitch - p_event.relative.y * view_sensitivity, 80), -80)
		get_node("Yaw").set_rotation(Vector3(0, deg2rad(yaw), 0))
		get_node("Yaw/Camera").set_rotation(Vector3(deg2rad(pitch), 0, 0))
	elif p_event is InputEventKey:
		if p_event.is_pressed() and p_event.get_scancode() == KEY_ESCAPE:
			get_tree().quit()
		
func _move(p_delta):
	var aim = get_node("Yaw/Camera").global_transform.basis
	var direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		direction -= aim[2]
	if Input.is_action_pressed("move_backward"):
		direction += aim[2]
	if Input.is_action_pressed("move_left"):
		direction -= aim[0]
	if Input.is_action_pressed("move_right"):
		direction += aim[0]
		
	is_moving = (direction.length() > 0)
	
	direction.y = 0
	direction = direction.normalized()
	
	var target = direction * MAX_SPEED

	
	var accel = DEACCEL
	if is_moving:
		accel = ACCEL
		
	var hvel = velocity
	hvel.y = 0
	
	hvel = hvel.linear_interpolate(target, accel * p_delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	
	if is_grounded == false:
		velocity.y += GRAVITY * p_delta
	else:
		velocity.y = 0.0
		if Input.is_action_just_pressed("jump"):
			is_grounded = false
			velocity.y = JUMP_HEIGHT
	
	# move the node
	var motion = velocity * p_delta
	motion = extended_move(motion, 4)
	
func _physics_process(p_delta):
	_move(p_delta)
	
func _process(delta):
	get_node("Control/Debug/IsGrounded").set_text("is_grounded: " + str(is_grounded))
	get_node("Control/Debug/Velocity").set_text("velocity: " + str(velocity))