extends AnimatedSprite

var planet
var is_destroyed = false
var type
var child
var buildup_time = 1

const textures = {
	attack = preload('res://images/buildings/rocket.png'),
	defense = preload('res://images/buildings/satellite.png'),
	income = preload('res://images/buildings/mine.png')
}

func init():
	if child.has_user_signal('income'):
		child.connect('income', self, 'add_money')

	add_child(child)

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
	queue_free()
	planet.update()

func add_money(value):
	print('add_money')
	var income_animation = preload('res://Income_animation.tscn').instance()
	income_animation.position = Vector2(-10, 8)
	add_child(income_animation)
	income_animation.label.text = '+' + str(value)

func upgrade():
	if planet.money < 40:
		return

	var new_child_script = child.upgrade()
	if typeof(new_child_script) != TYPE_STRING:
		return

	planet.money -= 40

	var new_child = load(new_child_script).new()
	new_child.name = child.name + '_upgrade'
	child.queue_free()
	add_child(new_child)
	child = new_child
	init()

func try_fire_rocket(name):
	if type == 'attack':
		child.try_fire_rocket(name)

func buildup_finish():
	child.buildup_finish()
	$AnimationPlayer.play('flash');
	animation = type
	speed_scale = 1
