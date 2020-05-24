extends AnimatedSprite

var planet
var type
var is_destroyed = false

var attack_range = 80

func _init():
	pass

func _process(_dt):
	var enemy_number = 1 if planet.playerNumber == 2 else 2
	var enemy_group = 'rocket' + str(enemy_number)
	var rockets = get_tree().get_nodes_in_group(enemy_group)
	for rocket in rockets:
		if global_position.distance_to(rocket.global_position) < attack_range:
			rocket.queue_free()

