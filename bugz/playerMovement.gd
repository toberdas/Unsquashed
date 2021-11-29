extends KinematicBody

var dir := Vector2.ZERO
var velocity := Vector3.ZERO
var roty = 0
var inAir = 1;

onready var timer = $Timer
onready var switchtimer = $SwitchTimer
onready var cam = $Camera
onready var pickupArea = $AreaPickup
onready var joint = $PinJoint

var shockwaveCurve = preload("res://shockwave_curve.tres")

enum state {normal}
var _state : int = state.normal

var gravity = 700
var speed = 0
var verSpeed = 0
var drag = 80
var rotation_speed = 6
var maxSpeed = 600
var hp = 30
var switchdelay = 1
var acceleration = 10
var carrying = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pickupArea.connect("body_entered", self, "pickup")
	pass # Replace with function body.


func _process(delta):
	if _state == state.normal:
		get_movement_input()
		add_velocity(delta)
		update_rotation(delta)
		update_position(delta)
	pass

func get_movement_input():
	dir.x = int(Input.is_action_pressed("key_left")) - int(Input.is_action_pressed("key_right"))
	dir.y = -int(Input.is_action_pressed("key_up"))

func update_rotation(delta):
	roty += ((dir.x * rotation_speed * delta) - roty) /2
#	transform.basis = Basis() # reset rotation
	rotate_object_local(Vector3(0, 1, 0), roty)
	pass

func add_velocity(delta):
	if dir.y < 0:
		speed = lerp(speed, maxSpeed * -dir.y, acceleration * delta)
	else:
		speed = lerp(speed, 0, 1)
	
	velocity = (transform.basis.z * speed * dir.y * delta) + (-transform.basis.y * gravity * delta)

	pass

func update_position(delta):
	move_and_slide(velocity)
	transform = transform.orthonormalized()
	pass

func shockwaved(bug):
	if bug == get_index():
		print("shockwaved")
		transform.origin.y += 3;

func splatted(bug):
	if bug == get_index():
		if timer.is_stopped():
			print("splatted")
			hp -= 1
			if hp == 0:
				add_to_group("Dead")

func pickup(body):
	if !carrying:
		if body.is_in_group("Food"):
			get_tree().call_group("Food", "pickedup", body.get_index())
			joint.set_node_a(get_path())
			joint.set_node_b(body.get_path())
			pass
