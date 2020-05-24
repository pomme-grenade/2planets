extends AnimatedSprite

export var player_color = Color(1, 1, 1)

var playerNumber
var movementDirection = 0
var planet
var current_building
var player_key
var ui

var rocket_name_index = 0

var building_cost = {
	attack = 40,
	defense = 40,
	income = 40,
}

export var speed = 1

func _ready():
	set_process_unhandled_input(false)
	call_deferred("init")

func init():
	player_key = "player" + str(playerNumber) + "_"
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
			flip_h = false
		elif Input.is_action_pressed(leftAction):
			movementDirection = -1
			flip_h = true
		else:
			movementDirection = 0

		position = position.rotated(movementDirection * speed  * dt)

	var target_rotation = position.angle() + PI/2 + (movementDirection * PI/6)
	var target_quat = Quat(Vector3.BACK, target_rotation)
	var current_quat = Quat(Vector3.BACK, rotation)
	rotation = current_quat.slerp(target_quat, 12 * dt).get_euler().z

	if movementDirection != 0:
		speed_scale = 1.8
		play('move')
		planet.update()
	else:
		speed_scale = 0.4
		play('idle')

	var new_building = get_building_in_range()
	if new_building != current_building:
		ui.update()
		if is_instance_valid(current_building):
			current_building.self_modulate = Color(1, 1, 1, 1)
		if is_instance_valid(new_building):
			new_building.self_modulate = Color(2, 2, 2, 1)
		current_building = new_building

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
		var scene = preload('res://menu.tscn').instance()
		get_node('/root/main').add_child(scene)
		get_tree().paused = true

	if event.is_action_pressed(player_key + "fire_rocket") and is_network_master():
		for building in get_tree().get_nodes_in_group("building" + str(playerNumber)):
			if building.type == 'attack':
				var name = '%d_rocket_%d' % [ playerNumber, rocket_name_index ]
				rocket_name_index += 1
				building.try_fire_rocket(name)

func get_building_in_range():
	for building in get_tree().get_nodes_in_group('building' + str(planet.playerNumber)):
		if abs(position.angle_to(building.position)) < (PI / planet.slot_count) / 2:
			return building

func can_build(type):
	return (planet.money >= building_cost[type]
		and not is_instance_valid(current_building))

func try_spawn_building(type, name, position):
	if is_network_master() and not can_build(type):
		planet.current_money_label.flash()
		return

	rpc('spawn_building', type, name, position)

func _animation_finished():
	if movementDirection == 0:
		stop()

remotesync func spawn_building(type, name, position):
	var building = preload('res://building/building.tscn').instance()
	var scripts = {
		'income': preload('res://building/types/income.gd'),
		'defense': preload('res://building/types/defense.gd'),
		'attack': preload('res://building/types/attack.gd'),
	}
	building.type = type
	building.child = scripts[type].new()
	building.planet = planet
	building.position = building.position.rotated(position.direction_to(Vector2(0, 0)).angle() - PI/2)
	building.position += position
	building.name = name
	building.set_network_master(get_network_master())
	planet.add_child(building)
	building.rotation = building.position \
		.direction_to(Vector2(0, 0)).angle() - PI/2
	building.add_to_group('building' + str(planet.playerNumber))
	building.centered = true

	if type == 'defense':
		building.position *= 1.5

	building.init()
	current_building = building
	current_building.self_modulate = Color(2, 2, 2, 1)
	ui.update()
	# re-draw circle highlighting the new building
	planet.update()

	planet.money -= building_cost[type]

func init_ui():
	ui = get_node('/root/main/planet_ui_%s' % playerNumber)
	ui.player = self
	ui.set_network_master(get_network_master())
	ui.init()
