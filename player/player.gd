extends AnimatedSprite

export var player_color = Color(1, 1, 1)

var player_number
var movementDirection = 0
var planet
var current_building
var player_action_key
var ui
var building_costs = preload('res://building/building_info.gd').costs

export var speed = 1

func _ready():
	set_process_unhandled_input(false)
	call_deferred("init")

func init():
	var is_online_multiplayer = \
		len(get_tree().get_network_connected_peers()) > 0

	if is_online_multiplayer:
		player_action_key = "player1_"
	else:
		player_action_key = "player%d_" % player_number

	set_process_unhandled_input(true)

	# warning-ignore:return_value_discarded
	connect('animation_finished', self, '_animation_finished')

	$AnimationPlayer.play('idle')

	init_ui()

func _process(dt):
	var rightAction = self.player_action_key + "right"
	var leftAction = self.player_action_key + "left"

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
	else:
		speed_scale = 8.0
		play('idle')

	var new_building = get_building_in_range()
	if new_building != current_building:
		ui.update()
		if is_instance_valid(current_building):
			current_building.set_highlighted(false)
		if is_instance_valid(new_building):
			new_building.set_highlighted(true)
		current_building = new_building

	if is_network_master():
		rpc_unreliable("set_pos_and_motion", position, movementDirection, rotation)

puppet func set_pos_and_motion(p_pos, p_dir, p_rot):
		position = p_pos
		movementDirection = p_dir
		rotation = p_rot

		if movementDirection == 1:
			flip_h = true
		elif movementDirection == -1:
			flip_h = false

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		var scene = preload('res://menu/pause_menu.tscn').instance()
		get_node('/root').add_child(scene)
		get_tree().paused = true

	if event.is_action_pressed(self.player_action_key + "deconstruct") and is_network_master():
		if is_instance_valid(current_building):
			current_building.start_deconstruction_timer()

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
	new_child.name = '%s_%s' % [name, type]
	building.add_building_child(new_child)

	current_building = building
	current_building.set_highlighted(true)
	ui.update()
	# re-draw circle highlighting the new building
	planet.update()

	planet.money -= building_costs[type]

func init_ui():
	ui = get_node('/root/main/planet_ui_%s' % player_number)
	ui.player = self
	ui.set_network_master(get_network_master())
	ui.init()
