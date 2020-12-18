extends Control

var player
var building_to_destroy
var building_index = 0
var info_container
var buildings = preload('res://building/building_info.gd')
var previously_pressed_button
var previously_pressed_slot

const building_types = [
	'attack',
	'defense',
	'income',
]

func init():
	info_container = $current_money_label

	if not is_network_master():
		return

	for type in building_types:
		add_button_shortcut(
			'new_building/' + type, 'build_' + type, 'start_building', [type])

	add_button_shortcut(
		'upgrade_building/activate', 'build_income', 'start_activate')
	add_button_shortcut(
		'upgrade_building/upgrade_1', 'build_defense', 'start_upgrade', [1])
	add_button_shortcut(
		'upgrade_building/upgrade_2', 'build_attack', 'start_upgrade', [2])

	$building_info.text = ''

func add_button_shortcut(
		path: String, 
		action_key: String, 
		callback_method: String, 
		callback_binds: Array = []
	):

	var button = get_node(path)

	var action = InputEventAction.new()
	action.action = player.player_action_key + action_key

	var shortcut = ShortCut.new()
	shortcut.shortcut = action
	button.shortcut = shortcut

	button.connect('pressed', self, callback_method, callback_binds)

func _process(_dt):
	var is_upgrade_visible = is_instance_valid(player.current_building)
	$upgrade_building.visible = is_upgrade_visible
	$new_building.visible = not is_upgrade_visible

	if is_upgrade_visible:
		update_upgrade_ui()
	else:
		update_new_building_ui()

	info_container.get_node('money').text = "%0.0f$" % player.planet.money
	info_container.get_node('income').text = "+%0.1f$/s" % player.planet.income


func update_upgrade_ui():
	var activate_button = $'upgrade_building/activate/activate_texture'
	if player.current_building.can_activate():
		activate_button.texture = load('res://buttons/arrow_%s.png' \
			% player.current_building.base_type)
	elif player.current_building.is_activatable():
		activate_button.texture = preload('res://buttons/arrow_cant_activate.png')
	else:
		activate_button.texture = null

	if previously_pressed_button == null:
		$building_info.text = player.current_building.building_info

	for index in [1, 2]:
		var upgrade_type = get_upgrade_type(index)
		var children = player.current_building.children
		var last_child = children[len(children) - 1]

		var upgrade_cost = ''
		if buildings.costs.get(upgrade_type) != null:
			upgrade_cost = '%d$' % buildings.costs[upgrade_type]
		if index == 1:
			$'building_cost/defense'.text = upgrade_cost
		elif index == 2:
			$'building_cost/attack'.text = upgrade_cost

		var upgrade_button = \
			get_node('upgrade_building/upgrade_%d/upgrade_texture' % index)
		if player.current_building.can_upgrade(index):
			upgrade_button.visible = true
			upgrade_button.texture = load('res://buttons/%s_button.png' \
				% last_child.get('upgrade_%s_type' % index))
			upgrade_button.self_modulate = Color(1, 1, 1, 1)
		elif last_child.get('upgrade_%s_type' % index) != null:
			upgrade_button.texture = load('res://buttons/%s_button.png' \
				% last_child.get('upgrade_%s_type' % index))
			upgrade_button.self_modulate = Color(1, 1, 1, 0.3)
		else:
			upgrade_button.visible = false

			
		if player.current_building.is_activatable():
			$'building_cost/income'.text = \
					'%d$' % player.current_building.activate_cost
		else:
			$'building_cost/income'.text = ''


func update_new_building_ui():
	for type in ['defense', 'attack', 'income']:
		if previously_pressed_slot == player.planet.current_slot_index:
			# button was highlighted in button press listener, dont change it
			pass
		elif player.planet.money <= buildings.costs[type]:
			get_node('new_building/%s' % type).modulate = Color(1, 1, 1, 0.3)
		else:
			get_node('new_building/%s' % type).modulate = Color(1, 1, 1, 1)

		get_node('building_cost/%s' % type).text = \
			'%s$' % buildings.costs[type]

	if (previously_pressed_button == null 
			or previously_pressed_slot != player.planet.current_slot_index):
		$building_info.text = ''
	
	if (previously_pressed_button != null && previously_pressed_slot != player.planet.current_slot_index):
		get_node(previously_pressed_button).modulate = Color(1, 1, 1)


func start_building(type: String):
	if (is_instance_valid(player.current_building) or
			not was_double_press('new_building/%s' % type, type)):
		return

	var name = '%d_building_%d' % [player.player_number, building_index]
	building_index += 1
	var position = player.planet.current_slot_position()
	player.try_spawn_building(type, name, position)
	update()


func start_upgrade(index):
	if (not was_double_press('upgrade_building/upgrade_%d' % index,
			get_upgrade_type(index))):
		return

	if ((not is_instance_valid(player.current_building))
		or player.current_building.is_destroyed):
		return

	player.current_building.try_upgrade(index)

func start_activate():
	player.current_building.try_activate()

func was_double_press(button_name: String, type) -> bool:
	var was_pressed_twice = (
		previously_pressed_button == button_name and
		previously_pressed_slot == player.planet.current_slot_index
	)

	if was_pressed_twice:
		previously_pressed_button = null
		get_node(button_name).modulate = Color(1, 1, 1)
	else:
		if previously_pressed_button != null:
			var previous_button_node = get_node(previously_pressed_button)
			if previous_button_node != null:
				previous_button_node.modulate = Color(1, 1, 1)

		previously_pressed_button = button_name
		previously_pressed_slot = player.planet.current_slot_index
		get_node(button_name).modulate = Color(2, 2, 2)
		if type != null:
			$building_info.text = Helper.with_default(
				buildings.descriptions.get(type),
				''
			)

	return was_pressed_twice

func get_upgrade_type(index):
	var children = player.current_building.children
	var last_child = children[len(children) - 1]
	return last_child.get('upgrade_%s_type' % index)
