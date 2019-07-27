extends Sprite

var health = 1

func _ready():
	add_to_group('building')
	add_user_signal('damage')
	connect('damage', self, 'on_damage')
	position.x = 600 + cos(250) * (100 + 8)
	position.y = 200 + sin(250) * (100 + 8)

	rotation = position.direction_to(Vector2(600, 200)).angle() - PI / 2

# func _draw():
# 	# draw_polygon([Vector2(-5, -5), Vector2(5, -5), Vector2(0, 8)], [Color(200, 0, 0), Color(200, 0, 0), Color(255, 0, 0)])
# 	pass

func on_damage():
	print(health)
	health -= 1
	if health <= 0:
		queue_free()

func _process(delta):
	# position += Vector2(delta, 0)
	pass
