extends Sprite

var planet
# 'attack', 'defense' or 'income'
# warning-ignore:unused_class_variable
var type
var rocket
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
	income = preload('res://building/white_drill.png')
}

const position_offsets = {
	income = 0.97,
	attack = 1.04,
	defense = 1.5
}

func _ready():
	add_to_group('building' + str(planet.playerNumber))
	target_player_number = 2 if planet.playerNumber == 1 else 1
	self.centered = true

func init():
	rotation = position.direction_to(Vector2(0, 0)).angle()
	texture = textures[type]
	position *= position_offsets[type]
	if type == 'income':
		incomeTimer = Timer.new()
		incomeTimer.connect('timeout', self, 'add_income')
		incomeTimer.start(4)
		add_child(incomeTimer)

func _process(dt):
	if type != 'defense':
		return

	if fire_position != null:
		update()

	cooldown -= dt

	if cooldown > 0:
		return
	else:
		self_modulate.a = 1

	var enemy_group = 'rocket' + str(1 if planet.playerNumber == 2 else 2)
	for rocket in get_tree().get_nodes_in_group(enemy_group):
		if global_position.distance_to(rocket.global_position) < attack_range:
			fire_position = to_local(rocket.global_position)
			cooldown = cooldown_time
			self_modulate.a = 0.5
			show_income_animation("0.5")

			rocket.queue_free()
			planet.money += 0.5

			break

func _draw():
	if type != 'defense':
		return

	draw_circle(Vector2(0, 0), attack_range, Color(0.1, 0.2, 0.7, 0.1))

	if fire_position != null:
		var alpha = cooldown + 1 - cooldown_time
		if alpha > 0:
			draw_line(Vector2(4, 0).rotated(fire_position.angle()), fire_position, Color(0.9, 0.9, 1, alpha))
		else:
			fire_position = null

func add_income():
	show_income_animation("0.06/s")
	planet.income += 0.06

remotesync func fire_rocket():
	print('fire target ' + str(target_player_number))
	if planet.money >= 10:
		planet.money -= 10
		show_income_animation("0.05/s")
		planet.income += 0.05
		rocket = preload("res://rocket.gd").new(target_player_number)
		rocket.ready = true
		# rocket_amount -= 1
		rocket.position = global_position - Vector2(5, 0).rotated(global_rotation)
		rocket.rotation = global_rotation + PI
		rocket.planet = planet
		rocket.building = self
		$'/root/main'.add_child(rocket)
		update()
	else:
		print('not firing')
		planet.current_money_label.flash()

remotesync func destroy(cost):
	planet.money += cost / 4
	is_destroyed = true
	queue_free()
	planet.update()

func show_income_animation(text):
	var income_animation = preload('res://Income_animation.tscn').instance()
	income_animation.position = Vector2(4, 9)
	income_animation.rotation_degrees = -90
	add_child(income_animation)
	income_animation.label.text = text
