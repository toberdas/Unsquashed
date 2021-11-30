extends Control

func _process(delta):
	if Input.is_action_pressed("start"):
		get_tree().change_scene("res://World1.tscn")
