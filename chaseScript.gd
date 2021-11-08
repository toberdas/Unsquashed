extends KinematicBody
var curve = preload("res://stomp_curve.tres")
onready var area = $Area
onready var area2 = $Area2
signal bugShockwaved

var speed = 500
var stompSpeed = 700
var stompDistance = 10

enum state {idle, chasing, waiting, stomping}
var _state : int = state.idle

var velocity = Vector3.ZERO
var moveTarget = transform.origin
var height
var stomping = false
var stompMultiplier = 1

var chasingBug = null

func _ready():
	height = transform.origin.y
	update_timer()
	area.connect("body_entered", self, "bug_detected")
	area2.connect("body_entered", self, "bug_shockwaved")
	pass

func _physics_process(delta):
	move_to_target(delta)

func update_timer():
	yield(get_tree().create_timer(1.0), "timeout")
	if _state == state.idle:
		patrol()
	if _state == state.chasing:
		raycasting()
		
	if _state == state.stomping:
		stomp()
	update_timer()
	pass

func stomp():
	if abs(transform.origin.y) <= 1:
		moveTarget.y = height
		stomping = false
		_state = state.idle
	if abs(transform.origin.y - height) < .5:
		moveTarget.y = 0
		stomping = true
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
			if Vector2(transform.origin.x,transform.origin.z).distance_to(Vector2(moveTarget.x,moveTarget.z)) < stompDistance:
					_state = state.stomping
		else:
			_state = state.idle

func bug_detected(bug):
	print("bug detected")
	if bug.is_in_group("Bugs"):
		chasingBug = bug
		_state = state.chasing
	pass

func bug_shockwaved(bug):
	var intensity = Vector2(transform.origin.x,transform.origin.z).distance_to(Vector2(moveTarget.x,moveTarget.z))
	emit_signal("bugShockwaved",intensity)
	pass

func move_to_target(delta):
	var _direction = (moveTarget - transform.origin).normalized()
	var _stompdirection = Vector3(0,_direction.y,0)
	var _movedirection = Vector3(_direction.x, 0, _direction.z)
	if stomping:
		var _heightdiffnorm = transform.origin.y / height
		stompMultiplier = 3 * (1 + curve.interpolate(1 - _heightdiffnorm))
	else:
		stompMultiplier = 1
	move_and_slide(_movedirection.normalized() * speed * delta)
	move_and_slide(_stompdirection.normalized() * speed * stompMultiplier * delta)
	pass
