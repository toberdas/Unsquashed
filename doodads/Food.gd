extends Spatial

onready var deathTimer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	deathTimer.connect("timeout", self, "destroy", [get_index()])
	pass


func pickedup(index):
	if get_index() == index:
#		deathTimer.stop()
#		transform.origin.y += .5
		pass

func destroy(index):
	if index == get_index():
		queue_free()
