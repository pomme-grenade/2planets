extends Control

var player
var cursor_index = 0

const index_to_types = {
	-1: 'defense',
	0: 'income',
	1: 'attack'
}

func _ready():
	pass

func _draw():
	# highlight
	var gap = 15
	var item_size = 10
	var cursor_size = 12
	var cursor_x = cursor_index * gap - cursor_size/2
	draw_rect(Rect2(Vector2(cursor_x, -20), Vector2(cursor_size, cursor_size)), Color(1, 1, 1))

	var textures = preload("building.gd").textures
	var i = -1
	for type in textures:
		draw_texture(textures[type], Vector2(gap * i - 3, -20))
		i += 1

func _input(event):
	var player_key = "player" + str(player.playerNumber) + "_"
	var direction = 0
	if event.is_action_pressed(player_key + "left"):
		direction = -1
	elif event.is_action_pressed(player_key + "right"):
		direction = 1

	if direction != 0:
		get_tree().set_input_as_handled()
		cursor_index = clamp(cursor_index + direction, -1, 1)
		update()

	if event.is_action_pressed(player_key + "up"):
		spawn_building()
		get_tree().set_input_as_handled()
		queue_free()

func spawn_building():
	var building = preload("res://building.gd").new()
	building.planet = player.planet
	building.position = player.position
	building.type = index_to_types[cursor_index]
	player.planet.add_child(building)
	building.init()
