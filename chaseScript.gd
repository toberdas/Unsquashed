extends KinematicBody

onready var area = $Area

var speed = 500

enum state {idle, chasing, waiting, stomping}
var _state : int = state.idle

var velocity = Vector3.ZERO
var moveTarget = transform.origin

var chasingBug = null

func _ready():
	update_timer()
	area.connect("body_entered", self, "bug_detected")
	pass

func _physics_process(delta):
	move_to_target(delta)

func update_timer():
	yield(get_tree().create_timer(1.0), "timeout")
	if _state == state.idle:
		patrol()
	if _state == state.chasing:
		raycasting()
	update_timer()
	print(_state)
	pass

func patrol():
	moveTarget.x = randf()
	moveTarget.z = randf()

func raycasting():
	var _direction = moveTarget - transform.origin
	var _direct_state = get_world().direct_space_state
	var raycol = _direct_state.intersect_ray(transform.origin, chasingBug.transform.origin)
	if raycol:
		if raycol.collider.is_in_group("Bugs"):
			moveTarget.x = chasingBug.transform.origin.x
			moveTarget.z = chasingBug.transform.origin.z
		else:
			_state = state.idle

func bug_detected(bug):
	if bug.is_in_group("Bugs"):
		chasingBug = bug
		_state = state.chasing
	pass

func move_to_target(delta):
	var _direction = moveTarget - transform.origin

	move_and_slide(_direction.normalized() * speed * delta)
	pass
