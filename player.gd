extends AnimatedSprite

export var player_color = Color(1, 1, 1)

var playerNumber
var movementDirection = 0
var planet
var current_building
var player_key
var ui
var building_index = 0

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

	spawn_menu()

func _process(delta):
	var rightAction = player_key + "right"
	var leftAction = player_key + "left"

	if is_network_master():
		if Input.is_action_pressed(rightAction):
			movementDirection = 1
		elif Input.is_action_pressed(leftAction):
			movementDirection = -1
		else:
			movementDirection = 0

		rpc_unreliable("set_pos_and_motion", position, movementDirection)

		position = position.rotated(movementDirection * speed  * delta)

	rotation += movementDirection * speed * delta
	if movementDirection == 1:
		flip_h = true
	else:
		flip_h = false

	if movementDirection != 0:
		play('move')
		planet.update()
	else:
		stop()

	var new_building = get_building_in_range()
	if new_building != current_building:
		ui.update()
		current_building = new_building

puppet func set_pos_and_motion(p_pos, movement_direction):
		position = p_pos
		movementDirection = movement_direction

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		var scene = preload('res://menu.tscn').instance()
		get_node('/root/main').add_child(scene)
		get_tree().paused = true

	if event.is_action_pressed(player_key + "fire_rocket") and is_network_master():

		for building in get_tree().get_nodes_in_group("building" + str(playerNumber)):
			if building.type == 'attack':
				building.rpc('fire_rocket')

func get_building_in_range():
	for building in get_tree().get_nodes_in_group('building' + str(planet.playerNumber)):
		if abs(position.angle_to(building.position)) < (PI / planet.slot_count) / 2:
			return building

func can_build(type):
	return (planet.money >= building_cost[type]
		and not is_instance_valid(current_building))

remotesync func spawn_building(type, position):
	if not can_build(type):
		planet.current_money_label.flash()
		return
	var building = preload("res://building/building.gd").new()
	building.planet = planet
	building.position = position
	building.type = type
	building.name = get_name() + str(building_index)
	building_index++
	planet.add_child(building)
	# re-draw circle highlighting the new building
	building.init()
	current_building = building
	ui.update()
	planet.update()

	planet.money -= building_cost[type]

func spawn_menu():
	ui = preload("res://planet_ui/add_building_ui.gd").new()
	get_node("/root/main").call_deferred("add_child", ui)
	ui.rect_position = planet.position + Vector2(-15, -40)
	ui.player = self
	ui.set_network_master(get_network_master())
