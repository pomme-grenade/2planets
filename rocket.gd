extends Node2D

var target
var velocity
var rotation_speed = 0.7
var target_player_number
var planet 
var ready
var building
var rocket_amount

func _ready():
	velocity = Vector2(60, 0).rotated(rotation)

	ready = false

func _init(target_player_number):
	self.target_player_number = target_player_number
	var owning_player_number = 1 if target_player_number == 2 else 2
	add_to_group('rocket' + str(owning_player_number))

func _draw():
	draw_rect(Rect2(Vector2(0, 0), Vector2(4, 1)), Color(0, 50, 255))

func _process(delta):
	if not is_instance_valid(target):
		target = find_new_target()
	if is_instance_valid(target):
		var target_angle = position.direction_to(target.global_position)
		var angle_diff = velocity.angle_to(target_angle)
		var rotation_direction = sign(angle_diff)
		velocity = velocity.rotated(rotation_direction * rotation_speed * delta)

		var acceleration = clamp(1 - abs(angle_diff), 0.1, 0.6) * delta
		velocity = velocity * (1 + acceleration)

		if position.distance_to(target.global_position) < 10:
			queue_free()
			target.emit_signal('damage')
			return

	for planet in get_tree().get_nodes_in_group('planet'):
		if position.distance_to(planet.global_position) - planet.planetRadius < 1:
			planet.health -= 5
			if planet.health <= 0:
				get_tree().change_scene("res://RightWins.tscn")
			queue_free()
			return

	position += velocity * delta
	rotation = velocity.angle()

func is_closer(a, b):
	return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)

func find_new_target():
	var potential_targets = get_tree().get_nodes_in_group('building' + str(target_player_number))
	potential_targets.sort_custom(self, 'is_closer')
	if potential_targets.size() > 0:
		return potential_targets[0]
	else:
		if planet.playerNumber == 1:
			return get_node("/root/Node2D/planet1")
		else:
			return get_node("/root/Node2D/planet0")
