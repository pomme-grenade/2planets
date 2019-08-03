extends Sprite

var health = 1
var planet
# 'attack', 'defense' or 'income'
var type
var rocket_amount_max = 2
var rocket_amount = 0
var rocket
var target_player_number

const rocket_spawn_rate = 1

const textures = {
	attack = preload('res://brownDrill.png'),
	defense = preload('res://satellite.png'),
	income = preload('res://brownDrill.png')
}

func _ready():
	add_to_group('building' + str(planet.playerNumber))
	add_user_signal('damage')
	connect('damage', self, 'on_damage')
	target_player_number = 2 if planet.playerNumber == 1 else 1

func init():
	rotation = position.direction_to(Vector2(0, 0)).angle()
	texture = textures[type]
	if type == 'attack':
		var attackTimer = Timer.new()
		attackTimer.connect('timeout', self, 'add_rocket')
		attackTimer.start(rocket_spawn_rate)
		add_child(attackTimer)

func on_damage():
	health -= 1
	if health <= 0:
		queue_free()

func fire_rocket():
	rocket.ready = true

func add_rocket():
	if rocket_amount < rocket_amount_max:
		rocket_amount += 1

	rocket = preload("res://rocket.gd").new(target_player_number)
	rocket.position = global_position - Vector2(5, 0).rotated(global_rotation)
	rocket.rotation = global_rotation + PI 
	rocket.planet = planet
	rocket.building = self
	rocket.rocket_amount = rocket_amount
	$'/root/Node2D'.add_child(rocket)

