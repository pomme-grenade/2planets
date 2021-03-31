extends Node2D

var new_drone_timer
var time_until_new_drone = 10
var max_drones
var drones := []
var base_building
var factory

func _ready():
	new_drone_timer = Timer.new()
	new_drone_timer.connect('timeout', self, 'spawn_drone')
	add_child(new_drone_timer)

func spawn_drone():
	if len(drones) >= max_drones:
		new_drone_timer.stop()
		base_building.play(base_building.type)
		return

	factory.new_drone()

func stop():
	new_drone_timer.stop()


func start_spawning():
	new_drone_timer.start(time_until_new_drone)
	var animation = '%s_activate' % base_building.type
	base_building.play(animation)
	var frames = base_building.frames.get_frame_count(animation)
	var speed = float(time_until_new_drone) / frames
	base_building.speed_scale = speed

