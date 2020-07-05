extends AnimatedSprite

var planet
var is_destroyed = false
var is_built = false
var type
var child
var buildup_time = 1
var repair_time
var initial_repair_time = 50
var activate_cost = 0
var base_type
var building_info = ''

const textures = {
	attack = preload('res://images/buildings/rocket.png'),
	defense = preload('res://images/buildings/satellite.png'),
	income = preload('res://images/buildings/mine.png')
}

func init():
	is_built = false
	repair_time = initial_repair_time
	if child.has_user_signal('income'):
		child.connect('income', self, 'add_money')

	add_child(child)
	child.set_network_master(get_network_master())

	connect('animation_finished', self, 'buildup_finish', [], CONNECT_ONESHOT)

	var animation_name = str(type) + '_buildup'
	var default_fps = frames.get_animation_speed(animation_name)
	var frame_count = frames.get_frame_count(animation_name)
	speed_scale = (frame_count / default_fps) / buildup_time
	frame = 0
	play(animation_name)

	child.planet = planet
	if child.has_method("init"):
		child.init()

	building_info = child.building_info

func _process(_dt):
	if is_destroyed and repair_time < initial_repair_time:
		animation = type + '_buildup'
		var completion = 1 - ( 0.8 * repair_time / initial_repair_time)
		frame = floor(completion * frames.get_frame_count(type + '_buildup'))


	if child.get('activate_cost') != null:
		activate_cost = child.activate_cost

remotesync func destroy():
	if child.has_method("on_destroy"):
		child.on_destroy()
	is_destroyed = true
	play('destroyed')
	stop()
	planet.update()

remotesync func deconstruct(cost):
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
	var income_animation = preload('res://Income_animation.tscn').instance()
	income_animation.position = Vector2(-10, 8)
	add_child(income_animation)
	income_animation.label.text = '+' + str(value)

func can_upgrade(index):
	return planet.money >= 40 and \
		is_network_master() and \
		typeof(child.get('upgrade_%d_type' % index)) == TYPE_STRING and \
		(not is_destroyed) and \
		is_built

func try_upgrade(index):
	if not can_upgrade(index):
		return

	rpc('upgrade', index)

remotesync func upgrade(index):
	if child.has_method('on_upgrade'):
		child.on_upgrade()

	type = child.get('upgrade_%d_type' % index)
	var new_child_script = 'res://building/types/%s.gd' % type
	if typeof(new_child_script) != TYPE_STRING:
		return

	planet.money -= 40

	var new_child = load(new_child_script).new()
	new_child.name = child.name + '_upgrade'
	child.queue_free()
	child = new_child

	init()

func buildup_finish():
	if is_destroyed:
		return

	if child.has_method('buildup_finish'):
		child.buildup_finish()

	is_built = true
	repair_time = initial_repair_time
	$AnimationPlayer.play('flash');
	animation = type
	speed_scale = 1

func activate():
	if can_activate():
		planet.money -= child.activate_cost
		child.on_activate()

func can_activate():
	if child.get('activate_cost') != null and child.get('animation_finished') == null:
		return planet.money >= child.activate_cost \
			and is_built \
			and child.has_method('on_activate') \
			and not is_destroyed 
	elif child.get('activate_cost') != null and child.get('animation_finished'):
		return planet.money >= child.activate_cost \
			and is_built \
			and child.has_method('on_activate') \
			and not is_destroyed \
			and child.animation_finished
