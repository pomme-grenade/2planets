extends Sprite

var rand_rotation
var velocity
var indicator

func _ready():
	rand_rotation = rand_range(-1, 1)
	indicator = \
		preload('res://asteroid/asteroid_indicator.tscn').instance()
	$'/root/main'.add_child(indicator)

func _process(dt):
	position += velocity * dt
	rotation += rand_rotation * dt

	if is_instance_valid(indicator):
		var inside_from_top = velocity.y > 0 and position.y > 0
		var inside_from_bottom = velocity.y < 0 and position.y < 400
		if (inside_from_bottom or inside_from_top):
			indicator.queue_free()
		else:
			indicator.global_position = Vector2(
				calculate_indicator_x(), 
				clamp(position.y, 0, 400)
			)
			indicator.rotation = velocity.angle() - PI/2

func calculate_indicator_x():
	var angle_to_vertical
	var y_offset
	if velocity.y < 0:
		angle_to_vertical = PI/2 + velocity.angle()
		y_offset = position.y - 400
	else:
		angle_to_vertical = PI/2 - velocity.angle()
		y_offset = abs(position.y)
	return (tan(angle_to_vertical) * y_offset) + position.x
