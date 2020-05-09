extends Control

var player
var action_pressed_timer
var building_to_destroy
var building_to_build
var timer_wait_time = 0.7
var building_index = 0

const building_types = [
	'attack',
	'defense',
	'income',
]

func _ready():
	set_process_unhandled_input(true)
	action_pressed_timer = Timer.new()
	action_pressed_timer.one_shot = true
	action_pressed_timer.connect('timeout', self, 'action_timer_timeout')
	add_child(action_pressed_timer)

# func _draw():
	# var gap = 20
	# var textures = preload('res://building/building.gd').textures
	# var delete = preload('res://planet_ui/delete_icon.png')
	# var empty_button = preload('res://planet_ui/empty_button.png')

	# var timer_progress = (timer_wait_time - action_pressed_timer.time_left) / timer_wait_time

	# if is_instance_valid(player.current_building) and building_to_build == null:
	# 	draw_texture(empty_button, Vector2(-5, 0))
	# 	if is_instance_valid(building_to_destroy):
	# 		# make the delete icon smaller
	# 		draw_set_transform(Vector2(1.8, 0.5), 0, Vector2(0.9, 0.9))
	# 	draw_texture(delete, Vector2(gap - 3, 0))
	# 	if is_instance_valid(building_to_destroy):
	# 		draw_rect(Rect2(Vector2(gap - 3, 10), Vector2(10, - 10 * timer_progress)), Color(0.8, 0, 0, 0.6))
	# 		draw_set_transform(Vector2(0, 0), 0, Vector2(1, 1))
	# 	draw_texture(empty_button, Vector2(2*gap - 3, 0))
	# else:
	# 	var types = ['defense', 'income', 'attack']
	# 	# rotate all icons by 90 degrees
	# 	for index in range(len(types)):
	# 		var scale = 0.9 if building_to_build == types[index] else 1.0
	# 		draw_set_transform(Vector2(0, 0), PI/2, Vector2(scale, scale))
	# 		var y_pos = (- gap * index - 5) - (1 - scale) * gap
	# 		draw_texture(textures[types[index]], Vector2(0, y_pos))
	# 		if building_to_build == types[index]:
	# 			draw_set_transform(Vector2(0, 0), 0, Vector2(scale, scale))
	# 			draw_rect(Rect2(Vector2(- y_pos - 9, 10), Vector2(10, - 10 * timer_progress)), Color(0, 0.6, 0.3, 0.6))

func _process(_dt):
	if (is_instance_valid(building_to_destroy)
		or building_to_build != null):
		update()

func _unhandled_input(event):
	if is_network_master():
		for type in building_types:
			if (event.is_action_pressed(player.player_key + "build_" + type)
				  and not is_instance_valid(player.current_building)):
				start_build_timer(type)
				return
			if (event.is_action_released(player.player_key + 'build_' + type)):
				action_pressed_timer.stop()
				building_to_destroy = null
				building_to_build = null
				update()

		if (is_instance_valid(player.current_building) and
		  event.is_action_pressed(player.player_key + 'build_income')
		  and not player.current_building.is_destroyed):
			start_destroy_timer(player.current_building)

func start_build_timer(type):
	building_to_build = type
	action_pressed_timer.start(timer_wait_time)
	update()

func start_destroy_timer(building):
	building_to_destroy = building
	action_pressed_timer.start(timer_wait_time)
	update()

func action_timer_timeout():
	if (is_instance_valid(building_to_destroy) and
		  player.current_building == building_to_destroy and
		  Input.is_action_pressed(player.player_key + 'build_income')):
		building_to_destroy.rpc('destroy', player.building_cost[building_to_destroy.type])
	elif (building_to_build != null and
		  Input.is_action_pressed(player.player_key + 'build_' + building_to_build)
		  and not is_instance_valid(player.current_building)):
		var name = '%d_building_%d' % [player.playerNumber, building_index]
		building_index += 1
		var position = player.planet.current_slot_position()
		player.try_spawn_building(building_to_build, name, position)

	building_to_destroy = null
	building_to_build = null
	update()

