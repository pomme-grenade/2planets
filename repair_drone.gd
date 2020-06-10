extends Node2D
var movement_direction
var speed = 0.3
var destroyed_building
var can_repair
var proximity = 0
var change_dir_timer
var change_dir_countdown = 2
var distance_to_planet = 20
var do_repair_timer
var do_repair_countdown
var do_repair_timer_finished
var do_repair_finished_countdown
var attached = false

func init():
	do_repair_countdown = rand_range(0.5, 1)
	do_repair_finished_countdown = rand_range(0.5, 4)

	movement_direction = 1 if round(rand_range(1, 2)) == 1 else -1
	change_dir_timer = Timer.new()
	change_dir_timer.connect('timeout', self, 'change_dir')
	add_child(change_dir_timer)
	do_repair_timer = Timer.new()
	do_repair_timer.connect('timeout', self, 'do_repair')
	add_child(do_repair_timer)
	do_repair_timer_finished = Timer.new()
	do_repair_timer_finished.connect('timeout', self, 'do_repair_finished')
	add_child(do_repair_timer_finished)

func _process(_dt):
	reset_drone()
	position = position.rotated(speed * movement_direction * _dt)

	if attached:
		destroyed_building.repair_time -= 0.1


	for building in get_tree().get_nodes_in_group("building" + str(get_parent().playerNumber)):
		if global_position.distance_to(building.global_position) < distance_to_planet + 5 and building.is_destroyed and not attached: 
			destroyed_building = building
			speed = 0.1
			change_dir_timer.start(change_dir_countdown)
			do_repair_timer.start(do_repair_countdown)
			attached = true
			do_repair()

	if attached and destroyed_building.repair_time <= 0: 
		destroyed_building.is_destroyed = false
		destroyed_building.repair_time = 300
		destroyed_building.play(destroyed_building.type)
		reset_drone()

	update()

func _draw():
	if (can_repair):
		draw_line(Vector2(0, 0), to_local(destroyed_building.global_position), Color(0.5, 0.5, 1, 0.7))

func change_dir():
	movement_direction = -1 * movement_direction
	z_index = 1 if z_index == 3 else 3

func do_repair():
	do_repair_countdown = rand_range(0.5, 1)
	do_repair_finished_countdown = rand_range(0.5, 4)
	change_dir_timer.paused = true
	do_repair_timer.paused = true
	can_repair = true
	speed = 0.02
	do_repair_timer_finished.paused = false
	do_repair_timer_finished.start(do_repair_finished_countdown)

func do_repair_finished():
	speed = 0.1
	can_repair = false
	do_repair_timer.paused = false
	change_dir_timer.paused = false

func reset_drone():
	if is_instance_valid(destroyed_building) and not destroyed_building.is_destroyed:
		can_repair = false
		speed = 0.3
		attached = false
		change_dir_timer.paused = true
		do_repair_timer.paused = true
		do_repair_timer_finished.paused = true
