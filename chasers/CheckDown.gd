extends Area

func _ready():
	pass # Replace with function body.

func _process(delta):
	for body in get_overlapping_bodies():
		emit_signal("body_entered", body)
