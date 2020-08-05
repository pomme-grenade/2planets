extends Node2D

var target
var velocity
var rotation_speed = 0.75
var target_player_number
var from_planet
#warning-ignore:unused_class_variable
var building
var planet_rocket_damage = 5
var is_destroyed = false
var explosion_radius = 20
var split_distance
var child_counter = 0
var color = Color(1, 0.3, 0.3)
var length = 6
var is_split_rocket = false

func _ready():
	velocity = Vector2(40, 0).rotated(rotation)

func init(_target_player_number):
	target_player_number = _target_player_number
	var owning_player_number = 1 if target_player_number == 2 else 2
	add_to_group('rocket' + str(owning_player_number))

	if split_distance != null:
		self.texture = preload('res://images/buildings/split_missile.png')

# calculates point on planet surfaces from rocket angle
func point_on_planet():
	 return (target.planetRadius - 10) * target.global_position.direction_to(global_position) + target.global_position

func _draw():
		# draw_circle(Vector2(0, 0), 50, Color(1, 1, 1))
		# draw_circle(to_local(point_on_planet()), explosion_radius, Color(1, 1, 1))
		pass

func _process(delta):
	if is_destroyed: 
		play_explosion(point_on_planet(), 'rocket_on_planet')

	if is_destroyed:
		queue_free()
		return

	if not is_instance_valid(target):
		target = find_new_target()

	if is_instance_valid(target):
		var target_angle = position.direction_to(target.global_position)
		var angle_diff = velocity.angle_to(target_angle)
		var rotation_direction = sign(angle_diff)
		velocity = velocity.rotated(rotation_direction * rotation_speed * delta)

		var acceleration = clamp(1 - abs(angle_diff), 0.25, 0.6) * delta
		velocity = velocity * (1 + acceleration)

		if target.is_network_master():
			var distance_to_target = global_position.distance_to(target.global_position) - target.planetRadius
			if distance_to_target < 1:
				rpc('hit_planet', target.get_path())
				return
			elif split_distance != null and distance_to_target < split_distance:
				rpc('split')
			elif position.length_squared() > 4000000:
				queue_free()

	position += velocity * delta
	rotation = velocity.angle()
	update()

remotesync func split():
	var count = 5
	var spread = PI/8
	for i in range(count):
		child_counter += 1
		var rocket = load('res://rocket.tscn').instance()
		rocket.name = name + '_' + str(child_counter)
		rocket.rotation = rotation - spread * floor(count/2) + i * spread
		rocket.position = position + velocity.rotated(rocket.rotation - rotation) * 0.2
		rocket.from_planet = from_planet
		rocket.target_player_number = target_player_number
		rocket.building = building
		rocket.set_network_master(get_network_master())
		rocket.planet_rocket_damage = 1
		rocket.color = color
		rocket.length = 2
		rocket.explosion_radius = 8
		rocket.texture = preload('res://images/buildings/split_missile.png')
		rocket.init(target_player_number)
		rocket.is_split_rocket = true
		$'/root/main'.add_child(rocket)
		rocket.velocity = velocity.rotated(rocket.rotation - rotation) * 0.8
		queue_free()

remotesync func hit_planet(path):
	is_destroyed = true
	var hit_building = false
	self.update()
	var planet = get_node(path)
	for building in get_tree().get_nodes_in_group("building" + str(target_player_number)):
		if point_on_planet().distance_to(building.global_position) < explosion_radius and not building.is_destroyed:
			if not building.is_destroyed:
				building.destroy()
				hit_building = true
	if not hit_building:
		planet.health -= planet_rocket_damage

	if planet.health <= 0:
		GameManager.game_over(target_player_number)

func is_closer(a, b):
	return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)

func find_new_target():
	if from_planet.playerNumber == 1:
		return get_node("/root/main/planet_2")
	else:
		return get_node("/root/main/planet_1")

func play_explosion(explosion_position, explosion_animation):
		var explosion = load('res://explosion.tscn').instance()
		explosion.position = explosion_position
		explosion.play(explosion_animation)
		$'/root/main'.add_child(explosion)

		if is_split_rocket:
			explosion.scale = Vector2(0.5, 0.5)
