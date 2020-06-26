extends Node2D

var planet
var type
var is_destroyed = false

var attack_range = 80
var max_strength = 40
var strength = max_strength
var regen = 5.0 / 2
var upgrade_1_type = 'shield'
var upgrade_1_script = 'res://building/types' + upgrade_1_type + '.gd'

func init():
	get_parent().rotation = get_parent().position.angle() + PI / 2
	update()
	pass

func _process(_dt):
	if not get_parent().is_built:
		return

	strength = min(max_strength, strength + regen * _dt)
	var enemy_number = 1 if planet.playerNumber == 2 else 2
	var enemy_group = 'rocket' + str(enemy_number)
	var rockets = get_tree().get_nodes_in_group(enemy_group)
	for rocket in rockets:
		if (global_position.distance_to(rocket.global_position) < (attack_range * get_parent().global_scale.x)
					and strength > rocket.planet_rocket_damage):
			rocket.queue_free()
			strength -= rocket.planet_rocket_damage
	update()

func _draw():
	if not get_parent().is_built:
		return

	var color_strength = round(strength / 5) / (max_strength / 5)
	draw_circle_arc(Vector2(0, 0), 80, -60, 60, Color(0.4, 0.2, 0.7, 0.4 * color_strength))
	
func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 16
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, 3)
