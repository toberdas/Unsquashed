extends KinematicBody

var dir := Vector2.ZERO
var velocity := Vector3.ZERO
var roty = 0

var impulse = 100
var drag = 80
var rotation_speed = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	get_player_input()
	add_velocity(delta)
	update_rotation(delta)
	update_position(delta)
	pass
	
func get_player_input():
	dir.x = int(Input.is_action_pressed("key_left")) - int(Input.is_action_pressed("key_right"))
	dir.y = int(Input.is_action_pressed("key_down")) - int(Input.is_action_pressed("key_up"))
#	dir = dir.normalized()
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
