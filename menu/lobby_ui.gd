extends Control

onready var networking = get_node('lobby_networking')
var waiting_for_network := false
var current_status_label = null

func _ready():
	# warning-ignore:return_value_discarded
	$'network/create'.connect('pressed', self, '_on_server')
	# warning-ignore:return_value_discarded
	$'network/connect_container/connect'.connect('pressed', self, '_on_connect')
	# warning-ignore:return_value_discarded
	$'local'.connect('pressed', self, '_on_local')
	$'network/connect_container/game_code_input'.connect('text_entered', self, '_on_connect')

	# warning-ignore:return_value_discarded
	networking.connect('exit_lobby', self, '_on_exit_lobby')
	networking.connect('update_status', self, '_update_status')

	reset_networking()

	$'network/connect_container/game_code_input'.grab_focus()

func _on_local():
	if waiting_for_network:
		# player started a network game before
		reset_networking()
		
	networking.server_for_local_game()

func _on_connect(_maybe_game_code = null):
	if waiting_for_network:
		# player pressed 'cancel'
		reset_networking()
		return

	waiting_for_network = true
	$'network/create'.visible = false
	$'network/limiter'.visible = false
	$'network/client_status'.visible = true
	$'network/client_status'.text = 'Connecting to server...'
	current_status_label = $'network/client_status'
	$'network/connect_container/connect'.text = 'cancel'

	var game_code = $'network/connect_container/game_code_input' \
		.text \
		.to_upper()
	networking.connect_to_server(game_code)

func _on_server():
	if waiting_for_network:
		# player pressed 'cancel'
		reset_networking()
		return

	waiting_for_network = true
	$'network/create'.text = 'Cancel'
	$'network/limiter'.visible = false
	$'network/connect_container'.visible = false
	$'network/server_status'.visible = true
	$'network/server_status'.text = 'Connecting to registry...'
	current_status_label = $'network/server_status'

	networking.start_server()


func reset_networking():
	networking.reset()

	$'network/server_status'.visible = false
	$'network/client_status'.visible = false

	$'network/create'.visible = true
	$'network/create'.text = 'create game'
	$'network/connect_container'.visible = true
	$'network/connect_container/connect'.text = 'join game'
	$'network/limiter'.visible = true
	current_status_label = null

	waiting_for_network = false

# remove the lobby scene completely and unpause
func _on_exit_lobby():
	get_parent().queue_free()
	get_tree().set_pause(false)
	get_node('/root/MusicPlayer').set_lowpass_active(false)

func _update_status(text):
	if is_instance_valid(current_status_label):
		current_status_label.text = text
	else:
		Helper.log('cannot set lobby ui status')
