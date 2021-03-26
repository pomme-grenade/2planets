extends Node

var other_player_id
var players_done = []

func _ready():	
	# warning-ignore:return_value_discarded
	get_tree().connect('network_peer_connected', self, '_player_connected')

func connect_to_server():
	Helper.log('traversing nat...')
	var result = yield(GameManager.traverse_nat($HolePunch, false, 'planet_2'), 'completed')
	Helper.log('nat traversed!')
	var host_address = result[2]
	var host_port = result[1]
	var own_port = result[0]
	Helper.log(['own port ', own_port])
	Helper.log(['host: ', host_address, ':', host_port])

	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host_address, host_port, 0, 0, own_port)
	get_tree().set_network_peer(peer)

func start_server():
	Helper.log('traversing nat...')
	var result =  \
		yield(GameManager.traverse_nat($HolePunch, true, 'planet_1'), 'completed')
	Helper.log('nat traversed!')
	var my_port = result[0]
	Helper.log(['my port ', my_port])

	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(my_port, 1)
	if (err != OK):
		Helper.log(err)
	get_tree().set_network_peer(peer)

func _player_connected(id):
	get_tree().refuse_new_network_connections = true
	other_player_id = id
	if get_tree().is_network_server():
		rpc('pre_configure_game')

remotesync func pre_configure_game():
	var selfPeerID = get_tree().get_network_unique_id()

	var world = load('res://Main.tscn').instance()

	var planet_name = \
		'planet_1' if get_tree().is_network_server() else 'planet_2'
	var my_planet = world.get_node(planet_name)
	my_planet.set_network_master(selfPeerID)

	var other_planet_name = \
		'planet_2' if get_tree().is_network_server() else 'planet_1'
	var other_planet = world.get_node(other_planet_name)
	other_planet.set_network_master(other_player_id)

	get_node('/root').add_child(world)

	rpc("done_preconfiguring", selfPeerID)
	get_tree().set_pause(true)

master func done_preconfiguring(who):
	assert(not who in players_done)

	players_done.append(who)

	if players_done.size() == 2:
		rpc("post_configure_game")

remotesync func post_configure_game():
	emit_signal('exit_lobby')
