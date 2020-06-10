extends Node2D

var planet

var target_player_number

func init():
	target_player_number = 2 if planet.playerNumber == 1 else 1

func try_fire_rocket(name):
	if planet.money < 10 or (not is_network_master()):
		planet.current_money_label.flash()
		return
	elif get_parent().is_built:
		var position = global_position - Vector2(5, 0).rotated(global_rotation)
		rpc('fire_rocket', name, position, global_rotation + PI)

remotesync func fire_rocket(name, position, rotation):
	planet.money -= 10
	var rocket = preload("res://rocket.gd").new(target_player_number)
	rocket.name = name
	rocket.position = position
	rocket.rotation = rotation + PI/2
	rocket.from_planet = planet
	rocket.building = self
	rocket.set_network_master(get_network_master())
	$'/root/main'.add_child(rocket)
	update()