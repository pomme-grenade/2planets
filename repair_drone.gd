extends Node2D
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

	change_dir_timer = Timer.new()
	change_dir_timer.connect('timeout', self, 'change_dir')
	add_child(change_dir_timer)
	do_repair_timer = Timer.new()
	do_repair_timer.connect('timeout', self, 'do_repair')
	add_child(do_repair_timer)
	do_repair_timer_finished = Timer.new()
	do_repair_timer_finished.connect('timeout', self, 'do_repair_finished')
	add_child(do_repair_timer_finished)

func _process(dt):
	reset_drone()

	if attached:
		destroyed_building.repair_time -= 0.1

		if destroyed_building.repair_time <= 0: 
			destroyed_building.is_destroyed = false
			destroyed_building.repair_time = 300
			destroyed_building.play(destroyed_building.type)
			destroyed_building.buildup_finish()
			reset_drone()

		return

	var buildings = get_tree().get_nodes_in_group("building" + str(get_parent().playerNumber))
	var closest_building = find_nearest_destroyed_building(buildings)
	if closest_building != null: 
		if global_position.distance_to(closest_building.global_position) < distance_to_planet + 5:
			destroyed_building = closest_building
			speed = 0.1
			change_dir_timer.start(change_dir_countdown)
			do_repair_timer.start(do_repair_countdown)
			attached = true
			do_repair()
		else:
			var own_quat = Quat(Vector3.BACK, 0)
			var target_quat = Quat(Vector3.BACK, closest_building.position.angle() - position.angle())
			var target_angle = own_quat.slerp(target_quat, 1 * dt).get_euler().z
			print(target_angle, ' ', position.angle())
			position = position.normalized().rotated(target_angle) * (closest_building.position.length() + distance_to_planet)

	update()

func find_nearest_destroyed_building(buildings):
	var result = null
	var distance_to_result = INF
	for building in buildings:
		var new_distance = global_position.distance_to(building.global_position)
		if (building.is_destroyed and 
				new_distance < distance_to_result):
			result = building
			distance_to_result = new_distance

	return result

func _draw():
	if (can_repair):
		draw_line(Vector2(0, 0), to_local(destroyed_building.global_position), Color(0.5, 0.5, 1, 0.7))

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
