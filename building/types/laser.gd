extends Node2D
var planet
var upgrade_1_type = 'laser'
var upgrade_1_script = 'res://building/types/' + upgrade_1_type + '.gd'
var enemy_player_number
var target_planet
var buildings
var stop_laser_timer
var shooting = false
var laser_position = 0
var activate_cost = 20
var one_building_destroyed = false

func init():
	stop_laser_timer = Timer.new()
	stop_laser_timer.connect('timeout', self, 'stop_laser')
	add_child(stop_laser_timer)
	enemy_player_number = 1 if planet.playerNumber == 2 else 2
	target_planet = get_node('/root/main/planet_%s' % enemy_player_number)

func _process(dt):
	buildings = get_tree().get_nodes_in_group('building' + str(enemy_player_number))
	if shooting:
		laser_position = 400
		for building in buildings:
			if Vector2(0, Vector2(0, 0).distance_to(to_local(building.global_position))).rotated(PI).distance_to(to_local(building.global_position)) < 10 \
			and Vector2(0, 0).distance_to(to_local(building.global_position)) < 400 and not building.is_destroyed and not one_building_destroyed:
				building.destroy()
				one_building_destroyed = true
	update()

func _draw():
	if shooting:
		draw_line(Vector2(0, 0), Vector2(0, laser_position).rotated(PI), Color(1, 1, 1), 4)

func stop_laser():
	laser_position = 0
	shooting = false
	one_building_destroyed = false
	stop_laser_timer.stop()

func on_activate():
	if planet.money >= 20 and not shooting:
		stop_laser_timer.start(0.07)
		shooting = true
		planet.money -= 20

func buildup_finish():
	get_node('/root/main/planet_ui_%d/building_cost/Label2' % planet.playerNumber).text = '10'
