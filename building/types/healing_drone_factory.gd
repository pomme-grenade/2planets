extends Node2D

var drone_index := 0
var planet
var building_info: String setget ,get_building_info
var animation_finished := true
var drones := []
const max_drones = 5
const activate_cost := 40

func init():
	building_info = ''

func new_drone():
	var healing_drone = preload('res://healing_drone.tscn').instance()
	healing_drone.name = '%s_drone_%d' % [name, drone_index]
	healing_drone.planet = planet
	healing_drone.position = healing_drone.position.rotated(position.direction_to(Vector2(0, 0)).angle() - PI/2)
	healing_drone.position += get_parent().position + Vector2(0, 20).rotated(Vector2(0, 0).direction_to(get_parent().position).angle() - PI/2)
	healing_drone.z_index = 3 if round(rand_range(1, 3)) == 1 else 1
	planet.add_child(healing_drone)
	healing_drone.init()
	drones.append(healing_drone)

func get_building_info() -> String:
	return '%d/%d drones' % [len(drones), max_drones]

func can_activate() -> bool:
	return len(drones) < max_drones
	
func on_activate():
	var _err = get_parent() \
		.connect('animation_finished', self, 'on_animation_finished', [], CONNECT_ONESHOT)
	get_parent().play('healing_drone_factory_activate')
	get_parent().speed_scale = 10
	animation_finished = false

func buildup_finish():
	for drone in drones:
		drone.active = true

func on_destroy():
	for drone in drones:
		drone.active = false

func on_animation_finished():
	animation_finished = true
	new_drone()
	get_parent().play('healing_drone_factory')
