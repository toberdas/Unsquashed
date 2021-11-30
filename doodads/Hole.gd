extends Spatial

var bug = preload("res://bugz/Bug.tscn")
onready var animplayer = $AnimationPlayer
onready var area = $Area
onready var spawnTimer = $Timer
onready var spawnPoint = $SpawnPoint
onready var audioplayer = $AudioStreamPlayer3D

func _ready():
	area.connect("body_entered",self,"take_food")
	spawnTimer.connect("timeout", self, "spawn_bug")
	pass 

func take_food(body):
	if body.is_in_group("Food"):
		audioplayer.play(0)
		animplayer.play("wiggle")
		get_tree().call_group("Food", "destroy", body.get_index())
		get_parent().tally_food()
		spawnTimer.start(1)
	
func spawn_bug():
	animplayer.play("wiggle")
	var newbug = bug.instance()
	newbug.transform.origin = spawnPoint.global_transform.origin
	get_tree().get_current_scene().add_child(newbug)
