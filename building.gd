extends Sprite

var health = 1
var planet
# 'attack', 'defense' or 'income'
var type

const textures = {
	attack = preload('res://brownDrill.png'),
	defense = preload('res://brownDrill.png'),
	income = preload('res://brownDrill.png')
}

func _ready():
	add_to_group('building')
	add_user_signal('damage')
	connect('damage', self, 'on_damage')

func init():
	rotation = position.direction_to(Vector2(0, 0)).angle() - PI / 2
	texture = textures[type]

func on_damage():
	health -= 1
	if health <= 0:
		queue_free()

func _process(delta):
	# position += Vector2(delta, 0)
	pass
