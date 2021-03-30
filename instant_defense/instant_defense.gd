extends Node2D

var planet

var fire_position : Vector2
var attack_range := 80
var fire_origin : Vector2
var cooldown := 0.0
var initial_cooldown_time := 1.0
var cooldown_time : float
var building_info : String
var circle_only_outline : Node2D
var outline_visible := false
var damage := 10.0
var electric_wave_scene : PackedScene = preload('res://instant_defense/electric_wave.tscn')
var wave_index := 0

func init():
	cooldown_time = initial_cooldown_time
	building_info = ''
	var children = get_parent().children
	var previous_child = children[len(children) - 2]
	children.erase(previous_child)
	previous_child.queue_free()

	circle_only_outline = preload('res://circle_only_outline.gd').new()
	
func _process(dt):
	if get_parent().is_destroyed or not get_parent().is_built:
		return
	if fire_position != Vector2.ZERO or not get_parent().is_built:
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
			fire_position = Vector2.ZERO
	
remotesync func shoot_rocket(path) -> void:
	var rocket = get_node(path)
	if rocket == null:
		Helper.log(['unknown rocket ', path])
		return
	fire_position = rocket.global_position
	fire_origin = to_global(Vector2(0, -8))
	cooldown = cooldown_time
	self_modulate.a = 0.8
	var new_health = rocket.health - damage
	rocket.health = new_health
	rocket.can_hit_planet.play_explosion('satellite_shot')

	if rocket.health <= 0:
		Helper.log(["satellite destroying rocket: ", rocket.name])
		rocket.is_destroyed = true
		planet.money += 5
	
	var all_waves = []
	shoot_chain_rockets(rocket, [rocket], all_waves)
	rocket.is_destroyed = true

	yield(get_tree().create_timer(0.5), 'timeout')
	for wave in all_waves:
		wave.queue_free()

	
func shoot_chain_rockets(initial_rocket : Sprite, already_connected_rockets : Array, all_waves : Array) -> void:
	var enemy_number = 1 if planet.player_number == 2 else 2
	var rockets = get_tree().get_nodes_in_group('rocket' + str(enemy_number))
	already_connected_rockets.append(initial_rocket)

	var closest_rocket : Sprite
	var closest_rocket_distance := 0.0
	for rocket in rockets:
		var distance_to_rocket := initial_rocket.position.distance_to(rocket.position)
		if (closest_rocket_distance == 0.0 or distance_to_rocket < closest_rocket_distance) and distance_to_rocket < 20.0:
			closest_rocket = rocket
			closest_rocket_distance = distance_to_rocket
		if not closest_rocket == null and not closest_rocket_distance == 0.0 and not closest_rocket in already_connected_rockets:
			var electric_wave := electric_wave_scene.instance()
			all_waves.append(electric_wave)
			var initial_wave_length = electric_wave.texture.get_size().x
			var angle_to_rocket = (closest_rocket.position - initial_rocket.position).angle()
			electric_wave.global_position = initial_rocket.global_position
			electric_wave.scale = Vector2(distance_to_rocket / initial_wave_length, 0.2)
			electric_wave.rotation = angle_to_rocket
			electric_wave.name = '%s_electric_wave%d' % [name, wave_index]
			get_tree().get_root().add_child(electric_wave)
			shoot_chain_rockets(closest_rocket, already_connected_rockets, all_waves)
			print("instant defense destroying rocket: ", closest_rocket.name)
			closest_rocket.is_destroyed = true
			wave_index += 1
			return

func update_income() -> void:
	cooldown_time = initial_cooldown_time
	cooldown_time -= (get_parent().get_connected_buildings().size() + 1) * 0.02
	if cooldown_time < 0:
		cooldown_time = 0

func buildup_animation_finished() -> void:
	update()

func on_destroy() -> void:
	update()

func on_highlight(is_highlighted) -> void:
	self.outline_visible = is_highlighted
	update()
