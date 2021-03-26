extends Control

onready var networking = get_node('lobby_networking')

func _ready():
	# warning-ignore:return_value_discarded
	$'network/create'.connect('pressed', self, '_on_server')
	# warning-ignore:return_value_discarded
	$'network/connect_container/connect'.connect('pressed', self, '_on_connect')
	# warning-ignore:return_value_discarded
	$'local'.connect('pressed', self, '_on_local')

	# warning-ignore:return_value_discarded
	networking.connect('exit_lobby', self, '_on_exit_lobby')

func _on_local():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(GameManager.SERVER_PORT, 2)
	get_tree().set_network_peer(peer)
	var world = load('res://Main.tscn').instance()
	get_node('/root').add_child(world)
	var selfPeerID = get_tree().get_network_unique_id()
	get_node('/root').set_network_master(selfPeerID)

	queue_free()

func _on_connect():
	$'network/create'.disabled = true
	$'network/connect_container/connect'.disabled = true

	networking.connect_to_server()

func _on_server():
	$'network/create'.disabled = true
	$'network/connect_container/connect'.disabled = true
	$'network/connect_container/ip_address'.editable = false

	networking.start_server()

# remove the lobby scene completely, unpause
func _on_exit_lobby():
	queue_free()
	get_tree().set_pause(false)
