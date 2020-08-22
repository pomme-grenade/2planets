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
var building_costs = preload('res://building/building_costs.gd').costs
var upgrading = false

func add_building_child(child):
	children.append(child)
	is_built = false
	repair_time = initial_repair_time
	if child.has_user_signal('income'):
		child.connect('income', self, 'add_money')
	add_child(child)
	child.set_network_master(get_network_master())
	child.planet = planet
	if child.has_method("init"):
		child.init()

	if child.get('activate_cost') != null:
		activate_cost = child.activate_cost

	connect('animation_finished', self, 'buildup_finish', [], CONNECT_ONESHOT)

	var animation_name = str(type) + '_buildup'
	var default_fps = frames.get_animation_speed(animation_name)
	var frame_count = frames.get_frame_count(animation_name)
	speed_scale = (frame_count / default_fps) / buildup_time
	frame = 0
	play(animation_name)


func _process(_dt):
	if is_destroyed and repair_time < initial_repair_time:
		animation = type + '_buildup'
		var completion = 1 - ( 0.8 * repair_time / initial_repair_time)
		frame = floor(completion * frames.get_frame_count(type + '_buildup'))


	for child in children:
		if child.get('activate_cost') != null:
			activate_cost = child.activate_cost

remotesync func destroy():
	for child in children:
		if child.has_method("on_destroy"):
			child.on_destroy()
		if child.get('additional_income') != null:
			planet.income -= child.additional_income
	is_destroyed = true
	play('%s_destroyed' % type)
	stop()
	planet.update()

remotesync func deconstruct(cost):
	for child in children:
		if child.has_method("on_destroy") and not is_destroyed:
			child.on_destroy()

	if is_built:
		planet.money += cost / 4
	else:
		planet.money += cost

	is_destroyed = true
	queue_free()
	planet.update()

func add_money(value):
	print('add_money')
	var income_animation = \
		preload('res://income/Income_animation.tscn').instance()
	income_animation.position = Vector2(-10, 8)
	add_child(income_animation)
	income_animation.label.text = '+' + str(value)

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
	for child in children:
		if child.has_method('on_upgrade'):
			child.on_upgrade()

		type = last_child.get('upgrade_%d_type' % index)

	var new_child_script = 'res://%s/%s.gd' % [type, type]
	if typeof(new_child_script) != TYPE_STRING:
		return

	planet.money -= building_costs[type]

	var new_child = load(new_child_script).new()
	new_child.name = last_child.name + '_upgrade'
	add_building_child(new_child)
	upgrading = true


func upgrade_finish():
	pass

func buildup_finish():
	var last_child = children[len(children) - 1]

	if is_destroyed:
		return

	if last_child.has_method('buildup_finish'):
		last_child.buildup_finish()

	if last_child.get('additional_income') != null and not upgrading:
		planet.income += last_child.additional_income

	upgrading = false
	is_built = true
	repair_time = initial_repair_time
	$AnimationPlayer.play('flash');
	animation = type
	speed_scale = 1

func activate():
	var last_child = children[len(children) - 1]
	if can_activate():
		planet.money -= last_child.activate_cost
		last_child.on_activate()

func can_activate():
	var last_child = children[len(children) - 1]
	var animation_finished = \
		last_child.get('animation_finished') == null || last_child.animation_finished
	if last_child.get('activate_cost') != null:
		return (planet.money >= last_child.activate_cost
			and is_built
			and last_child.has_method('on_activate')
			and (not last_child.has_method('can_activate') or last_child.can_activate())
			and not is_destroyed 
			and animation_finished
			and is_network_master())

func get_building_info() -> String:
	var last_child = children[len(children) - 1]
	return last_child.building_info
