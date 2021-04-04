extends Node2D

var planet
# warning-ignore:unused_class_variable
var upgrade_1_type = 'laser'
# warning-ignore:unused_class_variable
var upgrade_2_type = 'split_rocket'
var rocket_name_index = 0
# warning-ignore:unused_class_variable
var activate_cost := 20
var target_player_number
# warning-ignore:unused_class_variable
var building_info := 'activate to fire'

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
	for building in get_parent().get_connected_buildings():
		building.call_last_child_method('shoot')
	shoot()

func shoot():
	var name = '%s_rocket_%d' % [ self.name, rocket_name_index ]
	rocket_name_index += 1
	var position = global_position - Vector2(5, 0).rotated(global_rotation)
	fire_rocket(name, position, global_rotation + PI)
