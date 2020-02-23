extends Node2D

var target
var velocity
var rotation_speed = 0.75
var target_player_number
var planet
var ready
#warning-ignore:unused_class_variable
var building
var planet_rocket_damage = 5

func _ready():
	velocity = Vector2(40, 0).rotated(rotation)

	ready = false

func _init(target_player_number):
	self.target_player_number = target_player_number
	var owning_player_number = 1 if target_player_number == 2 else 2
	add_to_group('rocket' + str(owning_player_number))

func _draw():
	var length = 3 + velocity.length() / 50
	draw_rect(Rect2(Vector2(0, 0), Vector2(length, 1)), Color(0, 0.5, 2))

func _process(delta):
	if not is_instance_valid(target):
		target = find_new_target()
	if is_instance_valid(target):

		var target_angle = position.direction_to(target.global_position)
		var angle_diff = velocity.angle_to(target_angle)
		var rotation_direction = sign(angle_diff)
		velocity = velocity.rotated(rotation_direction * rotation_speed * delta)

		var acceleration = clamp(1 - abs(angle_diff), 0.25, 0.6) * delta
		velocity = velocity * (1 + acceleration)

		if position.distance_to(target.global_position) < 10:
			queue_free()
			return

	if is_network_master():
		for planet in get_tree().get_nodes_in_group('planet'):
			if position.distance_to(planet.global_position) - planet.planetRadius < 1:
				rpc('hit_planet', planet.get_path())
				return

	position += velocity * delta
	rotation = velocity.angle()
	update()

remotesync func hit_planet(path):
	var planet = get_node(path)
	planet.health -= planet_rocket_damage
	queue_free()
	if planet.health <= 0:
		sceneSwitcher.change_scene('res://gameOver.tscn', {"loser": target_player_number})

func is_closer(a, b):
	return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)

func find_new_target():
	if planet.playerNumber == 1:
		return get_node("/root/main/planet1")
	else:
		return get_node("/root/main/planet0")
