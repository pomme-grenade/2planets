extends Node2D
var destroyed_building
var laser_on
var proximity = 0
var distance_to_planet = 10
var toggle_laser_timer
var attached = false
var current_sin_param = rand_range(0, 10)

func init():
	toggle_laser_timer = Timer.new()
	toggle_laser_timer.connect('timeout', self, 'toggle_laser')
	add_child(toggle_laser_timer)
	toggle_laser_timer.start(random_laser_timer_countdown())

func _process(dt):
	update()

	if attached and is_instance_valid(destroyed_building):
		destroyed_building.repair_time -= 0.1

		if destroyed_building.repair_time <= 0 or not destroyed_building.is_destroyed: 
			destroyed_building.is_destroyed = false
			destroyed_building.repair_time = 300
			destroyed_building.play(destroyed_building.type)
			destroyed_building.buildup_finish()
			detach()

	if attached or not is_instance_valid(destroyed_building):
		current_sin_param += dt
		position = position.rotated(sin(current_sin_param) * (sin(current_sin_param / 2) / 300))
		position *= 1 + (sin(current_sin_param) * 0.001)

	var closest_building = destroyed_building
	if not is_instance_valid(closest_building):
		var buildings = get_tree().get_nodes_in_group("building" + str(get_parent().playerNumber))
		closest_building = find_nearest_destroyed_building(buildings)

	if closest_building != null: 
		if global_position.distance_to(closest_building.global_position) < distance_to_planet + 5 and not attached:
			attached = true
			toggle_laser_timer.paused = false
		else:
			var own_quat = Quat(Vector3.BACK, 0)
			var target_quat = Quat(Vector3.BACK, closest_building.position.angle() - position.angle())
			var target_angle = own_quat.slerp(target_quat, 1 * dt).get_euler().z
			position = position.rotated(target_angle)
			var target_height = closest_building.position.length() + distance_to_planet
			var current_height = position.length()
			position *= lerp(1, target_height / current_height, dt)
			destroyed_building = closest_building


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
	if (laser_on and attached):
		draw_line(Vector2(0, 0), to_local(destroyed_building.global_position), Color(0.5, 0.5, 1, 0.7))

func toggle_laser():
	toggle_laser_timer.wait_time = random_laser_timer_countdown()
	laser_on = !laser_on

func detach():
	laser_on = false
	attached = false
	toggle_laser_timer.paused = true
	destroyed_building = null

func random_laser_timer_countdown():
	return rand_range(0.5, 1)
