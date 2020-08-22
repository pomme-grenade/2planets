extends Control

var player
var building_to_destroy
var building_index = 0
var info_container
var building_costs = preload('res://building/building_costs.gd').costs
var previously_pressed_button

const building_types = [
	'attack',
	'defense',
	'income',
]

func init():
	if not is_network_master():
		return

	info_container = $current_money_label

	for type in building_types:
		add_button_shortcut(
			'new_building/' + type, 'build_' + type, 'start_building', [type])

	add_button_shortcut(
		'update_building/activate', 'build_income', 'start_activate')
	add_button_shortcut(
		'update_building/upgrade_1', 'build_defense', 'start_upgrade', [1])
	add_button_shortcut(
		'update_building/upgrade_2', 'build_attack', 'start_upgrade', [2])

func add_button_shortcut(
		path: String, 
		action_key: String, 
		callback_method: String, 
		callback_binds: Array = []
	):

	var button = get_node(path)

	var action = InputEventAction.new()
	action.action = player.player_key + action_key

	var shortcut = ShortCut.new()
	shortcut.shortcut = action
	button.shortcut = shortcut

	button.connect('pressed', self, callback_method, callback_binds)

func _process(_dt):
	if is_instance_valid(player.current_building):
		toggle_new_building_ui(false)
		var activate_button = $'update_building/activate/activate_texture'
		if player.current_building.can_activate():
			activate_button.texture = load('res://buttons/arrow_%s.png' \
				% player.current_building.base_type)
		else:
			activate_button.texture = load('res://buttons/arrow_cant_activate.png')

		for index in [1, 2]:
			var upgrade_type = player.current_building.child.get('upgrade_%s_type' % index)
			if index == 1 and upgrade_type != null:
				$'building_cost/defense'.text =  \
					str(building_costs[upgrade_type])
			elif index == 2 and upgrade_type != null:
				$'building_cost/attack'.text =  \
					str(building_costs[upgrade_type])

			var upgrade_button = get_node('update_building/upgrade_%d/upgrade_texture' % index)
			if player.current_building.can_upgrade(index):
				upgrade_button.visible = true
				upgrade_button.texture = load('res://buttons/%s_button.png' \
					% player.current_building.child.get('upgrade_%s_type' % index))
				upgrade_button.rect_scale = Vector2(0.8, 0.8)
				upgrade_button.self_modulate = Color(1, 1, 1, 1)
			elif player.current_building.child.get('upgrade_%s_type' % index) != null:
				upgrade_button.texture = load('res://buttons/%s_button.png' \
					% player.current_building.child.get('upgrade_%s_type' % index))
				upgrade_button.rect_scale = Vector2(0.8, 0.8)
				upgrade_button.self_modulate = Color(1, 1, 1, 0.3)
			else:
				upgrade_button.visible = false

				
			get_node('/root/main/planet_ui_%s/building_cost/income' \
				% player.player_number).text = '%d' % player.current_building.activate_cost

		$building_info.text = player.current_building.building_info
	else:
		$'building_cost/defense'.text = str(building_costs['defense'])
		$'building_cost/income'.text = str(building_costs['income'])
		$'building_cost/attack'.text = str(building_costs['attack'])

		toggle_new_building_ui(true)
		$building_info.text = ''

	info_container.get_node('money').text = "%0.0f$" % player.planet.money
	info_container.get_node('income').text = "+%0.1f$/s" % player.planet.income

func toggle_new_building_ui(visible: bool):
	$new_building.visible = visible
	$update_building.visible = not visible

func start_building(type: String):
	if (is_instance_valid(player.current_building) or
			not was_double_press('build_%s' % type)):
		return

	var name = '%d_building_%d' % [player.player_number, building_index]
	building_index += 1
	var position = player.planet.current_slot_position()
	player.try_spawn_building(type, name, position)
	update()

func start_upgrade(index):
	if (not was_double_press('upgrade_%d' % index)):
		return

	if ((not is_instance_valid(player.current_building))
		or player.current_building.is_destroyed):
		return

	player.current_building.try_upgrade(index)

func start_activate():
	player.current_building.activate()

func was_double_press(button_name: String) -> bool:
	var result = previously_pressed_button == button_name
	if result:
		previously_pressed_button = null
	else:
		previously_pressed_button = button_name

	return result
