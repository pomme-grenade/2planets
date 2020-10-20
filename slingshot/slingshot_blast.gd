extends Node2D

var planet
var attack_range = 80
var circle_position
var target_player_number
var is_exploding = false
var explosion_timer
var initial_time_until_explosion = 0.5

func _ready():
	target_player_number = 2 if planet.player_number == 1 else 1
	explosion_timer = Timer.new()
	explosion_timer.connect('timeout', self, 'explode')
	explosion_timer.one_shot = true
	add_child(explosion_timer)
	explosion_timer.start(initial_time_until_explosion)

func _process(dt):
	var asteroids = get_tree().get_nodes_in_group('asteroids')

	if not is_exploding:
		position.y -= 100 * dt
	elif is_exploding:
		for asteroid in asteroids:
			if global_position\
				.distance_to(asteroid.global_position)\
					<= attack_range:
					var target = find_new_target()
					var rotation_amount = asteroid.global_position\
						.angle_to_point(target.global_position)
					if not asteroid.was_rotated:
						asteroid.velocity = Vector2(-1, 0)\
							.rotated(rotation_amount) \
								* 5 * asteroid.velocity.length()
						asteroid.was_rotated = true

func _draw():
	if is_exploding:
		draw_circle(Vector2(0, 0), attack_range, Color(0.7, 0.7, 1, 0.05))

func explode():
	if not is_exploding:
		is_exploding = true
		explosion_timer.start(1)
	else:
		queue_free()
	update()

func find_new_target():
	if target_player_number == 2:
		return get_node("/root/main/planet_2")
	else:
		return get_node("/root/main/planet_1")
