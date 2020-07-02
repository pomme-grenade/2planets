extends Node2D

var planet
var rocket_name_index = 0
var activate_cost = 30
var target_player_number
var building_info

func init():
	building_info = ''
	target_player_number = 2 if planet.playerNumber == 1 else 1

remotesync func fire_rocket(name, position, rotation):
	var rocket = preload("res://rocket.gd").new(target_player_number)
	rocket.name = name
	rocket.split_distance = 150
	rocket.position = position
	rocket.rotation = rotation + PI/2
	rocket.from_planet = planet
	rocket.building = self
	rocket.color = Color(1, 0.8, 0.2)
	rocket.set_network_master(get_network_master())
	$'/root/main'.add_child(rocket)
	update()

func on_activate():
	if planet.money < activate_cost or (not is_network_master()):
		return

	var name = '%d_split_rocket_%d' % [ planet.playerNumber, rocket_name_index ]
	rocket_name_index += 1
	var position = global_position - Vector2(5, 0).rotated(global_rotation)
	rpc('fire_rocket', name, position, global_rotation + PI)
