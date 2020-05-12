extends AnimatedSprite

var planet
# 'attack', 'defense' or 'income'
# warning-ignore:unused_class_variable
var type
var target_player_number
var incomeTimer
#warning-ignore:unused_class_variable
var is_destroyed = false

# defense-specific fields
var attack_range = 80
var fire_position
var cooldown = 0
var cooldown_time = 0.5

const rocket_spawn_rate = 5

const textures = {
	attack = preload('res://building/rocketlauncher.png'),
	defense = preload('res://building/satellite.png'),
	income = preload('res://building/mine.png')
}

const position_offsets = {
	income = 0.95,
	attack = 0.94,
	defense = 1.5
}

func _ready():
	add_to_group('building' + str(planet.playerNumber))
	target_player_number = 2 if planet.playerNumber == 1 else 1
	self.centered = true

func init():
	rotation = position.direction_to(Vector2(0, 0)).angle() - PI/2
	position *= position_offsets[type]
	animation = type
	if type == 'income':
		incomeTimer = Timer.new()
		incomeTimer.connect('timeout', self, 'add_income')
		add_child(incomeTimer)
		incomeTimer.start(4)

func _process(dt):
	if type != 'defense':
		return

	if fire_position != null:
		update()

	var enemy_group = 'rocket' + str(1 if planet.playerNumber == 2 else 2)
	var rockets = get_tree().get_nodes_in_group(enemy_group)
	if len(rockets) > 0:
		var nearest_position = rockets[0].global_position
		for rocket in rockets:
			if global_position.distance_to(rocket.global_position) < global_position.distance_to(nearest_position):
				nearest_position = rocket.global_position

		global_rotation = (nearest_position - global_position).angle() + PI/2

	cooldown -= dt

	if cooldown > 0:
		return
	else:
		self_modulate.a = 1

	if is_network_master():
		for rocket in get_tree().get_nodes_in_group(enemy_group):
			if global_position.distance_to(rocket.global_position) < attack_range:
				rpc('destroy_rocket', rocket.get_path())
				break

remotesync func destroy_rocket(path):
	var rocket = get_node(path)
	if rocket == null:
		print('unknown rocket ', path)
		return
	fire_position = to_local(rocket.global_position)
	cooldown = cooldown_time
	self_modulate.a = 0.8
	show_income_animation('5')

	rocket.queue_free()
	planet.money += 5

func _draw():
	if type != 'defense':
		return

	draw_circle(Vector2(0, 0), attack_range/scale.x, Color(0.1, 0.2, 0.7, 0.1))

	if fire_position != null:
		var alpha = cooldown * (1 / cooldown_time)
		if alpha > 0:
			draw_line(Vector2(4, 0).rotated(fire_position.angle()), fire_position, Color(0.9, 0.9, 2, alpha), 1.1, true)
		else:
			fire_position = null

func add_income():
	show_income_animation("0.06/s")
	planet.income += 0.06

func try_fire_rocket(name):
	if planet.money < 10 or (not is_network_master()):
		planet.current_money_label.flash()
		return

	var position = global_position - Vector2(5, 0).rotated(global_rotation)
	rpc('fire_rocket', name, position, global_rotation + PI)

remotesync func fire_rocket(name, position, rotation):
	planet.money -= 10
	show_income_animation("0.05/s")
	planet.income += 0.05
	var rocket = preload("res://rocket.gd").new(target_player_number)
	rocket.name = name
	rocket.position = position
	rocket.rotation = rotation + PI/2
	rocket.from_planet = planet
	rocket.building = self
	rocket.set_network_master(get_network_master())
	$'/root/main'.add_child(rocket)
	update()

remotesync func destroy(cost):
	planet.money += cost / 4
	is_destroyed = true
	queue_free()
	planet.update()

func show_income_animation(text):
	var income_animation = preload('res://Income_animation.tscn').instance()
	income_animation.position = Vector2(-10, 8)
	add_child(income_animation)
	income_animation.label.text = text
