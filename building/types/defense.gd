extends Node2D

signal income(value)
signal change_type(script_path)

var planet

var fire_position
var attack_range = 80
var fire_origin
var cooldown = 0
var cooldown_time = 0.5

func init():
	pass

func _process(dt):
	if fire_position != null:
		update()

	var enemy_number = 1 if planet.playerNumber == 2 else 2
	var enemy_group = 'rocket' + str(enemy_number)
	var rockets = get_tree().get_nodes_in_group(enemy_group)
	var nearest_target = get_node('/root/main/planet_%s' % enemy_number)
	for rocket in rockets:
		if global_position.distance_to(rocket.global_position) < global_position.distance_to(nearest_target.global_position):
			nearest_target = rocket

	var parent = get_parent()
	var target_quat = Quat(Vector3.BACK, global_position.angle_to_point(nearest_target.global_position) - PI/2)
	var current_quat = Quat(Vector3.BACK, parent.global_rotation)
	parent.global_rotation = current_quat.slerp(target_quat, 5 * dt).get_euler().z
	cooldown -= dt
	z_index = -1
	get_node("/root/main/Background").z_index = -2

	if cooldown > 0:
		return
	else:
		self_modulate.a = 1

	if (is_network_master() and
			nearest_target != null and
			global_position.distance_to(nearest_target.global_position) < attack_range):
		rpc('destroy_rocket', nearest_target.get_path())

func _draw():
	draw_circle(Vector2(0, 0), attack_range/get_parent().global_scale.x, Color(0.1, 0.2, 0.7, 0.1))

	if fire_position != null:
		var alpha = cooldown * (1 / cooldown_time)
		if alpha > 0:
			draw_line(to_local(fire_origin), to_local(fire_position), Color(0.9, 0.9, 2, alpha), 1.1, true)
		else:
			fire_position = null

remotesync func destroy_rocket(path):
	var rocket = get_node(path)
	if rocket == null:
		print('unknown rocket ', path)
		return
	fire_position = rocket.global_position
	fire_origin = to_global(Vector2(0, -8))
	cooldown = cooldown_time
	self_modulate.a = 0.8
	emit_signal('income', 5)

	rocket.queue_free()
	planet.money += 5

func upgrade():
	emit_signal('change_type', 'res://building/types/shield.gd')
