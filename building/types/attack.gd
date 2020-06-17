extends Node2D

var planet
var upgrade_1_type = 'laser'
var upgrade_1 = 'res://building/types/' + upgrade_1_type + 'gd'
var rocket_name_index = 0
var activate_cost = 10
var target_player_number

func init():
	target_player_number = 2 if planet.playerNumber == 1 else 1

func try_fire_rocket(name):
	if planet.money < activate_cost or (not is_network_master()):
		return
	elif get_parent().is_built and not get_parent().is_destroyed:
		var position = global_position - Vector2(5, 0).rotated(global_rotation)
		rpc('fire_rocket', name, position, global_rotation + PI)
		
remotesync func fire_rocket(name, position, rotation):
	planet.money -= activate_cost
	var rocket = preload("res://rocket.gd").new(target_player_number)
	rocket.name = name
	rocket.position = position
	rocket.rotation = rotation + PI/2
	rocket.from_planet = planet
	rocket.building = self
	rocket.set_network_master(get_network_master())
	$'/root/main'.add_child(rocket)
	update()

func on_activate():
	for building in get_tree().get_nodes_in_group("building" + str(planet.playerNumber)):
		if building.type == 'attack':
			var name = '%d_rocket_%d' % [ planet.playerNumber, rocket_name_index ]
			rocket_name_index += 1
			building.try_fire_rocket(name)
