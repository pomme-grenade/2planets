extends Node2D
var planet
var upgrade_2_type = 'teleporter'
var upgrade_2_script = 'res://building/types/' + upgrade_2_type + 'gd'


func init():
	planet.player.position = planet.player.position.rotated(PI)

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
