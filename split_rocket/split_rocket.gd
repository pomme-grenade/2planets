extends Node2D

var planet
var rocket_name_index = 0
var activate_cost = 30
var target_player_number
var building_info
# var upgrade_2_type = 'slingshot'

func init():
	building_info = ''
	target_player_number = 2 if planet.player_number == 1 else 1

func fire_rocket(name, position, rotation):
	var rocket = preload('res://attack/rocket.tscn').instance()

	rocket.name = name
	rocket.split_distance = 150
	rocket.position = position
	rocket.rotation = rotation + PI/2
	rocket.from_planet = planet
	rocket.color = Color(1, 0.8, 0.2)

	rocket.init(target_player_number)
	rocket.set_network_master(get_network_master())
	$'/root/main'.add_child(rocket)
	update()

func on_activate():
	for building in get_parent().connected_buildings:
		building.call_last_child_method('shoot')
	shoot()

func shoot():
	var name = '%s_split_rocket_%d' % [ self.name, rocket_name_index ]
	rocket_name_index += 1
	var position = global_position - Vector2(5, 0).rotated(global_rotation)
	fire_rocket(name, position, global_rotation + PI)


