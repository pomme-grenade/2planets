extends Node2D

var planet

var fire_position
var attack_range = 0
var fire_origin
var cooldown = 0
var cooldown_time = 0.5
var upgrade_1_script = 'res://building/types/shield.gd'

func init():
	add_user_signal('income', [{'name': 'value', 'type': TYPE_INT}])
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
	draw_empty_circle(Vector2(0, 0), Vector2(0, attack_range / get_parent().global_scale.x), Color(0.4, 0.2, 0.7, 0.4), 0.5)

	if fire_position != null:
		var alpha = cooldown * (1 / cooldown_time)
		if alpha > 0:
			draw_line(to_local(fire_origin), to_local(fire_position), Color(0.9, 0.9, 2, alpha), 1.1, true)
		else:
			fire_position = null

func draw_empty_circle(circle_center, circle_radius, color, resolution):
	var draw_counter = 1
	var line_origin = Vector2()
	var line_end = Vector2()
	line_origin = circle_radius + circle_center

	while draw_counter <= 360:
		line_end = circle_radius.rotated(deg2rad(draw_counter)) + circle_center
		draw_line(line_origin, line_end, color)
		draw_counter += 1 / resolution
		line_origin = line_end

	line_end = circle_radius.rotated(deg2rad(360)) + circle_center
	draw_line(line_origin, line_end, color)

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

func on_upgrade():
	pass

func buildup_finish():
	attack_range = 80	
	update()

func on_destroy():
	pass
