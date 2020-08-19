extends Node2D

var planet
var building_info
var can_hit_planet
var attack_range = 120
var circle_only_outline
var circle_position
var target_player_number

func init():
	building_info = ''
	can_hit_planet = preload('res://can_hit_planet.gd').new()
	circle_only_outline = preload('res://circle_only_outline.gd').new()
	circle_position = get_parent().position * 2
	target_player_number = 2 if planet.player_number == 1 else 1

func on_activate():
	pass

func _process(dt):
	var asteroids = get_tree().get_nodes_in_group('asteroids')
	for asteroid in asteroids:
		if planet.to_global(circle_position)\
			.distance_to(asteroid.global_position)\
				<= attack_range:
				var target = find_new_target()
				var rotation_amount = asteroid.global_position\
					 .angle_to_point(target.global_position)
				if not asteroid.was_rotated:
					asteroid.velocity = Vector2(-1, 0).rotated(rotation_amount) * 5 * asteroid.velocity.length()
					asteroid.was_rotated = true

func _draw():
	circle_only_outline.draw_circle_only_outline(
		to_local(planet.to_global(circle_position)), 
		Vector2(0, attack_range / get_parent().global_scale.x), 
		Color(0.4, 0.2, 0.7, 0.2), 
		0.5, self)

func find_new_target():
	if target_player_number == 2:
		return get_node("/root/main/planet_2")
	else:
		return get_node("/root/main/planet_1")
