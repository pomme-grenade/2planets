extends Sprite

var rand_rotation

func _ready():
	rand_rotation = rand_range(-1, 1)

func _process(dt):
	position += Vector2(10 * dt, 10 * dt)
	rotation += rand_rotation * 0.01
