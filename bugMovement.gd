extends KinematicBody

var dir := Vector2.ZERO
var velocity := Vector3.ZERO
var roty = 0

onready var timer = $Timer
onready var aitimer = $AITimer

var shockwaveCurve = preload("res://shockwave_curve.tres")

enum state {normal, shockwaved}
var _state : int = state.normal

var impulse = 100
var drag = 80
var rotation_speed = 6
var hp = 3;
var maxSpeed = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if _state == state.normal:
		get_input()
		add_velocity(delta)
		update_rotation(delta)
		update_position(delta)
	if _state == state.shockwaved:
		update_rotation(delta)
		update_position(delta)
		transform.origin.y = shockwaveCurve.interpolate(1 - timer.time_left) * 2
		if timer.is_stopped():
			_state = state.normal
	pass
	
func get_input():
	if aitimer.is_stopped():
		dir.x = rand_range(-.2,.2)
		dir.y = rand_range(-1,-.5)
		aitimer.start(2)

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
	


func splatted(bug):
	var index = get_index()
	if bug == index:
		if timer.is_stopped():
			print("splatted")
			hp -= 1
			if hp == 0:
				add_to_group("Dead")
		timer.start(1)

func shockwaved(bug):
	var index = get_index()
	if bug == index:
		if timer.is_stopped():
			print("shockwaved")
			_state = state.shockwaved
		timer.start(1)

