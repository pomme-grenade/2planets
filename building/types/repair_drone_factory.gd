extends Node2D

var planet
var drone_index := 0
var activate_cost := 40
var building_info: String setget ,get_building_info
var animation_finished := true
var drones := []
const upgrade_1_type = 'healing_drone_factory'
const max_drones = 10

func init():
	building_info = ''

func buildup_finish():
	for drone in drones:
		drone.active = true

func new_drone():
	var repair_drone = preload('res://repair_drone.tscn').instance()
	repair_drone.name = '%s_drone_%d' % [name, drone_index]
	repair_drone.position = repair_drone.position.rotated(position.direction_to(Vector2(0, 0)).angle() - PI/2)
	repair_drone.position += get_parent().position + Vector2(0, 20).rotated(Vector2(0, 0).direction_to(get_parent().position).angle() - PI/2)
	repair_drone.z_index = 3 if round(rand_range(1, 3)) == 1 else 1
	planet.add_child(repair_drone)
	repair_drone.init()
	drones.append(repair_drone)

func on_destroy():
	for drone in drones:
		drone.active = false

func can_activate() -> bool:
	return len(drones) < max_drones

func get_building_info() -> String:
	return '%d/%d drones' % [len(drones), max_drones]
	
func on_activate():
	var _err = get_parent() \
		.connect('animation_finished', self, 'on_animation_finished', [], CONNECT_ONESHOT)
	get_parent().play('drone_factory_activate')
	get_parent().speed_scale = 10
	animation_finished = false

func on_animation_finished():
	animation_finished = true
	new_drone()
	get_parent().play('drone_factory')
