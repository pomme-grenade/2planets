extends Node2D

var healing_drone
var drone_index = 0
var planet
var activate_cost  = 40

func init():
    pass

func new_drone():
	healing_drone = preload('res://healing_drone.tscn').instance()
	healing_drone.name = '%s_drone_%d' % [name, drone_index]
	healing_drone.planet = planet
	drone_index += 1
	healing_drone.position = healing_drone.position.rotated(position.direction_to(Vector2(0, 0)).angle() - PI/2)
	healing_drone.position += get_parent().position + Vector2(0, 20).rotated(Vector2(0, 0).direction_to(get_parent().position).angle() - PI/2)
	healing_drone.z_index = 3 if round(rand_range(1, 3)) == 1 else 1
	planet.add_child(healing_drone)
	healing_drone.init()
	
func on_activate():
	get_parent().connect('animation_finished', self, 'on_animation_finished', [], CONNECT_ONESHOT)
	get_parent().play('drone_factory_activate')
	get_parent().speed_scale = 10

func on_animation_finished():
	new_drone()

	get_parent().play('drone_factory')
