extends Node

const SERVER_PORT = 10200
var upnp
# Private variable
var _params = null

func restart_game():
	get_node('/root/main').free()
	var main = preload('res://Main.tscn').instance()
	get_tree().get_root().add_child(main)
	get_tree().paused = false

func game_over(loser):
	var game_over_screen = preload('res://menu/gameOver.tscn').instance()
	game_over_screen.loser = loser
	get_tree().paused = true
	get_tree().get_root().add_child(game_over_screen)

func traverse_nat(hole_puncher, is_host, player_name):
	hole_puncher.start_traversal("test", is_host, player_name)
	var result = yield(hole_puncher, 'hole_punched')
	yield(get_tree().create_timer(0.1), 'timeout')
	return result

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		# var deleted = upnp.delete_port_mapping(SERVER_PORT)
		get_tree().quit() # default behavior
