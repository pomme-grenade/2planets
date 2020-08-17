extends Node2D

var planet
var upgrade_1_type = 'laser'
var upgrade_2_type = 'split_rocket'
var rocket_name_index = 0
var activate_cost = 10
var target_player_number
var building_info

func init():
	building_info = ''
	target_player_number = 2 if planet.player_number == 1 else 1

remotesync func fire_rocket(name, position, rotation):
	var rocket = preload("res://attack/rocket.tscn").instance()
	rocket.name = name
	rocket.target_player_number = target_player_number
	rocket.position = position
	rocket.rotation = rotation + PI/2
	rocket.from_planet = planet
	rocket.init(target_player_number)
	rocket.set_network_master(get_network_master())
	$'/root/main'.add_child(rocket)
	update()

func on_activate():
	var name = '%d_rocket_%d' % [ planet.player_number, rocket_name_index ]
	rocket_name_index += 1
	var position = global_position - Vector2(5, 0).rotated(global_rotation)
	rpc('fire_rocket', name, position, global_rotation + PI)
