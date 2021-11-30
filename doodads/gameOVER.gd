extends Spatial

onready var tween = $Path/PathFollow/Tween
onready var follow = $Path/PathFollow

func _ready():
	tween.interpolate_property(follow, "unit_offset", 0, 1,1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	pass 

func _process(delta):
	if Input.is_action_pressed("reset"):
		get_tree().change_scene("res://World1.tscn")
