extends Control

var player
var cursor_index = 0

func _ready():
	pass

func _draw():
	# highlight
	var gap = 15
	var item_size = 10
	var cursor_size = 12
	var cursor_x = cursor_index * (gap + item_size/2) - cursor_size/2
	draw_rect(Rect2(Vector2(cursor_x, -5), Vector2(cursor_size, cursor_size)), Color(1, 1, 1))

	# defense
	draw_circle(Vector2(-gap-item_size/2, 0), item_size/2, Color(0, 0.4, 1))
	# income
	draw_polygon([Vector2(-item_size/2, -item_size/2), Vector2(item_size/2, -item_size/2), Vector2(0, item_size/2)], [Color(200, 0, 0)])
	# attack
	draw_polygon([Vector2(gap, item_size/2), Vector2(gap + item_size, item_size/2), Vector2(gap + item_size/2, -item_size/2)], [Color(200, 0, 0)])

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
	pass
