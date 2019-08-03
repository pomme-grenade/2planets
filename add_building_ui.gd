extends Control

var player
var player_planet
var cursor_index = 0
var planet
var cost = {
	defense_cost = 4,
	income_cost = 4,
	attack_cost = 4,
}
var house_bonus_income_lvl1 = 0.5
var current_cost

const index_to_types = {
	-1: 'defense',
	0: 'income',
	1: 'attack'
}

func _draw():
	# highlight
	var gap = 15
	var item_size = 10
	var cursor_size = 12
	var cursor_x = cursor_index * gap - cursor_size/2
	draw_rect(Rect2(Vector2(cursor_x, -22), Vector2(cursor_size, cursor_size)), Color("#a3883e"))

	var textures = preload("building.gd").textures
	for index in index_to_types:
		draw_texture(textures[index_to_types[index]], Vector2(gap * index - 3, -20))

func _input(event):
	var player_key = "player" + str(player.playerNumber) + "_"

	if event.is_action_pressed(player_key + 'down'):
		queue_free()
		return

	if event.is_action(player_key + 'left') or event.is_action(player_key + 'right') or event.is_action(player_key + 'up'):
		get_tree().set_input_as_handled()

	var direction = 0
	if event.is_action_pressed(player_key + "left"):
		direction = -1
	elif event.is_action_pressed(player_key + "right"):
		direction = 1

	if direction != 0:
		cursor_index = clamp(cursor_index + direction, -1, 1)
		update()
 
	current_cost = index_to_types[cursor_index] + "_" + "cost"

	if event.is_action_pressed(player_key + "up"):
		get_tree().set_input_as_handled()
		if (planet.money >= cost[current_cost]):
			spawn_building()
			queue_free()


func spawn_building():
	var type = index_to_types[cursor_index]
	if type == 'defense':
		var satellite = preload("res://satellite.gd").new()
		satellite.position = player.position * 1.5
		satellite.player_number = player.playerNumber
		satellite.rotation = player.rotation
		player.planet.add_child(satellite)
	else:
		var building = preload("res://building.gd").new()
		building.planet = player.planet
		building.position = player.position
		building.type = type
		player.planet.add_child(building)
		building.init()

	planet.money -=  cost[current_cost]

	if (index_to_types[cursor_index] == "income"):
		planet.income += house_bonus_income_lvl1

# func _process(delta):
# 	rect_rotation =  
