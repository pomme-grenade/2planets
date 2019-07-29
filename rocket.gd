extends Node2D

var target
var velocity
var rotation_speed = 0.7
var target_player_number

func _ready():
	target = $'../building'
	velocity = Vector2(60, 0).rotated(rotation)

func _init(target_player_number):
	self.target_player_number = target_player_number
	var owning_player_number = 1 if target_player_number == 2 else 2
	add_to_group('rocket' + str(owning_player_number))

func _draw():
	draw_rect(Rect2(Vector2(0, 0), Vector2(4, 1)), Color(0, 50, 255))

func _process(delta):
	if not is_instance_valid(target):
		var potential_targets = get_tree().get_nodes_in_group('building' + str(target_player_number))
		if potential_targets.size() > 0:
			target = potential_targets[0]

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
			queue_free()
			return

	position += velocity * delta
	rotation = velocity.angle()

