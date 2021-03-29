extends Node2D

var planet

var fire_position
var attack_range = 80
var fire_origin
var cooldown = 0
var initial_cooldown_time := 1.0
var cooldown_time
var building_info
var circle_only_outline
var outline_visible := false
var damage = 10
var pulse_index = 0

func init():
	cooldown_time = initial_cooldown_time
	building_info = ''
	var children = get_parent().children
	var previous_child = children[len(children) - 2]
	children.erase(previous_child)
	previous_child.queue_free()
	
func _process(dt):
	if get_parent().is_destroyed or not get_parent().is_built:
		return
	if fire_position != null or not get_parent().is_built:
		update()

	var enemy_number = 1 if planet.player_number == 2 else 2
	var enemy_group = 'rocket' + str(enemy_number)
	var rockets = get_tree().get_nodes_in_group(enemy_group)
	var nearest_target = get_node('/root/main/planet_%s' % enemy_number)
	for rocket in rockets:
		if rocket.is_destroyed:
			continue

		var distance_rocket = global_position.distance_to(rocket.global_position)
		var distance_current_target = global_position.distance_to(nearest_target.global_position)
		if distance_rocket < distance_current_target:
			nearest_target = rocket

	var parent = get_parent()
	var target_quat = Quat(
		Vector3.BACK, 
		global_position.angle_to_point(nearest_target.global_position) - PI/2
	)
	var current_quat = Quat(Vector3.BACK, parent.global_rotation)
	parent.global_rotation = \
		current_quat.slerp(target_quat, 5 * dt).get_euler().z
	cooldown -= dt
	z_index = -1
	get_node("/root/main/background").z_index = -2

	if cooldown > 0:
		return
	else:
		self_modulate.a = 1

	if (nearest_target != null and
			global_position.distance_to(nearest_target.global_position)
				< attack_range):
		shoot_pulse()
	
func shoot_pulse():
	var instant_defense_pulse = preload('res://instant_defense/pulse.tscn').instance()
	instant_defense_pulse.name = '%s_pulse_%d' % [name, pulse_index]
	pulse_index += 1
	cooldown = initial_cooldown_time
	instant_defense_pulse.planet = planet
	add_child(instant_defense_pulse)

func update_income():
	cooldown_time = initial_cooldown_time
	cooldown_time -= (get_parent().get_connected_buildings().size() + 1) * 0.02
	if cooldown_time < 0:
		cooldown_time = 0
		
func _draw():
	pass

func buildup_animation_finished():
	update()

func on_destroy():
	update()

func on_highlight(is_highlighted):
	self.outline_visible = is_highlighted
	update()
