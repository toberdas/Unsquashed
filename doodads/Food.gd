extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func pickedup(index):
	if index == get_index():

		pass

func destroy(index):
	if index == get_index():
		queue_free()
