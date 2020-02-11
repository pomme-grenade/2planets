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

const rocket_spawn_rate = 5

const textures = {
	attack = preload('res://building/rocketlauncher.png'),
	defense = preload('res://building/satellite.png'),
	income = preload('res://building/white_drill.png')
}

func _ready():
	add_to_group('building' + str(planet.playerNumber))
	target_player_number = 2 if planet.playerNumber == 1 else 1
	self.centered = true

func init():
	rotation = position.direction_to(Vector2(0, 0)).angle()
	texture = textures[type]
	if type == 'income':
		incomeTimer = Timer.new()
		incomeTimer.connect('timeout', self, 'add_income')
		incomeTimer.start(4)
		add_child(incomeTimer)

func add_income():
	show_income_animation("0.06/s")
	planet.income += 0.06


func fire_rocket():
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
		$'/root/Node2D'.add_child(rocket)
		update()
	else:
		planet.current_money_label.flash()

func show_income_animation(text):
	var income_animation = preload('res://Income_animation.tscn').instance()
	income_animation.position = Vector2(4, 9)
	income_animation.rotation_degrees = -90
	add_child(income_animation)
	income_animation.label.text = text

func fire_all():
	fire_rocket()

