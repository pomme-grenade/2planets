extends Control

var player
var building_to_destroy
var building_index = 0
var info_container

const building_types = [
	'attack',
	'defense',
	'income',
]

func init():
	if not is_network_master():
		return

	info_container = $current_money_label

	$'building_cost/Label1'.text = '40'
	$'building_cost/Label2'.text = '0'
	$'building_cost/Label3'.text = '40'

	for type in building_types:
		var button = get_node('new_building/' + type)
		var shortcut = ShortCut.new()
		shortcut.shortcut = \
				InputMap.get_action_list(player.player_key + 'build_' + type)[0]
		button.shortcut = shortcut
		button.connect('pressed', self, 'start_building', [type])

	var activate_button = $'update_building/activate'
	var shortcut = ShortCut.new()
	shortcut.shortcut = \
			InputMap.get_action_list(player.player_key + 'build_income')[0]
	activate_button.shortcut = shortcut
	activate_button.connect('button_down', self, 'start_activate')
	# activate_button.connect('button_up', self, 'stop_action_timer')

	var upgrade_button_1 = $'update_building/upgrade_1'
	shortcut = ShortCut.new()
	shortcut.shortcut = \
			InputMap.get_action_list(player.player_key + 'build_defense')[0]
	upgrade_button_1.shortcut = shortcut
	upgrade_button_1.connect('pressed', self, 'start_upgrade', [1])

	var upgrade_button_2 = $'update_building/upgrade_2'
	shortcut = ShortCut.new()
	shortcut.shortcut = \
			InputMap.get_action_list(player.player_key + 'build_attack')[0]
	upgrade_button_2.shortcut = shortcut
	upgrade_button_2.connect('pressed', self, 'start_upgrade', [2])


func _process(_dt):
	if is_instance_valid(player.current_building):
		toggle_new_building_ui(false)
		for index in [1, 2]:
			if player.current_building.can_upgrade(index):
				get_node('update_building/upgrade_%d/arrow' % index).visible = true
			else:
				get_node('update_building/upgrade_%d/arrow' % index).visible = false
	else:
		toggle_new_building_ui(true)

	info_container.get_node('life').text = "%s ♥" % player.planet.health
	info_container.get_node('money').text = "%0.0f$" % player.planet.money
	info_container.get_node('income').text = "+%0.1f$/s" % player.planet.income

func toggle_new_building_ui(visible: bool):
	$new_building.visible = visible
	$update_building.visible = not visible

func start_building(type):
	if is_instance_valid(player.current_building):
		return

	var name = '%d_building_%d' % [player.playerNumber, building_index]
	building_index += 1
	var position = player.planet.current_slot_position()
	player.try_spawn_building(type, name, position)
	update()

func start_upgrade(index):
	if ((not is_instance_valid(player.current_building))
		or player.current_building.is_destroyed):
		return

	player.current_building.try_upgrade(index)

func start_activate():
	player.current_building.activate()
