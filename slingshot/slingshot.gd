extends Node2D

var planet
var activate_cost = 10
var building_info
var target_player_number
var slingshot_blast
var shot_amount = 0 

func init():
	building_info = ''

	get_parent().rotation = get_parent().position.direction_to(Vector2(0, 0)).angle() - PI / 2

remotesync func on_activate():
	add_slingshot_blast()

func add_slingshot_blast():
	slingshot_blast = preload('res://slingshot/slingshot_blast.tscn').instance()
	slingshot_blast.name = '%s_slingshot_blast_%d' % [name, shot_amount]
	shot_amount += 1
	slingshot_blast.planet = planet
	add_child(slingshot_blast)