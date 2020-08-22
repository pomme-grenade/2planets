extends Node2D

var new_drone_timer
var time_until_new_drone = 10
var max_drones
var drones := []
var base_building
var factory

func start_factory():
	new_drone_timer = Timer.new()
	new_drone_timer.connect('timeout', self, 'spawn_drone')
	factory.add_child(new_drone_timer)
	new_drone_timer.start()

func spawn_drone():
	if len(drones) > max_drones:
		new_drone_timer.stop()
		return

	var _err = base_building.connect(
		'animation_finished', 
		factory, 'on_animation_finished', 
		[], 
		CONNECT_ONESHOT
	)
	base_building.play('repair_drone_factory_activate')
	base_building.speed_scale = 10
	factory.animation_finished = false
