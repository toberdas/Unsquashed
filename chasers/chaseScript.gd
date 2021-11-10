extends KinematicBody

export (NodePath) var patrol_path
var patrol_points
var patrol_index = 0

var curve = preload("res://stomp_curve.tres")

onready var area = $Area
onready var shockwaveArea = $Area2
onready var shockwaveCollider = $Area2/CollisionShape
onready var area3 = $Area3
onready var patroltimer = $Timer
onready var animplayer = $AnimationPlayer

var speed = 900
var stompDistance = 3

enum state {idle, patrol, chasing, waiting, stomping}
var _state : int = state.idle

var velocity = Vector3.ZERO
var moveTarget = transform.origin
var height
var stomping = false
var stompMultiplier = 1

var chasingBug = null

func _ready():
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
	height = transform.origin.y
	area.connect("body_entered", self, "bug_detected")
	shockwaveArea.connect("body_entered", self, "bug_shockwaved")
	area3.connect("body_entered", self, "bug_splatted")
	pass

func _process(delta):
	move_to_target(delta)
	if _state == state.idle:
		patrol()
		animplayer.play("Idle")
	if _state == state.patrol:
		pass
	if _state == state.chasing:
		raycasting()
		animplayer.play("Chase")
	if _state == state.stomping:
		animplayer.play("Splat")

func patrol():
	if !patrol_path:
		return
	moveTarget.x = patrol_points[patrol_index].x
	moveTarget.z = patrol_points[patrol_index].z
	var position = transform.origin
	var distance = position.distance_to(moveTarget)
	if distance < 1:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		moveTarget.x = patrol_points[patrol_index].x
		moveTarget.z = patrol_points[patrol_index].z
	pass
	
func raycast(from, to):
	var _direct_state = get_world().direct_space_state
	var raycol = _direct_state.intersect_ray(from, to)
	return raycol
	
func raycasting():
	var _direct_state = get_world().direct_space_state
	var raycol = _direct_state.intersect_ray(transform.origin, chasingBug.transform.origin)
	if raycol:
		if raycol.collider.is_in_group("Bugs") && !raycol.collider.is_in_group("Dead"):
			moveTarget.x = chasingBug.transform.origin.x
			moveTarget.z = chasingBug.transform.origin.z
			if Vector2(transform.origin.x,transform.origin.z).distance_to(Vector2(moveTarget.x,moveTarget.z)) < stompDistance:
					_state = state.stomping
		else:
			_state = state.chasing

func bug_detected(bug):
	if bug.is_in_group("Bugs") && !bug.is_in_group("Dead"):
		var raycastbug = raycast(transform.origin, bug.transform.origin)
		if raycastbug.collider.is_in_group("Bugs") && !bug.is_in_group("Dead"):
			print("bug detected")
			chasingBug = bug
			_state = state.chasing
	pass

func bug_splatted(bug):
	get_tree().call_group("Bugs", "splatted", bug.get_index())

func bug_shockwaved(bug):
	shockwaveCollider.set_disabled(true)
	get_tree().call_group("Bugs", "shockwaved", bug.get_index())

func hand_up():
	transform.origin.y = 0
	moveTarget.y = height
	stomping = false
	_state = state.idle

func hand_down():
	shockwaveCollider.set_disabled(false)
	print("Stomp!")
	moveTarget.y = 0
	stomping = true

func move_to_target(delta):
	var _distance = moveTarget - transform.origin
	var _direction = _distance.normalized()
	
	if stomping:
		var _heightdiffnorm = transform.origin.y / height
		stompMultiplier = round(5 * (1 + curve.interpolate(1 - _heightdiffnorm)))
	else:
		stompMultiplier = 1
	if _distance.length() > 0.1:
		move_and_slide(_direction * (speed * stompMultiplier) * delta, Vector3.UP)
