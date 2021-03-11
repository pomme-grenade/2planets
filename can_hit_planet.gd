extends Node2D

var explosion_radius = 20
var damage = 5
var explosion_scene = preload('res://explosion/explosion.tscn')

func _ready():
	name = 'can_hit_planet'

func did_hit_planet(planet) -> bool:
	if planet.is_network_master():
		var distance_to_target = (
			global_position.distance_to(planet.global_position) 
			- planet.planetRadius
		)
		if distance_to_target < 1:
			return true

	return false

remotesync func hit_planet(type, planet_path):
	var hit_building = false

	var planet = get_node(planet_path)
	var buildings = get_tree()\
		.get_nodes_in_group("building" + str(planet.player_number))
	for building in buildings:
		var distance_to_building = point_on_planet(planet)\
			.distance_to(building.global_position)
		if (
			distance_to_building < explosion_radius 
			and not building.is_destroyed
		):
			if not building.is_destroyed:
				building.destroy()
				hit_building = true

	if not hit_building:
		planet.health -= damage

	play_explosion(type, point_on_planet(planet))
	
	print("rocket hit planet, destroying rocket: ", get_parent().name)
	get_parent().queue_free()

func play_explosion(explosion_animation, explosion_position = global_position):
	var explosion = explosion_scene.instance()
	explosion.position = explosion_position
	explosion.play(explosion_animation)
	$'/root/main'.add_child(explosion)

	var scale = explosion_radius / 20.0
	explosion.scale = Vector2(scale, scale)

func point_on_planet(target):
	 return (
		(target.planetRadius - 10)
		* target.global_position.direction_to(global_position) 
		+ target.global_position
	)
