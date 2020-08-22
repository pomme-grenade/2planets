extends AnimatedSprite

export var player_color = Color(1, 1, 1)

var player_number
var movementDirection = 0
var planet
var current_building
var player_key
var ui
var action_pressed_timer
var building_to_destroy
var timer_wait_time = 0.7
var do_dissolve = false
var dissolve_amount = 1
var building_costs = preload('res://building/building_costs.gd').costs


export var speed = 1

func _ready():
	set_process_unhandled_input(false)
	call_deferred("init")

func init():
	action_pressed_timer = Timer.new()
	action_pressed_timer.one_shot = true
	action_pressed_timer.connect('timeout', self, 'action_timer_timeout')
	add_child(action_pressed_timer)

	player_key = "player" + str(player_number) + "_"
	set_process_unhandled_input(true)

	# warning-ignore:return_value_discarded
	connect('animation_finished', self, '_animation_finished')

	$AnimationPlayer.play('idle')

	init_ui()

func _process(dt):
	var rightAction = player_key + "right"
	var leftAction = player_key + "left"

	if is_network_master():
		if Input.is_action_pressed(rightAction):
			movementDirection = 1
			flip_h = true
		elif Input.is_action_pressed(leftAction):
			movementDirection = -1
			flip_h = false
		else:
			movementDirection = 0

		position = position.rotated(movementDirection * speed  * dt)

	var target_rotation = position.angle() + PI/2 + (movementDirection * PI/6)
	var target_quat = Quat(Vector3.BACK, target_rotation)
	var current_quat = Quat(Vector3.BACK, rotation)
	rotation = current_quat.slerp(target_quat, 12 * dt).get_euler().z

	if movementDirection != 0:
		speed_scale = 30.0
		play('move')
		planet.update()
	else:
		speed_scale = 8.0
		play('idle')

	var new_building = get_building_in_range()
	if new_building != current_building:
		ui.update()
		if is_instance_valid(current_building):
			current_building.self_modulate = Color(1, 1, 1, 1)
		if is_instance_valid(new_building):
			new_building.self_modulate = Color(2, 2, 2, 1)
		current_building = new_building

	if is_instance_valid(current_building) and do_dissolve:
		dissolve_amount -= 1 / (0.7 / dt)
		current_building.material.set_shader_param('value', dissolve_amount) 
	else:
		dissolve_amount = 1
		var buildings = get_tree().get_nodes_in_group("building" + str(get_parent().player_number))
		for building in buildings:
			building.material.set_shader_param('value', dissolve_amount)

	if is_network_master():
		rpc_unreliable("set_pos_and_motion", position, movementDirection, rotation)

puppet func set_pos_and_motion(p_pos, p_dir, p_rot):
		position = p_pos
		movementDirection = p_dir
		rotation = p_rot

		if movementDirection == 1:
			flip_h = false
		elif movementDirection == -1:
			flip_h = true

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		var scene = preload('res://menu/pause_menu.tscn').instance()
		get_node('/root').add_child(scene)
		get_tree().paused = true

	if event.is_action_pressed(player_key + "deconstruct") and is_network_master():
		do_dissolve = true
		start_destroy_timer()

	if event.is_action_released(player_key + 'deconstruct') and is_network_master():
		do_dissolve = false
		action_pressed_timer.stop()

	if event.is_action_pressed("god"):
		planet.money += 100000


func get_building_in_range():
	for building in get_tree().get_nodes_in_group('building' + str(planet.player_number)):
		if abs(position.angle_to(building.position)) < (PI / planet.slot_count) / 2:
			return building

func can_build(type):
	return (planet.money >= building_costs[type]
		and not is_instance_valid(current_building))

func try_spawn_building(type, name, position):
	if is_network_master() and not can_build(type):
		return

	rpc('spawn_building', type, name, position)

func _animation_finished():
	if movementDirection == 0:
		stop()

remotesync func spawn_building(type, name, position):
	var building = preload('res://building/building.tscn').instance()
	var scripts = {
		'income': preload('res://income/income.gd'),
		'defense': preload('res://defense/defense.gd'),
		'attack': preload('res://attack/attack.gd'),
	}
	building.type = type
	building.base_type = type
	building.planet = planet
	building.position = building.position.rotated(position.direction_to(Vector2(0, 0)).angle() - PI/2)
	building.position += position
	building.name = name
	building.set_network_master(get_network_master())
	planet.add_child(building)
	building.rotation = building.position \
		.direction_to(Vector2(0, 0)).angle() - PI/2
	building.add_to_group('building' + str(planet.player_number))
	building.centered = true

	var new_child = scripts[type].new()
	new_child.name = name + '_child'
	building.add_building_child(new_child)

	current_building = building
	current_building.self_modulate = Color(2, 2, 2, 1)
	ui.update()
	# re-draw circle highlighting the new building
	planet.update()

	planet.money -= building_costs[type]

func init_ui():
	ui = get_node('/root/main/planet_ui_%s' % player_number)
	ui.player = self
	ui.set_network_master(get_network_master())
	ui.init()


func start_destroy_timer():
	if not is_instance_valid(current_building):
		return

	building_to_destroy = current_building
	action_pressed_timer.start(timer_wait_time)

func action_timer_timeout():
	if (is_instance_valid(building_to_destroy) and current_building == building_to_destroy):
		var price = 0 if building_to_destroy.is_destroyed else 40
		building_to_destroy.rpc('deconstruct', price)

	do_dissolve = false
	building_to_destroy = null
	update()
