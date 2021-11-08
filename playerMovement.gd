extends KinematicBody

var dir := Vector2.ZERO
var velocity := Vector3.ZERO
var roty = 0

onready var timer = $Timer

onready var foots = get_tree().get_root().find_node("Foot",true,false) 
var shockwaveCurve = preload("res://shockwave_curve.tres")

enum state {normal, shockwaved}
var _state : int = state.normal

var impulse = 100
var drag = 80
var rotation_speed = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	print(foots)
	foots.connect("bugShockwaved", self, "shockwaved")
	pass # Replace with function body.


func _process(delta):
	if _state == state.normal:
		get_player_input()
		add_velocity(delta)
		update_rotation(delta)
		update_position(delta)
	if _state == state.shockwaved:
		get_player_input()
		update_rotation(delta)
		update_position(delta)
		transform.origin.y = shockwaveCurve.interpolate(1 - timer.time_left) * 2
		if timer.is_stopped():
			_state = state.normal
	pass
	
func get_player_input():
	dir.x = int(Input.is_action_pressed("key_left")) - int(Input.is_action_pressed("key_right"))
	dir.y = -int(Input.is_action_pressed("key_up"))
	pass

func update_rotation(delta):
	roty += ((dir.x * rotation_speed * delta) - roty) /2
#	transform.basis = Basis() # reset rotation
	rotate_object_local(Vector3(0, 1, 0), roty)
	pass

func add_velocity(delta):
	velocity += transform.basis.z * impulse * dir.y * delta
	velocity = velocity.move_toward(Vector3.ZERO, drag * delta)
	pass
	
func update_position(delta):
	move_and_slide(velocity)
	transform = transform.orthonormalized()
	pass
	
func shockwaved(bug, intensity):
	var index = get_index()
	if bug == index:
		print("shockwaved")
		if timer.is_stopped():
			_state = state.shockwaved
		timer.start(1)

