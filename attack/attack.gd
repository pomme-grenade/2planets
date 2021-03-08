extends Node2D

var planet
var upgrade_1_type = 'laser'
var upgrade_2_type = 'split_rocket'
var activate_cost = 10
var target_player_number
var building_info = ''

func init():
	target_player_number = 2 if planet.player_number == 1 else 1

func fire_rocket(name, position, rotation):
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
	var name = '%d_rocket_%d' % [ planet.player_number, planet.rocket_name_index ]
	planet.rocket_name_index += 1
	var position = global_position - Vector2(5, 0).rotated(global_rotation)
	fire_rocket(name, position, global_rotation + PI)
