extends Node2D
var destroyed_building
var laser_on
var distance_to_planet = 10
var toggle_laser_timer
var attached = false
var current_sin_param = rand_range(0, 10)
var active = true setget set_active

func init():
	toggle_laser_timer = Timer.new()
	toggle_laser_timer.connect('timeout', self, 'toggle_laser')
	add_child(toggle_laser_timer)
	toggle_laser_timer.start(random_laser_timer_countdown())

func _process(dt):
	update()

	if not active:
		return

	if attached and is_instance_valid(destroyed_building) and destroyed_building.is_destroyed:
		destroyed_building.repair_time -= dt

		if destroyed_building.repair_time <= 0:
			destroyed_building.is_destroyed = false
			destroyed_building.repair_finished()
			detach()

	if attached and is_instance_valid(destroyed_building) and not destroyed_building.is_destroyed:
		detach()

	current_sin_param += dt
	position = position.rotated(sin(current_sin_param) * (sin(current_sin_param / 2) / 300))
	position *= 1 + (sin(current_sin_param) * 0.001)

	var closest_building = destroyed_building
	if not is_instance_valid(closest_building):
		closest_building = find_nearest_destroyed_building()

	if closest_building != null: 
		if global_position.distance_to(closest_building.global_position) < distance_to_planet + 5 \
				and not attached:
			attached = true
			toggle_laser_timer.paused = false
		else:
			move_towards_building(closest_building, dt)

func move_towards_building(building, dt):
	var own_quat = Quat(Vector3.BACK, position.angle())
	var target_quat = Quat(Vector3.BACK, building.position.angle())
	var target_angle = own_quat.slerp(target_quat, 1 * dt).get_euler().z
	position = position.rotated(target_angle - position.angle())
	var target_height = building.position.length() + distance_to_planet
	var current_height = position.length()
	position *= lerp(1, target_height / current_height, dt)
	destroyed_building = building


func find_nearest_destroyed_building():
	var buildings = get_tree().get_nodes_in_group("building" + str(get_parent().player_number))
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
	if (laser_on and attached and is_instance_valid(destroyed_building)):
		var laser_length_factor = 1 + sin(current_sin_param) * 0.2
		var global_target = destroyed_building.get_parent().to_global(destroyed_building.position * 0.98)
		var target_position = to_local(global_target) * laser_length_factor

		draw_line(Vector2(0, 0), target_position , Color(0.5, 0.5, 1, 0.7))

func toggle_laser():
	toggle_laser_timer.wait_time = random_laser_timer_countdown()
	laser_on = !laser_on

func set_active(new_active):
	active = new_active
	if not active:
		modulate = Color(1, 0.6, 0.6)
		detach()
	else:
		self.modulate = Color(1, 1, 1)

func detach():
	laser_on = false
	attached = false
	toggle_laser_timer.paused = true
	destroyed_building = null

func random_laser_timer_countdown():
	return rand_range(0.5, 1)
