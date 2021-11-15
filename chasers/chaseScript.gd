extends KinematicBody

export (NodePath) var patrol_path
var patrol_points
var patrol_index = 0

var curve = preload("res://stomp_curve.tres")

onready var scanArea = $Area
onready var shockwaveArea = $Area2
onready var shockwaveCollider = $Area2/CollisionShape
onready var area3 = $Area3
onready var waittimer = $Timer
onready var animplayer = $AnimationPlayer

var speed = 1200
var stompDistance = 3

enum state {idle, patrol, chasing, waiting, stomping}
var _state : int = state.patrol

var velocity = Vector3.ZERO
var moveTarget = transform.origin
var height
var stomping = false
var stompMultiplier = 1

var chasingBug = null

func _ready():
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
	height = global_transform.origin.y
	moveTarget.y = height
	scanArea.connect("body_entered", self, "bug_detected")
	shockwaveArea.connect("body_entered", self, "bug_shockwaved")
	area3.connect("body_entered", self, "bug_splatted")
	pass

func _process(delta):
	move_to_target(delta)
	if _state == state.idle:
		pass
	if _state == state.patrol:
		patrol()
		animplayer.play("Idle")
	if _state == state.chasing:
		raycasting()
		animplayer.play("Chase")
	if _state == state.stomping:
		animplayer.play("Splat")
		check_stomp_hit()
	

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
	var raycol = raycast(transform.origin, chasingBug.transform.origin)
	if raycol:
		if raycol.collider.is_in_group("Bugs") && !raycol.collider.is_in_group("Dead"):
			moveTarget.x = chasingBug.transform.origin.x
			moveTarget.z = chasingBug.transform.origin.z
			if Vector2(transform.origin.x,transform.origin.z).distance_to(Vector2(moveTarget.x,moveTarget.z)) < stompDistance:
					_state = state.stomping
		else:
			_state = state.patrol

func bug_detected(bug):
	if bug.is_in_group("Bugs") && !bug.is_in_group("Dead"):
		var raycastbug = raycast(transform.origin, bug.transform.origin)
		if raycastbug:
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

func check_stomp_hit():
	if stomping == true:
		if abs(global_transform.origin.y - moveTarget.y) < 1:
			hand_up()

func hand_up():
	moveTarget.y = height
	stomping = false
	_state = state.patrol

func hand_down():
	shockwaveCollider.set_disabled(false)
	print("Stomp!")
	moveTarget.y = chasingBug.transform.origin.y
	stomping = true

func move_to_target(delta):
	var _distance = moveTarget - transform.origin
	var _direction = _distance.normalized()
	if stomping:
		var _heightdiffnorm = transform.origin.y / height
		stompMultiplier = round(5 * (1 + curve.interpolate(1 - _heightdiffnorm)))
	else:
		stompMultiplier = 1
	if _distance.length() > 0.2:
		move_and_slide(_direction * (speed * stompMultiplier) * delta, Vector3.UP)
