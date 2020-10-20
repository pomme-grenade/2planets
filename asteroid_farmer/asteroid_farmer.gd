extends Node2D
var planet
var enemy_player_number
var target_planet
var asteroids
var stop_laser_timer
var shooting = false
var laser_position = 0
var activate_cost = 20
var laser_range = 300
var building_info
var attached_asteroid

func init():
	building_info = ''
	stop_laser_timer = Timer.new()
	stop_laser_timer.connect('timeout', self, 'stop_laser')
	add_child(stop_laser_timer)
	enemy_player_number = 1 if planet.player_number == 2 else 2
	target_planet = get_node('/root/main/planet_%s' % enemy_player_number)

func _process(dt):
	asteroids = get_tree().get_nodes_in_group('asteroids')
	if shooting:
		for asteroid in asteroids:
			var building_distance_to_asteroid = \
				global_position.distance_to(asteroid.global_position)
			var laser_distance_to_asteroid = \
				Vector2(0, -building_distance_to_asteroid).\
					distance_to(to_local(asteroid.global_position))

			if asteroid.is_attached \
				and attached_asteroid \
					and laser_distance_to_asteroid < 50 \
						and building_distance_to_asteroid < laser_range:
				asteroid.health -= 50 * dt
				asteroid.global_position = to_global(
					Vector2(0, 
					-building_distance_to_asteroid)
				)
				laser_position = building_distance_to_asteroid
				update()
				if asteroid.health < 0:
					attached_asteroid = null
					asteroid.can_hit_planet.play_explosion('asteroid')
					asteroid.queue_free()
					laser_position = 0
					shooting = false
					planet.money += 50
					return

			if not attached_asteroid and laser_distance_to_asteroid < 30 \
				and building_distance_to_asteroid < laser_range:
				stop_laser_timer.stop()
				attached_asteroid = asteroid
				asteroid.is_attached = true


func _draw():
	if shooting:
		draw_line(Vector2(0, 0), Vector2(0, -laser_position), Color(1, 1, 1), 1)

func stop_laser():
	laser_position = 0
	shooting = false
	stop_laser_timer.stop()
	update()

remotesync func on_activate():
	if not shooting:
		stop_laser_timer.start(0.07)
		shooting = true
		laser_position = laser_range
		update()

func on_destroy():
	shooting = false
	laser_position = 0
	attached_asteroid = null
