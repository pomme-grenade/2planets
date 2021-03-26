extends Control

onready var networking = get_node('lobby_networking')
var waiting_for_network := false

func _ready():
	# warning-ignore:return_value_discarded
	$'network/create'.connect('pressed', self, '_on_server')
	# warning-ignore:return_value_discarded
	$'network/connect_container/connect'.connect('pressed', self, '_on_connect')
	# warning-ignore:return_value_discarded
	$'local'.connect('pressed', self, '_on_local')

	# warning-ignore:return_value_discarded
	networking.connect('exit_lobby', self, '_on_exit_lobby')

	reset_networking()

func _on_local():
	networking.server_for_local_game()

func _on_connect():
	if waiting_for_network:
		# player pressed 'cancel'
		reset_networking()
		return

	waiting_for_network = true
	$'network/create'.visible = false
	$'network/client_status'.visible = true
	$'network/client_status'.text = 'Connecting to server...'
	$'network/connect_container/connect'.text = 'cancel'

	networking.connect_to_server()

func _on_server():
	if waiting_for_network:
		# player pressed 'cancel'
		reset_networking()
		return

	waiting_for_network = true
	$'network/create'.text = 'Cancel'
	$'network/connect_container'.visible = false
	$'network/server_status'.visible = true
	$'network/server_status'.text = 'Server started.\nWaiting for other player...'

	networking.start_server()

func reset_networking():
	$'network/server_status'.visible = false
	$'network/client_status'.visible = false

	$'network/create'.visible = true
	$'network/create'.text = 'start server'
	$'network/connect_container'.visible = true
	$'network/connect_container/connect'.text = 'connect'

	waiting_for_network = false

# remove the lobby scene completely, unpause
func _on_exit_lobby():
	queue_free()
	get_tree().set_pause(false)
