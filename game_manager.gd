extends Node

const SERVER_PORT = 10200

func restart_game() -> void:
	get_node('/root/main').free()
	var main = preload('res://Main.tscn').instance()
	get_tree().get_root().add_child(main)
	get_tree().paused = false

func game_over(loser, loser_network_id) -> void:
	var game_over_screen = preload('res://menu/game_over.tscn').instance()
	game_over_screen.loser = loser
	game_over_screen.loser_network_id = loser_network_id
	get_tree().paused = true
	get_tree().get_root().add_child(game_over_screen)

func traverse_nat(hole_puncher, is_host, player_name):
	hole_puncher.start_traversal("test", is_host, player_name)
	var result = yield(hole_puncher, 'hole_punched')
	yield(get_tree().create_timer(0.1), 'timeout')
	return result

func _notification(what) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit() # default behavior
	
func _unhandled_input(event: InputEvent):
	if has_node('/root/main') and event.is_action_pressed('pause'):
		var player1: AnimatedSprite = get_node('/root/main/planet_1').player
		var player2: AnimatedSprite = get_node('/root/main/planet_2').player

		player1.paused_input = true
		player2.paused_input = true
		var pause_menu = preload('res://menu/pause_menu.tscn').instance()
		get_node('/root').add_child(pause_menu)
		get_node('/root').get_tree().set_input_as_handled()

		# wait until pause is over
		yield(pause_menu, 'unpause')
		player1.paused_input = false
		player2.paused_input = false
