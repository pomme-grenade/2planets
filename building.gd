extends Node2D

var health = 1

func _ready():
	add_to_group('building')
	add_user_signal('damage')
	connect('damage', self, 'on_damage')

func _draw():
	draw_polygon([Vector2(-5, -5), Vector2(5, -5), Vector2(0, 8)], [Color(200, 0, 0), Color(200, 0, 0), Color(255, 0, 0)])

func on_damage():
	print(health)
	health -= 1
	if health <= 0:
		queue_free()
