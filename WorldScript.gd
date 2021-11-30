extends Spatial
var hand = preload("res://chasers/hand.tscn")
onready var spawnpathfollow = $SpawnPath/PathFollow
onready var tallylabel = $RichTextLabel
onready var handpathfollow = $PatrolPath/PathFollow

var bug = preload("res://bugz/Bug.tscn")
var foodtally = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	var newbug = bug.instance()
	newbug.playerControlled = true
	spawnpathfollow.unit_offset = randf()
	newbug.transform.origin = spawnpathfollow.global_transform.origin
	get_tree().get_current_scene().add_child(newbug)
	pass 

func tally_food():
	foodtally += 1
	tallylabel.clear()
	tallylabel.add_text(str(foodtally))
	if foodtally % 5 == 0:
		var newhand = hand.instance()
		handpathfollow.unit_offset = randf()
		newhand.transform.origin = handpathfollow.global_transform.origin
		add_child(newhand)

func _process(delta):
	if get_tree().get_nodes_in_group("Bugs").size() == 0:
		print("GAME OVER")
		get_tree().change_scene("res://doodads/gameOVER.tscn")
	pass
