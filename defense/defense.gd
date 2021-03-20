extends Node2D

var planet

var fire_position
var attack_range = 80
var fire_origin
var cooldown = 0
var cooldown_time := 0.5
var upgrade_1_type := 'shield'
var upgrade_2_type := 'instant_defense'
var building_info
var circle_only_outline
var outline_visible := false
var damage = 10

func init():
	building_info = ''
	get_parent().position *= 1.5
	add_user_signal('income', [{'name': 'value', 'type': TYPE_INT}])
	circle_only_outline = preload('res://circle_only_outline.gd').new()
	cooldown_time -= (get_parent().get_connected_buildings().size() + 1) * 0.02

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
		if global_position.distance_to(rocket.global_position) \
				< global_position.distance_to(nearest_target.global_position):
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

	if (is_network_master() and
			nearest_target != null and
			global_position.distance_to(nearest_target.global_position) \
				< attack_range and
			(not nearest_target.is_destroyed)):
		rpc('shoot_rocket', nearest_target.get_path())

func _draw():
	if not get_parent().is_built or get_parent().is_destroyed:
		return

	if self.outline_visible:
		circle_only_outline.draw_circle_only_outline(
			Vector2(0, 0), 
			Vector2(0, attack_range / get_parent().global_scale.x), 
			Color(0.4, 0.2, 0.7, 0.4), 
			0.5, self)

	if fire_position != null:
		var alpha = cooldown * (1 / cooldown_time)
		if alpha > 0:
			draw_line(
				to_local(fire_origin), 
				to_local(fire_position), 
				Color(0.9, 0.9, 2, alpha), 
				1.1, 
				true)
		else:
			fire_position = null

remotesync func shoot_rocket(path):
	var rocket = get_node(path)
	if rocket == null:
		Helper.log(['unknown rocket ', path])
		return
	fire_position = rocket.global_position
	fire_origin = to_global(Vector2(0, -8))
	cooldown = cooldown_time
	self_modulate.a = 0.8
	var new_health = rocket.health - damage
	rocket.rset('health', new_health)
	rocket.can_hit_planet.play_explosion('satellite_shot')

	if rocket.health < 0:
		print("satellite destroying rocket: ", rocket.name)
		rocket.queue_free()
		planet.money += 5

func update_connection_bonus():
	cooldown_time = 0.5;
	cooldown_time -= (get_parent().get_connected_buildings().size() + 1) * 0.02
	if cooldown_time < 0:
		cooldown_time = 0
	print(cooldown_time)

func buildup_animation_finished():
	update()

func on_destroy():
	update()

func on_highlight(is_highlighted):
	self.outline_visible = is_highlighted
	update()
