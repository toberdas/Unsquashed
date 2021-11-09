extends KinematicBody
var curve = preload("res://stomp_curve.tres")
onready var area = $Area
onready var area2 = $Area2
onready var area3 = $Area3
onready var patroltimer = $Timer
onready var animplayer = $AnimationPlayer

var speed = 600
var stompDistance = 3

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
	area.connect("body_entered", self, "bug_detected")
	area2.connect("body_entered", self, "bug_shockwaved")
	area3.connect("body_entered", self, "bug_splatted")
	pass

func _process(delta):
	move_to_target(delta)
	if _state == state.idle:
		patrol()
		animplayer.queue("Idle")
	if _state == state.chasing:
		raycasting()
		animplayer.queue("Chase")
	if _state == state.stomping:
		stomp()
		animplayer.queue("Splat")

func stomp():
	if abs(transform.origin.y) <= 2:
		transform.origin.y = 0
		moveTarget.y = height
		stomping = false
		_state = state.chasing
	if abs(transform.origin.y - height) < 1:
		print("Stomp!")
		moveTarget.y = 0
		stomping = true
	pass

func patrol():
	if patroltimer.is_stopped():
		moveTarget.x = randi() % 20   
		moveTarget.z = randi() % 20   
		patroltimer.start(2)

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
			_state = state.idle

func bug_detected(bug):
	if bug.is_in_group("Bugs") && !bug.is_in_group("Dead"):
		print("bug detected")
		chasingBug = bug
		_state = state.chasing
	pass

func bug_shockwaved(bug):
	get_tree().call_group("Bugs", "shockwaved", bug.get_index())

	
func bug_splatted(bug):
	get_tree().call_group("Bugs", "splatted", bug.get_index())


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
