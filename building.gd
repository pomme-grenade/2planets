extends Sprite

var health = 1
var planet
# 'attack', 'defense' or 'income'
var type
var rocket_amount_max = 2
var rocket_amount = 0
var rocket
var target_player_number
var player_is_close
var delayTimer
var is_targeted
var targeted_by 

const rocket_spawn_rate = 5
 
const textures = {
	attack = preload('res://img/rocketlauncher.png'),
	defense = preload('res://satellite.png'),
	income = preload('res://img/white_drill.png')
}
func _draw():
	for i in range(rocket_amount):
	# draw_set_transform(Vector2(global_position.x, global_position.y), rotation, Vector2(1, 1))
		draw_rect(Rect2(Vector2(0, -5 - (i * 3)), Vector2(4, 1)), Color(0, 50, 255))

func _ready():
	targeted_by = self
	add_to_group('building' + str(planet.playerNumber))
	add_user_signal('damage')
	connect('damage', self, 'on_damage')
	target_player_number = 2 if planet.playerNumber == 1 else 1
	self.centered = true
	delayTimer = Timer.new()
	is_targeted = false

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
	if planet.money >= 1:
		planet.money -= 1
		planet.income += 0.05
		delayTimer.stop()
		rocket = preload("res://rocket.gd").new(target_player_number)
		rocket.ready = true
		rocket_amount -= 1
		rocket.position = global_position - Vector2(5, 0).rotated(global_rotation)
		rocket.rotation = global_rotation + PI 
		rocket.planet = planet
		rocket.building = self
		$'/root/Node2D'.add_child(rocket)
		update()

func add_rocket():
	if rocket_amount < rocket_amount_max:
		rocket_amount += 1
		update()

func fire_all():
	fire_rocket()
	# for i in range(rocket_amount):
	# 	delayTimer.connect('timeout', self, 'fire_rocket')
	# 	delayTimer.start(0.2)
	# 	add_child(delayTimer)
		

