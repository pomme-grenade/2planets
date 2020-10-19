extends Control

var other_player_id
var players_done = []
var config_file_path = 'res://server_config.cfg'
var config_file

func _ready():
	# warning-ignore:return_value_discarded
	$'network/create'.connect('pressed', self, '_on_create')
	# warning-ignore:return_value_discarded
	$'network/connect_container/connect'.connect('pressed', self, '_on_connect')
	# warning-ignore:return_value_discarded
	$'local'.connect('pressed', self, '_on_local')
	# warning-ignore:return_value_discarded
	get_tree().connect('network_peer_connected', self, '_player_connected')
	config_file = ConfigFile.new()
	config_file.load(config_file_path)
	var saved_ip = config_file.get_value('config', 'ip_address_to_connect', '')
	$'network/connect_container/ip_address'.text = saved_ip

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
	var ip = $'network/connect_container/ip_address'.text
	config_file.set_value('config', 'ip_address_to_connect', ip)
	config_file.save(config_file_path)
	$'network/create'.disabled = true
	$'network/connect_container/connect'.disabled = true

	print('traversing nat...')
	var result = yield(GameManager.traverse_nat($HolePunch, false, 'planet_2'), 'completed')
	print('nat traversed!')
	var host_address = result[2]
	var host_port = result[1]
	var own_port = result[0]
	print('own port ', own_port)
	print('host: ', host_address, ':', host_port)

	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host_address, host_port, 0, 0, own_port)
	get_tree().set_network_peer(peer)

func _on_create():
	$'network/create'.disabled = true
	$'network/connect_container/connect'.disabled = true
	$'network/connect_container/ip_address'.editable = false

	print('traversing nat...')
	var result =  \
		yield(GameManager.traverse_nat($HolePunch, true, 'planet_1'), 'completed')
	print('nat traversed!')
	var my_port = result[0]
	print('my port ', my_port)

	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(my_port, 1)
	if (err != OK):
		print(err)
	get_tree().set_network_peer(peer)

remotesync func pre_configure_game():
	var selfPeerID = get_tree().get_network_unique_id()

	var world = load('res://Main.tscn').instance()
	get_node('/root').add_child(world)

	var asteroid_spawner = get_node('/root/main/asteroid_spawner')
	if get_tree().is_network_server(): 
		asteroid_spawner.set_network_master(selfPeerID)
	else:
		asteroid_spawner.set_network_master(other_player_id)

	var planet_name = \
		'planet_1' if get_tree().is_network_server() else 'planet_2'
	var my_planet = get_node('/root/main/' + planet_name)
	my_planet.set_network_master(selfPeerID)

	var other_planet_name = \
		'planet_2' if get_tree().is_network_server() else 'planet_1'
	var other_planet = get_node('/root/main/' + other_planet_name)
	other_planet.set_network_master(other_player_id)

	rpc("done_preconfiguring", selfPeerID)
	get_tree().set_pause(true)

func _player_connected(id):
	get_tree().refuse_new_network_connections = true
	other_player_id = id
	if get_tree().is_network_server():
		rpc('pre_configure_game')

master func done_preconfiguring(who):
	assert(not who in players_done) # Was not added yet

	players_done.append(who)

	if players_done.size() == 2:
		rpc("post_configure_game")

remotesync func post_configure_game():
	queue_free()
	get_tree().set_pause(false)
