extends Node2D

var building
var explosion_timer
var initial_time_until_explosion = 0.5
var is_exploding = false
var planet
var attack_range = 50
var electric_wave
var wave_index = 0

func _ready():
	building = get_parent().get_parent()
	explosion_timer = Timer.new()
	explosion_timer.connect('timeout', self, 'explode')
	explosion_timer.one_shot = true
	add_child(explosion_timer)
	explosion_timer.start(initial_time_until_explosion)

func _process(dt):
	if not is_exploding:
		position.y -= 100 * dt
	elif is_exploding:
		var enemy_number = 1 if planet.playerNumber == 2 else 2
		var rockets = get_tree().get_nodes_in_group('rocket' + str(enemy_number))
		for rocket in rockets:
			if global_position.distance_to(rocket.global_position) < attack_range:
				electric_wave = preload('res://electric_wave.tscn').instance()
				var distance_to_rocket = Vector2(0, 0).distance_to(to_local(rocket.global_position))
				var initial_wave_length = electric_wave.texture.get_size().x
				var angle_to_rocket = Vector2(0, 0).direction_to(to_local(rocket.global_position)).angle()
				electric_wave.position = Vector2(0,0)
				electric_wave.scale = Vector2(distance_to_rocket / initial_wave_length, 0.2)
				electric_wave.rotation = angle_to_rocket 
				electric_wave.position += Vector2(0, ((distance_to_rocket / initial_wave_length) * initial_wave_length) / 2).rotated(angle_to_rocket - PI / 2)
				electric_wave.name = '%s_electric_wave%d' % [name, wave_index]
				wave_index += 1
				add_child(electric_wave)
				rocket.queue_free()

func _draw():
	if is_exploding:
		draw_circle(Vector2(0, 0), attack_range, Color(0.7, 0.7, 1, 0.05))

func explode():
	if not is_exploding:
		is_exploding = true
		explosion_timer.start(0.3)
	else:
		queue_free()

	update()
