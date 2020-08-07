extends Node

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

# Call this instead to be able to provide arguments to the next scene
# func change_scene(next_scene, params=null):
# 	_params = params

# 	var peer = get_tree().network_peer
# 	# get_tree().set_network_peer(peer)

# 	get_tree().change_scene(next_scene)
# 	var selfPeerID = get_tree().get_network_unique_id()
# 	get_node('/root').set_network_master(selfPeerID)
	
# # In the newly opened scene, you can get the parameters by name
# func get_param(name):
# 	if _params != null and _params.has(name):
# 		return _params[name]
# 	return null
