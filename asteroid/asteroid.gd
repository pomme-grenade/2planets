extends Sprite

remotesync var rand_rotation
var velocity
var indicator
var can_hit_planet
var type = 'asteroid'
var was_rotated = false
var health = 100
var is_attached = false
remotesync var is_destroyed = false

func _ready():
	can_hit_planet = preload('res://can_hit_planet.gd').new()
	add_child(can_hit_planet)
	add_to_group('asteroids')

	rset('rand_rotation', rand_range(-1, 1))
	indicator = \
		preload('res://asteroid/asteroid_indicator.tscn').instance()
	$'/root/main'.add_child(indicator)

func _process(dt):
	if is_destroyed: 
		queue_free()
		return

	position += velocity * dt
	rotation += rand_rotation * dt

	if is_instance_valid(indicator):
		var inside_from_top = velocity.y > 0 and position.y > -15
		var inside_from_bottom = velocity.y < 0 and position.y < 415
		if (inside_from_bottom or inside_from_top):
			indicator.queue_free()
		else:
			indicator.global_position = Vector2(
				calculate_indicator_x(), 
				clamp(position.y, 0, 400)
			)
			indicator.rotation = velocity.angle() - PI/2

	var planets = get_tree().get_nodes_in_group('planets')
	for planet in planets:
		if can_hit_planet.did_hit_planet(planet):
			rset('is_destroyed', true)
			can_hit_planet.rpc('hit_planet', type, planet.get_path())

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
