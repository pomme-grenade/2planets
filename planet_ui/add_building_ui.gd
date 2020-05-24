extends Control

var player
var action_pressed_timer
var building_to_destroy
var building_to_build
var building_to_upgrade
var timer_wait_time = 0.7
var building_index = 0

const building_types = [
	'attack',
	'defense',
	'income',
]

func init():
	if not is_network_master():
		return

	action_pressed_timer = Timer.new()
	action_pressed_timer.one_shot = true
	action_pressed_timer.connect('timeout', self, 'action_timer_timeout')
	add_child(action_pressed_timer)

	for type in building_types:
		var button = get_node('new_building/' + type)
		var shortcut = ShortCut.new()
		shortcut.shortcut = \
				InputMap.get_action_list(player.player_key + 'build_' + type)[0]
		button.shortcut = shortcut
		button.connect('button_down', self, 'start_build_timer', [type])
		button.connect('button_up', self, 'stop_action_timer')

	var destroy_button = $'update_building/destroy'
	var shortcut = ShortCut.new()
	shortcut.shortcut = \
			InputMap.get_action_list(player.player_key + 'build_income')[0]
	destroy_button.shortcut = shortcut
	destroy_button.connect('button_down', self, 'start_destroy_timer')
	destroy_button.connect('button_up', self, 'stop_action_timer')

	var upgrade_button = $'update_building/upgrade_1'
	shortcut = ShortCut.new()
	shortcut.shortcut = \
			InputMap.get_action_list(player.player_key + 'build_defense')[0]
	upgrade_button.shortcut = shortcut
	upgrade_button.connect('button_down', self, 'start_upgrade_timer')
	upgrade_button.connect('button_up', self, 'stop_action_timer')

func _process(_dt):
	if (is_instance_valid(player.current_building) 
			and building_to_build == null):
		toggle_new_building_ui(false)
	else:
		toggle_new_building_ui(true)

func toggle_new_building_ui(visible: bool):
	$new_building.visible = visible
	$update_building.visible = not visible

func start_build_timer(type):
	if is_instance_valid(player.current_building):
		return

	building_to_build = type
	action_pressed_timer.start(timer_wait_time)

func stop_action_timer():
	action_pressed_timer.stop()
	building_to_destroy = null
	building_to_build = null
	building_to_upgrade = null

func start_destroy_timer():
	if ((not is_instance_valid(player.current_building))
			or player.current_building.is_destroyed):
		return

	building_to_destroy = player.current_building
	action_pressed_timer.start(timer_wait_time)

func start_upgrade_timer():
	if ((not is_instance_valid(player.current_building))
		or player.current_building.is_destroyed):
		return

	building_to_upgrade = player.current_building
	action_pressed_timer.start(timer_wait_time / 2)

func action_timer_timeout():
	if (is_instance_valid(building_to_destroy) and
			player.current_building == building_to_destroy):

		building_to_destroy.rpc('destroy', 
			player.building_cost[building_to_destroy.type])
	elif (building_to_build != null 
			and not is_instance_valid(player.current_building)):

		var name = '%d_building_%d' % [player.playerNumber, building_index]
		building_index += 1
		var position = player.planet.current_slot_position()
		player.try_spawn_building(building_to_build, name, position)
	elif is_instance_valid(building_to_upgrade):
		building_to_upgrade.upgrade()

	building_to_destroy = null
	building_to_build = null
	building_to_upgrade = null
	update()
