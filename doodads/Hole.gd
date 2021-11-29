extends Spatial

onready var animplayer = $AnimationPlayer
onready var area = $Area

# Called when the node enters the scene tree for the first time.
func _ready():
	area.connect("body_entered",self,"take_food")
	pass # Replace with function body.

func take_food(body):
	if body.is_in_group("Food"):
		animplayer.play("wiggle")
		get_tree().call_group("Food", "destroy", body.get_index())
	
