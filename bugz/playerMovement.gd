extends KinematicBody

var dir := Vector2.ZERO
var velocity := Vector3.ZERO
var roty = 0

onready var timer = $Timer
onready var switchtimer = $SwitchTimer
onready var overviewcam = $OverviewCamera
onready var cam = $SpringArm/Camera
onready var raycastup = $RayCastUp
onready var raycastdown = $RayCastDown
onready var raycastdownback = $RayCastDownback

var shockwaveCurve = preload("res://shockwave_curve.tres")

enum state {normal, shockwaved, overview}
var _state : int = state.normal

var impulse = 100
var drag = 80
var rotation_speed = 6
var maxSpeed = 30
var hp = 3
var switchdelay = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if _state == state.normal:
		get_movement_input()
		get_control_input()
		add_velocity(delta)
		update_rotation(delta)
		update_position(delta)
		raycast_from_head()
	if _state == state.shockwaved:
		get_movement_input()
		update_rotation(delta)
		update_position(delta)
		transform.origin.y = shockwaveCurve.interpolate(1 - timer.time_left) * 2
		if timer.is_stopped():
			_state = state.normal
	if _state == state.overview:
		get_control_input()
		overview_input()
	pass

func overview_input():
	if Input.is_action_just_pressed("select_unit"):
		select_units()

func raycast_from_head():
	if velocity.length() > 1:
		raycast_up()
		raycast_down()
	pass
	
func raycast_down():
	var colliderdown = raycastdown.get_collider()
	var colliderdownback = raycastdownback.get_collider()
	if !colliderdown or !colliderdown.is_in_group("Walls"):
		if colliderdownback:
			if colliderdownback.is_in_group("Walls"):
				global_transform = align_with_y(global_transform, raycastup.get_collision_normal())
#				transform.origin = raycastdownback.get_collision_point()

func raycast_up():
	var colliderup = raycastup.get_collider()
	if colliderup:
		if colliderup.is_in_group("Walls"):
			global_transform = align_with_y(global_transform, raycastup.get_collision_normal())
#			transform.origin = raycastup.get_collision_point()

func look_at_with_y(trans,new_y,v_up):
#	trans.basis.y=new_y.normalized()
#	trans.basis.z= v_up*-1
#	trans.basis.x = trans.basis.z.cross(trans.basis.y).normalized();
#	#Recompute z = y cross X
#	trans.basis.z = trans.basis.y.cross(trans.basis.x).normalized();
#	trans.basis.x = trans.basis.x * -1   # <======= ADDED THIS LINE
#	trans.basis = trans.basis.orthonormalized() # make sure it is valid 
	pass
	return trans
	
func align_with_y(xform, new_y):
	var result = Basis()
	result.x = new_y.cross(xform.basis.z)
	result.y = new_y
	result.z = xform.basis.x.cross(new_y)
	return result

func select_units():
	var ray_result = raycast_from_mouse()
	if ray_result: 
		if ray_result.collider.is_in_group("Bugs") && !ray_result.collider.is_in_group("Dead"):
			get_tree().call_group("Bugs", "selected", ray_result.collider.get_index())
	pass

func raycast_from_mouse():
	var mousepos = get_viewport().get_mouse_position()
	var from = cam.project_ray_origin(mousepos)
	var to = from + cam.project_ray_normal(mousepos) * 1000
	var _direct_state = get_world().direct_space_state
	var raycol = _direct_state.intersect_ray(from, to)
	return raycol

func get_control_input():
	if Input.is_action_just_pressed("overview"):
		print("overview pressed")
		switch_overview()

func get_movement_input():
	dir.x = int(Input.is_action_pressed("key_left")) - int(Input.is_action_pressed("key_right"))
	dir.y = -int(Input.is_action_pressed("key_up"))

func switch_overview():
	if switchtimer.is_stopped():	
		if _state == state.overview:
			_state = state.normal
			cam.make_current()
			switchtimer.start(switchdelay)
			return
		if _state == state.normal:
			_state = state.overview
			overviewcam.make_current()
			switchtimer.start(switchdelay)
			return

func update_rotation(delta):
	roty += ((dir.x * rotation_speed * delta) - roty) /2
#	transform.basis = Basis() # reset rotation
	rotate_object_local(Vector3(0, 1, 0), roty)
	pass

func add_velocity(delta):
	velocity += transform.basis.z * impulse * dir.y * delta
	velocity = velocity.move_toward(Vector3.ZERO, drag * delta)
	velocity.x = clamp(velocity.x, -maxSpeed, maxSpeed)
	velocity.z = clamp(velocity.z, -maxSpeed, maxSpeed)
	pass

func update_position(delta):
	move_and_slide(velocity)
	transform = transform.orthonormalized()
	pass

func shockwaved(bug):
	var index = get_index()
	if bug == index:
		print("shockwaved")
		if timer.is_stopped():
			_state = state.shockwaved
		timer.start(1)

func splatted(bug):
	var index = get_index()
	if bug == index:
		if timer.is_stopped():
			print("splatted")
			hp -= 1
			if hp == 0:
				add_to_group("Dead")

