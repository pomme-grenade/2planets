extends Control

var player
var destroy_pressed_timer
var building_to_destroy
var time_to_destroy = 0.7

const building_types = [
	'attack',
	'defense',
	'income',
]

func _ready():
	set_process_unhandled_input(true)

func _draw():
	var gap = 15
	var textures = preload('res://building/building.gd').textures
	var delete = preload('res://planet_ui/delete_icon.png')

	if is_instance_valid(player.current_building):
		draw_rect(Rect2(Vector2(-3, 0), Vector2(10, 10)), Color(1, 1, 1))
		if is_instance_valid(building_to_destroy):
			# make the delete icon smaller
			draw_set_transform(Vector2(1.8, 0.5), 0, Vector2(0.9, 0.9))
		draw_texture(delete, Vector2(gap - 3, 0))
		if is_instance_valid(building_to_destroy):
			var destroy_progress = destroy_pressed_timer.time_left / time_to_destroy
			draw_rect(Rect2(Vector2(gap - 3, 10), Vector2(10, - 10 + 10 * destroy_progress)), Color(0.8, 0, 0, 0.6))
			draw_set_transform(Vector2(0, 0), 0, Vector2(1, 1))
		# draw_rect(Rect2(Vector2(gap - 3, 0), Vector2(10, 10)), Color(0, 0, 0))
		draw_rect(Rect2(Vector2(2 * gap - 3, 0), Vector2(10, 10)), Color(1, 1, 1))
	else:
		var types = ['defense', 'income', 'attack']
		# rotate all icons by 90 degrees
		draw_set_transform(Vector2(0, 0), PI/2, Vector2(1, 1))
		for index in range(len(types)):
			draw_texture(textures[types[index]], Vector2(0, -gap * index - 5))

func _process(dt):
	if is_instance_valid(building_to_destroy):
		update()

func _unhandled_input(event):
	for type in building_types:
		if (event.is_action_pressed(player.player_key + "build_" + type)
			and not is_instance_valid(player.current_building)):
			player.spawn_building(type)
			return

	if (is_instance_valid(player.current_building) and
	  event.is_action_pressed(player.player_key + 'build_income')
	  and not player.current_building.is_destroyed):
	    start_destroy_timer(player.current_building)
	elif (event.is_action_released(player.player_key + 'build_income') and
		  is_instance_valid(building_to_destroy)):
		destroy_pressed_timer.stop()
		building_to_destroy = null
		update()

func start_destroy_timer(building):
	building_to_destroy = building
	destroy_pressed_timer = Timer.new()
	destroy_pressed_timer.one_shot = true
	destroy_pressed_timer.connect('timeout', self, 'destroy_timer_timeout')
	destroy_pressed_timer.start(time_to_destroy)
	add_child(destroy_pressed_timer)
	update()

func destroy_timer_timeout():
	if (player.current_building == building_to_destroy and
	  Input.is_action_pressed(player.player_key + 'build_income')):
		player.destroy_building(building_to_destroy)
		building_to_destroy = null
	update()

