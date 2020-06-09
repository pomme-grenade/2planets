extends AnimatedSprite

var planet
var is_destroyed = false
var type
var child
var buildup_time = 0.7
var wait_buildup_timer

const textures = {
	attack = preload('res://images/buildings/rocket.png'),
	defense = preload('res://images/buildings/satellite.png'),
	income = preload('res://images/buildings/mine.png')
}

func init():
	connect('animation_finished', self, 'buildup_finish', [], CONNECT_ONESHOT)

	child.planet = planet
	add_child(child)
	child.connect('income', self, 'add_money')
	child.connect('change_type', self, 'change_child_type')
	child.init()

	if type == 'attack':
		speed_scale = 2.0

remotesync func destroy(cost):
	if child.has_method("on_destroy"):
		child.on_destroy()
	planet.money += cost / 4
	is_destroyed = true
	queue_free()
	planet.update()

func add_money(value):
	var income_animation = preload('res://Income_animation.tscn').instance()
	income_animation.position = Vector2(-10, 8)
	add_child(income_animation)
	income_animation.label.text = str(value)

func upgrade():
	if planet.money < 40:
		return

	planet.money -= 40
	child.upgrade()

func change_child_type(path):
	child.set_script(load(path))
	child.planet = planet
	child.init()

func try_fire_rocket(name):
	if type == 'attack':
		child.try_fire_rocket(name)

func buildup_finish():
	child.buildup_finish()
	$AnimationPlayer.play('flash');
	animation = type
