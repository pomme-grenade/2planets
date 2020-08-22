extends Node2D

var drone_index := 0
var planet
var building_info: String setget ,get_building_info
var drones := []
var drone_spawner
const max_drones = 3
const activate_cost := 40

func init():
	building_info = ''
	drone_spawner = load('res://drone_spawner.gd').new()
	drone_spawner.max_drones = max_drones
	drone_spawner.base_building = get_parent()
	drone_spawner.factory = self
	add_child(drone_spawner)


func new_drone():
	var direction_to_planet = \
		Vector2(0, 0).direction_to(get_parent().position).angle() - PI/2
	var healing_drone_rotation = \
		position.direction_to(Vector2(0, 0)).angle() - PI/2
	var healing_drone = \
		preload('res://healing_drone_factory/healing_drone.tscn').instance()
	healing_drone.name = '%s_drone_%d' % [name, drone_index]
	healing_drone.planet = planet
	healing_drone.position = \
		healing_drone.position.rotated(healing_drone_rotation)
	healing_drone.position += \
		get_parent().position + Vector2(0, 20).rotated(direction_to_planet)
	healing_drone.z_index = 3 if round(rand_range(1, 3)) == 1 else 1
	planet.add_child(healing_drone)
	healing_drone.init()
	drones.append(healing_drone)
	drone_spawner.drones = drones

func get_building_info() -> String:
	return '%d/%d drones' % [len(drones), max_drones]

func buildup_animation_finished():
	for drone in drones:
		drone.active = true

func on_destroy():
	for drone in drones:
		drone.active = false

func on_deconstruct():
	for drone in drones:
		drone.queue_free()

func on_animation_finished():
	new_drone()
	get_parent().play(get_parent().type)
