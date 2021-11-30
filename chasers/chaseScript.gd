extends KinematicBody

export (NodePath) var patrol_path
var patrol_points
var patrol_index = 0

var curve = preload("res://stomp_curve.tres")

onready var scanArea = $AreaScan
onready var shockwaveArea = $AreaShock
onready var shockwaveCollider = $AreaShock/CollisionShape
onready var areaHit = $AreaHit
onready var areaDown = $AreaDown
onready var animplayer = $AnimationPlayer
onready var waitTimer = $WaitTimer
onready var audioplayer = $AudioStreamPlayer3D

var speed = 1000
var stompDistance = 3

enum state {idle, patrol, chasing, waiting, stomping}
var _state : int = state.patrol

var velocity = Vector3.ZERO
var moveTarget = transform.origin
var height
var stomping = false
var stompMultiplier = 1

var bugList = []
var chasingBug = null

func _ready():
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
	height = global_transform.origin.y
	moveTarget.y = height
	scanArea.connect("body_entered", self, "bug_detected")
	scanArea.connect("body_exited", self, "bug_left")
	shockwaveArea.connect("body_entered", self, "bug_shockwaved")
	areaHit.connect("body_entered", self, "bug_splatted")
	areaDown.connect("body_entered", self, "go_stomp")
	waitTimer.connect("timeout", self, "switch_state", [state.patrol])
	pass

func _process(delta):
	move_to_target(delta)
	if _state == state.idle:
		pass
	if _state == state.patrol:
		speed = 1000
		patrol()
		animplayer.play("Idle")
		raycasting()
	if _state == state.chasing:
		speed = 2000
		
		raycasting()
		animplayer.play("Chase")
	if _state == state.stomping:
		speed = 1000
		waitTimer.set_paused(true)
		animplayer.play("Splat")

func switch_state(state):
	_state = state

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

func raycast_bug(bug):
	if !is_instance_valid(bug):
		return
	var raycol = raycast(transform.origin, bug.transform.origin)
	if raycol:
		if raycol.collider.is_in_group("Bugs") && !raycol.collider.is_in_group("Dead"):
			return true

func raycasting():
	for bug in bugList.size():
		var ind = bugList[bug]
		if !is_instance_valid(ind):
			bugList.remove(bug)
			return
		if raycast_bug(ind):
				moveTarget.x = ind.transform.origin.x
				moveTarget.z = ind.transform.origin.z
				_state = state.chasing
				return

func bug_detected(body):
	if body.is_in_group("Bugs") && !body.is_in_group("Dead"):
		if !bugList.has(body):
			bugList.append(body)
	pass
	
func bug_left(body):
	if body.is_in_group("Bugs") && !body.is_in_group("Dead"):
		if bugList.has(body):
			bugList.erase(body)

func bug_splatted(body):
	if body.is_in_group("Walls"):
		audioplayer.play(0)
		shockwaveCollider.set_disabled(true)
		hand_up()
	get_tree().call_group("Bugs", "splatted", body)

func bug_shockwaved(body):
	get_tree().call_group("Bugs", "shockwaved", body)

func go_stomp(body):
	if body.is_in_group("Bugs") && !body.is_in_group("Dead"):
		_state = state.stomping
	
func hand_up():
	stomping = false
	waitTimer.set_paused(false)
	moveTarget.y = height
	_state = state.chasing

func hand_down():
	waitTimer.set_paused(true)
	shockwaveCollider.set_disabled(false)
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
	if _distance.length() > 0.2:
		move_and_slide(_direction * (speed * stompMultiplier) * delta, Vector3.UP)

