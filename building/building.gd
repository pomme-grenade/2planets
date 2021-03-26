extends AnimatedSprite

var planet
var is_destroyed = false
var is_built = false
var type
var children := []
var buildup_time = 1
var repair_time
var initial_repair_time = 50
var activate_cost = 0
var base_type
var building_info: String setget ,get_building_info
var building_costs = preload('res://building/building_info.gd').costs
var upgrading = false
var do_dissolve = false
var dissolve_amount = 1
var deconstruction_timer_wait_time = 0.7

func add_building_child(child):
	children.append(child)
	is_built = false
	repair_time = initial_repair_time
	add_child(child)
	child.set_network_master(get_network_master())
	child.planet = planet
	if child.has_method("init"):
		child.init()

	if child.has_user_signal('income'):
		child.connect('income', self, 'add_money')

	if child.get('activate_cost') != null:
		activate_cost = child.activate_cost

	connect('animation_finished', self, 'buildup_animation_finished', [], CONNECT_ONESHOT)

	var animation_name = str(type) + '_buildup'
	var default_fps = frames.get_animation_speed(animation_name)
	var frame_count = frames.get_frame_count(animation_name)
	speed_scale = (frame_count / default_fps) / buildup_time
	frame = 0
	play(animation_name)

func _process(dt):
	$Particles2D.emitting = get_connected_buildings().size() > 0 and not is_destroyed
	
	if do_dissolve:
		material.set_shader_param('value', dissolve_amount) 
		dissolve_amount -= dt / 0.7

	if is_destroyed and repair_time < initial_repair_time:
		animation = type + '_buildup'
		var completion = 1 - ( 0.8 * repair_time / initial_repair_time)
		frame = floor(completion * frames.get_frame_count(type + '_buildup'))


	for child in children:
		if child.get('activate_cost') != null:
			activate_cost = child.activate_cost

remotesync func destroy():
	is_destroyed = true
	call_children_method('on_destroy')
	play('%s_destroyed' % type)
	stop()
	update_connected_buildings()
	planet.update()

func start_deconstruction_timer():
	var deconstruction_timer = Timer.new()
	deconstruction_timer.one_shot = true
	deconstruction_timer.connect('timeout', self, 'try_deconstruct')
	add_child(deconstruction_timer)
	deconstruction_timer.start(deconstruction_timer_wait_time)
	do_dissolve = true

func try_deconstruct():
	var price = building_costs[type] / 2 if not is_destroyed else 0
	rpc('deconstruct', price)

	do_dissolve = false
	update()

remotesync func deconstruct(cost):
	if not is_destroyed:
		is_destroyed = true
		call_children_method('on_deconstruct')
		update_connected_buildings()

	if is_built:
		planet.money += cost / 4
	else:
		planet.money += cost

	queue_free()
	planet.update()

func add_money(value):
	var last_child = children[len(children) - 1]
	var income_animation = \
		preload('res://income/Income_animation.tscn').instance()
	$'/root/main'.add_child(income_animation)
	income_animation.label.text = '+' + str(value) + '$'
	income_animation.global_position = last_child.global_position

func can_upgrade(index):
	var last_child = children[len(children) - 1]
	var upgrade_type = last_child.get('upgrade_%d_type' % index)
	return (
		is_network_master() and
		typeof(upgrade_type) == TYPE_STRING and
		planet.money >= building_costs[upgrade_type] and
		(not is_destroyed) and
		is_built
	)

func try_upgrade(index):
	if not can_upgrade(index):
		return

	rpc('upgrade', index)

remotesync func upgrade(index):
	var last_child = children[len(children) - 1]

	type = last_child.get('upgrade_%d_type' % index)

	var new_child_script = 'res://%s/%s.gd' % [type, type]
	if typeof(new_child_script) != TYPE_STRING:
		return

	planet.money -= building_costs[type]

	var new_child = load(new_child_script).new()
	new_child.name = '%s_%s' % [self.name, type]
	add_building_child(new_child)
	upgrading = true

func repair_finished():
	for child in children:
		if child.has_method('repair_finished'):
			child.repair_finished()

	buildup_animation_finished()
	update_connected_buildings()

func initial_build_finished():
	for child in children:
		if child.has_method('initial_build_finished'):
			child.initial_build_finished()
		
func buildup_animation_finished():
	if is_destroyed:
		return

	for child in children:
		if child.has_method('buildup_animation_finished'):
			child.buildup_animation_finished()

	update_connected_buildings()

	upgrading = false
	is_built = true
	repair_time = initial_repair_time
	$AnimationPlayer.play('flash');
	animation = type
	speed_scale = 1

remotesync func activate():
	var last_child = children[len(children) - 1]
	planet.money -= last_child.activate_cost
	last_child.on_activate()

func try_activate():
	if can_activate():
		rpc('activate')

func is_activatable():
	var last_child = children[len(children) - 1]
	return (
		last_child.get('activate_cost') != null
		and last_child.has_method('on_activate')
	)

func can_activate():
	var last_child = children[len(children) - 1]
	var animation_finished = \
		last_child.get('animation_finished') == null || last_child.animation_finished
	return (
		is_activatable() 
		and planet.money >= last_child.activate_cost
		and is_built
		and (not last_child.has_method('can_activate') or last_child.can_activate())
		and not is_destroyed 
		and animation_finished
	)

func get_building_info() -> String:
	var last_child = children[len(children) - 1]
	return last_child.building_info

func get_connected_buildings():
	var neighbours = get_neighbours(self)

	return neighbours

func get_neighbours(previous):
	var neighbours = []
	for building in get_tree().get_nodes_in_group('building' + str(planet.player_number)):
		if building != self \
				and building != previous \
				and not building.is_destroyed \
				and abs(position.angle_to(building.position)) < (PI / planet.slot_count) * 1.1 \
				and building.type == type:
			neighbours.append(building)
			for neighbour in building.get_neighbours(self):
				neighbours.append(neighbour)

	return neighbours

func set_highlighted(is_highlighted: bool):
	if is_highlighted:
		self.self_modulate = Color(2, 2, 2, 1)
	else:
		self.self_modulate = Color(1, 1, 1, 1)

	call_children_method('on_highlight', [is_highlighted])

func update_connected_buildings():
	for building in get_connected_buildings():
		building.call_last_child_method('update_income')
	call_last_child_method('update_income')

func call_last_child_method(method: String, args: Array = []):
	var last_child = self.children[len(self.children) - 1]
	if last_child.has_method(method):
		last_child.callv(method, args)


func call_children_method(method: String, args: Array = []):
	for child in children:
		if child.has_method(method):
			child.callv(method, args)
