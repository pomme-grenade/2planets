extends Sprite

var health = 1
var planet
# 'attack', 'defense' or 'income'
var type

const rocket_spawn_rate = 5

const textures = {
	attack = preload('res://brownDrill.png'),
	defense = preload('res://brownDrill.png'),
	income = preload('res://brownDrill.png')
}

func _ready():
	add_to_group('building' + str(planet.playerNumber))
	add_user_signal('damage')
	connect('damage', self, 'on_damage')

func init():
	rotation = position.direction_to(Vector2(0, 0)).angle()
	texture = textures[type]
	if type == 'attack':
		var attackTimer = Timer.new()
		attackTimer.connect('timeout', self, 'fire_rocket')
		attackTimer.start(rocket_spawn_rate)
		add_child(attackTimer)

func on_damage():
	health -= 1
	if health <= 0:
		queue_free()

func fire_rocket():
	var target_player_number = 2 if planet.playerNumber == 1 else 1
	var rocket = preload("res://rocket.gd").new(target_player_number)
	rocket.position = global_position - Vector2(5, 0).rotated(rotation)
	rocket.rotation = global_rotation + PI
	$'/root/Node2D'.add_child(rocket)
