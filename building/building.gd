extends AnimatedSprite

var planet
var is_destroyed = false
var is_built = false
var type
var child
var buildup_time = 1
var repair_time = 300

const textures = {
	attack = preload('res://images/buildings/rocket.png'),
	defense = preload('res://images/buildings/satellite.png'),
	income = preload('res://images/buildings/mine.png')
}

func init():
	is_built = false
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
	child.init()

remotesync func destroy(cost):
	if child.has_method("on_destroy"):
		child.on_destroy()
	planet.money += cost / 4
	is_destroyed = true
	play(str(type) + '_destroyed')
	# queue_free()
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
		typeof(child.get('upgrade_%d_script' % index)) == TYPE_STRING and \
		(not is_destroyed) and \
		is_built

func try_upgrade(index):
	if not can_upgrade(index):
		return

	rpc('upgrade', index)

remotesync func upgrade(index):
	if child.has_method('on_upgrade'):
		child.on_upgrade()

	var new_child_script = child.get('upgrade_%d_script' % index)
	if typeof(new_child_script) != TYPE_STRING:
		return

	planet.money -= 40

	var new_child = load(new_child_script).new()
	new_child.name = child.name + '_upgrade'
	child.queue_free()
	child = new_child
	init()

func try_fire_rocket(name):
	if type == 'attack':
		child.try_fire_rocket(name)

func buildup_finish():
	if is_destroyed:
		return

	is_built = true
	if child.has_method('buildup_finish'):
		child.buildup_finish()
	$AnimationPlayer.play('flash');
	animation = type
	speed_scale = 1
