extends Node2D

var target
var velocity
var rotation_speed = 0.75
var target_player_number
var planet
var ready
var building
var planet_rocket_damage

func _ready():
	velocity = Vector2(40, 0).rotated(rotation)
	planet_rocket_damage = 5

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
		target = find_new_target(get_tree().get_nodes_in_group('building' + str(target_player_number)))
	elif target.is_targeted and target.targeted_by != self:
		target = find_new_target(get_tree().get_nodes_in_group('building' + str(target_player_number)))
	if is_instance_valid(target) and (target.is_targeted == false or target.targeted_by == self):
		# target.is_targeted = true

		var target_angle = position.direction_to(target.global_position)
		var angle_diff = velocity.angle_to(target_angle)
		var rotation_direction = sign(angle_diff)
		velocity = velocity.rotated(rotation_direction * rotation_speed * delta)

		var acceleration = clamp(1 - abs(angle_diff), 0.25, 0.6) * delta
		velocity = velocity * (1 + acceleration)

		if position.distance_to(target.global_position) < 10:
			target.is_targeted = false
			target.targeted_by = target
			queue_free()
			target.emit_signal('damage')
			return

	for planet in get_tree().get_nodes_in_group('planet'):
		if position.distance_to(planet.global_position) - planet.planetRadius < 1:
			planet.health -= planet_rocket_damage
			if planet.health <= 0:
				sceneSwitcher.change_scene('res://gameOver.tscn', {"loser": target_player_number})
			target.is_targeted = false
			target.targeted_by = target
			queue_free()
			return

	position += velocity * delta
	rotation = velocity.angle()
	update()

func is_closer(a, b):
	return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)

func find_new_target(potential_targets):
	# potential_targets.sort_custom(self, 'is_closer')
	# for target in potential_targets:
	# 	if not target.is_targeted:
	# 		# potential_targets[0].is_targeted = true
	# 		target.is_targeted = true
	# 		target.targeted_by = self
	# 		return target
	# elif potential_targets.size() > 0 and potential_targets[0].is_targeted:
	# 	potential_targets.erase(potential_targets[0])
		# potential_targets.sort_custom(self, 'is_closer')
		# potential_targets[0].is_targeted = true
		# potential_targets[0].targeted_by = self
		# return potential_targets[0]
	if planet.playerNumber == 1:
		return get_node("/root/Node2D/planet1")
	else:
		return get_node("/root/Node2D/planet0")
