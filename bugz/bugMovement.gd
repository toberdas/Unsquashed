extends KinematicBody

var dir := Vector2.ZERO
var velocity := Vector3.ZERO
var roty = 0
var selected = false

onready var timer = $Timer
onready var aitimer = $AITimer
onready var animplayer = $AnimationPlayer


var shockwaveCurve = preload("res://shockwave_curve.tres")

enum state {wandering, shockwaved, splatted, dead}
var _state : int = state.wandering
var _lastState : int = _state

var gravity = 600
var speed = 500
var impulse = 100
var drag = 80
var rotation_speed = 6
var hp = 1;
var maxSpeed = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if _state == state.wandering:
		get_input()
		add_velocity(delta)
		update_rotation(delta)
		update_position(delta)
		if dir.length() > .5:
			animplayer.play("Walk")
		else:
			animplayer.stop("Walk")
	if _state == state.splatted:
		dir = Vector2.ZERO
		add_velocity(delta)
		update_position(delta)
		pass
	if _state == state.dead:
		dir = Vector2.ZERO
		add_velocity(delta)
		update_position(delta)
		pass
	
	
func get_input():
	if aitimer.is_stopped():
		dir.x = rand_range(-.2,.2)
		dir.y = rand_range(-1,-.8)
		aitimer.start(2)

func update_rotation(delta):
	roty += ((dir.x * rotation_speed * delta) - roty) /2
#	transform.basis = Basis() # reset rotation
	rotate_object_local(Vector3(0, 1, 0), roty)
	pass

func add_velocity(delta):
	velocity = (transform.basis.z * speed * dir.y * delta) + (-transform.basis.y * gravity * delta)
	pass
	
func update_position(delta):
	move_and_slide(velocity)
	transform = transform.orthonormalized()
	pass

func splatted(bug):
	var index = get_index()
	if bug == index:
		if _state != state.splatted && _state != state.dead:
			print("splatted")
			animplayer.play("Hit")
			_state = state.splatted
			hp -= 1
			if hp == 0:
				bug_death()
			

func shockwaved(bug):
	var index = get_index()
	if bug == index:
		print("shockwaved")
		transform.origin.y += 3;

func bug_death():
	add_to_group("Dead")
	_state = state.dead
	velocity = Vector3.ZERO
	animplayer.seek(animplayer.get_current_animation_length(), true)

func selected(bug):
	print("selected")
	selected = true
	pass

func recover():
	_state = state.wandering
