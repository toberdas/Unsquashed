extends KinematicBody

var dir := Vector2.ZERO
var velocity := Vector3.ZERO
var roty = 0
var inAir = 1;

onready var decayTimer = $DecayTimer
onready var switchtimer = $SwitchTimer
onready var cam = $Camera
onready var pickupArea = $AreaPickup
onready var joint = $Generic6DOFJoint
onready var animplayer = $AnimationPlayer
onready var audioplayer = $AudioStreamPlayer3D

export var playerControlled : bool

var shockwaveCurve = preload("res://shockwave_curve.tres")

enum state {normal, dead}
var _state : int = state.normal

var gravity = 700
var speed = 0
var verSpeed = 0
var drag = 80
export var rotation_speed = 3
export var maxSpeed = 1100
var hp = 1
var switchdelay = 1
var acceleration = 6
var carrying = false


func _ready():
	pickupArea.connect("body_entered", self, "pickup")
	decayTimer.connect("timeout",self,"queue_free")
#	if playerControlled:
#		cam.make_current()
	pass


func _process(delta):
	if _state == state.normal:
		if cam.is_current():
			playerControlled = true
		get_movement_input()
		add_velocity(delta)
		update_rotation(delta)
		update_position(delta)
		if dir != Vector2.ZERO:
			animplayer.play("Walk")
		else:
			animplayer.stop()
	if _state == state.dead:
		var dir := Vector2.ZERO
		add_velocity(delta)
		update_rotation(delta)
		update_position(delta)
		animplayer.play("Hit")
		animplayer.seek(animplayer.get_current_animation_length(), true)
		pass
	pass

func get_movement_input():
	if playerControlled:
		dir.x = int(Input.is_action_pressed("key_left")) - int(Input.is_action_pressed("key_right"))
		dir.y = -int(Input.is_action_pressed("key_up"))
	else:
		if switchtimer.is_stopped():
			dir.x = rand_range(-.8,.8)
			dir.y = rand_range(-1,-.8)
			switchtimer.start(1)

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
	if bug.get_index() == get_index():
		transform.origin.y += 1;

func splatted(bug):
	if bug.get_index() == get_index():
		hp -= 1
		if hp <= 0:
			player_death()


func player_death():
	dir = Vector2.ZERO
	velocity = Vector3.ZERO
	roty = 0
	add_to_group("Dead")
	_state = state.dead
	decayTimer.start(4)

func pickup(body):
	if !carrying:
		if body.is_in_group("Food"):
			audioplayer.play(0)
			get_tree().call_group("Food", "pickedup", body.get_index())
			joint.set_node_a(get_path())
			joint.set_node_b(body.get_path())
			pass
