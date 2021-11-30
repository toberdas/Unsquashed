extends Path

onready var dispenseTimer = $Timer
onready var follow = $PathFollow
var morsel = preload("res://doodads/stupidmorsel.tscn")
export var morseldrop = 10
var drop = true

func _ready():
	dispenseTimer.connect("timeout", self, "dispense")
	pass


func _process(delta):
	if drop:
		for i in range(morseldrop):
			dispense()
		drop = false
	pass

func dispense():
	var newmorsel = morsel.instance()
	follow.unit_offset = randf()
	newmorsel.transform.origin = follow.global_transform.origin
	get_tree().get_current_scene().add_child(newmorsel)
	pass

