extends Node2D

var planet
var repair_drone
var drone_index = 0
var upgrade_1_type = 'healing_drone_factory'
var upgrade_1_script = 'res://building/types/' + upgrade_1_type + '.gd'
var activate_cost = 40

func init():
	pass
func buildup_finish():
	pass

func new_drone():
	repair_drone = preload('res://repair_drone.tscn').instance()
	repair_drone.name = '%s_drone_%d' % [name, drone_index]
	drone_index += 1
	repair_drone.position = repair_drone.position.rotated(position.direction_to(Vector2(0, 0)).angle() - PI/2)
	repair_drone.position += get_parent().position + Vector2(0, 20).rotated(Vector2(0, 0).direction_to(get_parent().position).angle() - PI/2)
	repair_drone.z_index = 3 if round(rand_range(1, 3)) == 1 else 1
	planet.add_child(repair_drone)
	repair_drone.init()
	
func on_activate():
	get_parent().connect('animation_finished', self, 'on_animation_finished', [], CONNECT_ONESHOT)
	get_parent().play('drone_factory_activate')
	get_parent().speed_scale = 10

func on_animation_finished():
	if planet.money >= activate_cost:
		new_drone()
		planet.money -= activate_cost

	get_parent().play('drone_factory')
