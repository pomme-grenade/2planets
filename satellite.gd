extends Sprite

var player_number
var attack_range = 50
var fire_position
var cooldown = 0
var cooldown_time = 5

func _draw():
	draw_circle(Vector2(0, 0), 3, Color(0, 0.3, 1))

	if fire_position != null:
		var alpha = cooldown + 1 - cooldown_time
		if alpha > 0:
			draw_line(Vector2(5, 0).rotated(fire_position.angle()), fire_position, Color(0.9, 0.9, 1, alpha))
		else:
			fire_position = null

func _process(dt):
	if fire_position != null:
		update()

	cooldown -= dt

	if cooldown > 0:
		return

	var enemy_group = 'rocket' + str(1 if player_number == 2 else 2)
	for rocket in get_tree().get_nodes_in_group(enemy_group):
		if global_position.distance_to(rocket.global_position) < attack_range:
			fire_position = to_local(rocket.global_position)
			cooldown = cooldown_time
			rocket.queue_free()
			break
